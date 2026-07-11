#!/usr/bin/env bash
# Annotate ELF binaries with a systemd `.note.package` section so that Syft
# includes them in the generated SBOM (see https://systemd.io/ELF_PACKAGE_METADATA/).
#
# This is used for tools that are installed outside of a package manager (e.g.
# downloaded release binaries) and that Syft cannot otherwise detect. Binaries
# that do not exist are skipped; if none of the given binaries exist the script
# fails so that a renamed or dropped tool becomes a hard build error.
#
# Usage: add-sbom-note.sh <name> <version> <purl> <binary>...
set -Eeuo pipefail

name="${1:?tool name required}"
version="${2:?tool version required}"
purl="${3:?tool purl required}"
shift 3

note="$(mktemp)"
trap 'rm -f "${note}"' EXIT
jq -n --arg name "${name}" --arg version "${version}" --arg purl "${purl}" '{name: $name, version: $version, purl: $purl}' > "${note}"

tagged=0
for binary in "$@"; do
    if [ -x "${binary}" ]; then
        objcopy --add-section .note.package="${note}" \
                --set-section-flags .note.package=noload,readonly "${binary}"
        tagged=1
    fi
done

[ "${tagged}" -eq 1 ] || { echo "no binaries found to annotate for ${name}" >&2; exit 1; }
