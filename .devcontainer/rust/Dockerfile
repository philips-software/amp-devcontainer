# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-base:edge
FROM ${BASE_IMAGE}

ARG BASE_VERSION=unknown

ARG CARGO_BINSTALL_VERSION=1.15.11
ARG RUST_VERSION=1.91.1

ARG AMP_DEVCONTAINER_VERSION=local

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the base system with all tool dependencies
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/rust/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
 apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | xargs apt-get install -y --no-install-recommends

# Install rust
ENV BINSTALL_DISABLE_TELEMETRY=true \
    CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:"$PATH" \
    AMP_DEVCONTAINER_BASE_VERSION=${BASE_VERSION} \
    AMP_DEVCONTAINER_VERSION=${AMP_DEVCONTAINER_VERSION}
RUN rustup set profile minimal \
 && rustup default ${RUST_VERSION} \
 && rustup component add clippy llvm-tools rustfmt \
 && rustup target add thumbv7em-none-eabi \
 && rustup target add thumbv7em-none-eabihf

# Install additional rust tools
RUN wget -qO - "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-$(uname -m)-unknown-linux-gnu.tgz" | tar xz -C "/usr/bin" \
 && cargo-binstall -y --locked cargo-binutils@0.3.6 cargo-mutants@25.3.1 flip-link@0.1.12 probe-rs-tools@0.30.0
