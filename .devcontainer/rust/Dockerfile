# syntax=docker/dockerfile:1

FROM ubuntu:24.04@sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252 AS extractor

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

FROM ubuntu:24.04@sha256:66460d557b25769b102175144d538d88219c077c678a49af4afca6fbfc1b5252

ARG CARGO_BINSTALL_VERSION=1.15.1
ARG RUST_VERSION=1.89.0

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
RUN wget -qO /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && update-ca-certificates

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
RUN wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-$(uname -m)-unknown-linux-gnu.tgz" | tar xz -C "/usr/bin" \
 && cargo-binstall -y --locked cargo-binutils@0.3.6 cargo-mutants@25.3.1 flip-link@0.1.10 probe-rs-tools@0.29.1
