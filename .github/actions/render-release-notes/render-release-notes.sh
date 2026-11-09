#!/usr/bin/env bash
# Render a Jinja2 template with the data of released container images and insert
# the result into the notes of a GitHub release, see README.md.
#
# The template is rendered by render.py in a container, the release is only
# edited, once, after everything has been rendered.
#
# Environment:
#   RELEASE_TAG          release to render, also used as the tag of the images
#   RENDER_IMAGE         container image with python3 and jinja2 that renders the template
#   TEMPLATE_FILE        template to render (default: default-template.md.j2 next to this script)
#   IMAGES               newline-separated image references, without tag
#   INVENTORY_DIRECTORY  directory with tool-inventory-<image-basename>/tool-inventory.json (default: .)

set -Eeuo pipefail

script_directory=${BASH_SOURCE[0]%/*}

# shellcheck source=render.bash
source "${script_directory}/render.bash"

release_tag=${RELEASE_TAG:?release tag required}
render_image=${RENDER_IMAGE:?render image required}
template_file=${TEMPLATE_FILE:-${script_directory}/default-template.md.j2}
images=${IMAGES-}
inventory_directory=${INVENTORY_DIRECTORY:-.}

if [[ ! -f "${template_file}" ]]; then
  echo "error: template file not found: ${template_file}" >&2
  exit 1
fi

# The container user is not the user of this script, so make the files readable.
work_directory=$(mktemp -d)
trap 'rm -rf "${work_directory}"' EXIT
chmod 0755 "${work_directory}"
install -m 0644 "${script_directory}/render.py" "${work_directory}/render.py"
install -m 0644 "${template_file}" "${work_directory}/template.md.j2"

data=$(jq -cn --arg tag "${release_tag}" '{release: {tag: $tag}, images: {}}')
while IFS= read -r image; do
  image=${image//[[:space:]]/}
  [[ -n "${image}" ]] || continue

  basename=${image##*/}
  if jq -e --arg name "${basename}" '.images | has($name)' <<< "${data}" > /dev/null; then
    echo "error: more than one image with the basename: ${basename}" >&2
    exit 1
  fi

  digest=$(docker buildx imagetools inspect "${image}:${release_tag}" --format '{{json .}}' \
    | jq -er '.manifest.digest // .manifests[0].digest')
  image_json=$(image_data "${image}" "${release_tag}" "${digest}" \
    "${inventory_directory}/tool-inventory-${basename}/tool-inventory.json")

  data=$(jq -c --arg name "${basename}" --argjson image "${image_json}" '.images[$name] = $image' <<< "${data}")
done <<< "${images}"
printf '%s\n' "${data}" > "${work_directory}/data.json"
chmod 0644 "${work_directory}/data.json"

rendered_file="${work_directory}/rendered.md"
docker run --rm --network none --cap-drop ALL --security-opt no-new-privileges \
  --volume "${work_directory}:/work:ro" --workdir /work \
  "${render_image}" python3 render.py template.md.j2 data.json > "${rendered_file}"

notes=$(gh release view "${release_tag}" --json body -q '.body')
notes=$(insert_after_header "${notes}" "${rendered_file}")
gh release edit "${release_tag}" --notes "${notes}"
