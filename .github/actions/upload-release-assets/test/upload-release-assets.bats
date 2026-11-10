#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../upload-release-assets.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/digests" "${FAKE_DIR}/attestations" "${FAKE_DIR}/inventory" "${FAKE_DIR}/uploaded"

  FAKE_DIGEST_ALPHA=sha256:0000000000000000000000000000000000000000000000000000000000000001
  FAKE_DIGEST_BETA=sha256:0000000000000000000000000000000000000000000000000000000000000002
  IMAGE_ALPHA=fake-registry.invalid/fake-owner/fake-image-alpha
  IMAGE_BETA=fake-registry.invalid/fake-owner/fake-image-beta

  export FAKE_DIR
  export -f gh docker
}

# 'attestation verify' prints the base64 encoded payload that is prepared for the reference,
# 'release upload' stores copies of the uploaded files.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  case "$1 $2" in
    "attestation verify")
      # the arguments are: --repo <repository> oci://<image>@<digest>
      reference=${5#oci://}
      cat "${FAKE_DIR}/attestations/${reference//\//_}" || return 1
      ;;
    "release upload")
      shift 4 # release upload --clobber <tag>
      cp "$@" "${FAKE_DIR}/uploaded/"
      ;;
    *) return 64 ;;
  esac
}

# 'buildx imagetools inspect' prints the manifest that is prepared for the reference.
docker() {
  echo "$*" >> "${FAKE_DIR}/docker-calls"
  [[ "$1 $2 $3" == "buildx imagetools inspect" ]] || return 64
  cat "${FAKE_DIR}/digests/${4//\//_}"
}

# Usage: add_image IMAGE DIGEST [INVENTORY_JSON] [STATEMENT_JSON]
add_image() {
  local image=${1:?} digest=${2:?}
  local inventory=${3-'{"tools": []}'}
  local statement=${4-"{\"fake\": \"statement for ${image}\"}"}
  local basename=${image##*/}

  printf '{"manifest": {"digest": "%s"}}' "${digest}" > "${FAKE_DIR}/digests/${image//\//_}:9.9.9-fake"
  printf '%s' "${statement}" | base64 -w0 > "${FAKE_DIR}/attestations/${image//\//_}@${digest}"
  mkdir -p "${FAKE_DIR}/inventory/tool-inventory-${basename}"
  printf '%s' "${inventory}" > "${FAKE_DIR}/inventory/tool-inventory-${basename}/tool-inventory.json"
}

run_script() {
  RELEASE_TAG=9.9.9-fake \
    GH_REPO=fake-owner/fake-repo \
    INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" \
    run bash "${SCRIPT}"
}

@test "the attestation and tool inventory of every image are uploaded in a single call" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_image "${IMAGE_BETA}" "${FAKE_DIGEST_BETA}"

  IMAGES=$'fake-registry.invalid/fake-owner/fake-image-alpha\n\n  fake-registry.invalid/fake-owner/fake-image-beta  \n' run_script

  assert_success
  run grep -c "^release upload" "${FAKE_DIR}/gh-calls"
  assert_output "1"
  run ls "${FAKE_DIR}/uploaded"
  assert_output "$(printf '%s\n' \
    "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.intoto.jsonl" \
    "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.tool-inventory.json" \
    "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.intoto.jsonl" \
    "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.tool-inventory.json")"
}

@test "the assets are named after the owner of the repository, the image and the digest" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" GH_REPO=fake-other-owner/fake-repo RELEASE_TAG=9.9.9-fake INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" run bash "${SCRIPT}"

  assert_success
  run ls "${FAKE_DIR}/uploaded"
  assert_line --index 0 --partial "fake-other-owner-fake-image-alpha_sha256_"
}

