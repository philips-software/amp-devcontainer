FROM ubuntu:22.04@sha256:8eab65df33a6de2844c9aefd19efe8ddb87b7df5e9185a4ab73af936225685bb

ARG BATS_VERSION=1.10.0
ARG CCACHE_VERSION=4.8.3
ARG CLANG_VERSION=16
ARG DOCKER_VERSION=24.0.6
ARG MULL_VERSION=main
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.20
ARG XWIN_VERSION=0.5.0

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the base system with all tool dependencies
COPY .devcontainer/apt-requirements-base.json /tmp/apt-requirements-base.json
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | xargs apt-get install -y --no-install-recommends \
 && rm /tmp/apt-requirements-base.json \
 && rm -rf /var/lib/apt/lists/*

# Include the Cisco Umbrella PKI Root
RUN wget -qO /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && update-ca-certificates

# Install some tools via pip to get more recent versions
COPY .devcontainer/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt \
 && rm -rf /tmp/requirements.txt

# Set default generator for CMake to Ninja
ENV CMAKE_GENERATOR="Ninja"

# Install clang toolchain
COPY .devcontainer/apt-requirements-clang.json /tmp/apt-requirements-clang.json
# hadolint ignore=SC1091
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot-keyring.gpg \
 && UBUNTU_CODENAME=$(. /etc/os-release; echo "${UBUNTU_CODENAME/*, /}") \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot-keyring.gpg] http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null \
 && apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-clang.json | xargs apt-get install -y --no-install-recommends \
 && rm /tmp/apt-requirements* \
 && rm -rf /var/lib/apt/lists/*
ENV PATH="$PATH:/usr/lib/llvm-${CLANG_VERSION}/bin"

# Compile and install additional clang tools now that we have a clang toolchain
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev libsqlite3-dev \
 && wget -qO - https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -S /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} -B /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
 && cmake --build /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build --target install \
 && rm -rf /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} \
 && git -C /tmp clone --recurse-submodules -b ${MULL_VERSION} https://github.com/mull-project/mull.git \
 && CC=clang CXX=clang++ cmake -S /tmp/mull -B /tmp/mull/build \
 && cmake --build /tmp/mull/build --target install \
 && rm -rf /tmp/mull \
 && apt-get purge -y libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev libsqlite3-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install ccache from source for a recent version
RUN wget -qO - https://github.com/ccache/ccache/archive/refs/tags/v${CCACHE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -S /tmp/ccache-${CCACHE_VERSION} -B /tmp/ccache-${CCACHE_VERSION}/build \
 && cmake --build /tmp/ccache-${CCACHE_VERSION}/build --target install \
 && rm -rf /tmp/ccache-${CCACHE_VERSION}

# Install arm-gcc toolchain
RUN mkdir /opt/gcc-arm-none-eabi \
 && wget -qO - "https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-$(uname -m)-arm-none-eabi.tar.xz" | tar --exclude='*arm-none-eabi-gdb*' --exclude='share' --strip-components=1 -xJC /opt/gcc-arm-none-eabi
ENV PATH="$PATH:/opt/gcc-arm-none-eabi/bin"

# Install docker-cli for Docker-from-Docker tools
RUN wget -qO - "https://download.docker.com/linux/static/stable/$(uname -m)/docker-${DOCKER_VERSION}.tgz" | tar xz -C /tmp \
 && mv /tmp/docker/docker /usr/local/bin/ \
 && rm -rf /tmp/docker

# Install bats
RUN batstmp="$(mktemp -d /tmp/bats-core-${BATS_VERSION}.XXXX)" \
 && wget -qO - https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz | tar xz -C "${batstmp}" \
 && bash "${batstmp}/bats-core-${BATS_VERSION}/install.sh" /usr/local \
 && rm -rf "${batstmp}" \
 && git -C /usr/local clone -b v0.3.0 https://github.com/bats-core/bats-support.git \
 && git -C /usr/local clone -b v2.1.0 https://github.com/bats-core/bats-assert.git

# Install xwin
RUN wget -qO - "https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl.tar.gz" | tar -xzv -C /usr/local/bin --strip-components=1 "xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl/xwin"

# Update all tool alternatives to the correct version
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 20 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 20 \
 && update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-12 10 \
 && update-alternatives --install /usr/bin/iwyu iwyu /usr/local/bin/include-what-you-use 10 \
 && update-alternatives --install /usr/bin/mull-runner mull-runner /usr/local/bin/mull-runner-${CLANG_VERSION} 10 \
 && update-alternatives --install /usr/lib/mull-ir-frontend mull-ir-frontend /usr/local/lib/mull-ir-frontend-${CLANG_VERSION} 10 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10
