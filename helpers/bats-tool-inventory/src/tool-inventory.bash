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

function _run_inventory_command() {
  local seconds=${1:?} directory pid result=0 fd
  shift
  if ! [[ "${seconds}" =~ ^([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]] ||
    ! jq -en --arg seconds "${seconds}" '$seconds | tonumber | . > 0 and . < 1e308' >/dev/null; then
    echo "timeout must be a positive, finite number of seconds"
    return 125
  fi
  directory=$(mktemp -d "${BATS_TEST_TMPDIR:?}/inventory-command.XXXXXX") || return
  (
    export INVENTORY_OUTPUT="${directory}/output"
    # Close Bats' descriptors before starting any command or output drainer.
    for fd in /proc/"${BASHPID}"/fd/*; do
      fd=${fd##*/}
      if ((fd > 2)); then exec {fd}>&-; fi
    done
    # shellcheck disable=SC2016
    exec timeout --kill-after=5s "${seconds}s" bash -c '
      set -o pipefail
      trap "exit 124" TERM
      result=0
      "$@" 2>&1 | {
        stdbuf -o0 head -c 16385 > "$INVENTORY_OUTPUT"
        cat > /dev/null
      } || result=$?
      : > "$INVENTORY_OUTPUT.complete"
      exit "$result"
    ' _ "$@"
  ) </dev/null >/dev/null 2>/dev/null &
  pid=$!
  # The drainer is inside the deadline, so inherited streams cannot extend it.
  # GNU timeout creates a process group whose id is its own PID.
  wait "${pid}" || result=$?
  kill -KILL -- "-${pid}" 2>/dev/null || true
  if [[ -f "${directory}/output" ]]; then
    # JSON escaping keeps control bytes and invalid UTF-8 out of JUnit XML.
    head -c 16384 "${directory}/output" | jq -Rrs 'gsub("[\uFFFE\uFFFF]"; "\uFFFD") | @json'
    if [[ $(wc -c < "${directory}/output") -gt 16384 ]]; then
      echo "[output truncated after 16384 bytes]"
    fi
  fi
  if [[ ! -f "${directory}/output.complete" ]] &&
    [[ "${result}" -eq 124 || "${result}" -eq 137 ]]; then
    echo "[timed out after ${seconds}s; termination grace 5s; exit code ${result}]"
  fi
  rm -rf "${directory}"
  return "${result}"
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
