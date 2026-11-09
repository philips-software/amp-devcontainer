#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-tool-inventory

  DEVCONTAINER_DIR="${BATS_TEST_DIRNAME}/../../.devcontainer"
  INVENTORY="${DEVCONTAINER_DIR}/embedded-rust/tool-inventory.json"
  APT_REQUIREMENTS=("${DEVCONTAINER_DIR}"/{base,rust}/apt-requirements*.json)

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf ./**/target

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

@test "valid code input should result in working elf executable targeting the cortex-m architecture" {
  pushd cortex-m

  cargo build

  run cargo readobj --bin hello-cortex -- --file-headers
  assert_output --partial "Class:                             ELF32"
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"

  popd
}

@test "valid code input should result in working elf executable targeting the cortex-mf architecture" {
  pushd cortex-mf

  cargo build

  run cargo readobj --bin hello-cortex -- --file-headers
  assert_output --partial "Class:                             ELF32"
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"

  popd
}
