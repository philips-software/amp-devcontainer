#!/usr/bin/env bats
# ~/~ begin <<specification/test/HEAD-1.0.md#test/testsuite.bats>>[init]

setup() {
  #!/usr/bin/env bats
  #!/usr/bin/env bats
  # ~/~ begin <<specification/test/HEAD-1.0.md#setup>>[init]
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  # ~/~ end
}

teardown() {
  #!/usr/bin/env bats
  # ~/~ begin <<specification/test/TEST-0015.md#teardown>>[init]
  rm -rf .xwin-cache /winsdk
  # ~/~ end
  #!/usr/bin/env bats
  # ~/~ begin <<specification/test/HEAD-1.0.md#teardown>>[0]
  rm -rf build
  # ~/~ end
  # ~/~ begin <<specification/test/TEST-0009.md#teardown>>[0]
  rm -rf crash-*
  # ~/~ end
}

# ~/~ begin <<specification/test/TEST-0002.md#testcase>>[init]
# bats test_tags=tc:TEST-0002
@test "valid code input should result in elf executable using arm-none-eabi compiler" {
  run cmake --preset gcc-arm-none-eabi
  assert_success

  run cmake --build --preset gcc-arm-none-eabi
  assert_success

  run readelf -h build/gcc-arm-none-eabi/gcc-arm-none-eabi/test-gcc-arm-none-eabi
  assert_output --partial "Type:                              EXEC"
  assert_output --partial "Machine:                           ARM"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0007.md#testcase>>[0]
# bats test_tags=tc:TEST-0007
@test "running clang-format should result in re-formatted code" {
  run clang-format clang-tools/unformatted.cpp
  assert_success
  assert_output "int main() {}"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0012.md#testcase>>[0]
# bats test_tags=tc:TEST-0012
@test "gdb-multiarch should be able to start" {
  run gdb-multiarch --version
  assert_success
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0001.md#testcase>>[0]
# bats test_tags=tc:TEST-0001
@test "valid code input should result in working executable using host compiler" {
  run cmake --preset gcc
  assert_success

  run cmake --build --preset gcc
  assert_success

  run build/gcc/gcc/test-gcc
  assert_success
  assert_output "Hello World!"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0015.md#testcase>>[0]
# bats test_tags=tc:TEST-0015
@test "using xwin to install Windows SDK/CRT should result in working environment" {
  run xwin --accept-license splat --preserve-ms-arch-notation && mv .xwin-cache/splat/ /winsdk
  assert_success

  run cmake --preset clang-cl
  assert_success

  run cmake --build --preset clang-cl
  assert_success
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0011.md#testcase>>[0]
# bats test_tags=tc:TEST-0011
@test "host gdb should be able to start" {
  run gdb --version
  assert_success
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0013.md#testcase>>[0]
# bats test_tags=tc:TEST-0013
@test "clangd should be able to analyze source files" {
  run clangd --check=gcc/main.cpp
  assert_success
  assert_output --partial "All checks completed, 0 errors"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0003.md#testcase>>[0]
# bats test_tags=tc:TEST-0003
@test "invalid code input should result in failing build" {
  run cmake --preset gcc
  assert_success

  run cmake --build --preset gcc-fail
  assert_failure
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0014.md#testcase>>[0]
# bats test_tags=tc:TEST-0014
@test "using lld as an alternative linker should result in working host executable" {
  run cmake --preset gcc
  assert_success

  run cmake --build --preset gcc-lld
  assert_success

  run readelf --string-dump .comment build/gcc/gcc/test-gcc-lld
  assert_output --partial "Linker: Ubuntu LLD"

  run build/gcc/gcc/test-gcc-lld
  assert_success
  assert_output "Hello World!"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0005.md#testcase>>[0]
# bats test_tags=tc:TEST-0005
@test "running clang-tidy as part of the build should result in warning diagnostics" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset clang-tidy
  assert_success
  assert_output --partial "warning: use a trailing return type for this function"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0008.md#testcase>>[0]
# bats test_tags=tc:TEST-0008
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
# ~/~ end
# ~/~ begin <<specification/test/TEST-0009.md#testcase>>[0]
# bats test_tags=tc:TEST-0009
@test "fuzzing an executable should be supported" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset fuzzing
  assert_success

  run build/clang/fuzzing/test-fuzzing
  assert_failure
  assert_output --partial "SUMMARY: libFuzzer: deadly signal"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0006.md#testcase>>[0]
# bats test_tags=tc:TEST-0006
@test "running include-what-you-use as part of the build should result in warning diagnostics" {
  run cmake --preset clang
  assert_success

  run cmake --build --preset clang-iwyu
  assert_success
  assert_output --partial "Warning: include-what-you-use reported diagnostics:"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0010.md#testcase>>[0]
# bats test_tags=tc:TEST-0010
@test "mutation testing an executable should be supported" {
  run cmake --preset mutation
  assert_success

  run cmake --build --preset mutation
  assert_success

  run ctest --preset mutation
  assert_output --partial "[info] Mutation score:"
}
# ~/~ end
# ~/~ begin <<specification/test/TEST-0004.md#testcase>>[0]
# bats test_tags=tc:TEST-0004
@test "using ccache as a compiler launcher should result in cached build" {
  run ccache --clear --zero-stats

  run cmake --preset gcc -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  assert_success

  run cmake --build --preset gcc
  assert_success

  run ccache -s
  assert_output --partial "Hits:               0"
  assert_output --partial "Misses:             1"

  run rm -rf build
  run ccache --zero-stats

  run cmake --preset gcc -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  assert_success

  run cmake --build --preset gcc
  assert_success

  run ccache -s
  assert_output --partial "Hits:               1"
  assert_output --partial "Misses:             0"
}
# ~/~ end
# ~/~ end