#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../require-draft-release.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  export FAKE_DIR
  export -f gh sleep
}

# The check waits for the release to be created, without waiting in the tests.
sleep() {
  echo "$*" >> "${FAKE_DIR}/sleep-calls"
}

# 'release view' prints the draft state, which is FAKE_DRAFT unless the lookup is set to fail.
# A number in draft-view-failures is the number of lookups that fail before the release exists.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  [[ "$1 $2 $4 $5" == "release view --json isDraft" ]] || return 64
  if [[ -f "${FAKE_DIR}/fail-draft-view" ]]; then
    echo "release not found" >&2
    return 1
  fi
  if [[ -f "${FAKE_DIR}/draft-view-failures" ]]; then
    failures=$(< "${FAKE_DIR}/draft-view-failures")
    if (( failures > 0 )); then
      echo $((failures - 1)) > "${FAKE_DIR}/draft-view-failures"
      echo "release not found" >&2
      return 1
    fi
  fi
  printf '%s\n' "${FAKE_DRAFT:-true}"
}

run_script() {
  RELEASE_TAG=9.9.9-fake GH_REPO=fake-owner/fake-repo FAKE_DRAFT="${FAKE_DRAFT:-true}" run bash "${SCRIPT}"
}

@test "passes for a draft release" {
  run_script

  assert_success
  refute [ -e "${FAKE_DIR}/sleep-calls" ]
}

@test "waits for the draft that is created after the tag" {
  echo 2 > "${FAKE_DIR}/draft-view-failures"

  run_script

  assert_success
  run grep -c "^10$" "${FAKE_DIR}/sleep-calls"
  assert_output "2"
}

@test "fails after a bounded wait when there is no release" {
  touch "${FAKE_DIR}/fail-draft-view"

  run_script

  assert_failure
  assert_output --partial "No release found for 9.9.9-fake"
  assert_output --partial "gh release create 9.9.9-fake --draft --verify-tag"
  run grep -c "^10$" "${FAKE_DIR}/sleep-calls"
  assert_output "6"
}

@test "fails for a release that is already published" {
  FAKE_DRAFT=false run_script

  assert_failure
  assert_output --partial "already published"
  refute [ -e "${FAKE_DIR}/sleep-calls" ]
}

@test "fails on an unexpected draft state" {
  FAKE_DRAFT=maybe run_script

  assert_failure
  assert_output --partial "Unexpected draft state of release 9.9.9-fake: maybe"
}

@test "fails without a release tag" {
  run env -u RELEASE_TAG GH_REPO=fake-owner/fake-repo bash "${SCRIPT}"

  assert_failure
  assert_output --partial "release tag required"
}
