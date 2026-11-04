#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
  source "${BATS_TEST_DIRNAME}/../../.devcontainer/base/apt-snapshot.sh"
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

@test "base compatibility rejects installed packages missing from the snapshot" {
  function dpkg-query() { printf 'fake-package\t101.202.303\tinstalled\n'; }
  function apt-cache() { :; }
  run check_base_compatibility
  assert_failure
  assert_output --partial "fake-package is absent"
}

@test "uninstalled base package records do not require a repository candidate" {
  function dpkg-query() { printf 'fake-removed-package\t999.888.777\tconfig-files\n'; }
  function apt-cache() { return 1; }
  check_base_compatibility
}

setup_updater_fixture() {
  FIXTURE="${BATS_TEST_TMPDIR}/repository"
  mkdir -p "${FIXTURE}/.github/scripts" "${FIXTURE}/.devcontainer/base"
  cp "${BATS_TEST_DIRNAME}/../../.github/scripts/update-ubuntu-snapshot.sh" "${FIXTURE}/.github/scripts/"
  cp "${BATS_TEST_DIRNAME}/../../.devcontainer/base/apt-snapshot.sh" "${FIXTURE}/.devcontainer/base/"
  printf 'ARG UBUNTU_SNAPSHOT=20261028T000000Z\nARG GH_VERSION=101.202.303\n' > "${FIXTURE}/.devcontainer/base/Dockerfile"
  function curl() {
    while [[ $# -gt 0 ]]; do
      if [[ "${1}" == -o ]]; then
        printf 'Architectures: amd64 arm64\n' > "${2}"
        return
      fi
      shift
    done
    return 1
  }
  function gpgv() { :; }
  export -f curl gpgv
}

@test "snapshot updater changes only the timestamp after checking signed metadata" {
  setup_updater_fixture
  run bash "${FIXTURE}/.github/scripts/update-ubuntu-snapshot.sh" 20261103T000000Z
  assert_success
  assert_output --partial '20261028T000000Z -> 20261103T000000Z'
  run cat "${FIXTURE}/.devcontainer/base/Dockerfile"
  assert_output $'ARG UBUNTU_SNAPSHOT=20261103T000000Z\nARG GH_VERSION=101.202.303'
}

@test "snapshot updater leaves the timestamp unchanged on signature failure" {
  setup_updater_fixture
  function gpgv() { echo 'fake signature verification failure' >&2; return 1; }
  export -f gpgv
  run bash "${FIXTURE}/.github/scripts/update-ubuntu-snapshot.sh" 20261103T000000Z
  assert_failure
  assert_output --partial 'fake signature verification failure'
  run grep '^ARG UBUNTU_SNAPSHOT=' "${FIXTURE}/.devcontainer/base/Dockerfile"
  assert_output 'ARG UBUNTU_SNAPSHOT=20261028T000000Z'
}

@test "snapshot updater rejects missing ARM64 metadata" {
  setup_updater_fixture
  function curl() {
    while [[ $# -gt 0 ]]; do
      if [[ "${1}" == -o ]]; then
        printf 'Architectures: amd64\n' > "${2}"
        return
      fi
      shift
    done
    return 1
  }
  export -f curl
  run bash "${FIXTURE}/.github/scripts/update-ubuntu-snapshot.sh" 20261103T000000Z
  assert_failure
  assert_output --partial 'does not advertise arm64'
  run grep '^ARG UBUNTU_SNAPSHOT=' "${FIXTURE}/.devcontainer/base/Dockerfile"
  assert_output 'ARG UBUNTU_SNAPSHOT=20261028T000000Z'
}

@test "snapshot updater does not modify the pin when a pocket download fails" {
  setup_updater_fixture
  function curl() { echo 'fake snapshot service unavailable' >&2; return 22; }
  export -f curl
  run bash "${FIXTURE}/.github/scripts/update-ubuntu-snapshot.sh" 20261103T000000Z
  assert_failure
  assert_output --partial 'fake snapshot service unavailable'
  run grep '^ARG UBUNTU_SNAPSHOT=' "${FIXTURE}/.devcontainer/base/Dockerfile"
  assert_output 'ARG UBUNTU_SNAPSHOT=20261028T000000Z'
}

@test "Dockerfiles no longer require APT version manifests or cached package indexes" {
  local ROOT="${BATS_TEST_DIRNAME}/../.."
  run grep -E 'apt-requirements|target=/var/lib/apt' \
    "${ROOT}/.devcontainer/"{base,cpp,docs,rust}/Dockerfile
  assert_failure
  assert_output ''
}
