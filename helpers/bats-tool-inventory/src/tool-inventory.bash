function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}

# Merge apt requirement files (JSON objects of package => version) into a
# single JSON object. Later files override earlier ones.
#
# Usage: read_apt_requirements REQUIREMENTS_JSON...
function read_apt_requirements() {
  local file

  if [[ $# -eq 0 ]]; then
    echo "No apt requirements files given" >&2
    return 1
  fi

  for file in "$@"; do
    if [[ ! -f "${file}" ]]; then
      echo "Apt requirements file not found: ${file}" >&2
      return 1
    fi
  done

  jq -s 'reduce .[] as $requirements ({}; . * $requirements)' "$@"
}

# Print the pinned upstream version (without the packaging revision) of a tool.
# A tool matches a package when the names are equal or the package name starts
# with the tool name followed by a dash.
#
# Usage: get_expected_version_for TOOL REQUIREMENTS_JSON...
function get_expected_version_for() {
  local tool=${1:?}
  shift
  local requirements

  requirements=$(read_apt_requirements "$@") || return
  jq -er --arg tool "${tool}" '
    to_entries | map(
      select(.key == $tool or (.key | startswith($tool + "-"))) |
      .value | sub("-.*"; "")
    ) | unique |
    if length == 1 then .[0]
    elif length == 0 then error("No apt version found for " + $tool)
    else error("Ambiguous apt versions for " + $tool)
    end
  ' <<< "${requirements}"
}

# Usage: get_expected_semver_for TOOL REQUIREMENTS_JSON...
function get_expected_semver_for() {
  local version
  version=$(get_expected_version_for "$@") || return
  to_semver <<< "${version}"
}

# Assert that the actual version of a tool matches the expected version
# failing with a decorated diagnostic if the versions do not match.
function assert_tool_version() {
  local tool=${1:?}
  local actual=${2-}
  local expected=${3-}

  if [[ "${actual}" != "${expected}" ]]; then
    batslib_print_kv_single_or_multi 8 \
      'tool' "${tool}" \
      'expected' "${expected}" \
      'actual' "${actual}" \
      | batslib_decorate 'tool version does not match' \
      | fail
  fi
}

# Assert that every package in the apt requirement files is installed at
# exactly its pinned version.
#
# Usage: assert_apt_packages_at_pinned_versions REQUIREMENTS_JSON...
function assert_apt_packages_at_pinned_versions() {
  local requirements
  local packages
  local package
  local expected_version

  run read_apt_requirements "$@"
  assert_success || return
  requirements="${output}"

  run jq -r 'to_entries[] | .key + "=" + .value' <<< "${requirements}"
  assert_success || return
  packages="${output}"

  while IFS="=" read -r package expected_version; do
    [[ -n "${package}" ]] || continue
    run dpkg-query -W -f='${Version}' "${package}"
    assert_success || return
    assert_tool_version "${package}" "${output}" "${expected_version}" || return
  done <<< "${packages}"
}

# Assert that every command passed as an argument is available on the PATH,
# failing with a decorated diagnostic on the first one that cannot be found.
function assert_commands_available() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "${cmd}" > /dev/null 2>&1; then
      batslib_print_kv_single 7 'command' "${cmd}" \
        | batslib_decorate 'command not found on PATH' \
        | fail
      return 1
    fi
  done
}

# Print one compact JSON object per command and file in the inventory.
#
# Usage: read_inventory_tools INVENTORY_JSON
function read_inventory_tools() {
  local packages
  packages=$(resolve_inventory "${1:?}") || return
  jq -c '
    to_entries[] |
      .key as $package | (if .value == {} then {commands: [$package]} else .value end) |
        . as $entry |
        ((.commands // [])[] | {
          package: $package, kind: "command", tool: .,
          args: ($entry["smoke-test-args"][.] // ["--version"])
        }),
        ((.files // [])[] | {package: $package, kind: "file", tool: .})
  ' <<< "${packages}"
}

# Usage: assert_inventory_tools_available INVENTORY_JSON
function assert_inventory_tools_available() {
  local package kind tool
  local tools

  run read_inventory_tools "${1:?}"
  assert_success || return
  tools="${output}"

  while IFS=$'\t' read -r package kind tool; do
    [[ -n "${package}" ]] || continue
    if [[ "${kind}" == "command" ]]; then
      assert_commands_available "${tool}" || return
    elif [[ ! -f "${tool}" ]]; then
      batslib_print_kv_single_or_multi 7 'package' "${package}" 'file' "${tool}" \
        | batslib_decorate 'inventory file not found' \
        | fail
      return 1
    fi
  done < <(jq -r '[.package, .kind, .tool] | @tsv' <<< "${tools}")
}

# Keep supervision inside the helper, using Perl already installed with Git.
# A subreaper can clean up detached children without relying on container PID 1.
function _run_inventory_command() {
  perl - "$@" <<'PERL'
use strict;
use warnings;
use POSIX qw(WNOHANG);
use IO::Select;
use Time::HiRes qw(clock_gettime CLOCK_MONOTONIC sleep);
use Encode qw(decode FB_DEFAULT);
require 'syscall.ph';

my ($seconds, @command) = @ARGV;
my ($pid, $reader, $writer, $status);
my ($output, $truncated, $timed_out) = ('', 0, 0);
sub now { clock_gettime(CLOCK_MONOTONIC) }
sub cleanup {
    my $deadline = now() + 5;
    while (1) {
        my $reaped;
        1 while (($reaped = waitpid(-1, WNOHANG)) > 0);
        return if $reaped == -1;
        open my $children, '<', "/proc/self/task/$$/children" or die "cannot read children: $!\n";
        my $pids = do { local $/; <$children> };
        close $children;
        kill(now() < $deadline ? 'TERM' : 'KILL', split ' ', $pids);
        die "could not reap smoke command descendants after SIGKILL\n" if now() >= $deadline + 1;
        sleep 0.01;
    }
}

my $ok = eval {
    die "timeout must be a positive, finite number of seconds\n"
        unless $seconds =~ /^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$/ &&
            $seconds > 0 && POSIX::isfinite($seconds);
    # PR_SET_CHILD_SUBREAPER; syscall.ph supplies the architecture's syscall number.
    syscall(&SYS_prctl, 36, 1, 0, 0, 0) == 0 or die "cannot enable child subreaper: $!\n";
    # Neither the tool nor its descendants may inherit Bats capture descriptors.
    opendir my $fds, '/proc/self/fd' or die "cannot read descriptors: $!\n";
    my @fds = grep { /^\d+$/ && $_ > 2 } readdir $fds;
    closedir $fds;
    POSIX::close($_) for @fds;
    pipe($reader, $writer) or die "cannot create output pipe: $!\n";
    $pid = fork();
    die "cannot fork smoke command: $!\n" unless defined $pid;
    if (!$pid) {
        close $reader;
        POSIX::setsid() >= 0 or die "cannot create session: $!\n";
        open STDIN, '<', '/dev/null' or die "cannot redirect stdin: $!\n";
        open STDOUT, '>&', $writer or die "cannot redirect stdout: $!\n";
        open STDERR, '>&', \*STDOUT or die "cannot redirect stderr: $!\n";
        close $writer;
        # List-form exec preserves literal arguments; it never invokes a shell.
        exec { $command[0] } @command or do {
            my $code = $!{ENOENT} ? 127 : 126;
            print STDERR "cannot start smoke command: $!\n";
            POSIX::_exit($code);
        };
    }
    close $writer;
    $SIG{TERM} = $SIG{INT} = sub { die "smoke command supervisor interrupted\n" };
    my $select = IO::Select->new($reader);
    my $deadline = now() + $seconds;
    while (1) {
        my $remaining = $deadline - now();
        if ($remaining <= 0) { $timed_out = 1; last }
        if ($select->count && $select->can_read($remaining < 0.05 ? $remaining : 0.05)) {
            my $count = sysread($reader, my $chunk, 65536);
            die "cannot read smoke output: $!\n" unless defined $count;
            $select->remove($reader) unless $count;
            my $available = 16384 - length $output;
            $output .= substr($chunk, 0, $available);
            $truncated ||= $count > $available;
        } elsif (!$select->count) { sleep 0.01 }
        $status = $? if !defined($status) && waitpid($pid, WNOHANG) == $pid;
        last if defined($status) && !$select->count;
    }
    1;
};
my $error = $@;
close $reader if defined $reader;
# Do not let a second signal interrupt cleanup and leave inherited streams open.
$SIG{TERM} = $SIG{INT} = 'IGNORE';
eval { cleanup() };
$error ||= $@;
if (!$ok || $error) {
    print STDERR "smoke command supervisor failed: $error";
    exit 125;
}
my $text = decode('UTF-8', $output, FB_DEFAULT);
$text =~ s/([^\x09\x0a\x0d\x20-\x{fffd}\x{10000}-\x{10ffff}])/sprintf '\\x%02x', ord $1/ge;
binmode STDOUT, ':encoding(UTF-8)';
print "$text\n" if length $text;
print "[output truncated after 16384 bytes]\n" if $truncated;
print "[timed out after ${seconds}s; termination grace 5s; exit code 124]\n" if $timed_out;
exit($timed_out ? 124 : ($status & 127) ? 128 + ($status & 127) : $status >> 8);
PERL
}

# Usage: assert_inventory_tools_run INVENTORY_JSON [TIMEOUT_SECONDS]
function assert_inventory_tools_run() {
  local tools entry package tool invocation
  local timeout_seconds=${2:-30}
  local args=()

  run read_inventory_tools "${1:?}"
  assert_success || return
  tools="${output}"

  while IFS= read -r entry; do
    package=$(jq -r '.package' <<< "${entry}")
    tool=$(jq -r '.tool' <<< "${entry}")
    mapfile -t args < <(jq -r '.args[]' <<< "${entry}")
    printf -v invocation '%q ' "${tool}" "${args[@]}"

    run _run_inventory_command "${timeout_seconds}" "${tool}" "${args[@]}"
    if [[ "${status}" -ne 0 ]]; then
      batslib_print_kv_single_or_multi 10 \
        'package' "${package}" \
        'command' "${invocation% }" \
        'timeout' "${timeout_seconds}s (+5s termination grace)" \
        'exit code' "${status}" \
        'output' "${output}" \
        | batslib_decorate 'inventory command failed to start successfully' \
        | fail
      return 1
    fi
  done < <(jq -c 'select(.kind == "command")' <<< "${tools}")
}
