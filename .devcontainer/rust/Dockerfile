FROM ubuntu:22.04@sha256:1b8d8ff4777f36f19bfe73ee4df61e3a0b789caeff29caa019539ec7c9a57f95

ARG BATS_VERSION=1.10.0
ARG RUST_VERSION=1.77.2
ARG RUSTUP_INIT_VERSION=1.26.0

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the base system with all tool dependencies
COPY .devcontainer/rust/apt-requirements-base.json /tmp/apt-requirements-base.json
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | xargs apt-get install -y --no-install-recommends \
 && rm /tmp/apt-requirements-base.json \
 && rm -rf /var/lib/apt/lists/*

# Include the Cisco Umbrella PKI Root
RUN wget -qO /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && update-ca-certificates

# Install rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:"$PATH"
RUN declare -A RUSTUP_SHA \
 RUSTUP_SHA["x86_64"]="0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db" \
 RUSTUP_SHA["aarch64"]="673e336c81c65e6b16dcdede33f4cc9ed0f08bde1dbe7a935f113605292dc800" \
 && wget -qO /tmp/rustup-init "https://static.rust-lang.org/rustup/archive/${RUSTUP_INIT_VERSION}/$(uname -m)-unknown-linux-gnu/rustup-init" \
 && echo "${RUSTUP_SHA[$(uname -m)]} /tmp/rustup-init" | sha256sum -c - \
 && chmod +x /tmp/rustup-init \
 && /tmp/rustup-init -y --no-modify-path --default-toolchain=${RUST_VERSION} --component llvm-tools --target thumbv7em-none-eabi \
 && rm -rf /tmp/rustup-init

# Install bats
RUN batstmp="$(mktemp -d /tmp/bats-core-${BATS_VERSION}.XXXX)" \
 && wget -qO - "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz" | tar xz -C "${batstmp}" \
 && bash "${batstmp}/bats-core-${BATS_VERSION}/install.sh" /usr/local \
 && rm -rf "${batstmp}" \
 && git -C /usr/local clone -b v0.3.0 https://github.com/bats-core/bats-support.git \
 && git -C /usr/local clone -b v2.1.0 https://github.com/bats-core/bats-assert.git

# Update all tool alternatives to the correct version
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 20

# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends libudev-dev \
 && cargo install cargo-binutils \
 && cargo install flip-link \
 && cargo install probe-rs --features cli \
 && rm -rf "$CARGO_HOME/registry" \
 && apt-get purge -y libudev-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
