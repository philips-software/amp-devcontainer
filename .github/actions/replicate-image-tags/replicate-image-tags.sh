#!/usr/bin/env bash
# Verify a released container image and copy it to more tags, in the same registry or in others, see README.md.
#
# Everything is resolved and verified before the first tag is written, and no tag is ever moved: a tag that
# exists with another digest fails the script, a tag that has the digest already is left alone. So an
# interrupted run can be repeated.
#
# Environment:
#   RELEASE_TAG      tag of the source image that identifies the image to copy
#   SOURCE_IMAGE     the image to copy, without tag
#   TAGS             newline-separated references with a tag to create, e.g. registry.example.invalid/my-org/my-image:1.2.3
#   SIGNER_WORKFLOW  re-usable workflow that signed the attestation of the image (optional)
#   GH_REPO          repository (<owner>/<name>) that built the image, the attestation is verified against it
#   GH_TOKEN         token that can read the release and verify its attestation
#   GITHUB_OUTPUT    file the output `digest` is appended to (optional)

set -Eeuo pipefail

release_tag=${RELEASE_TAG:?release tag required}
source_image=${SOURCE_IMAGE:?source image required}
repository=${GH_REPO:?GH_REPO required}
signer_workflow=${SIGNER_WORKFLOW-}
tags=${TAGS-}

work_directory=$(mktemp -d)
trap 'rm -rf "${work_directory}"' EXIT

# Print the digest of an image, nothing when it does not exist. Any other failure, such as a login that
# is not valid, fails: a missing tag must not be mistaken for a registry that can't be read.
digest_of() {
  local reference=${1:?} manifest

  if manifest=$(docker buildx imagetools inspect "${reference}" --format '{{json .}}' 2> "${work_directory}/inspect.log"); then
    jq -er '.manifest.digest // .manifests[0].digest' <<< "${manifest}"
  elif grep -qiE 'not found|manifest unknown|name unknown|does not exist|404' "${work_directory}/inspect.log"; then
    return 0
  else
    echo "error: ${reference} could not be inspected: $(< "${work_directory}/inspect.log")" >&2
    return 1
  fi
}

references=()
while IFS= read -r reference; do
  reference=${reference//[[:space:]]/}
  [[ -n "${reference}" ]] || continue

  # A reference has a tag in its last path component, a port in the registry is not a tag
  if [[ "${reference}" == *@* || "${reference##*/}" != *:* ]]; then
    echo "error: not an image reference with a tag: ${reference}" >&2
    exit 1
  fi
  [[ " ${references[*]-} " == *" ${reference} "* ]] || references+=("${reference}")
done <<< "${tags}"

if [[ ${#references[@]} -eq 0 ]]; then
  echo "error: no tags to copy the image to" >&2
  exit 1
fi

if is_draft=$(gh release view "${release_tag}" --json isDraft --jq '.isDraft'); then
  case "${is_draft}" in
    false) ;;
    true) echo "::error::Release ${release_tag} is a draft, refusing to replicate it"; exit 1 ;;
    *) echo "::error::Unexpected draft state of release ${release_tag}: ${is_draft}"; exit 1 ;;
  esac
else
  echo "::error::Could not read release ${release_tag} in ${repository}, refusing to replicate it" >&2
  exit 1
fi

source_digest=$(digest_of "${source_image}:${release_tag}")
if [[ -z "${source_digest}" ]]; then
  echo "error: ${source_image}:${release_tag} not found" >&2
  exit 1
fi

verify_arguments=(--repo "${repository}")
[[ -z "${signer_workflow}" ]] || verify_arguments+=(--signer-workflow "${signer_workflow}")
gh attestation verify "${verify_arguments[@]}" "oci://${source_image}@${source_digest}"

pending=()
for reference in "${references[@]}"; do
  existing=$(digest_of "${reference}")
  if [[ -z "${existing}" ]]; then
    pending+=("${reference}")
  elif [[ "${existing}" != "${source_digest}" ]]; then
    echo "error: ${reference} is ${existing}, not ${source_digest}, a tag is never moved" >&2
    exit 1
  else
    echo "${reference} is ${source_digest} already"
  fi
done

if [[ ${#pending[@]} -gt 0 ]]; then
  create_arguments=(--prefer-index=false)
  for reference in "${pending[@]}"; do
    create_arguments+=(--tag "${reference}")
  done
  docker buildx imagetools create "${create_arguments[@]}" "${source_image}@${source_digest}"
fi

# Every tag has to resolve to the verified digest, this is checked once all of them are written
for reference in "${references[@]}"; do
  actual=$(digest_of "${reference}")
  if [[ "${actual}" != "${source_digest}" ]]; then
    echo "error: ${reference} is ${actual:-missing}, expected ${source_digest}" >&2
    exit 1
  fi
done

[[ -z "${GITHUB_OUTPUT:-}" ]] || printf 'digest=%s\n' "${source_digest}" >> "${GITHUB_OUTPUT}"
