#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'

  pushd workspace
}

teardown() {
  rm -rf build ./**/target ./**/default*.prof* ./**/mutants.out

  popd
}

@test "valid code input should result in working executable targeting the host architecture" {
  rustc --out-dir build rust/hello.rs

  run build/hello
  assert_success
  assert_output "Hello, world!"
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

@test "running clippy should result in warning diagnostics" {
  pushd clippy

  run cargo clippy
  assert_failure
  assert_output --partial "approximate value of"

  popd
}

@test "running rustfmt should result in re-formatted code" {
  run rustfmt --color=never --check rust/unformatted.rs
  assert_failure
  assert_output --partial - <<EOF
-fn main()
-{
-  println!("Hello, world!");
+fn main() {
+    println!("Hello, world!");
 }
EOF
}

@test "coverage information should be generated when running a testsuite" {
  pushd test

  RUSTFLAGS="-C instrument-coverage" run cargo test
  assert_success
  assert_output --partial "test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out;"

  cargo profdata -- merge -sparse default_*.profraw -o default.profdata

  run cargo cov -- report --instr-profile=default.profdata --object target/debug/deps/test-79ff237e4a2ee06d
  assert_success
  assert_output --partial "77.78%"

  popd
}

@test "mutation testing a test executable should be supported" {
  pushd test

  run cargo mutants
  assert_failure
  assert_output --partial "MISSED   src/main.rs:4:25: replace + with * in factorial"

  popd
}
