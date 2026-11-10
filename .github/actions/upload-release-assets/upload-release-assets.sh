#!/usr/bin/env bash
# Verify the attestations of released container images and upload them, together with the
# tool inventories and optionally the SBOMs of the images, to a GitHub release, see README.md.
#
# Everything is verified and collected before anything is uploaded. An interrupted upload
# can be retried while the release is a draft.
#
# Environment:
#   RELEASE_TAG          release to upload to, also used as the tag of the images
#   IMAGES               newline-separated image references, without tag
#   INVENTORY_DIRECTORY  directory with tool-inventory-<image-basename>/tool-inventory.json (default: .)
#   SBOM_DIRECTORY       optional directory containing SBOMs produced by anchore/sbom-action
#   GH_REPO              repository (<owner>/<name>) of the release, the attestations are verified against it
#   SIGNER_WORKFLOW      workflow (<owner>/<repository>/<path>) that signed the attestations, which is not
#                        in GH_REPO when the images are built by a re-usable workflow of another repository

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}
repository=${GH_REPO:?GH_REPO required}
signer_workflow=${SIGNER_WORKFLOW:?signer workflow required}
images=${IMAGES-}
inventory_directory=${INVENTORY_DIRECTORY:-.}
sbom_directory=${SBOM_DIRECTORY:-}
owner=${repository%%/*}

work_directory=$(mktemp -d)
trap 'rm -rf "${work_directory}"' EXIT

assets=()
seen=()
seen_sboms=()
while IFS= read -r image; do
  image=${image//[[:space:]]/}
  [[ -n "${image}" ]] || continue

  basename=${image##*/}
  if [[ " ${seen[*]-} " == *" ${basename} "* ]]; then
    echo "error: more than one image with the basename: ${basename}" >&2
    exit 1
  fi
  seen+=("${basename}")

  inventory="${inventory_directory}/tool-inventory-${basename}/tool-inventory.json"
  if [[ ! -f "${inventory}" ]]; then
    echo "error: tool inventory not found: ${inventory}" >&2
    exit 1
  fi

  digest=$(docker buildx imagetools inspect "${image}:${release_tag}" --format '{{json .}}' \
    | jq -er '.manifest.digest // .manifests[0].digest')
  asset_name="${owner}-${basename}_${digest//:/_}"

  if [[ -n "${sbom_directory}" ]]; then
    # Match the artifact name produced by anchore/sbom-action for the image and digest.
    sbom_name="${image}@${digest}"
    if [[ "${sbom_name}" == */*/* ]]; then
      sbom_name=${sbom_name#*/}
    fi
    sbom_name=${sbom_name//\//-}
    sbom_name="${sbom_name//[^a-zA-Z0-9-]/_}.spdx.json"
    if [[ " ${seen_sboms[*]-} " == *" ${sbom_name} "* ]]; then
      echo "error: more than one image has the SBOM artifact name: ${sbom_name}" >&2
      exit 1
    fi
    seen_sboms+=("${sbom_name}")

    sbom="${sbom_directory}/${sbom_name}"
    if [[ ! -s "${sbom}" ]]; then
      echo "error: SBOM not found or empty: ${sbom}" >&2
      exit 1
    fi
    if ! jq -es 'length == 1 and (.[0] | type == "object" and
      (.spdxVersion | type == "string" and startswith("SPDX-")))' "${sbom}" > /dev/null; then
      echo "error: invalid SPDX SBOM JSON object: ${sbom}" >&2
      exit 1
    fi
    cp "${sbom}" "${work_directory}/${sbom_name}"
    assets+=("${work_directory}/${sbom_name}")
  fi

  # The attestation is verified, and written as the in-toto statement it contains
  gh attestation verify --repo "${repository}" --signer-workflow "${signer_workflow}" "oci://${image}@${digest}" --format json \
    --jq '.[] | .attestation.bundle.dsseEnvelope | select(.payloadType == "application/vnd.in-toto+json").payload' \
    | base64 -d | jq . > "${work_directory}/${asset_name}.intoto.jsonl"
  if [[ ! -s "${work_directory}/${asset_name}.intoto.jsonl" ]]; then
    echo "error: no in-toto attestation found for ${image}@${digest}" >&2
    exit 1
  fi
  cp "${inventory}" "${work_directory}/${asset_name}.tool-inventory.json"

  assets+=("${work_directory}/${asset_name}.intoto.jsonl" "${work_directory}/${asset_name}.tool-inventory.json")
done <<< "${images}"

if [[ ${#assets[@]} -eq 0 ]]; then
  if [[ -n "${sbom_directory}" ]]; then
    echo "error: no images given for SBOM verification" >&2
    exit 1
  fi
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf 'asset-names=[]\n' >> "${GITHUB_OUTPUT}"
  fi
  echo "no images given, nothing to upload"
  exit 0
fi

gh release upload --clobber "${release_tag}" "${assets[@]}"

asset_names=()
for asset in "${assets[@]}"; do
  asset_names+=("${asset##*/}")
done
expected_assets=$(jq -nc '$ARGS.positional' --args "${asset_names[@]}")

if [[ -n "${sbom_directory}" ]]; then
  EXPECTED_ASSETS="${expected_assets}" bash "$(dirname "${BASH_SOURCE[0]}")/verify-release-assets.sh"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  printf 'asset-names=%s\n' "${expected_assets}" >> "${GITHUB_OUTPUT}"
fi
