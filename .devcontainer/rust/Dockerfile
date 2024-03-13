FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

ARG BATS_VERSION=1.10.0
ARG RUST_VERSION=1.76.0

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
RUN wget -qO /tmp/rustup-init "https://static.rust-lang.org/rustup/dist/$(uname -m)-unknown-linux-gnu/rustup-init" \
 && chmod +x /tmp/rustup-init \
 && /tmp/rustup-init -qy --default-toolchain=${RUST_VERSION} --component llvm-tools --target thumbv7em-none-eabi \
 && rm -rf /tmp/rustup-init

# See https://github.com/moby/moby/issues/28971 why we can't use $HOME here
ENV PATH="/root/.cargo/bin:$PATH"

# Install bats
RUN batstmp="$(mktemp -d /tmp/bats-core-${BATS_VERSION}.XXXX)" \
 && wget -qO - "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz" | tar xz -C "${batstmp}" \
 && bash "${batstmp}/bats-core-${BATS_VERSION}/install.sh" /usr/local \
 && rm -rf "${batstmp}" \
 && git -C /usr/local clone -b v0.3.0 https://github.com/bats-core/bats-support.git \
 && git -C /usr/local clone -b v2.1.0 https://github.com/bats-core/bats-assert.git

# Update all tool alternatives to the correct version
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 20 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 20

# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends libudev-dev \
 && cargo install cargo-binutils \
 && cargo install probe-rs --features cli \
 && rm -rf "$HOME/.cargo/registry" \
 && apt-get purge -y libudev-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
