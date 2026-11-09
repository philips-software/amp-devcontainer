#!/usr/bin/env bash
# Derive a curated tool inventory from a Syft SPDX SBOM, see README.md.
#
# Environment:
#   SBOM            path to the Syft SPDX SBOM
#   TOOL_INVENTORY  path to the inventory JSON that lists the tools
#   FLAVOR          name the inventory is reported under
#   OUTPUT_FILE     path the generated inventory is written to

set -Eeuo pipefail

sbom=${SBOM:?SBOM required}
tool_inventory=${TOOL_INVENTORY:?TOOL_INVENTORY required}
flavor=${FLAVOR:?FLAVOR required}
output_file=${OUTPUT_FILE:?OUTPUT_FILE required}

packages="$(bash "${BASH_SOURCE[0]%/*}/resolve.sh" "${tool_inventory}")"

# Keep only packages whose name is on the tool-inventory and project them
# to {name, version, purl, commands, files}. Versions come from the SBOM, so the
# inventory can never disagree with it.
inventory="$(jq -n \
  --slurpfile sbom "${sbom}" \
  --argjson allow "${packages}" \
  --arg flavor "${flavor}" '
  ($allow | with_entries(
    if .value == {} then .value = {commands: [.key]} else . end
    | .key |= ascii_downcase
  )) as $packages
  | ($packages | keys) as $names
  | [ $sbom[0].packages[]
      | select(.name != null)
      | . as $pkg
      | select($names | index($pkg.name | ascii_downcase))
      | { name: $pkg.name,
          version: $pkg.versionInfo,
          commands: ($packages[$pkg.name | ascii_downcase].commands // []),
          files: ($packages[$pkg.name | ascii_downcase].files // []),
          purl: ([ $pkg.externalRefs[]? | select(.referenceType == "purl") | .referenceLocator ] | first) } ]
  | unique_by(.name | ascii_downcase)
  | sort_by(.name | ascii_downcase)
  | { flavor: $flavor, tools: . }')"

# Fail if an included tool is absent from the SBOM. This turns a version
# bump that renames a package (e.g. clang-22 -> clang-23) or a tool that
# silently dropped out of the image into a hard, actionable CI error.
missing="$(jq -rn \
  --argjson inventory "${inventory}" \
  --argjson allow "${packages}" '
  ($inventory.tools | map(.name | ascii_downcase)) as $found
  | ($allow | keys)
  | map(select((ascii_downcase) as $name | ($found | index($name)) | not))
  | .[]')"

if [ -n "${missing}" ]; then
  echo "error: the following tools from the tool-inventory were not found in the SBOM:" >&2
  echo "${missing}" | sed 's/^/  - /' >&2
  exit 1
fi

echo "${inventory}" | tee "${output_file}"
