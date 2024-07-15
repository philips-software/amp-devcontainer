#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup_file() {
  # Installing the Windows SDK/CRT takes a long time.
  # When still valid, use the installation from cache.

  xwin --accept-license --cache-dir .xwin-hash list
  HASH_LIST_MANIFEST=$(sha256sum .xwin-hash/dl/manifest*.json | awk '{ print $1 }')
  HASH_CACHED_MANIFEST=

  if [[ -d .xwin-cache/dl ]]; then
    HASH_CACHED_MANIFEST=$(sha256sum .xwin-cache/dl/manifest*.json | awk '{ print $1 }')
  fi

  if [[ $HASH_LIST_MANIFEST != $HASH_CACHED_MANIFEST ]]; then
    xwin --accept-license splat --preserve-ms-arch-notation
  fi

  cp -r .xwin-cache/splat/ /winsdk
}

teardown_file() {
  rm -rf .xwin-hash/ /winsdk
}

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
}

teardown() {
  rm -rf build crash-*
}

@test "valid code input should result in working executable using host compiler" {
  cmake --preset gcc
  cmake --build --preset gcc

  run build/gcc/gcc/test-gcc
  assert_success
  assert_output "Hello World!"
}

@test "valid code input should result in elf executable using arm-none-eabi compiler" {
  cmake --preset gcc-arm-none-eabi
  cmake --build --preset gcc-arm-none-eabi

  run readelf -h build/gcc-arm-none-eabi/gcc-arm-none-eabi/test-gcc-arm-none-eabi
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"
}

@test "valid code input should result in Windows executable using clang-cl compiler" {
  cmake --preset clang-cl
  cmake --build --preset clang-cl
}

@test "compilation database should be generated on CMake configure" {
  cmake --preset gcc
  assert [ -e build/gcc/compile_commands.json ]

  cmake --preset gcc-arm-none-eabi
  assert [ -e build/gcc-arm-none-eabi/compile_commands.json ]
}

@test "invalid code input should result in failing build" {
  cmake --preset gcc
  run ! cmake --build --preset gcc-fail
}

@test "using ccache as a compiler launcher should result in cached build using gcc compiler" {
  configure_and_build_with_ccache gcc
}

@test "using ccache as a compiler launcher should result in cached build using clang-cl compiler" {
  configure_and_build_with_ccache clang-cl
}

@test "running clang-tidy as part of the build should result in warning diagnostics" {
  cmake --preset clang

  run cmake --build --preset clang-tidy
  assert_success
  assert_output --partial "warning: use a trailing return type for this function"
}

@test "running include-what-you-use as part of the build should result in warning diagnostics" {
  cmake --preset clang

  run cmake --build --preset clang-iwyu
  assert_success
  assert_output --partial "Warning: include-what-you-use reported diagnostics:"
}

@test "running clang-format should result in re-formatted code" {
  run clang-format clang-tools/unformatted.cpp
  assert_success
  assert_output "int main() {}"
}

@test "coverage information should be generated when running a testsuite" {
  cmake --preset coverage
  cmake --build --preset coverage

  run ctest --preset coverage
  assert_success
  assert_output --partial "100% tests passed, 0 tests failed out of 1"

  run gcovr --exclude=.*/_deps/.*
  assert_success
  assert_output --partial "GCC Code Coverage Report"
}

@test "crashes should be detected when fuzzing an executable" {
  cmake --preset clang
  cmake --build --preset fuzzing

  run build/clang/fuzzing/test-fuzzing
  assert_failure
  assert_output --partial "SUMMARY: libFuzzer: deadly signal"
}

@test "a mutation score should be calculated when mutation testing a testsuite" {
  cmake --preset mutation
  cmake --build --preset mutation

  run ctest --preset mutation
  assert_output --partial "[info] Mutation score:"
}

@test "host gdb should be able to start" {
  gdb --version
}

@test "gdb-multiarch should be able to start" {
  gdb-multiarch --version
}

@test "clangd should be able to analyze source files" {
  run clangd --check=gcc/main.cpp
  assert_success
  assert_output --partial "All checks completed, 0 errors"
}

@test "using lld as an alternative linker should result in working host executable" {
  cmake --preset gcc
  cmake --build --preset gcc-lld

  run readelf --string-dump .comment build/gcc/gcc/test-gcc-lld
  assert_output --partial "Linker: Ubuntu LLD"

  run build/gcc/gcc/test-gcc-lld
  assert_success
  assert_output "Hello World!"
}

@test "when the docker socket is mounted, using the docker cli should give access to the host docker daemon" {
  run docker info
  assert_success
  assert_output --partial "Server Version:"
}

@test "sanitizers should detect undefined or suspicious behavior in code compiled with gcc" {
  build_and_run_with_sanitizers gcc
}

@test "sanitizers should detect undefined or suspicious behavior in code compiled with clang" {
  build_and_run_with_sanitizers clang
}

function configure_and_build_with_ccache() {
  local PRESET=${1:?}

  ccache --clear --zero-stats
  cmake --preset ${PRESET} -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  cmake --build --preset ${PRESET}

  run ccache -s
  assert_output --partial "Hits:               0"
  assert_output --partial "Misses:             1"

  rm -rf build
  ccache --zero-stats
  cmake --preset ${PRESET} -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  cmake --build --preset ${PRESET}

  run ccache -s
  assert_output --partial "Hits:               1"
  assert_output --partial "Misses:             0"
}

function build_and_run_with_sanitizers() {
  local PRESET=${1:?}

  cmake --preset ${PRESET}
  cmake --build --preset ${PRESET}-sanitizers

  run build/${PRESET}/sanitizers/test-asan
  assert_failure
  assert_output --partial "AddressSanitizer: stack-buffer-overflow"

  run build/${PRESET}/sanitizers/test-ubsan
  assert_failure
  assert_output --partial "runtime error: load of null pointer"
}

@test "using clang-uml should generate a uml class diagram for a source file" {
  cmake --preset clang
  cmake --build --preset clang-uml

  run clang-uml --config ./clang-uml/.clang-uml
  assert_success
  assert_output --partial "Written test_class diagram to"
}
