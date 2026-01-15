# syntax=docker/dockerfile:1

FROM ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54 AS extractor

ARG BATS_CORE_VERSION=1.12.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.1.0

ADD --checksum=sha256:e36b020436228262731e3319ed013d84fcd7c4bd97a1b34dee33d170e9ae6bab \
 https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_CORE_VERSION}.tar.gz /bats-core.tar.gz
ADD --checksum=sha256:7815237aafeb42ddcc1b8c698fc5808026d33317d8701d5ec2396e9634e2918f \
 https://github.com/bats-core/bats-support/archive/refs/tags/v${BATS_SUPPORT_VERSION}.tar.gz /bats-support.tar.gz
ADD --checksum=sha256:98ca3b685f8b8993e48ec057565e6e2abcc541034ed5b0e81f191505682037fd \
 https://github.com/bats-core/bats-assert/archive/refs/tags/v2.1.0.tar.gz /bats-assert.tar.gz

RUN tar xzf /bats-core.tar.gz && mv bats-core-*/ bats-core \
 && tar xzf /bats-support.tar.gz && mv bats-support-*/ bats-support \
 && tar xzf /bats-assert.tar.gz && mv bats-assert-*/ bats-assert

FROM ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54

ARG CARGO_BINSTALL_VERSION=1.15.11
ARG RUST_VERSION=1.91.1

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the base system with all tool dependencies
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/rust/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | xargs apt-get install -y --no-install-recommends

# Include the Cisco Umbrella PKI Root
# Checksum verified against official Cisco PKI website: https://www.cisco.com/security/pki/
ARG CISCO_UMBRELLA_ROOT_CA_SHA256=a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb
RUN wget --no-hsts -qO /tmp/cisco-root-ca.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && echo "${CISCO_UMBRELLA_ROOT_CA_SHA256}  /tmp/cisco-root-ca.crt" | sha256sum -c - \
 && mv /tmp/cisco-root-ca.crt /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt \
 && update-ca-certificates

# Install rust
# Note: rustup is installed from Ubuntu APT (version pinned in apt-requirements-base.json)
# and automatically verifies component signatures using its built-in trust chain.
# Components are downloaded from https://static.rust-lang.org/ and verified against
# Mozilla's root certificates and rustup's built-in signature verification.
ENV BINSTALL_DISABLE_TELEMETRY=true \
    CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:"$PATH"
RUN rustup set profile minimal \
 && rustup default ${RUST_VERSION} \
 && rustup component add clippy llvm-tools rustfmt \
 && rustup target add thumbv7em-none-eabi \
 && rustup target add thumbv7em-none-eabihf

# Install bats
RUN --mount=from=extractor,target=/src \
 bash /src/bats-core/install.sh /usr/local \
 && cp -r /src/bats-support /usr/local/bats-support \
 && cp -r /src/bats-assert /usr/local/bats-assert

# Update all tool alternatives to the correct version
# and patch root's bashrc to include bash-completion
RUN --mount=type=cache,target=/var/log,sharing=locked \
 update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-14 20 \
 && cp /etc/skel/.bashrc /root/.bashrc

# Install additional rust tools
# Checksums verified against GitHub releases: https://github.com/cargo-bins/cargo-binstall/releases/tag/v1.15.11
# This tool is specifically targeted by shai-hulud 2.0 attacks, so checksum verification is critical
# VERIFICATION: Checksums obtained by downloading the release artifacts and computing sha256sum
# x86_64: wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v1.15.11/cargo-binstall-x86_64-unknown-linux-gnu.tgz" | sha256sum
# aarch64: wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v1.15.11/cargo-binstall-aarch64-unknown-linux-gnu.tgz" | sha256sum
ARG CARGO_BINSTALL_X86_64_SHA256=c3755ef142c8f2013ead0a5a15a2d63f97947f3ac15334e044b3138272705a62
ARG CARGO_BINSTALL_AARCH64_SHA256=5b5d4bd0996461554ebc9fb8f16776279146c42c75630c64b26a064a07a4e115
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then EXPECTED_SHA256=$CARGO_BINSTALL_X86_64_SHA256; \
    elif [ "$ARCH" = "aarch64" ]; then EXPECTED_SHA256=$CARGO_BINSTALL_AARCH64_SHA256; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    wget --no-hsts -qO /tmp/cargo-binstall.tgz "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-${ARCH}-unknown-linux-gnu.tgz" && \
    echo "${EXPECTED_SHA256}  /tmp/cargo-binstall.tgz" | sha256sum -c - && \
    tar xz -C /usr/bin -f /tmp/cargo-binstall.tgz && \
    rm /tmp/cargo-binstall.tgz && \
    cargo-binstall -y --locked cargo-binutils@0.3.6 cargo-mutants@25.3.1 flip-link@0.1.12 probe-rs-tools@0.30.0
