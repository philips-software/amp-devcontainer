#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build

  popd
}

# bats test_tags=Sbom
@test "tools listed in the inventory are present in the image" {
  TOOL_INVENTORY="${BATS_TEST_DIRNAME}/../../.devcontainer/embedded-cpp/tool-inventory.json"

  run jq -r '.[]' "${TOOL_INVENTORY}"
  assert_success

  while IFS= read -r TOOL; do
    case "${TOOL}" in
      arm-gnu-toolchain)
        assert_commands_available arm-none-eabi-{gcc,g++,as,ld,objcopy,objdump,readelf}
        ;;
      clang-tools-22)
        assert_commands_available clang-22 clang-{check,cpp,doc,format,include-cleaner,move,query,refactor,tidy}-22
        ;;
      llvm-22)
        assert_commands_available llvm-{ar,as,cxxfilt,cov,link,nm,objcopy,objdump,readelf}-22
        ;;
      mull-22)
        assert_commands_available mull-{instrument,runner,reporter}-22
        ;;
      ninja-build)
        assert_commands_available ninja
        ;;
      *)
        assert_commands_available "${TOOL}"
        ;;
    esac
  done <<< "${output}"
}

## This section contains tests for the embedded (ARM none-eabi) toolchain.
#  Verifying that the host and embedded toolchains are aligned in terms of major
#  and minor versions and that valid source code can be compiled into a working
#  ELF executable targeting the ARM Cortex architecture.

# bats test_tags=Compatibility,Version,HostGCCArmGCC
@test "host and embedded gcc toolchain versions should be the same major and minor version" {
  EXPECTED_MAJOR_MINOR_VERSION=$(g++-15 -dumpfullversion | cut -d. -f1,2)
  INSTALLED_MAJOR_MINOR_VERSION=$(arm-none-eabi-gcc -dumpfullversion | cut -d. -f1,2)
  assert_equal "$INSTALLED_MAJOR_MINOR_VERSION" "$EXPECTED_MAJOR_MINOR_VERSION"
}

@test "valid code input should result in elf executable using arm-none-eabi compiler" {
  # @sbdl test-comp-0002 is test { custom:title is [[[[@-LINE]]]]; requirement is req-comp-0002 }
  cmake --preset gcc-arm-none-eabi
  cmake --build --preset gcc-arm-none-eabi

  run readelf -h build/gcc-arm-none-eabi/gcc-arm-none-eabi/test-gcc-arm-none-eabi
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"
}

@test "compilation database should be generated on CMake configure" {
  cmake --preset gcc-arm-none-eabi
  assert [ -e build/gcc-arm-none-eabi/compile_commands.json ]
}

function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}


# Assert that every command passed as an argument is available on the PATH,
# failing with a decorated diagnostic on the first one that cannot be found.
function assert_commands_available() {
  for CMD in "$@"; do
    if ! command -v "${CMD}" > /dev/null 2>&1; then
      batslib_print_kv_single 7 'command' "${CMD}" \
        | batslib_decorate 'command not found on PATH' \
        | fail
    fi
  done
}
