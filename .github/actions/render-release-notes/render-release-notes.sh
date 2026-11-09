#!/usr/bin/env bash
# Render the placeholders in the notes of a GitHub release, see README.md.
#
# The release is only edited, once, after everything has been rendered.
#
# Environment:
#   RELEASE_TAG          release to render, also used as the tag of the images
#   IMAGES               newline-separated image references, without tag
#   INVENTORY_DIRECTORY  directory with tool-inventory-<image-basename>/tool-inventory.json (default: .)
#   TEMPLATE_FILE        optional template to apply to the notes first

set -Eeuo pipefail

# shellcheck source=render.bash
source "${BASH_SOURCE[0]%/*}/render.bash"

release_tag=${RELEASE_TAG:?release tag required}
images=${IMAGES-}
inventory_directory=${INVENTORY_DIRECTORY:-.}
template_file=${TEMPLATE_FILE-}

notes=$(gh release view "${release_tag}" --json body -q '.body')

if [[ -n "${template_file}" ]]; then
  notes=$(apply_template "${notes}" "${template_file}")
fi

values='{}'
while IFS= read -r image; do
  image=${image//[[:space:]]/}
  [[ -n "${image}" ]] || continue

  basename=${image##*/}
  digest=$(docker buildx imagetools inspect "${image}:${release_tag}" --format '{{json .}}' \
    | jq -er '.manifest.digest // .manifests[0].digest')
  tools=$(tools_table "${inventory_directory}/tool-inventory-${basename}/tool-inventory.json")

  values=$(jq -cn \
    --argjson values "${values}" \
    --argjson image "$(image_values "${basename}" "${release_tag}" "${digest}" "${tools}")" \
    '$values + $image')
done <<< "${images}"

rendered=$(render_placeholders "${notes}" "${values}")
gh release edit "${release_tag}" --notes "${rendered}"