@test "the attestation is uploaded as the formatted statement and the inventory as it is" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}" '{"flavor":"fake-name","tools":[]}' '{"fake":"statement","list":[1,2]}'

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_success
  local asset="fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  run cat "${FAKE_DIR}/uploaded/${asset}.intoto.jsonl"
  assert_output "$(printf '{\n  "fake": "statement",\n  "list": [\n    1,\n    2\n  ]\n}')"
  run cat "${FAKE_DIR}/uploaded/${asset}.tool-inventory.json"
  assert_output '{"flavor":"fake-name","tools":[]}'
}

@test "the attestation is verified against the repository and the digest of the image with the given tag" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_success
  run cat "${FAKE_DIR}/docker-calls"
  assert_line "buildx imagetools inspect ${IMAGE_ALPHA}:9.9.9-fake --format {{json .}}"
  run cat "${FAKE_DIR}/gh-calls"
  assert_line --regexp "^attestation verify --repo fake-owner/fake-repo oci://${IMAGE_ALPHA}@${FAKE_DIGEST_ALPHA} --format json --jq "
  assert_line --regexp "^release upload --clobber 9.9.9-fake "
}

@test "the digest of a manifest list is used" {
  add_image "${IMAGE_ALPHA}" "unused"
  printf '{"manifests": [{"digest": "%s"}]}' "${FAKE_DIGEST_BETA}" > "${FAKE_DIR}/digests/${IMAGE_ALPHA//\//_}:9.9.9-fake"
  printf '{"fake": "statement"}' | base64 -w0 > "${FAKE_DIR}/attestations/${IMAGE_ALPHA//\//_}@${FAKE_DIGEST_BETA}"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_success
  run ls "${FAKE_DIR}/uploaded"
  assert_line "fake-owner-fake-image-alpha_${FAKE_DIGEST_BETA//:/_}.intoto.jsonl"
}

@test "nothing is uploaded when the attestation of an image cannot be verified" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_image "${IMAGE_BETA}" "${FAKE_DIGEST_BETA}"
  rm "${FAKE_DIR}/attestations/${IMAGE_BETA//\//_}@${FAKE_DIGEST_BETA}"

  IMAGES=$'fake-registry.invalid/fake-owner/fake-image-alpha\nfake-registry.invalid/fake-owner/fake-image-beta' run_script

  assert_failure
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
  run ls "${FAKE_DIR}/uploaded"
  assert_output ""
}

@test "nothing is uploaded when an image has no in-toto attestation" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  : > "${FAKE_DIR}/attestations/${IMAGE_ALPHA//\//_}@${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_failure
  assert_output --partial "no in-toto attestation found for ${IMAGE_ALPHA}@${FAKE_DIGEST_ALPHA}"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "nothing is uploaded when the tool inventory of an image is missing" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  rm -r "${FAKE_DIR}/inventory/tool-inventory-fake-image-alpha"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_failure
  assert_output --partial "tool inventory not found"
  refute [ -e "${FAKE_DIR}/gh-calls" ]
}

@test "nothing is uploaded when the digest of an image cannot be resolved" {
  IMAGES="${IMAGE_ALPHA}" run_script

  assert_failure
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "the script fails when images have the same basename" {
  add_image fake-registry.invalid/fake-owner-one/fake-image-alpha "${FAKE_DIGEST_ALPHA}"
  add_image fake-registry.invalid/fake-owner-two/fake-image-alpha "${FAKE_DIGEST_BETA}"

  IMAGES=$'fake-registry.invalid/fake-owner-one/fake-image-alpha\nfake-registry.invalid/fake-owner-two/fake-image-alpha' run_script

  assert_failure
  assert_output --partial "more than one image with the basename: fake-image-alpha"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "the script does nothing without images" {
  IMAGES="" run_script

  assert_success
  assert_output --partial "nothing to upload"
  refute [ -e "${FAKE_DIR}/gh-calls" ]
}

@test "the script fails without a release tag or repository" {
  run env -u RELEASE_TAG GH_REPO=fake bash "${SCRIPT}"
  assert_failure
  assert_output --partial "release tag required"

  run env -u GH_REPO RELEASE_TAG=fake bash "${SCRIPT}"
  assert_failure
  assert_output --partial "GH_REPO required"
}
