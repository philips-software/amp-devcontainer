#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../extract-manifest-digest.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  FAKE_DIGEST=sha256:0000000000000000000000000000000000000000000000000000000000000001
  mkdir -p "${FAKE_DIR}"

  export FAKE_DIR
  export GITHUB_OUTPUT="${FAKE_DIR}/output"
  export -f docker
}

# Prints the prepared inspect result.
docker() {
  echo "$*" >> "${FAKE_DIR}/docker-calls"
  [[ "$1 $2 $3" == "buildx imagetools inspect" ]] || return 64
  cat "${FAKE_DIR}/inspect-result"
}

@test "the digest of the manifest is written to the output" {
  printf '{"name": "fake-registry.invalid/fake-image:1.2.3", "manifest": {"digest": "%s"}}' "${FAKE_DIGEST}" > "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "digest=${FAKE_DIGEST}"
}

@test "the digest of the first manifest is used when there is no manifest digest" {
  printf '{"manifests": [{"digest": "%s"}, {"digest": "sha256:other"}]}' "${FAKE_DIGEST}" > "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "digest=${FAKE_DIGEST}"
}

@test "the manifest digest takes precedence over the digest of the first manifest" {
  printf '{"manifest": {"digest": "%s"}, "manifests": [{"digest": "sha256:other"}]}' "${FAKE_DIGEST}" > "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "digest=${FAKE_DIGEST}"
}

@test "the container is inspected with the given reference" {
  printf '{"manifest": {"digest": "%s"}}' "${FAKE_DIGEST}" > "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-owner/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_success
  run cat "${FAKE_DIR}/docker-calls"
  assert_output "buildx imagetools inspect fake-registry.invalid/fake-owner/fake-image:1.2.3 --format {{json .}}"
}

@test "the script fails without writing an output when there is no digest" {
  printf '{"name": "fake-registry.invalid/fake-image:1.2.3"}' > "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_failure
  refute [ -e "${GITHUB_OUTPUT}" ]
}

@test "the script fails when the container cannot be inspected" {
  rm -f "${FAKE_DIR}/inspect-result"

  CONTAINER=fake-registry.invalid/fake-image:1.2.3 run bash "${SCRIPT}"

  assert_failure
  refute [ -e "${GITHUB_OUTPUT}" ]
}

@test "the script fails without a container or output file" {
  run env -u CONTAINER bash "${SCRIPT}"
  assert_failure
  assert_output --partial "container required"

  run env -u GITHUB_OUTPUT CONTAINER=fake-image bash "${SCRIPT}"
  assert_failure
  assert_output --partial "GITHUB_OUTPUT required"
}
