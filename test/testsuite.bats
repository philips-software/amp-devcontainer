#!/usr/bin/env bats

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
}

teardown() {
  rm -rf build crash-*
}

# bats test_tags=tc:1
@test "valid code input should result in working executable using host compiler" {
  run cmake --preset gcc
  assert_success

  run cmake --build --preset gcc
  assert_success

  run build/gcc/gcc/test-gcc
  assert_success
  assert_output "Hello World!"
}

# bats test_tags=tc:2
@test "valid code input should result in elf executable using arm-none-eabi compiler" {
  run cmake --preset gcc-arm-none-eabi
  assert_success

  run cmake --build --preset gcc-arm-none-eabi
  assert_success
}

# bats test_tags=tc:4
@test "invalid code input should result in failing build" {
  run cmake --preset gcc
  assert_success

  run cmake --build --preset gcc-fail
  assert_failure
}

# bats test_tags=tc:5
@test "ccache can be used as a compiler launcher" {
  run cmake --preset gcc -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  assert_success

  run cmake --build --preset gcc
  assert_success
}

# bats test_tags=tc:6
@test "clang-tidy should be run as part of the build" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset clang-tidy
  assert_success
  assert_output --partial "warning: use a trailing return type for this function"
}

# bats test_tags=tc:7
@test "include-what-you-use should be run as part of the build" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset clang-iwyu
  assert_success
  assert_output --partial "Warning: include-what-you-use reported diagnostics:"
}

# bats test_tags=tc:8
@test "formatting tool included in image should format code" {
  run clang-format clang-tools/unformatted.cpp
  assert_success
  assert_output "int main() {}"
}

# bats test_tags=tc:9
@test "coverage information should be generated when running tests" {
  run cmake --preset coverage
  assert_success

  run cmake --build --preset coverage
  assert_success

  run ctest --preset coverage
  assert_success
  assert_output --partial "100% tests passed, 0 tests failed out of 1"

  run gcovr --exclude=.*/_deps/.*
  assert_success
  assert_output --partial "GCC Code Coverage Report"
}

# bats test_tags=tc:10
@test "fuzzing an executable should be supported" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset fuzzing
  assert_success

  run build/clang/fuzzing/test-fuzzing
  assert_failure
  assert_output --partial "SUMMARY: libFuzzer: deadly signal"
}

# bats test_tags=tc:11
@test "mutation testing an executable should be supported" {
  run cmake --preset mutation
  assert_success

  run cmake --build --preset mutation
  assert_success

  run ctest --preset mutation
  assert_output --partial "[info] Mutation score:"
}

# bats test_tags=tc:12
@test "host gdb should be able to start" {
  run gdb --version
  assert_success
}

# bats test_tags=tc:13
@test "arm-none-eabi-gdb should be able to start" {
  run arm-none-eabi-gdb --version
  assert_success
}
