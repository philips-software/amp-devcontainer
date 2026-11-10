#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../upload-release-assets.sh"
  ROOT_DIRECTORY="${BATS_TEST_DIRNAME}/../../../.."
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/digests" "${FAKE_DIR}/attestations" "${FAKE_DIR}/inventory" "${FAKE_DIR}/sboms" "${FAKE_DIR}/uploaded"

  FAKE_DIGEST_ALPHA=sha256:0000000000000000000000000000000000000000000000000000000000000001
  FAKE_DIGEST_BETA=sha256:0000000000000000000000000000000000000000000000000000000000000002
  IMAGE_ALPHA=fake-registry.invalid/fake-owner/fake-image-alpha
  IMAGE_BETA=fake-registry.invalid/fake-owner/fake-image-beta

  export FAKE_DIR
  export -f gh docker sleep
}

# The checks wait for the release to be created, without waiting in the tests.
sleep() {
  echo "$*" >> "${FAKE_DIR}/sleep-calls"
}

# 'attestation verify' prints the base64 encoded payload that is prepared for the reference,
# 'release upload' stores copies of the uploaded files.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  case "$1 $2" in
    "attestation verify")
      # the reference is the argument that starts with oci://
      for argument in "$@"; do
        [[ "${argument}" == oci://* ]] && reference=${argument#oci://}
      done
      cat "${FAKE_DIR}/attestations/${reference//\//_}" || return 1
      ;;
    "release upload")
      clobber=false
      [[ "$3" == "--clobber" ]] && clobber=true
      shift 4 # release upload --clobber <tag>
      # like GitHub, an asset that exists is only replaced with --clobber
      for file in "$@"; do
        if [[ "${clobber}" == false && -e "${FAKE_DIR}/uploaded/${file##*/}" ]]; then
          echo "asset under the same name already exists: ${file##*/}" >&2
          return 1
        fi
      done
      if [[ -f "${FAKE_DIR}/fail-upload-once" ]]; then
        rm "${FAKE_DIR}/fail-upload-once"
        cp "$1" "${FAKE_DIR}/uploaded/"
        echo "simulated upload failure" >&2
        return 1
      fi
      cp "$@" "${FAKE_DIR}/uploaded/"
      ;;
    "release view")
      if [[ -f "${FAKE_DIR}/fail-release-view" ]]; then
        echo "simulated release lookup failure" >&2
        return 1
      fi
      if [[ "${5-}" == "assets" && -f "${FAKE_DIR}/fail-asset-view" ]]; then
        echo "simulated asset lookup failure" >&2
        return 1
      fi
      if [[ "${5-}" == "isDraft" ]]; then
        if [[ -f "${FAKE_DIR}/fail-draft-view" ]]; then
          echo "simulated draft lookup failure" >&2
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
        return
      fi
      if [[ -f "${FAKE_DIR}/release-assets.json" ]]; then
        cat "${FAKE_DIR}/release-assets.json"
      else
        find "${FAKE_DIR}/uploaded" -maxdepth 1 -type f -printf '%f\n' \
          | jq -Rsc 'split("\n") | map(select(length > 0) | {name: ., state: "uploaded"}) | {assets: .}'
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

add_sbom() {
  local name=${1:?} content=${2-'{"spdxVersion":"SPDX-2.3"}'}
  printf '%s' "${content}" > "${FAKE_DIR}/sboms/${name}.spdx.json"
}

run_script() {
  RELEASE_TAG=9.9.9-fake \
    GH_REPO=fake-owner/fake-repo \
    SIGNER_WORKFLOW=${SIGNER_WORKFLOW-fake-signer-owner/fake-signer-repo/.github/workflows/fake-build.yml} \
    INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" \
    SBOM_DIRECTORY="${SBOM_DIRECTORY:-}" \
    run bash "${SCRIPT}"
}

