#!/usr/bin/env bash
# Verify that the expected image assets are present on a GitHub release.

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}
expected_assets=${EXPECTED_ASSETS:?expected release assets required}

if ! jq -e 'type == "array" and length > 0 and all(.[]; type == "string" and length > 0)' \
  <<< "${expected_assets}" > /dev/null; then
  echo "error: expected release assets must be a nonempty JSON array of names" >&2
  exit 1
fi

release_assets=$(gh release view "${release_tag}" --json assets)
missing_assets=$(jq -c --argjson expected "${expected_assets}" '
  if (.assets | type) != "array" then
    error("release assets response has no assets array")
  else
    .assets as $assets
    | [$expected[] | select(. as $name | all($assets[]; .name != $name or .state != "uploaded"))]
  end
' <<< "${release_assets}")

if [[ "${missing_assets}" != "[]" ]]; then
  echo "error: expected uploaded release asset not found: ${missing_assets}" >&2
  exit 1
fi
