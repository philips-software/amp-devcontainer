#!/usr/bin/env bash
# Assemble the devcontainer.metadata image label of a derived image and write it to
# GITHUB_OUTPUT, see README.md.
#
# Environment:
#   BASE_IMAGE                  reference of the image this image is built FROM (optional)
#   DEVCONTAINER_METADATA_FILE  the image's own devcontainer-metadata.json (optional)
#   GITHUB_OUTPUT               file the `label` output is appended to

set -Eeuo pipefail

github_output=${GITHUB_OUTPUT:?GITHUB_OUTPUT required}

if [ -z "${DEVCONTAINER_METADATA_FILE:-}" ] || [ ! -f "${DEVCONTAINER_METADATA_FILE}" ]; then
  echo "devcontainer-metadata-file input not set or file does not exist, skipping devcontainer.metadata label"
  echo "label=" >> "${github_output}"
  exit 0
fi

# Extract the base image's existing devcontainer.metadata array. Falls back
# to an empty array when no base image is given or it carries no such label.
base_metadata="[]"
if [ -n "${BASE_IMAGE:-}" ]; then
  # `.Image` is the image config for single-platform references and a map of
  # `platform -> config` for multi-platform references; the label is identical
  # across platforms, so any entry works.
  config="$(docker buildx imagetools inspect "${BASE_IMAGE}" --format '{{json .Image}}')"
  base_metadata="$(jq -c '
    (if has("config") then . else (to_entries[0].value) end)
    | (.config.Labels["devcontainer.metadata"] // "") as $raw
    | if $raw == "" then [] else (try ($raw | fromjson) catch []) end
    | if type == "array" then . else [] end
  ' <<< "${config}")"
fi

# Concatenate the base entries with the image's own entry and emit the label value.
# The gsub adds a space after each comma so `docker buildx build --label`
# does not misinterpret the array and produce invalid JSON (e.g.
# ["x","y"] -> ["x",y]).
merged="$(jq -cr --slurpfile entry "${DEVCONTAINER_METADATA_FILE}" '. + $entry | @json | gsub("\",\""; "\", \"")' <<< "${base_metadata}")"

echo "label=devcontainer.metadata=${merged}" >> "${github_output}"
