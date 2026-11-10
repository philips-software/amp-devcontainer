#!/usr/bin/env bash
# Verify the attestations of released container images and upload them, together with the
# tool inventories of the images, to a GitHub release, see README.md.
#
# Everything is verified and collected before anything is uploaded, and all assets are
# uploaded in a single call, so a failure doesn't leave the release with a part of the assets.
#
# Environment:
#   RELEASE_TAG          release to upload to, also used as the tag of the images
#   IMAGES               newline-separated image references, without tag
#   INVENTORY_DIRECTORY  directory with tool-inventory-<image-basename>/tool-inventory.json (default: .)
#   GH_REPO              repository (<owner>/<name>) of the release, the attestations are verified against it

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}
repository=${GH_REPO:?GH_REPO required}
images=${IMAGES-}
inventory_directory=${INVENTORY_DIRECTORY:-.}
owner=${repository%%/*}

work_directory=$(mktemp -d)
trap 'rm -rf "${work_directory}"' EXIT

assets=()
seen=()
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

  # The attestation is verified, and written as the in-toto statement it contains
  gh attestation verify --repo "${repository}" "oci://${image}@${digest}" --format json \
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
  echo "no images given, nothing to upload"
  exit 0
fi

gh release upload --clobber "${release_tag}" "${assets[@]}"
