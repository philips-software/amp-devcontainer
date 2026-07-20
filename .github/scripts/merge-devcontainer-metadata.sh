#!/usr/bin/env bash
# Assemble the `devcontainer.metadata` image label for a flavor by concatenating
# the base image's existing metadata array with the flavor's own metadata entry.
#
# The devcontainer specification stores `devcontainer.metadata` as an *array* of
# metadata entries and leaves the property-level merge to the consuming tool
# (e.g. VS Code / the Dev Container CLI), see
# https://containers.dev/implementors/spec/#merge-logic. Because our images are
# built with `docker buildx` (not the Dev Container CLI), the base array is not
# appended automatically: a same-named label simply overwrites the inherited one.
# This script restores the spec behavior by producing `[<base...>, <flavor>]` so
# that flavor images inherit base metadata without duplicating it.
#
# Order matters: base entries come first, the flavor entry last, so that the
# flavor (and any downstream image built on top) overrides the base on merge.
#
# Usage: merge-devcontainer-metadata.sh <base-image-ref> <flavor-metadata-file>
#   <base-image-ref>       Reference of the image this flavor is built FROM.
#                          When empty, the base array defaults to [] (the flavor
#                          becomes the sole entry, matching a base-less build).
#   <flavor-metadata-file> Path to the flavor's devcontainer-metadata.json.
#
# Prints `devcontainer.metadata=<json-array>` on stdout, ready to be used as a
# `docker buildx build --label` value.
set -Eeuo pipefail

BASE_IMAGE="${1:-}"
METADATA_FILE="${2:?path to flavor devcontainer metadata file required}"

if [ ! -f "${METADATA_FILE}" ]; then
    echo "error: flavor metadata file '${METADATA_FILE}' does not exist" >&2
    exit 1
fi

# Extract the base image's existing devcontainer.metadata array. Falls back to an
# empty array when no base image is given or the base carries no such label.
base_metadata="[]"
if [ -n "${BASE_IMAGE}" ]; then
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

# Concatenate base entries with the flavor entry and emit the label value.
#
# The gsub expression adds a space after each comma to prevent `docker buildx build --label` to
# misinterpret the array and produce invalid JSON (e.g. ["x","y"] -> ["x",y]).
merged="$(jq -cr --slurpfile flavor "${METADATA_FILE}" '. + $flavor | @json | gsub("\",\""; "\", \")' <<< "${base_metadata}")"

echo "devcontainer.metadata=${merged}"
