#!/usr/bin/env bash
# Verify that a published release is immutable, see README.md.
#
# The release attestation is created after the release is published, so retry for a short while.
#
# Environment:
#   RELEASE_TAG  tag of the release
#   GH_REPO      repository (<owner>/<name>) of the release
#   GH_TOKEN     token that can read the release and its attestation

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}

for attempt in 1 2 3 4 5; do
  gh release verify "${release_tag}" && exit 0
  sleep $((attempt * 10))
done

echo "::error::Release ${release_tag} is not immutable, enable immutable releases in the repository settings"
exit 1
