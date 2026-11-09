# syntax=docker/dockerfile:1

FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c AS extractor

ARG BATS_CORE_VERSION=1.13.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.2.4

ADD --checksum=sha256:a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb \
 https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem /cisco-umbrella-root.crt

ADD --checksum=sha256:6084d5d7bd8e288441e0e94fc6275570895da18e6751f70f057485dc2d1a811b \
 https://cli.github.com/packages/githubcli-archive-keyring.gpg /githubcli-archive-keyring.gpg

ADD --checksum=sha256:a85e12b8828271a152b338ca8109aa23493b57950987c8e6dff97ba492772ff3 \
 https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_CORE_VERSION}.tar.gz /bats-core.tar.gz
ADD --checksum=sha256:7815237aafeb42ddcc1b8c698fc5808026d33317d8701d5ec2396e9634e2918f \
 https://github.com/bats-core/bats-support/archive/refs/tags/v${BATS_SUPPORT_VERSION}.tar.gz /bats-support.tar.gz
ADD --checksum=sha256:e305df20c4c36cba4570e10f1cd824efb1ae71d88b5ef474550781ebee04192f \
 https://github.com/bats-core/bats-assert/archive/refs/tags/v${BATS_ASSERT_VERSION}.tar.gz /bats-assert.tar.gz

RUN tar xzf /bats-core.tar.gz && mv bats-core-*/ bats-core \
 && tar xzf /bats-support.tar.gz && mv bats-support-*/ bats-support \
 && tar xzf /bats-assert.tar.gz && mv bats-assert-*/ bats-assert

FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c

ARG DEBIAN_FRONTEND=noninteractive

ENV BATS_LIB_PATH=/usr/local \
    LANG=C.UTF-8

HEALTHCHECK NONE

SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/base/add-sbom-note.sh,target=/tmp/add-sbom-note.sh \
    --mount=type=bind,source=.devcontainer/base/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=bind,source=.devcontainer/base/apt-requirements-gh.json,target=/tmp/apt-requirements-gh.json \
    --mount=type=bind,source=helpers/bats-tool-inventory,target=/tmp/bats-tool-inventory \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
    --mount=from=extractor,target=/src <<EOF

   # Install the base system with all tool dependencies
   apt-get update && apt-get install -y --no-install-recommends jq
   jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | \
      xargs apt-get install -y --no-install-recommends

   # Include the Cisco Umbrella PKI Root Certificate
   install -m 0644 /src/cisco-umbrella-root.crt /usr/local/share/ca-certificates/
   update-ca-certificates

   # Install GitHub cli
   gpg --no-options --homedir /dev/null --batch \
    --trust-model always --no-default-keyring \
    --keyring /src/githubcli-archive-keyring.gpg \
    --list-keys 0x7F38BBB59D064DBCB3D84D725612B36462313325
   cat /src/githubcli-archive-keyring.gpg | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
   cat > /etc/apt/sources.list.d/github-cli.sources <<SOURCE
Types: deb
URIs: https://cli.github.com/packages
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/githubcli-archive-keyring.gpg
SOURCE
   apt-get update
   jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-gh.json | \
      xargs apt-get install -y --no-install-recommends

   # Install bats
   bash /src/bats-core/install.sh /usr/local
   # Install the bats libraries, only with the files that are needed at runtime
   for library in /src/bats-support /src/bats-assert /tmp/bats-tool-inventory; do
      install -d "/usr/local/${library##*/}/src"
      install -m 0644 -t "/usr/local/${library##*/}" "${library}"/{load.bash,package.json,LICENSE}
      install -m 0644 -t "/usr/local/${library##*/}/src" "${library}"/src/*.bash
   done

   # Retain the bats-core manifest so the tool is captured in the SBOM
   mkdir -p /usr/local/lib/bats-core
   cp /src/bats-core/package.json /usr/local/lib/bats-core/package.json

   # Install the SBOM annotation helper so downstream flavors can annotate tools
   # that Syft cannot detect on its own (see .devcontainer/base/add-sbom-note.sh)
   install -m 0755 /tmp/add-sbom-note.sh /usr/local/bin/add-sbom-note

   # Generate locale
   sed -i '/C.UTF-8/s/^# //' /etc/locale.gen
   locale-gen

   # Rename Ubuntu's default account while preserving its UID and GID.
   usermod --login code --home /home/code --move-home ubuntu
   groupmod --new-name code ubuntu

   # Ensure the developer account has a bashrc with bash-completion enabled.
   install -d -m 0755 -o code -g code /home/code
   cp /etc/skel/.bashrc /home/code/.bashrc
   chown code:code /home/code/.bashrc

   # Keep root's bashrc configured for image build and maintenance commands.
   cp /etc/skel/.bashrc /root/.bashrc
EOF

USER 1000
