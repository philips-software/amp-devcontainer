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

## This section contains tests for the embedded (ARM none-eabi) toolchain.
#  Verifying that the host and embedded toolchains are aligned in terms of major
#  and minor versions and that valid source code can be compiled into a working
#  ELF executable targeting the ARM Cortex architecture.

# bats test_tags=Compatibility,Version,HostGCCArmGCC
@test "host and embedded gcc toolchain versions should be the same major and minor version" {
  EXPECTED_MAJOR_MINOR_VERSION=$(get_expected_semver_for g++ | cut -d. -f1,2)
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

function get_expected_version_for() {
  local TOOL=${1:?}

  jq -sr ".[0] * .[1] * .[2] | to_entries[] | select(.key | startswith(\"${TOOL}\")) | .value | sub(\"-.*\"; \"\")" \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/base/apt-requirements.json \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/cpp/apt-requirements-base.json \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/cpp/apt-requirements-clang.json
}

function get_expected_semver_for() {
  local TOOL=${1:?}

  get_expected_version_for ${TOOL} | to_semver
}
