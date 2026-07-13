#!/usr/bin/env bash
# Derive a curated, per-flavor tool inventory from a Syft SPDX SBOM.
#
# The inventory is a filtered view of the (complete) SBOM: it keeps only the
# packages whose name is listed in the flavor's allowlist and projects them to
# {name, version, purl} pairs. Because the versions come straight from the SBOM,
# the inventory can never disagree with it.
#
# The script fails if an allowlisted tool is absent from the SBOM. This turns a
# version bump that renames a package (e.g. clang-22 -> clang-23) or a tool that
# silently dropped out of the image into a hard, actionable CI error.
#
# Usage: generate-tool-inventory.sh <sbom.spdx.json> <allowlist.json> <flavor>
set -Eeuo pipefail

SBOM="${1:?path to SPDX SBOM required}"
ALLOWLIST="${2:?path to allowlist JSON required}"
FLAVOR="${3:?flavor name required}"

inventory="$(jq -n \
  --slurpfile sbom "${SBOM}" \
  --slurpfile allow "${ALLOWLIST}" \
  --arg flavor "${FLAVOR}" '
  ($allow[0] | map(ascii_downcase)) as $names
  | [ $sbom[0].packages[]
      | select(.name != null)
      | . as $pkg
      | select($names | index($pkg.name | ascii_downcase))
      | { name: $pkg.name,
          version: $pkg.versionInfo,
          purl: ([ $pkg.externalRefs[]? | select(.referenceType == "purl") | .referenceLocator ] | first) } ]
  | unique_by(.name | ascii_downcase)
  | sort_by(.name | ascii_downcase)
  | { flavor: $flavor, tools: . }')"

missing="$(jq -rn \
  --argjson inventory "${inventory}" \
  --slurpfile allow "${ALLOWLIST}" '
  ($inventory.tools | map(.name | ascii_downcase)) as $found
  | $allow[0]
  | map(select((ascii_downcase) as $name | ($found | index($name)) | not))
  | .[]')"

if [ -n "${missing}" ]; then
  echo "error: the following allowlisted tools were not found in the SBOM:" >&2
  echo "${missing}" | sed 's/^/  - /' >&2
  exit 1
fi

echo "${inventory}"
