#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  load '../tool-inventory'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf ./**/target

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