run_workflow_step() {
  local step=${1:?}

  awk -v header="      - name: ${step}" '
    $0 == header { in_step = 1; next }
    in_step && $0 == "        env:" { exit }
    in_step && /^          / { sub(/^          /, ""); print }
  ' "${ROOT_DIRECTORY}/.github/workflows/release-build.yml" > "${FAKE_DIR}/step.sh"

  RELEASE_TAG=9.9.9-fake \
    REF_NAME=9.9.9-fake \
    GH_REPO=fake-owner/fake-repo \
    EXPECTED_ASSETS="${EXPECTED_ASSETS:-}" \
    FAKE_DRAFT="${FAKE_DRAFT:-true}" \
    run bash -c 'cd "${2:-.}"; exec bash "$1"' _ "${FAKE_DIR}/step.sh" "${STEP_DIRECTORY:-${ROOT_DIRECTORY}}"
}

run_publish() {
  run_workflow_step "Publish release"
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

@test "the SBOM of every image is uploaded and the release assets are verified" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_image "${IMAGE_BETA}" "${FAKE_DIGEST_BETA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" '{"spdxVersion":"SPDX-2.3","name":"alpha"}'
  add_sbom "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}" '{"spdxVersion":"SPDX-2.3","name":"beta"}'

  GITHUB_OUTPUT="${FAKE_DIR}/action-output" \
    IMAGES="${IMAGE_ALPHA}"$'\n'"${IMAGE_BETA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_success
  run ls "${FAKE_DIR}/uploaded"
  assert_line "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
  assert_line "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.intoto.jsonl"
  assert_line "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.tool-inventory.json"
  assert_line "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.spdx.json"
  assert_line "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.intoto.jsonl"
  assert_line "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.tool-inventory.json"
  assert_equal "${#lines[@]}" 6
  run cat "${FAKE_DIR}/uploaded/fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
  assert_output '{"spdxVersion":"SPDX-2.3","name":"alpha"}'
  run cat "${FAKE_DIR}/gh-calls"
  assert_line "release view 9.9.9-fake --json assets"
  local alpha="fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  local beta="fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}"
  local expected
  expected=$(jq -nc --arg alpha "${alpha}" --arg beta "${beta}" \
    '[$alpha + ".spdx.json", $alpha + ".intoto.jsonl", $alpha + ".tool-inventory.json",
      $beta + ".spdx.json", $beta + ".intoto.jsonl", $beta + ".tool-inventory.json"]')
  run cat "${FAKE_DIR}/action-output"
  assert_output "asset-names=${expected}"
}

@test "nothing is uploaded when an image's SBOM is missing" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_image "${IMAGE_BETA}" "${FAKE_DIGEST_BETA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"

  IMAGES="${IMAGE_ALPHA}"$'\n'"${IMAGE_BETA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "SBOM not found or empty"
  assert_output --partial "fake-owner-fake-image-beta_${FAKE_DIGEST_BETA//:/_}.spdx.json"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "an SBOM for a different digest does not satisfy an image" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_BETA//:/_}"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "an empty or invalid SBOM cannot be uploaded" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" ""

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "SBOM not found or empty"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"

  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" '[]'
  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "invalid SPDX SBOM JSON object"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"

  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" '{invalid'
  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "invalid SPDX SBOM JSON object"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"

  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" '{}'
  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "invalid SPDX SBOM JSON object"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"

  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}" \
    '{"spdxVersion":"SPDX-2.3"}{"spdxVersion":"SPDX-2.3"}'
  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "invalid SPDX SBOM JSON object"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "SBOM artifact names follow the image namespace and Anchore sanitization" {
  local image=fake-registry.invalid/acme.sub/nested_ns/fake.image-alpha
  add_image "${image}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "acme_sub-nested_ns-fake_image-alpha_${FAKE_DIGEST_ALPHA//:/_}"

  IMAGES="${image}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_success
  run ls "${FAKE_DIR}/uploaded"
  assert_line "acme_sub-nested_ns-fake_image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
}

@test "a two-component image reference keeps both components in the SBOM name" {
  local image=registry.invalid/fake-image-alpha
  add_image "${image}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "registry_invalid-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"

  IMAGES="${image}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_success
  run ls "${FAKE_DIR}/uploaded"
  assert_line "registry_invalid-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
}

@test "images with the same sanitized SBOM name cannot be uploaded" {
  local image_one=fake-registry.invalid/fake-owner/fake.image
  local image_two=fake-registry.invalid/fake-owner/fake_image
  add_image "${image_one}" "${FAKE_DIGEST_ALPHA}"
  add_image "${image_two}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake_image_${FAKE_DIGEST_ALPHA//:/_}"

  IMAGES="${image_one}"$'\n'"${image_two}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "more than one image has the SBOM artifact name"
  refute grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "the script fails when an uploaded SBOM is absent from the release" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  printf '{"assets":[]}' > "${FAKE_DIR}/release-assets.json"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "expected uploaded release asset not found"
  assert_output --partial "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json"
  grep -q "^release upload" "${FAKE_DIR}/gh-calls"
}

@test "a release asset that is not uploaded does not satisfy verification" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  printf '{"assets":[{"name":"%s","state":"starter"}]}' \
    "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}.spdx.json" > "${FAKE_DIR}/release-assets.json"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "expected uploaded release asset not found"
}

