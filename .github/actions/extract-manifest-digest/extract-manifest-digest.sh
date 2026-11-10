#!/usr/bin/env bash
# Inspect a container image manifest and write its digest to GITHUB_OUTPUT, see README.md.
#
# Environment:
#   CONTAINER      fully qualified image reference, including tag
#   GITHUB_OUTPUT  file the `digest` output is appended to

set -Eeuo pipefail

container=${CONTAINER:?container required}
github_output=${GITHUB_OUTPUT:?GITHUB_OUTPUT required}

# Depending on the buildx version the digest is reported as `.manifest.digest`, or as the
# first entry of `.manifests`.
digest="$(docker buildx imagetools inspect "${container}" --format '{{json .}}' | jq -er '.manifest.digest // .manifests[0].digest')"

echo "digest=${digest}" >> "${github_output}"
