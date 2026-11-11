#!/usr/bin/env bats

# Checks the release-please configuration, which can't be tried out in a pull request.
# These tests inspect this repository, they do not need a container.

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  CONFIG="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/release-please-config.json"
}

@test "the root package does not release for the commits that only change another package" {
  # release-please gives the root package all commits, only exclude-paths takes them out again, so
  # a fix of a re-usable workflow would otherwise release the containers as well.
  run jq -r '
    (.packages["."]["exclude-paths"] // []) as $excluded
    | .packages | keys[] | select(. != ".") | select(. as $path | $excluded | index($path) | not)
  ' "${CONFIG}"

  assert_success
  assert_output ""
}

@test "the actions package is the one that is released with the re-usable workflows" {
  run jq -r '.packages[".github"]["package-name"]' "${CONFIG}"

  assert_success
  assert_output "actions"
}
