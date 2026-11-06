#!/usr/bin/env bash

set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
source "${ROOT}/.devcontainer/base/apt-snapshot.sh"
SNAPSHOT=${1:-$(date -u -d yesterday +%Y%m%dT000000Z)}
validate_snapshot "${SNAPSHOT}"
DOCKERFILE="${ROOT}/.devcontainer/base/Dockerfile"
CURRENT=$(sed -n 's/^ARG UBUNTU_SNAPSHOT=//p' "${DOCKERFILE}")
validate_snapshot "${CURRENT}"
CODENAME=${UBUNTU_CODENAME:-resolute}
TEMP=$(mktemp -d)
trap 'rm -f "${TEMP}/InRelease"; rmdir "${TEMP}"' EXIT

for SUITE in "${CODENAME}" "${CODENAME}-updates" "${CODENAME}-security" "${CODENAME}-backports"; do
    curl --fail --silent --show-error --location --retry 3 --max-time 120 \
        "https://snapshot.ubuntu.com/ubuntu/${SNAPSHOT}/dists/${SUITE}/InRelease" \
        -o "${TEMP}/InRelease"
    gpgv --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg "${TEMP}/InRelease"
    for ARCH in amd64 arm64; do
        if ! grep '^Architectures:' "${TEMP}/InRelease" | grep -qw "${ARCH}"; then
            echo "error: ${SUITE} at ${SNAPSHOT} does not advertise ${ARCH}" >&2
            exit 1
        fi
    done
done

sed -i "s/^ARG UBUNTU_SNAPSHOT=.*/ARG UBUNTU_SNAPSHOT=${SNAPSHOT}/" "${DOCKERFILE}"
printf 'Ubuntu snapshot: %s -> %s\n' "${CURRENT}" "${SNAPSHOT}"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    printf 'Ubuntu snapshot: `%s` -> `%s`. Signed metadata verified for all pockets and both architectures. Native builds, package manifests and LLVM compatibility remain CI merge gates.\n' \
        "${CURRENT}" "${SNAPSHOT}" >> "${GITHUB_STEP_SUMMARY}"
fi
