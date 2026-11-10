#!/usr/bin/env bash
# Check that the draft release of a tag exists, see README.md.
#
# release-please creates the tag, which starts the release workflow, before it creates the
# draft release. Wait for a minute for the release, and fail now instead of after the build.
#
# Environment:
#   RELEASE_TAG  tag of the release
#   GH_REPO      repository (<owner>/<name>) of the release
#   GH_TOKEN     token that can see a draft release, which needs write access

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}

for _ in 1 2 3 4 5 6; do
  if is_draft=$(gh release view "${release_tag}" --json isDraft --jq '.isDraft'); then
    case "${is_draft}" in
      true) exit 0 ;;
      false) echo "::error::Release ${release_tag} is already published, its assets can't be changed anymore"; exit 1 ;;
      *) echo "::error::Unexpected draft state of release ${release_tag}: ${is_draft}"; exit 1 ;;
    esac
  fi
  sleep 10
done

echo "::error::No release found for ${release_tag}, create the draft with 'gh release create ${release_tag} --draft --verify-tag --title ${release_tag} --notes \"\"' and run the failed jobs again"
exit 1
