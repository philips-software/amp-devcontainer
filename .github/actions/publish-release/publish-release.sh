#!/usr/bin/env bash
# Publish a draft release after checking that its assets are there, see README.md.
#
# Environment:
#   RELEASE_TAG      tag of the release to publish
#   EXPECTED_ASSETS  JSON array with the names of the assets that the release has to have
#   GH_REPO          repository (<owner>/<name>) of the release
#   GH_TOKEN         token that can edit the release

set -Eeuo pipefail

script_directory=${BASH_SOURCE[0]%/*}
release_tag=${RELEASE_TAG:?release tag required}

# Also for a release that is published by hand in the meantime, so a missing asset is noticed
RELEASE_TAG="${release_tag}" bash "${script_directory}/../upload-release-assets/verify-release-assets.sh"

is_draft=$(gh release view "${release_tag}" --json isDraft --jq '.isDraft')
case "${is_draft}" in
  true) gh release edit "${release_tag}" --draft=false --verify-tag ;;
  false) echo "release ${release_tag} is already published" ;;
  *) echo "error: unexpected draft state of release ${release_tag}: ${is_draft}" >&2; exit 1 ;;
esac
