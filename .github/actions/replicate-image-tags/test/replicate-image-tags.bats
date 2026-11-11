#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../replicate-image-tags.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/refs"

  FAKE_DIGEST=sha256:0000000000000000000000000000000000000000000000000000000000000001
  FAKE_OTHER_DIGEST=sha256:0000000000000000000000000000000000000000000000000000000000000002
  SOURCE=fake-registry.invalid/fake-owner/fake-image
  TARGET_ONE=fake-target-one.invalid/fake-org/fake-image
  TARGET_TWO=fake-target-two.invalid:5000/fake-org/fake-image

  GITHUB_OUTPUT="${FAKE_DIR}/github-output"

  export FAKE_DIR GITHUB_OUTPUT FAKE_OTHER_DIGEST SOURCE
  export -f gh docker
}

# 'attestation verify' succeeds unless the digest is marked as unverified.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  [[ "$1 $2" == "attestation verify" ]] || return 64
  [[ ! -e "${FAKE_DIR}/unverified" ]]
}

# 'buildx imagetools inspect' prints the manifest of a reference that is prepared with add_ref, fails with
# 'not found' for any other, and with the error in 'inspect-error' when that is prepared.
# 'buildx imagetools create' points the tags to the digest of the source.
docker() {
  echo "$*" >> "${FAKE_DIR}/docker-calls"
  case "$1 $2 $3" in
    "buildx imagetools inspect")
      if [[ -f "${FAKE_DIR}/inspect-error" && "$4" != "${SOURCE}:9.9.9-fake" ]]; then
        cat "${FAKE_DIR}/inspect-error" >&2
        return 1
      fi
      if [[ ! -f "${FAKE_DIR}/refs/${4//\//_}" ]]; then
        echo "ERROR: $4: not found" >&2
        return 1
      fi
      cat "${FAKE_DIR}/refs/${4//\//_}"
      ;;
    "buildx imagetools create")
      shift 3
      if [[ -f "${FAKE_DIR}/fail-create-once" ]]; then
        rm "${FAKE_DIR}/fail-create-once"
        echo "simulated push failure" >&2
        return 1
      fi
      local tags=() source
      while [[ "$1" == "--tag" ]]; do
        tags+=("$2")
        shift 2
      done
      source=${1#*@}
      [[ ! -f "${FAKE_DIR}/change-digest" ]] || source=${FAKE_OTHER_DIGEST}
      for tag in "${tags[@]}"; do
        printf '{"manifest": {"digest": "%s"}}' "${source}" > "${FAKE_DIR}/refs/${tag//\//_}"
      done
      ;;
    *) return 64 ;;
  esac
}

# Usage: add_ref REFERENCE DIGEST
add_ref() {
  local reference=${1:?}
  printf '{"manifest": {"digest": "%s"}}' "${2:?}" > "${FAKE_DIR}/refs/${reference//\//_}"
}

run_script() {
  RELEASE_TAG=9.9.9-fake SOURCE_IMAGE=${SOURCE} GH_REPO=fake-owner/fake-repo run bash "${SCRIPT}"
}

creates() {
  grep "^buildx imagetools create" "${FAKE_DIR}/docker-calls"
}

@test "the verified image is copied to every tag, in more than one registry, in one call" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"

  TAGS=$'fake-target-one.invalid/fake-org/fake-image:1.2.3\n\n  fake-target-one.invalid/fake-org/fake-image:latest  \nfake-target-two.invalid:5000/fake-org/fake-image:1.2.3\n' run_script

  assert_success
  run creates
  assert_output "buildx imagetools create --tag ${TARGET_ONE}:1.2.3 --tag ${TARGET_ONE}:latest --tag ${TARGET_TWO}:1.2.3 ${SOURCE}@${FAKE_DIGEST}"
  run cat "${GITHUB_OUTPUT}"
  assert_output "digest=${FAKE_DIGEST}"
}

@test "the attestation is verified against the repository, and the signing workflow when given" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"

  TAGS="${TARGET_ONE}:1.2.3" run_script
  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_output "attestation verify --repo fake-owner/fake-repo oci://${SOURCE}@${FAKE_DIGEST}"

  rm "${FAKE_DIR}/gh-calls" "${FAKE_DIR}/refs/${TARGET_ONE//\//_}:1.2.3"
  TAGS="${TARGET_ONE}:1.2.3" SIGNER_WORKFLOW=fake-owner/fake-repo/.github/workflows/fake.yml run_script
  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_output "attestation verify --repo fake-owner/fake-repo --signer-workflow fake-owner/fake-repo/.github/workflows/fake.yml oci://${SOURCE}@${FAKE_DIGEST}"
}

