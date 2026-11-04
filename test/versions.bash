function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}

function read_apt_requirements() {
  local ROOT="${BATS_TEST_DIRNAME}/../../.devcontainer"
  local FLAVOR
  local FILES=()
  local FLAVOR_FILES

  for FLAVOR in "$@"; do
    FLAVOR_FILES=("${ROOT}/${FLAVOR}"/apt-requirements*.json)
    if [[ ! -f "${FLAVOR_FILES[0]}" ]]; then
      echo "No apt requirements found for flavor '${FLAVOR}' in ${ROOT}" >&2
      return 1
    fi
    FILES+=("${FLAVOR_FILES[@]}")
  done

  jq -s 'reduce .[] as $requirements ({}; . * $requirements)' "${FILES[@]}"
}

function get_expected_version_for() {
  local TOOL=${1:?}
  local REQUIREMENTS

  REQUIREMENTS=$(read_flavor_apt_requirements) || return
  jq -er --arg tool "${TOOL}" '
    to_entries | map(
      select(.key == $tool or (.key | startswith($tool + "-"))) |
      .value | sub("-.*"; "")
    ) | unique |
    if length == 1 then .[0]
    elif length == 0 then error("No apt version found for " + $tool)
    else error("Ambiguous apt versions for " + $tool)
    end
  ' <<< "${REQUIREMENTS}"
}

function read_flavor_apt_requirements() {
  local FLAVOR="${BATS_TEST_DIRNAME##*/}"
  local FLAVORS=(base)

  case "${FLAVOR}" in
    base) ;;
    embedded-cpp) FLAVORS+=(cpp embedded-cpp) ;;
    embedded-rust) FLAVORS+=(rust) ;;
    *) FLAVORS+=("${FLAVOR}") ;;
  esac
  read_apt_requirements "${FLAVORS[@]}"
}

function get_expected_semver_for() {
  local VERSION
  VERSION=$(get_expected_version_for "${1:?}") || return
  to_semver <<< "${VERSION}"
}

function assert_tool_version() {
  local TOOL=${1:?}
  local ACTUAL=${2-}
  local EXPECTED=${3-}

  if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
    batslib_print_kv_single_or_multi 8 \
      'tool' "${TOOL}" \
      'expected' "${EXPECTED}" \
      'actual' "${ACTUAL}" \
      | batslib_decorate 'tool version does not match' \
      | fail
  fi
}

# Assert that the actual version of a tool matches the expected version
# failing with a decorated diagnostic if the versions do not match.
function assert_apt_packages_at_pinned_versions() {
  local REQUIREMENTS
  local PACKAGES
  local PACKAGE
  local EXPECTED_VERSION

  run read_flavor_apt_requirements
  assert_success || return
  REQUIREMENTS="${output}"

  run jq -r 'to_entries[] | .key + "=" + .value' <<< "${REQUIREMENTS}"
  assert_success || return
  PACKAGES="${output}"

  while IFS="=" read -r PACKAGE EXPECTED_VERSION; do
    run dpkg-query -W -f='${Version}' "${PACKAGE}"
    assert_success || return
    assert_tool_version "${PACKAGE}" "${output}" "${EXPECTED_VERSION}" || return
  done <<< "${PACKAGES}"
}

# Assert that every command passed as an argument is available on the PATH,
# failing with a decorated diagnostic on the first one that cannot be found.
function assert_commands_available() {
  local CMD
  for CMD in "$@"; do
    if ! command -v "${CMD}" > /dev/null 2>&1; then
      batslib_print_kv_single 7 'command' "${CMD}" \
        | batslib_decorate 'command not found on PATH' \
        | fail
      return 1
    fi
  done
}

function assert_inventory_tools_available() {
  local TOOL
  local TOOLS
  local ROOT="${BATS_TEST_DIRNAME}/../../.devcontainer"
  local FLAVOR="${BATS_TEST_DIRNAME##*/}"

  local INVENTORIES=("${ROOT}/base/tool-inventory.json")
  if [[ "${FLAVOR}" != "base" ]]; then
    INVENTORIES+=("${ROOT}/${FLAVOR}/tool-inventory.json")
  fi
  run jq -r '.[]' "${INVENTORIES[@]}"
  assert_success || return
  TOOLS="${output}"

  while IFS= read -r TOOL; do
    case "${TOOL}" in
      bats-support | bats-assert)
        assert [ -f "/usr/local/${TOOL}/load.bash" ]
        ;;
      gnupg2) assert_commands_available gpg ;;
      graphviz) assert_commands_available dot ;;
      include-what-you-use) assert_commands_available iwyu ;;
      ninja-build) assert_commands_available ninja ;;
      arm-gnu-toolchain)
        assert_commands_available arm-none-eabi-{gcc,g++,as,ld,objcopy,objdump,readelf}
        ;;
      clang-tools-*)
        local MAJOR="${TOOL##*-}"
        assert_commands_available "clang-${MAJOR}" clang-{check,cpp,doc,format,include-cleaner,move,query,refactor,tidy}-"${MAJOR}"
        ;;
      llvm-*)
        local MAJOR="${TOOL##*-}"
        assert_commands_available llvm-{ar,as,cxxfilt,cov,link,nm,objcopy,objdump,readelf}-"${MAJOR}"
        ;;
      lld-*) assert_commands_available "ld.lld-${TOOL##*-}" ;;
      mull-*)
        assert_commands_available mull-{instrument,runner,reporter}-"${TOOL##*-}"
        ;;
      rust) assert_commands_available rustc cargo rustfmt cargo-clippy ;;
      cargo-binutils) assert_commands_available cargo-{ar,cov,nm,objcopy,objdump,profdata,readobj,size,strip} ;;
      probe-rs-tools) assert_commands_available probe-rs cargo-embed cargo-flash ;;
      *) assert_commands_available "${TOOL}" ;;
    esac || return
  done <<< "${TOOLS}"
}
