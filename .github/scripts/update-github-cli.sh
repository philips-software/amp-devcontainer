#!/usr/bin/env bash

set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
DOCKERFILE="${ROOT}/.devcontainer/base/Dockerfile"
TEMP=$(mktemp -d /tmp/update-github-cli.XXXXXX)
trap 'rm -rf "${TEMP}"' EXIT
mkdir -p "${TEMP}/lists/partial" "${TEMP}/cache/archives/partial" "${TEMP}/sources"
cat > "${TEMP}/apt.conf" <<EOF
Dir::Etc::parts "${TEMP}/sources";
Dir::Etc::main "/dev/null";
EOF
export APT_CONFIG="${TEMP}/apt.conf"

KEY_SHA256=$(awk '
    /^ADD --checksum=sha256:/ {sub(/^ADD --checksum=sha256:/, ""); checksum=$1}
    /https:\/\/cli.github.com\/packages\/githubcli-archive-keyring.gpg/ {print checksum}
' "${DOCKERFILE}")
if [[ ! "${KEY_SHA256}" =~ ^[[:xdigit:]]{64}$ ]]; then
    echo "error: cannot determine the pinned GitHub CLI keyring checksum" >&2
    exit 1
fi
curl --fail --silent --show-error --location --retry 3 --max-time 120 \
    https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "${TEMP}/keyring.gpg"
echo "${KEY_SHA256}  ${TEMP}/keyring.gpg" | sha256sum --check --strict -
cat > "${TEMP}/github-cli.sources" <<EOF
Types: deb
URIs: https://cli.github.com/packages
Suites: stable
Components: main
Architectures: amd64 arm64
Signed-By: ${TEMP}/keyring.gpg
EOF
APT_OPTIONS=(
    -o "Dir::State::lists=${TEMP}/lists"
    -o "Dir::Cache=${TEMP}/cache"
    -o "Dir::Etc::sourcelist=${TEMP}/github-cli.sources"
    -o "Dir::Etc::sourceparts=${TEMP}/sources"
    -o APT::Architectures::=amd64
    -o APT::Architectures::=arm64
    -o APT::Update::Error-Mode=any
    -o Acquire::Retries=3
    -o Acquire::https::Timeout=60
)
apt-get "${APT_OPTIONS[@]}" update
VERSION=""
for ARCH in amd64 arm64; do
    VERSIONS=$(apt-cache "${APT_OPTIONS[@]}" madison "gh:${ARCH}" | awk -F '|' '{gsub(/[[:space:]]/, "", $2); print $2}')
    BEST=""
    while IFS= read -r CANDIDATE; do
        [[ -n "${CANDIDATE}" ]] || continue
        if [[ -z "${BEST}" ]] || dpkg --compare-versions "${CANDIDATE}" gt "${BEST}"; then
            BEST="${CANDIDATE}"
        fi
    done <<< "${VERSIONS}"
    if [[ -z "${BEST}" || ! "${BEST}" =~ ^[0-9][0-9A-Za-z.+:~_-]*$ ]]; then
        echo "error: no valid GitHub CLI candidate for ${ARCH}" >&2
        exit 1
    fi
    if [[ -n "${VERSION}" && "${VERSION}" != "${BEST}" ]]; then
        echo "error: GitHub CLI candidates differ across architectures: ${VERSION} versus ${BEST}" >&2
        exit 1
    fi
    VERSION="${BEST}"
done
sed -i "s/^ARG GH_VERSION=.*/ARG GH_VERSION=${VERSION}/" "${DOCKERFILE}"
printf 'GitHub CLI candidate available for both architectures: %s\n' "${VERSION}"
