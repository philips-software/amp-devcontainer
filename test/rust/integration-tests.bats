#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build ./**/target ./**/default*.prof* ./**/mutants.out

  popd
}

@test "Rust toolchain directories are writable by the code user" {
  WRITE_TESTS=("${CARGO_HOME}/.write-test" "${RUSTUP_HOME}/.write-test")

  assert_equal "$(id -un)" code
  run touch "${WRITE_TESTS[@]}"
  assert_success

  rm -f "${WRITE_TESTS[@]}"
}

@test "valid code input should result in working executable targeting the host architecture" {
  # @sbdl test-comp-0008 is test { custom:title is [[[[@-LINE]]]]; requirement is req-comp-0001 }
  rustc --out-dir build rust/hello.rs

  run build/hello
  assert_success
  assert_output "Hello, world!"
}

@test "gdb-multiarch should set a breakpoint and inspect a Rust variable" {
  # @sbdl test-debug-0002 is test { custom:title is [[[[@-LINE]]]]; requirement is req-debug-0001 }
  rustc -g -C opt-level=0 --out-dir build rust/debug.rs

  run gdb-multiarch --batch -ex "break main" -ex run -ex next -ex "print value" -ex continue --args build/debug
  assert_success
  assert_output --partial "42"
}

@test "rust-gdb should pretty-print Rust collection types" {
  # @sbdl test-debug-0003 is test { custom:title is [[[[@-LINE]]]]; requirement is req-debug-0001 }
  rustc -g -C opt-level=0 --out-dir build rust/pretty-print.rs

  run rust-gdb --batch -ex "break main" -ex run -ex next -ex "print values" -ex continue --args build/pretty-print
  assert_success
  assert_output --partial "Vec(size=3)"
  assert_output --partial "{17, 29, 43}"
}

@test "using cargo run should result in working executable" {
  # @sbdl test-comp-0009 is test { custom:title is [[[[@-LINE]]]]; requirement is req-comp-0001 }
  pushd cargo

  run cargo run
  assert_success
  assert_output --partial "Hello, world!"

  popd
}

@test "invalid code input should result in failing build" {
  # @sbdl test-comp-0010 is test { custom:title is [[[[@-LINE]]]]; requirement is req-comp-0001 }
  run rustc rust/fail.rs
  assert_failure
  assert_output --partial "error: "
}

@test "running clippy should result in warning diagnostics" {
  # @sbdl test-sda-0008 is test { custom:title is [[[[@-LINE]]]]; requirement is req-sda-0002 }
  pushd clippy

  run cargo clippy
  assert_failure
  assert_output --partial "approximate value of"

  popd
}

@test "running rustfmt should result in re-formatted code" {
  # @sbdl test-sda-0009 is test { custom:title is [[[[@-LINE]]]]; requirement is req-sda-0001 }
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
  # @sbdl test-sda-0010 is test { custom:title is [[[[@-LINE]]]]; requirement is req-sda-0003 }
  pushd test

  RUSTFLAGS="-C instrument-coverage" run cargo test
  assert_success
  assert_output --partial "test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out;"

  cargo profdata -- merge -sparse default_*.profraw -o default.profdata

  run cargo cov -- report --instr-profile=default.profdata --object $(find target/debug/deps -name "test-*" -executable)
  assert_success
  assert_output --partial "88.24%"

  popd
}

@test "mutation testing a test executable should be supported" {
  # @sbdl test-sda-0011 is test { custom:title is [[[[@-LINE]]]]; requirement is req-sda-0004 }
  pushd test

  run cargo mutants
  assert_failure
  assert_output --partial "MISSED   src/main.rs:4:25: replace + with * in factorial"

  popd
}
