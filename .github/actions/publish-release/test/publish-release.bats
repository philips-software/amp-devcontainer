#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../publish-release.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  # The release has the asset that most tests expect
  printf '{"assets":[{"name":"fake-asset.spdx.json","state":"uploaded"}]}' > "${FAKE_DIR}/release-assets.json"

  export FAKE_DIR
  export -f gh
}

# 'release view' prints the assets of the release, or its draft state, which is FAKE_DRAFT.
# Files in the fake directory make a command fail.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  case "$1 $2" in
    "release view")
      if [[ "${5-}" == "assets" ]]; then
        if [[ -f "${FAKE_DIR}/fail-asset-view" ]]; then
          echo "simulated asset lookup failure" >&2
          return 1
        fi
        cat "${FAKE_DIR}/release-assets.json"
      elif [[ "${5-}" == "isDraft" ]]; then
        if [[ -f "${FAKE_DIR}/fail-draft-view" ]]; then
          echo "simulated draft lookup failure" >&2
          return 1
        fi
        printf '%s\n' "${FAKE_DRAFT:-true}"
      else
        return 64
      fi
      ;;
    "release edit")
      if [[ -f "${FAKE_DIR}/fail-release-edit" ]]; then
        echo "simulated edit failure" >&2
        return 1
      fi
      ;;
    *) return 64 ;;
  esac
}

run_script() {
  RELEASE_TAG=9.9.9-fake GH_REPO=fake-owner/fake-repo EXPECTED_ASSETS="${EXPECTED_ASSETS-}" FAKE_DRAFT="${FAKE_DRAFT:-true}" run bash "${SCRIPT}"
}

assert_not_published() {
  run grep "^release edit" "${FAKE_DIR}/gh-calls"
  assert_failure
}

@test "publishes a draft release that has the expected assets" {
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_success
  run grep -c "^release edit 9.9.9-fake --draft=false --verify-tag$" "${FAKE_DIR}/gh-calls"
  assert_output "1"
}

@test "checks the assets again, so an asset that disappeared after the upload is noticed" {
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script
  assert_success

  printf '{"assets":[]}' > "${FAKE_DIR}/release-assets.json"
  : > "${FAKE_DIR}/gh-calls"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "expected uploaded release asset not found"
  assert_output --partial "fake-asset.spdx.json"
  assert_not_published
}

@test "an asset that is not uploaded yet counts as missing" {
  printf '{"assets":[{"name":"fake-asset.spdx.json","state":"starter"}]}' > "${FAKE_DIR}/release-assets.json"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_not_published
}

@test "refuses an absent or invalid list of expected assets" {
  local expected
  for expected in '' '[]' '{}' '[""]' '["asset",null]' '["\n"]' '{invalid'; do
    : > "${FAKE_DIR}/gh-calls"
    EXPECTED_ASSETS="${expected}" run_script

    assert_failure
    assert_not_published
  done
}

@test "refuses a malformed response for the assets of the release" {
  printf '{"assets":null}' > "${FAKE_DIR}/release-assets.json"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "release assets response has no assets array"
  assert_not_published

  printf '{invalid' > "${FAKE_DIR}/release-assets.json"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_not_published
}

@test "refuses to proceed when the lookup of the assets fails" {
  touch "${FAKE_DIR}/fail-asset-view"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "simulated asset lookup failure"
  assert_not_published
}

@test "fails when the draft state of the release cannot be looked up" {
  touch "${FAKE_DIR}/fail-draft-view"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "simulated draft lookup failure"
  assert_not_published
}

@test "fails on an unexpected draft state" {
  FAKE_DRAFT=maybe EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "unexpected draft state of release 9.9.9-fake: maybe"
  assert_not_published
}

@test "fails when the release cannot be published" {
  touch "${FAKE_DIR}/fail-release-edit"
  EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "simulated edit failure"
}

@test "leaves a release that is already published as it is" {
  FAKE_DRAFT=false EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_success
  assert_output --partial "already published"
  assert_not_published
}

@test "reports missing assets even when the release was published by hand" {
  printf '{"assets":[]}' > "${FAKE_DIR}/release-assets.json"
  FAKE_DRAFT=false EXPECTED_ASSETS='["fake-asset.spdx.json"]' run_script

  assert_failure
  assert_output --partial "fake-asset.spdx.json"
  assert_not_published
}

@test "fails without a release tag" {
  run env -u RELEASE_TAG EXPECTED_ASSETS='["fake-asset.spdx.json"]' GH_REPO=fake-owner/fake-repo bash "${SCRIPT}"

  assert_failure
  assert_output --partial "release tag required"
}