@test "verification requires the attestation and inventory as well as the SBOM" {
  local asset="fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "${asset}"
  jq -nc --arg sbom "${asset}.spdx.json" \
    '{assets: [{name: $sbom, state: "uploaded"}]}' > "${FAKE_DIR}/release-assets.json"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "${asset}.intoto.jsonl"

  jq -nc --arg sbom "${asset}.spdx.json" --arg attestation "${asset}.intoto.jsonl" \
    '{assets: [{name: $sbom, state: "uploaded"}, {name: $attestation, state: "uploaded"}]}' \
    > "${FAKE_DIR}/release-assets.json"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "${asset}.tool-inventory.json"
}

@test "a failed release lookup fails the upload job" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  touch "${FAKE_DIR}/fail-release-view"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "simulated release lookup failure"
}

@test "a partially failed upload can be retried on a draft" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  touch "${FAKE_DIR}/fail-upload-once"

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script
  assert_failure

  IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script
  assert_success
  run grep -c "^release upload --clobber" "${FAKE_DIR}/gh-calls"
  assert_output "2"
}

@test "the documents can be uploaded again after a partial or complete upload" {
  local directory="${BATS_TEST_TMPDIR}/documents"
  mkdir -p "${directory}"
  echo pdf > "${directory}/fake-document.pdf"
  echo sbdl > "${directory}/fake-requirements.sbdl"
  echo old > "${FAKE_DIR}/uploaded/fake-document.pdf"

  STEP_DIRECTORY="${directory}" run_workflow_step "Upload documents to release"
  assert_success
  STEP_DIRECTORY="${directory}" run_workflow_step "Upload documents to release"
  assert_success

  run cat "${FAKE_DIR}/uploaded/fake-document.pdf"
  assert_output "pdf"
  run grep -c "^release upload --clobber 9.9.9-fake " "${FAKE_DIR}/gh-calls"
  assert_output "2"
}

@test "the documents step fails when there are no documents" {
  STEP_DIRECTORY="${BATS_TEST_TMPDIR}" run_workflow_step "Upload documents to release"

  assert_failure
}

