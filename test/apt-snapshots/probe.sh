#!/usr/bin/env bash

set -Eeuo pipefail

validate_snapshot() {
    local SNAPSHOT=${1:?}
    if [[ ! "${SNAPSHOT}" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] ||
        ! date -u -d "${SNAPSHOT:0:4}-${SNAPSHOT:4:2}-${SNAPSHOT:6:2} ${SNAPSHOT:9:2}:${SNAPSHOT:11:2}:${SNAPSHOT:13:2}" > /dev/null 2>&1; then
        echo "error: invalid Ubuntu snapshot timestamp: ${SNAPSHOT}" >&2
        return 1
    fi
}

ubuntu_requirements() {
    local ROOT=${1:?}
    local FLAVOR=${2:?}
    local FILES=("${ROOT}/.devcontainer/base/apt-requirements-base.json")

    case "${FLAVOR}" in
        base) ;;
        cpp | embedded-cpp)
            FILES+=("${ROOT}/.devcontainer/cpp"/apt-requirements*.json)
            if [[ "${FLAVOR}" == embedded-cpp ]]; then
                FILES+=("${ROOT}/.devcontainer/embedded-cpp/apt-requirements.json")
            fi
            ;;
        docs | rust) FILES+=("${ROOT}/.devcontainer/${FLAVOR}/apt-requirements.json") ;;
        embedded-rust) FILES+=("${ROOT}/.devcontainer/rust/apt-requirements.json") ;;
        *)
            echo "error: unsupported flavor: ${FLAVOR}" >&2
            return 1
            ;;
    esac

    jq -sr 'map(keys) | add | unique[]' "${FILES[@]}"
}

snapshot_version() {
    local PACKAGE=${1:?}
    local VERSION BEST=""
    local VERSIONS
    VERSIONS=$(apt-cache madison "${PACKAGE}") || return
    while IFS="|" read -r _ VERSION _; do
        VERSION="${VERSION//[[:space:]]/}"
        [[ -n "${VERSION}" ]] || continue
        if [[ -z "${BEST}" ]] || dpkg --compare-versions "${VERSION}" gt "${BEST}"; then
            BEST="${VERSION}"
        fi
    done <<< "${VERSIONS}"

    if [[ -z "${BEST}" ]]; then
        echo "error: ${PACKAGE} is absent from the configured Ubuntu snapshot" >&2
        return 1
    fi
    printf '%s\n' "${BEST}"
}

check_base_compatibility() {
    local PACKAGE INSTALLED AVAILABLE STATUS
    local PACKAGES
    PACKAGES=$(dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Status}\n') || return
    while IFS=$'\t' read -r PACKAGE INSTALLED STATUS; do
        [[ "${STATUS}" == installed ]] || continue
        AVAILABLE=$(snapshot_version "${PACKAGE}") || return
        if dpkg --compare-versions "${INSTALLED}" gt "${AVAILABLE}"; then
            echo "error: base package ${PACKAGE}=${INSTALLED} is newer than snapshot version ${AVAILABLE}; advance the snapshot or defer the base-image update" >&2
            return 1
        fi
    done <<< "${PACKAGES}"
}

main() {
    local SNAPSHOT=${1:?Expected snapshot timestamp}
    local FLAVOR=${2:?Expected flavor}
    local OUTPUT=${3:?Expected output directory}
    local ROOT
    ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
    validate_snapshot "${SNAPSHOT}"
    case "${FLAVOR}" in
        base | cpp | docs | embedded-cpp | rust | embedded-rust) ;;
        *) echo "error: unsupported flavor: ${FLAVOR}" >&2; return 1 ;;
    esac
    if [[ "${SNAPSHOT_PROBE:-}" != 1 || ! -f /.dockerenv || "${EUID}" != 0 ]]; then
        echo "error: run this probe only as root in a disposable Docker container with SNAPSHOT_PROBE=1" >&2
        return 1
    fi

    mkdir -p "${OUTPUT}"
    local ARCH
    ARCH=$(dpkg --print-architecture)
    case "${ARCH}" in
        amd64 | arm64) ;;
        *) echo "error: unsupported architecture: ${ARCH}" >&2; return 1 ;;
    esac
    local CODENAME
    CODENAME=$(. /etc/os-release && printf '%s' "${VERSION_CODENAME}")
    printf 'snapshot=%s\nflavor=%s\narchitecture=%s\ncodename=%s\n' \
        "${SNAPSHOT}" "${FLAVOR}" "${ARCH}" "${CODENAME}" | tee "${OUTPUT}/configuration.txt"

    cat > /etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: https://snapshot.ubuntu.com/ubuntu/${SNAPSHOT}/
