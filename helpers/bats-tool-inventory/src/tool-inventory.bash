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

# Usage: assert_inventory_tools_run INVENTORY_JSON [TIMEOUT_SECONDS]
function assert_inventory_tools_run() {
  local tools entry package tool invocation
  local timeout_seconds=${2:-30}
  local runner
  runner="$(dirname "${BASH_SOURCE[0]}")/run-command.py"
  local args=()

  run read_inventory_tools "${1:?}"
  assert_success || return
  tools="${output}"

  while IFS= read -r entry; do
    package=$(jq -r '.package' <<< "${entry}")
    tool=$(jq -r '.tool' <<< "${entry}")
    mapfile -t args < <(jq -r '.args[]' <<< "${entry}")
    printf -v invocation '%q ' "${tool}" "${args[@]}"

    run python3 "${runner}" "${timeout_seconds}" "${tool}" "${args[@]}"
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