@test "the digest of a manifest list is used" {
  printf '{"manifests": [{"digest": "%s"}]}' "${FAKE_OTHER_DIGEST}" > "${FAKE_DIR}/refs/${SOURCE//\//_}:9.9.9-fake"

  TAGS="${TARGET_ONE}:1.2.3" run_script

  assert_success
  run creates
  assert_output --partial "${SOURCE}@${FAKE_OTHER_DIGEST}"
}

@test "nothing is written when the attestation cannot be verified" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  touch "${FAKE_DIR}/unverified"

  TAGS="${TARGET_ONE}:1.2.3" run_script

  assert_failure
  refute creates
}

@test "nothing is written when the source image does not exist" {
  TAGS="${TARGET_ONE}:1.2.3" run_script

  assert_failure
  assert_output --partial "${SOURCE}:9.9.9-fake not found"
  refute [ -e "${FAKE_DIR}/gh-calls" ]
  refute creates
}

@test "a tag is never moved, and nothing is written when one of the tags would be" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  add_ref "${TARGET_TWO}:1.2.3" "${FAKE_OTHER_DIGEST}"

  TAGS="${TARGET_ONE}:1.2.3"$'\n'"${TARGET_TWO}:1.2.3" run_script

  assert_failure
  assert_output --partial "${TARGET_TWO}:1.2.3 is ${FAKE_OTHER_DIGEST}, not ${FAKE_DIGEST}, a tag is never moved"
  refute creates
}

@test "tags that have the digest already are left alone, and a repeated run writes nothing" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  add_ref "${TARGET_ONE}:1.2.3" "${FAKE_DIGEST}"

  TAGS="${TARGET_ONE}:1.2.3"$'\n'"${TARGET_ONE}:latest" run_script
  assert_success
  assert_output --partial "${TARGET_ONE}:1.2.3 is ${FAKE_DIGEST} already"
  run creates
  assert_output "buildx imagetools create --tag ${TARGET_ONE}:latest ${SOURCE}@${FAKE_DIGEST}"

  rm "${FAKE_DIR}/docker-calls"
  TAGS="${TARGET_ONE}:1.2.3"$'\n'"${TARGET_ONE}:latest" run_script
  assert_success
  refute creates
}

@test "the same tag more than once is written once" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"

  TAGS="${TARGET_ONE}:1.2.3"$'\n'"${TARGET_ONE}:1.2.3" run_script

  assert_success
  run creates
  assert_output "buildx imagetools create --tag ${TARGET_ONE}:1.2.3 ${SOURCE}@${FAKE_DIGEST}"
}

@test "a failed push fails the script and can be repeated" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  touch "${FAKE_DIR}/fail-create-once"

  TAGS="${TARGET_ONE}:1.2.3" run_script
  assert_failure
  assert_output --partial "simulated push failure"

  TAGS="${TARGET_ONE}:1.2.3" run_script
  assert_success
}

@test "the script fails when a tag does not resolve to the verified digest afterwards" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  touch "${FAKE_DIR}/change-digest"

  TAGS="${TARGET_ONE}:1.2.3" run_script

  assert_failure
  assert_output --partial "${TARGET_ONE}:1.2.3 is ${FAKE_OTHER_DIGEST}, expected ${FAKE_DIGEST}"
  refute [ -s "${GITHUB_OUTPUT}" ]
}

@test "a registry that can't be read is not mistaken for a tag that does not exist" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"
  echo "ERROR: unauthorized: authentication required" > "${FAKE_DIR}/inspect-error"

  TAGS="${TARGET_ONE}:1.2.3" run_script

  assert_failure
  assert_output --partial "${TARGET_ONE}:1.2.3 could not be inspected: ERROR: unauthorized"
  refute creates
}

@test "references without a tag are refused" {
  add_ref "${SOURCE}:9.9.9-fake" "${FAKE_DIGEST}"

  for reference in "${TARGET_ONE}" "${TARGET_TWO}" "${TARGET_ONE}@${FAKE_DIGEST}" "${TARGET_ONE}:1.2.3@${FAKE_DIGEST}"; do
    TAGS="${reference}" run_script

    assert_failure
    assert_output --partial "not an image reference with a tag"
    refute [ -e "${FAKE_DIR}/docker-calls" ]
  done
}

@test "the script fails without tags" {
  TAGS=$'\n  \n' run_script

  assert_failure
  assert_output --partial "no tags to copy the image to"
  refute [ -e "${FAKE_DIR}/docker-calls" ]
}

@test "the script fails without a release tag, source image or repository" {
  run env -u RELEASE_TAG SOURCE_IMAGE=x GH_REPO=x bash "${SCRIPT}"
  assert_failure
  assert_output --partial "release tag required"

  run env -u SOURCE_IMAGE RELEASE_TAG=x GH_REPO=x bash "${SCRIPT}"
  assert_failure
  assert_output --partial "source image required"

  run env -u GH_REPO RELEASE_TAG=x SOURCE_IMAGE=x bash "${SCRIPT}"
  assert_failure
  assert_output --partial "GH_REPO required"
}
