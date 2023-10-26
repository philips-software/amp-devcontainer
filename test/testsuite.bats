#!/usr/bin/env bats
# ~/~ begin <<specification/tests/HEAD-1.0.md#tests/testsuite.bats>>[init]

setup() {
  #!/usr/bin/env bats
  #!/usr/bin/env bats
  # ~/~ begin <<specification/tests/HEAD-1.0.md#setup>>[init]
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  # ~/~ end
}

teardown() {
  #!/usr/bin/env bats
  #!/usr/bin/env bats
  # ~/~ begin <<specification/tests/HEAD-1.0.md#teardown>>[init]
  rm -rf build
  # ~/~ end
}

# ~/~ begin <<specification/tests/TEST-0001.md#testcase>>[init]
# bats test_tags=TC:TEST-0001
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
# ~/~ end