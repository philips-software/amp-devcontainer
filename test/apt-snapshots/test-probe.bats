#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  source "${BATS_TEST_DIRNAME}/probe.sh"
}

@test "snapshot IDs reject invalid dates and shell input" {
  validate_snapshot 20261028T000000Z
  local VALUE
  for VALUE in latest 20260230T000000Z '20261028T000000Z;false' 20261028T250000Z; do
    run validate_snapshot "${VALUE}"
    assert_failure
    assert_output --partial "invalid Ubuntu snapshot timestamp"
  done
}

@test "snapshot candidates come from repository versions, not installed versions" {
  function apt-cache() {
    printf '%s\n' ' fake-package | 111.222.333-4 | https://snapshot.ubuntu.com/ubuntu/test main amd64 Packages' \
      ' fake-package | 9:101.202.303-4 | https://snapshot.ubuntu.com/ubuntu/test main amd64 Packages'
  }
  run snapshot_version fake-package
  assert_success
  assert_output '9:101.202.303-4'
}

@test "missing repository candidates fail explicitly" {
  function apt-cache() { :; }
  run snapshot_version fake-package
  assert_failure
  assert_output --partial "fake-package is absent"
}

@test "base compatibility rejects newer installed packages" {
  function dpkg-query() { printf 'fake-package\t999.888.777\tinstalled\n'; }
  function apt-cache() { printf ' fake-package | 111.222.333 | snapshot main amd64 Packages\n'; }
  run check_base_compatibility
  assert_failure
  assert_output --partial "base package fake-package=999.888.777 is newer"
}

@test "base compatibility accepts older installed packages" {
  function dpkg-query() { printf 'fake-package\t101.202.303\tinstalled\n'; }
  function apt-cache() { printf ' fake-package | 111.222.333 | snapshot main arm64 Packages\n'; }
  check_base_compatibility
}

@test "Ubuntu flavor package discovery excludes GitHub CLI pins" {
  local ROOT="${BATS_TEST_DIRNAME}/../.."
  local FLAVOR
  for FLAVOR in base cpp docs embedded-cpp rust embedded-rust; do
    run ubuntu_requirements "${ROOT}" "${FLAVOR}"
    assert_success
    refute_output --regexp '^gh$'
    assert_output --partial ca-certificates
  done
}

@test "the probe refuses to mutate the current devcontainer without explicit opt in" {
  unset SNAPSHOT_PROBE
  run main 20261028T000000Z base "${BATS_TEST_TMPDIR}"
  assert_failure
  assert_output --partial "disposable Docker container"
}
