function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}

function read_apt_requirements() {
  local root="${BATS_TEST_DIRNAME}/../../.devcontainer"
  local flavor
  local files=()
  local flavor_files

  for flavor in "$@"; do
    flavor_files=("${root}/${flavor}"/apt-requirements*.json)
    if [[ ! -f "${flavor_files[0]}" ]]; then
      echo "No apt requirements found for flavor '${flavor}' in ${root}" >&2
      return 1
    fi
    files+=("${flavor_files[@]}")
  done

  jq -s 'reduce .[] as $requirements ({}; . * $requirements)' "${files[@]}"
}

function get_expected_version_for() {
  local tool=${1:?}
  local requirements

  requirements=$(read_flavor_apt_requirements) || return
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

function read_flavor_apt_requirements() {
  local flavor="${BATS_TEST_DIRNAME##*/}"
  local flavors=(base)

  case "${flavor}" in
    base) ;;
    embedded-cpp) flavors+=(cpp embedded-cpp) ;;
    embedded-rust) flavors+=(rust) ;;
    *) flavors+=("${flavor}") ;;
  esac
  read_apt_requirements "${flavors[@]}"
}

function get_expected_semver_for() {
  local version
  version=$(get_expected_version_for "${1:?}") || return
  to_semver <<< "${version}"
}

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

# Assert that the actual version of a tool matches the expected version
# failing with a decorated diagnostic if the versions do not match.
function assert_apt_packages_at_pinned_versions() {
  local requirements
  local packages
  local package
  local expected_version

  run read_flavor_apt_requirements
  assert_success || return
  requirements="${output}"

  run jq -r 'to_entries[] | .key + "=" + .value' <<< "${requirements}"
  assert_success || return
  packages="${output}"

  while IFS="=" read -r package expected_version; do
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

function assert_inventory_tools_available() {
  local package kind tool
  local tools
  local root="${BATS_TEST_DIRNAME}/../../.devcontainer"
  local flavor="${BATS_TEST_DIRNAME##*/}"

  local inventories=("${root}/base/tool-inventory.json")
  if [[ "${flavor}" != "base" ]]; then
    inventories+=("${root}/${flavor}/tool-inventory.json")
  fi
  run jq -r '
    def paths: type == "array" and all(.[]; type == "string" and length > 0 and (test("[\\t\\r\\n]") | not));
    if type != "object" then error("Tool inventory must be a package mapping")
    else to_entries[] |
      if (.value | type != "object") then error("Invalid inventory entry for " + .key)
      elif (.value | keys - ["commands", "files"] | length > 0)
        or (.value | all(.[]; paths) | not)
        or (.value != {} and ((.value.commands // []) + (.value.files // []) | length == 0))
      then error("Invalid commands/files for " + .key)
      else .key as $package | (if .value == {} then {commands: [$package]} else .value end) |
        ((.commands // [])[] | [$package, "command", .]),
        ((.files // [])[] | [$package, "file", .]) | @tsv
      end
    end
  ' "${inventories[@]}"
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
  done <<< "${tools}"
}