Suites: ${CODENAME} ${CODENAME}-updates ${CODENAME}-security ${CODENAME}-backports
Components: main universe restricted multiverse
Architectures: ${ARCH}
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    cat > /etc/apt/apt.conf.d/99snapshot-probe <<'EOF'
Acquire::Retries "3";
APT::Update::Error-Mode "any";
Acquire::https::CaInfo "/bootstrap-ca.crt";
EOF
    apt-get update
    check_base_compatibility
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --with-new-pkgs --no-remove
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq

    local PACKAGES
    PACKAGES=$(ubuntu_requirements "${ROOT}" "${FLAVOR}")
    local REQUESTED=()
    mapfile -t REQUESTED <<< "${PACKAGES}"
    local LLVM_MAJOR
    LLVM_MAJOR=$(sed -n 's/^ARG LLVM_MAJOR_VERSION=//p' "${ROOT}/.devcontainer/cpp/Dockerfile")
    if [[ "${FLAVOR}" == cpp || "${FLAVOR}" == embedded-cpp ]]; then
        REQUESTED+=(minisign "libclang-${LLVM_MAJOR}-dev" "llvm-${LLVM_MAJOR}-dev")
    elif [[ "${FLAVOR}" == rust || "${FLAVOR}" == embedded-rust ]]; then
        REQUESTED+=(minisign)
    fi

    local PACKAGE VERSION
    for PACKAGE in "${REQUESTED[@]}"; do
        VERSION=$(snapshot_version "${PACKAGE}")
        printf '%s\t%s\n' "${PACKAGE}" "${VERSION}" >> "${OUTPUT}/expected-ubuntu.tsv"
    done
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${REQUESTED[@]}"
    while IFS=$'\t' read -r PACKAGE VERSION; do
        local INSTALLED
        INSTALLED=$(dpkg-query -W -f='${Version}' "${PACKAGE}")
        if [[ "${INSTALLED}" != "${VERSION}" ]]; then
            echo "error: ${PACKAGE}: expected ${VERSION} from snapshot, installed ${INSTALLED}" >&2
            return 1
        fi
    done < "${OUTPUT}/expected-ubuntu.tsv"

    local KEY_SHA256
    KEY_SHA256=$(awk '
        /^ADD --checksum=sha256:/ {sub(/^ADD --checksum=sha256:/, ""); checksum=$1}
        /https:\/\/cli.github.com\/packages\/githubcli-archive-keyring.gpg/ {print checksum}
    ' "${ROOT}/.devcontainer/base/Dockerfile")
    if [[ ! "${KEY_SHA256}" =~ ^[[:xdigit:]]{64}$ ]]; then
        echo "error: cannot determine the pinned GitHub CLI keyring checksum" >&2
        return 1
    fi
    wget --no-hsts -qO /usr/share/keyrings/githubcli-archive-keyring.gpg \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg
    echo "${KEY_SHA256}  /usr/share/keyrings/githubcli-archive-keyring.gpg" | sha256sum --check --strict -
    cat > /etc/apt/sources.list.d/github-cli.sources <<EOF
Types: deb
URIs: https://cli.github.com/packages
Suites: stable
Components: main
Architectures: ${ARCH}
Signed-By: /usr/share/keyrings/githubcli-archive-keyring.gpg
Snapshot: no
EOF
    apt-get update
    local GH_VERSION
    GH_VERSION=$(jq -er '.gh' "${ROOT}/.devcontainer/base/apt-requirements-gh.json")
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "gh=${GH_VERSION}"
    local GH_INSTALLED
    GH_INSTALLED=$(dpkg-query -W -f='${Version}' gh)
    if [[ "${GH_INSTALLED}" != "${GH_VERSION}" ]]; then
        echo "error: GitHub CLI: expected ${GH_VERSION}, installed ${GH_INSTALLED}" >&2
        return 1
    fi
    gh --version

    if [[ "${FLAVOR}" == cpp || "${FLAVOR}" == embedded-cpp ]]; then
        local LLVM_EXPECTED LLVM_ACTUAL
        LLVM_EXPECTED=$(sed -n 's/^ARG LLVM_VERSION=//p' "${ROOT}/.devcontainer/cpp/Dockerfile")
        LLVM_ACTUAL=$("clang-${LLVM_MAJOR}" --version | sed -n 's/.*clang version \([0-9][0-9.]*\).*/\1/p')
        if [[ "${LLVM_EXPECTED}" != "${LLVM_ACTUAL}" ]]; then
            echo "error: snapshot Clang ${LLVM_ACTUAL} differs from Windows LLVM runtime ${LLVM_EXPECTED}; update its version and checksums together" >&2
            return 1
        fi
        printf 'int main() { return 0; }\n' | "clang++-${LLVM_MAJOR}" -x c++ - -o /tmp/snapshot-smoke
        /tmp/snapshot-smoke
    fi
    if [[ "${FLAVOR}" == docs ]]; then
        printf 'digraph { snapshot -> validated }\n' | dot -Tsvg > "${OUTPUT}/graphviz.svg"
    fi
    if [[ "${FLAVOR}" == rust || "${FLAVOR}" == embedded-rust ]]; then
        rustup --version
    fi
    dpkg-query -W -f='${binary:Package}\t${Version}\t${Architecture}\n' \
        | sort > "${OUTPUT}/installed-packages.tsv"
    echo "Ubuntu snapshot proof passed for ${FLAVOR}/${ARCH}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
