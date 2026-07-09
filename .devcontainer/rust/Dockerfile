# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-base:edge
FROM ${BASE_IMAGE}

ARG CARGO_BINSTALL_VERSION=1.17.9
ARG CARGO_BINUTILS_VERSION=0.3.6
ARG CARGO_MUTANTS_VERSION=25.3.1
ARG FLIP_LINK_VERSION=0.1.12
ARG PROBE_RS_TOOLS_VERSION=0.30.0
ARG RUST_VERSION=1.94.1

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

RUN --mount=type=bind,source=.devcontainer/rust/apt-requirements.json,target=/tmp/apt-requirements.json \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked <<EOF

    # Install the base system with all tool dependencies
    apt-get update && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements.json | \
        xargs apt-get install -y --no-install-recommends

    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-15 10 \
                        --slave /usr/bin/c++ c++ /usr/bin/g++-15
EOF

# Install rust
ENV BINSTALL_DISABLE_TELEMETRY=true \
    CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:"$PATH"

RUN rustup set profile minimal \
 && rustup default ${RUST_VERSION} \
 && rustup component add clippy llvm-tools rustfmt \
 && rustup target add thumbv7em-none-eabi \
 && rustup target add thumbv7em-none-eabihf

# Install additional rust tools
RUN wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-$(uname -m)-unknown-linux-gnu.tgz" | tar xz -C "/usr/bin" \
 && cargo-binstall -y --locked "cargo-binutils@${CARGO_BINUTILS_VERSION}" "cargo-mutants@${CARGO_MUTANTS_VERSION}" "flip-link@${FLIP_LINK_VERSION}" "probe-rs-tools@${PROBE_RS_TOOLS_VERSION}"

# Annotate tools that Syft cannot detect on its own with a `.note.package` ELF
# section (systemd ELF package metadata convention, see
# https://systemd.io/ELF_PACKAGE_METADATA/) so they are included in the SBOM
# generated for the image.
RUN --mount=type=bind,source=.devcontainer/scripts/add-sbom-note.sh,target=/tmp/add-sbom-note.sh <<EOF
    add_sbom_note() { bash /tmp/add-sbom-note.sh "$@"; }

    add_sbom_note cargo-binstall "${CARGO_BINSTALL_VERSION}" "pkg:cargo/cargo-binstall@${CARGO_BINSTALL_VERSION}" \
        /usr/bin/cargo-binstall
    add_sbom_note cargo-binutils "${CARGO_BINUTILS_VERSION}" "pkg:cargo/cargo-binutils@${CARGO_BINUTILS_VERSION}" \
        "${CARGO_HOME}"/bin/cargo-{cov,nm,objcopy,profdata,readobj,size,strip}
    add_sbom_note cargo-mutants "${CARGO_MUTANTS_VERSION}" "pkg:cargo/cargo-mutants@${CARGO_MUTANTS_VERSION}" \
        "${CARGO_HOME}/bin/cargo-mutants"
    add_sbom_note flip-link "${FLIP_LINK_VERSION}" "pkg:cargo/flip-link@${FLIP_LINK_VERSION}" \
        "${CARGO_HOME}/bin/flip-link"
    add_sbom_note probe-rs-tools "${PROBE_RS_TOOLS_VERSION}" "pkg:cargo/probe-rs-tools@${PROBE_RS_TOOLS_VERSION}" \
        "${CARGO_HOME}"/bin/probe-rs "${CARGO_HOME}"/bin/cargo-embed "${CARGO_HOME}"/bin/cargo-flash
EOF
