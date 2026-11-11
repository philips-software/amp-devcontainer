#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../verify-immutable-release.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  export FAKE_DIR
  export -f gh sleep
}

# The check waits for the release attestation, without waiting in the tests.
sleep() {
  echo "$*" >> "${FAKE_DIR}/sleep-calls"
}

# 'release verify' fails as often as the number in verify-failures, and from then on succeeds.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  [[ "$1 $2" == "release verify" ]] || return 64
  if [[ -f "${FAKE_DIR}/verify-failures" ]]; then
    failures=$(< "${FAKE_DIR}/verify-failures")
    if (( failures > 0 )); then
      echo $((failures - 1)) > "${FAKE_DIR}/verify-failures"
      echo "release is not immutable" >&2
      return 1
    fi
  fi
}

run_script() {
  RELEASE_TAG=9.9.9-fake GH_REPO=fake-owner/fake-repo run bash "${SCRIPT}"
}

@test "passes for an immutable release without waiting" {
  run_script

  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_output "release verify 9.9.9-fake"
  refute [ -e "${FAKE_DIR}/sleep-calls" ]
}

@test "waits for the release attestation that is created after the publication" {
  echo 2 > "${FAKE_DIR}/verify-failures"

  run_script

  assert_success
  run cat "${FAKE_DIR}/sleep-calls"
  assert_output "$(printf '10\n20')"
}

@test "fails after a bounded wait for a release that is not immutable" {
  echo 100 > "${FAKE_DIR}/verify-failures"

  run_script

  assert_failure
  assert_output --partial "Release 9.9.9-fake is not immutable"
  run grep -c "^release verify" "${FAKE_DIR}/gh-calls"
  assert_output "5"
}

@test "fails without a release tag" {
  run env -u RELEASE_TAG GH_REPO=fake-owner/fake-repo bash "${SCRIPT}"

  assert_failure
  assert_output --partial "release tag required"
}
