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

# bats test_tags=compilation,compile-for-container-host-architecture-and-operating-system
#!sbdl rust-compile-host is test { requirement is compile-for-container-host-architecture-and-operating-system }
@test "valid code input should result in working executable targeting the host architecture" {
  rustc --out-dir build rust/hello.rs

  run build/hello
  assert_success
  assert_output "Hello, world!"
}

# bats test_tags=compilation,compile-for-arm-cortex-target-architecture
#!sbdl rust-compile-arm-cortex-m is test { requirement is compile-for-arm-cortex-target-architecture }
@test "valid code input should result in working elf executable targeting the cortex-m architecture" {
  pushd cortex-m

  cargo build

  run cargo readobj --bin hello-cortex -- --file-headers
  assert_output --partial "Class:                             ELF32"
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"

  popd
}

# bats test_tags=compilation,compile-for-arm-cortex-target-architecture
#!sbdl rust-compile-arm-cortex-mf is test { requirement is compile-for-arm-cortex-target-architecture }
@test "valid code input should result in working elf executable targeting the cortex-mf architecture" {
  pushd cortex-mf

  cargo build

  run cargo readobj --bin hello-cortex -- --file-headers
  assert_output --partial "Class:                             ELF32"
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"

  popd
}

# bats test_tags=compilation,compile-for-container-host-architecture-and-operating-system
#!sbdl rust-cargo-run is test { requirement is compile-for-container-host-architecture-and-operating-system }
@test "using cargo run should result in working executable" {
  pushd cargo

  run cargo run
  assert_success
  assert_output --partial "Hello, world!"

  popd
}

# bats test_tags=compilation,compile-for-container-host-architecture-and-operating-system
#!sbdl rust-compile-fail is test { requirement is compile-for-container-host-architecture-and-operating-system }
@test "invalid code input should result in failing build" {
  run rustc rust/fail.rs
  assert_failure
  assert_output --partial "error: "
}

# bats test_tags=static-and-dynamic-analysis,static-analysis
#!sbdl rust-clippy is test { requirement is static-analysis }
@test "running clippy should result in warning diagnostics" {
  pushd clippy

  run cargo clippy
  assert_failure
  assert_output --partial "approximate value of"

  popd
}

# bats test_tags=static-and-dynamic-analysis,code-formatting
#!sbdl rust-rustfmt is test { requirement is code-formatting }
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

# bats test_tags=static-and-dynamic-analysis,coverage-analysis
#!sbdl rust-coverage is test { requirement is coverage-analysis }
@test "coverage information should be generated when running a testsuite" {
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

# bats test_tags=static-and-dynamic-analysis,mutation-testing
#!sbdl rust-mutation-testing is test { requirement is mutation-testing }
@test "mutation testing a test executable should be supported" {
  pushd test

  run cargo mutants
  assert_failure
  assert_output --partial "MISSED   src/main.rs:4:25: replace + with * in factorial"

  popd
}
