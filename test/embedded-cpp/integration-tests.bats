#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  load '../tool-inventory'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build

  popd
}

# bats test_tags=Sbom
@test "tools listed in the inventory are present in the image" {
  assert_inventory_tools_available
}

# bats test_tags=Functional
@test "commands listed in the inventory start successfully" {
  assert_inventory_tools_run
}

## This section contains tests for the embedded (ARM none-eabi) toolchain.
#  Verifying that the host and embedded toolchains are aligned in terms of major
#  and minor versions and that valid source code can be compiled into a working
#  ELF executable targeting the ARM Cortex architecture.

# bats test_tags=Compatibility,Version,HostGCCArmGCC
@test "host and embedded gcc toolchain versions should be the same major and minor version" {
  EXPECTED_MAJOR_MINOR_VERSION=$(g++-15 -dumpfullversion | cut -d. -f1,2)
  INSTALLED_MAJOR_MINOR_VERSION=$(arm-none-eabi-gcc -dumpfullversion | cut -d. -f1,2)
  assert_tool_version arm-none-eabi-gcc "${INSTALLED_MAJOR_MINOR_VERSION}" "${EXPECTED_MAJOR_MINOR_VERSION}"
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
