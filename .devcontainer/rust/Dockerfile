FROM ubuntu:24.04@sha256:3f85b7caad41a95462cf5b787d8a04604c8262cdcdf9a472b8c52ef83375fe15

ARG BATS_VERSION=1.11.0
ARG CARGO_BINSTALL_VERSION=1.6.8
ARG RUST_VERSION=1.78.0

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
ENV CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:"$PATH"
RUN rustup set profile minimal \
 && rustup default ${RUST_VERSION} \
 && rustup component add clippy llvm-tools rustfmt \
 && rustup target add thumbv7em-none-eabi

# Install bats
RUN batstmp="$(mktemp -d /tmp/bats-core-${BATS_VERSION}.XXXX)" \
 && wget -qO - "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz" | tar xz -C "${batstmp}" \
 && bash "${batstmp}/bats-core-${BATS_VERSION}/install.sh" /usr/local \
 && rm -rf "${batstmp}" \
 && git -C /usr/local clone -b v0.3.0 https://github.com/bats-core/bats-support.git \
 && git -C /usr/local clone -b v2.1.0 https://github.com/bats-core/bats-assert.git

# Update all tool alternatives to the correct version
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-13 20

# Install additional rust tools
RUN wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-$(uname -m)-unknown-linux-gnu.tgz" | tar xz -C "/usr/bin" \
 && cargo-binstall -y --locked cargo-binutils@0.3.6 cargo-mutants@24.5.0 flip-link@0.1.8 \
 # cargo-binstall can't (yet) install probe-rs-tools for aarch64, fall-back to script installation
 && wget -qO - https://github.com/probe-rs/probe-rs/releases/download/v0.24.0/probe-rs-tools-installer.sh | sh