@test "publication rechecks the image assets after approval" {
  local asset="fake-owner-fake-image-alpha_${FAKE_DIGEST_ALPHA//:/_}"
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"
  add_sbom "${asset}"

  GITHUB_OUTPUT="${FAKE_DIR}/action-output" \
    IMAGES="${IMAGE_ALPHA}" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script
  assert_success
  local expected
  expected=$(sed -n 's/^asset-names=//p' "${FAKE_DIR}/action-output")

  EXPECTED_ASSETS="${expected}" run_publish
  assert_success
  run grep -c "^release edit 9.9.9-fake --draft=false --verify-tag$" "${FAKE_DIR}/gh-calls"
  assert_output "1"

  rm "${FAKE_DIR}/uploaded/${asset}.spdx.json"
  : > "${FAKE_DIR}/gh-calls"
  EXPECTED_ASSETS="${expected}" run_publish

  assert_failure
  assert_output --partial "expected uploaded release asset not found"
  assert_output --partial "${asset}.spdx.json"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "publication refuses an absent or invalid expected asset list" {
  local expected
  for expected in '' '[]' '{}' '[""]' '["asset",null]' '["\n"]' '{invalid'; do
    : > "${FAKE_DIR}/gh-calls"
    EXPECTED_ASSETS="${expected}" run_publish

    assert_failure
    refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
  done
}

@test "publication refuses a malformed release asset response" {
  printf '{"assets":null}' > "${FAKE_DIR}/release-assets.json"
  EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "release assets response has no assets array"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"

  printf '{invalid' > "${FAKE_DIR}/release-assets.json"
  EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "publication refuses to proceed when asset lookup fails" {
  touch "${FAKE_DIR}/fail-asset-view"
  EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "simulated asset lookup failure"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "publication fails when the draft state of the release cannot be looked up" {
  printf '{"assets":[{"name":"required.spdx.json","state":"uploaded"}]}' > "${FAKE_DIR}/release-assets.json"
  touch "${FAKE_DIR}/fail-draft-view"
  EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "simulated draft lookup failure"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "publication fails on an unexpected draft state" {
  printf '{"assets":[{"name":"required.spdx.json","state":"uploaded"}]}' > "${FAKE_DIR}/release-assets.json"
  FAKE_DRAFT=maybe EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "unexpected draft state of release 9.9.9-fake: maybe"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "publication fails when the release cannot be published" {
  printf '{"assets":[{"name":"required.spdx.json","state":"uploaded"}]}' > "${FAKE_DIR}/release-assets.json"
  touch "${FAKE_DIR}/fail-release-edit"
  EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "simulated edit failure"
}

@test "an already published release is left as is" {
  printf '{"assets":[{"name":"required.spdx.json","state":"uploaded"}]}' > "${FAKE_DIR}/release-assets.json"
  FAKE_DRAFT=false EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_success
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "missing assets are reported even when the release was published manually" {
  printf '{"assets":[]}' > "${FAKE_DIR}/release-assets.json"
  FAKE_DRAFT=false EXPECTED_ASSETS='["required.spdx.json"]' run_publish

  assert_failure
  assert_output --partial "required.spdx.json"
  refute grep -q "^release edit" "${FAKE_DIR}/gh-calls"
}

@test "the assets are named after the owner of the repository, the image and the digest" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" GH_REPO=fake-other-owner/fake-repo SIGNER_WORKFLOW=fake-signer-owner/fake-signer-repo/fake.yml RELEASE_TAG=9.9.9-fake INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" run bash "${SCRIPT}"

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

@test "the attestation is verified against the workflow that signed it, which can be in another repository" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_line --regexp "^attestation verify --repo fake-owner/fake-repo --signer-workflow fake-signer-owner/fake-signer-repo/.github/workflows/fake-build.yml oci://"
}

@test "fails without a signer workflow" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  SIGNER_WORKFLOW= IMAGES="${IMAGE_ALPHA}" run_script

  assert_failure
  assert_output --partial "signer workflow required"
  refute [ -e "${FAKE_DIR}/gh-calls" ]
}

@test "the attestation is verified against the repository and the digest of the image with the given tag" {
  add_image "${IMAGE_ALPHA}" "${FAKE_DIGEST_ALPHA}"

  IMAGES="${IMAGE_ALPHA}" run_script

  assert_success
  run cat "${FAKE_DIR}/docker-calls"
  assert_line "buildx imagetools inspect ${IMAGE_ALPHA}:9.9.9-fake --format {{json .}}"
  run cat "${FAKE_DIR}/gh-calls"
  assert_line --regexp "^attestation verify --repo fake-owner/fake-repo --signer-workflow \\S+ oci://${IMAGE_ALPHA}@${FAKE_DIGEST_ALPHA} --format json --jq "
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
  GITHUB_OUTPUT="${FAKE_DIR}/action-output" IMAGES="" run_script

  assert_success
  assert_output --partial "nothing to upload"
  refute [ -e "${FAKE_DIR}/gh-calls" ]
  run cat "${FAKE_DIR}/action-output"
  assert_output "asset-names=[]"
}

@test "SBOM verification fails without images" {
  IMAGES="" SBOM_DIRECTORY="${FAKE_DIR}/sboms" run_script

  assert_failure
  assert_output --partial "no images given for SBOM verification"
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
