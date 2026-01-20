#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup_file() {
  install_win_sdk_when_ci_set
}

teardown_file() {
  rm -rf ${BATS_TEST_DIRNAME}/.xwin-hash/ /winsdk
}

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build crash-* $(conan config home)/p

  popd
}

## This section contains tests for version correctness and compatibility of the installed tools.
#  Comparing the versions of the installed tools with the expected versions and ensuring
#  that the tools are compatible with each other. E.g. that the host and embedded toolchains
#  are aligned in terms of major and minor versions.

# bats test_tags=Compatibility,Version,Clang
@test "clang toolchain versions should be aligned with expected versions" {
  EXPECTED_VERSION=$(get_expected_semver_for clang)

  for TOOL in clang clang++ clang-cl clang-format clang-tidy; do
    INSTALLED_VERSION=$($TOOL --version | to_semver)
    assert_equal_print "$EXPECTED_VERSION" "$INSTALLED_VERSION" "Tool '${TOOL}' version"
  done
}

# bats test_tags=Compatibility,Version,GCC
@test "host gcc toolchain versions and alternatives should be aligned with expected versions" {
  EXPECTED_VERSION=$(get_expected_semver_for g++)

  for TOOL in cc gcc c++ g++ gcov; do
    INSTALLED_VERSION=$($TOOL --version | to_semver)
    assert_equal_print "$EXPECTED_VERSION" "$INSTALLED_VERSION" "Tool '${TOOL}' version"
  done
}

# bats test_tags=Compatibility,Version,HostGCCArmGCC
@test "host and embedded gcc toolchain versions should be the same major and minor version" {
  EXPECTED_MAJOR_MINOR_VERSION=$(get_expected_semver_for g++ | cut -d. -f1,2)
  INSTALLED_MAJOR_MINOR_VERSION=$(arm-none-eabi-gcc -dumpfullversion | cut -d. -f1,2)
  assert_equal_print "$EXPECTED_MAJOR_MINOR_VERSION" "$INSTALLED_MAJOR_MINOR_VERSION" "Host and ARM GCC major and minor version"
}

# bats test_tags=Compatibility,Version,Tools
@test "supporting tool versions should be aligned with expected versions" {
  for TOOL in gdb gdb-multiarch git ninja; do
    EXPECTED_VERSION=$(get_expected_semver_for ${TOOL})
    INSTALLED_VERSION=$(${TOOL} --version | to_semver)

    assert_equal_print "$EXPECTED_VERSION" "$INSTALLED_VERSION" "Tool '${TOOL}' version"
  done

  for TOOL in cmake conan; do
    EXPECTED_VERSION=$(cat ${BATS_TEST_DIRNAME}/../../.devcontainer/cpp/requirements.in | grep ${TOOL} | to_semver)
    INSTALLED_VERSION=$(${TOOL} --version | to_semver)

    assert_equal_print "$EXPECTED_VERSION" "$INSTALLED_VERSION" "Tool '${TOOL}' version"
  done
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
  install_win_sdk_when_ci_unset

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
  install_win_sdk_when_ci_unset

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

@test "clangd should be able to analyze source files" {
  run clangd --check=gcc/main.cpp
  assert_success
  assert_output --partial "All checks completed, 0 errors"
}

@test "clangd should start with a specified compile commands path" {
  run timeout 1s clangd --compile-commands-dir=/root/.amp
  refute_output --partial "Path specified by --compile-commands-dir does not exist. The argument will be ignored."
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

@test "sanitizers should detect undefined or suspicious behavior in code compiled with gcc" {
  build_and_run_with_sanitizers gcc
}

@test "sanitizers should detect undefined or suspicious behavior in code compiled with clang" {
  build_and_run_with_sanitizers clang
}

@test "using Conan as package manager should resolve external dependencies" {
  pushd package-managers/conan

  conan install . --output-folder=../../build --build=missing

  cmake --preset conan-release
  cmake --build --preset conan-release

  popd
}

@test "using CPM as package manager should resolve external dependencies" {
  cmake --preset cpm
  cmake --build --preset cpm
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

  run build/${PRESET}/sanitizers/test-threadsan
  assert_failure
  assert_output --partial "ThreadSanitizer: data race"
}

function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}

function get_expected_version_for() {
  local TOOL=${1:?}

  jq -sr ".[0] * .[1] * .[2] | to_entries[] | select(.key | startswith(\"${TOOL}\")) | .value | sub(\"-.*\"; \"\")" \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/base/apt-requirements.json \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/cpp/apt-requirements-base.json \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/cpp/apt-requirements-clang.json
}

function get_expected_semver_for() {
  local TOOL=${1:?}

  get_expected_version_for ${TOOL} | to_semver
}

function install_win_sdk() {
  xwin --http-retry 2 --accept-license --manifest-version 16 --cache-dir ${BATS_TEST_DIRNAME}/.xwin-cache splat --preserve-ms-arch-notation
  ln -sf ${BATS_TEST_DIRNAME}/.xwin-cache/splat/ /winsdk
}

function install_win_sdk_when_ci_unset() {
  # When running tests locally we typically run them one by one,
  # and want to install the Win SDK only for each test that requires it.

  if [[ -z "${CI}" ]]; then
    install_win_sdk
  fi
}

function install_win_sdk_when_ci_set() {
  # When running on a CI environment we run all tests in a single batch,
  # and only want to install the Win SKD once.

  if [[ -n "${CI}" ]]; then
    install_win_sdk
  fi
}

function assert_equal_print() {
  local EXPECTED=${1:?}
  local ACTUAL=${2:?}
  local MESSAGE=${3:-"Expecting values to be equal"}

  echo "# ${MESSAGE} expected(${EXPECTED}) actual(${ACTUAL})" >&3
  assert_equal ${ACTUAL} ${EXPECTED}
}
