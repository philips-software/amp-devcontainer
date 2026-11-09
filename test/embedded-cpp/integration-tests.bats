#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-tool-inventory

  DEVCONTAINER_DIR="${BATS_TEST_DIRNAME}/../../.devcontainer"
  INVENTORY="${DEVCONTAINER_DIR}/embedded-cpp/tool-inventory.json"
  APT_REQUIREMENTS=("${DEVCONTAINER_DIR}"/{base,cpp,embedded-cpp}/apt-requirements*.json)

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build

  popd
}

# bats test_tags=Compatibility,Version
@test "apt packages are installed at their pinned versions" {
  assert_apt_packages_at_pinned_versions "${APT_REQUIREMENTS[@]}"
}

# bats test_tags=Sbom
@test "tools listed in the inventory are present in the image" {
  assert_inventory_tools_available "${INVENTORY}"
}

# bats test_tags=Functional
@test "commands listed in the inventory start successfully" {
  assert_inventory_tools_run "${INVENTORY}"
}

## This section contains tests for the embedded (ARM none-eabi) toolchain.
#  Verifying that the host and embedded toolchains are aligned in terms of major
#  and minor versions and that valid source code can be compiled into a working
#  ELF executable targeting the ARM Cortex architecture.

# bats test_tags=Compatibility,Version,HostGCCArmGCC
@test "host and embedded gcc toolchain versions should be the same major and minor version" {
  EXPECTED_MAJOR_MINOR_VERSION=$(get_expected_semver_for g++ "${APT_REQUIREMENTS[@]}" | cut -d. -f1,2)
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
