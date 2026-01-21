# syntax=docker/dockerfile:1

FROM ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54 AS extractor

ARG BATS_CORE_VERSION=1.12.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.1.0

ADD --checksum=sha256:a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb \
 https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem /cisco-umbrella-root.crt

ADD --checksum=sha256:e36b020436228262731e3319ed013d84fcd7c4bd97a1b34dee33d170e9ae6bab \
 https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_CORE_VERSION}.tar.gz /bats-core.tar.gz
ADD --checksum=sha256:7815237aafeb42ddcc1b8c698fc5808026d33317d8701d5ec2396e9634e2918f \
 https://github.com/bats-core/bats-support/archive/refs/tags/v${BATS_SUPPORT_VERSION}.tar.gz /bats-support.tar.gz
ADD --checksum=sha256:98ca3b685f8b8993e48ec057565e6e2abcc541034ed5b0e81f191505682037fd \
 https://github.com/bats-core/bats-assert/archive/refs/tags/v${BATS_ASSERT_VERSION}.tar.gz /bats-assert.tar.gz

RUN tar xzf /bats-core.tar.gz && mv bats-core-*/ bats-core \
 && tar xzf /bats-support.tar.gz && mv bats-support-*/ bats-support \
 && tar xzf /bats-assert.tar.gz && mv bats-assert-*/ bats-assert

FROM ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/base/apt-requirements.json,target=/tmp/apt-requirements.json \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
    --mount=from=extractor,target=/src <<EOF

   # Install the base system with all tool dependencies
   apt-get update && apt-get install -y --no-install-recommends jq
   jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements.json | \
      xargs apt-get install -y --no-install-recommends

   # Include the Cisco Umbrella PKI Root Certificate
   cp /src/cisco-umbrella-root.crt /usr/local/share/ca-certificates/
   update-ca-certificates

   # Install bats
   bash /src/bats-core/install.sh /usr/local
   cp -r /src/bats-support /usr/local/bats-support
   cp -r /src/bats-assert /usr/local/bats-assert

   # Update all tool alternatives to the correct version
   # and patch root's bashrc to include bash-completion
   update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-14 20
   cp /etc/skel/.bashrc /root/.bashrc
EOF
