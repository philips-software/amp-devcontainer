#!/usr/bin/env bats

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
}

teardown() {
  rm -rf build ./**/target
}

@test "valid code input should result in working executable targeting the host architecture" {
  run rustc --out-dir build rust/hello.rs
  assert_success

  run build/hello
  assert_success
  assert_output "Hello, world!"
}

@test "valid code input should result in working elf executable targeting the cortex-m architecture" {
  pushd cortex-m

  run cargo build
  assert_success

  run cargo readobj --bin hello-cortex -- --file-headers
  assert_output --partial "Class:                             ELF32"
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"

  popd
}

@test "using cargo run should result in working executable" {
  pushd cargo

  run cargo run
  assert_success
  assert_output --partial "Hello, world!"

  popd
}

@test "invalid code input should result in failing build" {
  run rustc rust/fail.rs
  assert_failure
  assert_output --partial "error: "
}
