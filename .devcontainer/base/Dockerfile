# syntax=docker/dockerfile:1

ARG GH_VERSION=2.94.0
ARG GH_AW_VERSION=0.79.6

FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS downloader

ARG GH_VERSION
ARG GH_AW_VERSION
ARG TARGETARCH

SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
    apt-get update && apt-get install -y --no-install-recommends ca-certificates wget

    case "${TARGETARCH}" in
      amd64) GH_SHA=a757f1ba6db18f4de8cbadb244843a5f89bc75b5e7c6fc127d2bd77fbd12ed62
             GH_AW_SHA=77e69ddcda854560f827045ae59f87fdf6a07f07d5ab37a750317b3368eb6c2e ;;
      arm64) GH_SHA=705a23b70b0f1b7ba4c302fdcef392ce3edaacfa7ce8e85e4d93d72ea800a538
             GH_AW_SHA=1054d302486b6e56a27095a1b887e9ec0ffdfe009006835dcf3c6b931bf9d040 ;;
    esac

    wget --no-hsts -qO /gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz"
    echo "${GH_SHA}  /gh.tar.gz" | sha256sum -c -
    mkdir /tmp/gh && tar xzf /gh.tar.gz --strip-components=1 -C /tmp/gh
    cp /tmp/gh/bin/gh /gh

    wget --no-hsts -qO /gh-aw "https://github.com/github/gh-aw/releases/download/v${GH_AW_VERSION}/linux-${TARGETARCH}"
    echo "${GH_AW_SHA}  /gh-aw" | sha256sum -c -
    chmod +x /gh-aw
EOF

FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS extractor

ARG BATS_CORE_VERSION=1.13.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.2.4

ADD --checksum=sha256:a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb \
 https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem /cisco-umbrella-root.crt

ADD --checksum=sha256:a85e12b8828271a152b338ca8109aa23493b57950987c8e6dff97ba492772ff3 \
 https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_CORE_VERSION}.tar.gz /bats-core.tar.gz
ADD --checksum=sha256:7815237aafeb42ddcc1b8c698fc5808026d33317d8701d5ec2396e9634e2918f \
 https://github.com/bats-core/bats-support/archive/refs/tags/v${BATS_SUPPORT_VERSION}.tar.gz /bats-support.tar.gz
ADD --checksum=sha256:e305df20c4c36cba4570e10f1cd824efb1ae71d88b5ef474550781ebee04192f \
 https://github.com/bats-core/bats-assert/archive/refs/tags/v${BATS_ASSERT_VERSION}.tar.gz /bats-assert.tar.gz

RUN --mount=from=downloader,source=/gh,target=/dl/gh \
    --mount=from=downloader,source=/gh-aw,target=/dl/gh-aw \
 tar xzf /bats-core.tar.gz && mv bats-core-*/ bats-core \
 && tar xzf /bats-support.tar.gz && mv bats-support-*/ bats-support \
 && tar xzf /bats-assert.tar.gz && mv bats-assert-*/ bats-assert \
 && cp /dl/gh /gh \
 && cp /dl/gh-aw /gh-aw

FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8

HEALTHCHECK NONE

SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

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

   # Install gh and gh-aw extension
   cp /src/gh /usr/local/bin/gh
   mkdir -p /root/.local/share/gh/extensions/gh-aw
   cp /src/gh-aw /root/.local/share/gh/extensions/gh-aw/gh-aw

   # Generate locale
   sed -i '/C.UTF-8/s/^# //' /etc/locale.gen
   locale-gen

   # Patch root's bashrc to include bash-completion
   cp /etc/skel/.bashrc /root/.bashrc
EOF
