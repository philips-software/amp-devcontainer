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

snapshot_version() {
    local PACKAGE=${1:?}
    local VERSION BEST="" VERSIONS
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
    local PACKAGE INSTALLED AVAILABLE STATUS PACKAGES
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

configure_snapshot() {
    local SNAPSHOT=${1:?}
    validate_snapshot "${SNAPSHOT}"
    if [[ "${EUID}" != 0 ]]; then
        echo "error: configuring Ubuntu snapshots requires root" >&2
        return 1
    fi
    sed -i -E \
        "s|^URIs:.*|URIs: https://snapshot.ubuntu.com/ubuntu/${SNAPSHOT}/|" \
        /etc/apt/sources.list.d/ubuntu.sources
    cat > /etc/apt/apt.conf.d/50snapshot <<'EOF'
Acquire::Retries "3";
Acquire::http::Timeout "60";
Acquire::https::Timeout "60";
APT::Update::Error-Mode "any";
EOF
    printf '%s\n' "${SNAPSHOT}" > /etc/apt/ubuntu-snapshot
    apt-get update
    check_base_compatibility
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --with-new-pkgs --no-remove
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_snapshot "$@"
fi
