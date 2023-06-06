FROM ubuntu@sha256:ac58ff7fe25edc58bdf0067ca99df00014dbd032e2246d30a722fa348fd799a5

ARG BATS_VERSION=1.9.0
ARG CLANG_VERSION=15
ARG DOCKER_VERSION=24.0.0
ARG GCC_VERSION=10
ARG MULL_VERSION=0.20.0
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.19

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the base system with all tool dependencies
COPY .devcontainer/base/apt-requirements.json /tmp/apt-requirements-base.json
COPY .devcontainer/gcc-${GCC_VERSION}/apt-requirements.json /tmp/apt-requirements-gcc.json
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -s '.[0] * .[1]' /tmp/apt-requirements-base.json /tmp/apt-requirements-gcc.json > /tmp/apt-requirements.json \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements.json | xargs apt-get install -y --no-install-recommends \
 && rm /tmp/apt-requirements* \
 && rm -rf /var/lib/apt/lists/*

# Include the Cisco Umbrella PKI Root
RUN wget -qO /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && update-ca-certificates

# Install some tools via pip to get more recent versions
RUN python3 -m pip --no-cache-dir install \
  cmake==3.26.3 \
  gcovr==6.0

# Set default generator for CMake to Ninja
ENV CMAKE_GENERATOR="Ninja"

# Install clang toolchain
COPY .devcontainer/clang-${CLANG_VERSION}/apt-requirements.json /tmp/apt-requirements-clang.json
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot-keyring.gpg] http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null \
 && apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-clang.json | xargs apt-get install -y --no-install-recommends \
 && rm /tmp/apt-requirements* \
 && rm -rf /var/lib/apt/lists/*
ENV PATH="$PATH:/usr/lib/llvm-${CLANG_VERSION}/bin"

# Compile and install additional clang tools now that we have a clang toolchain
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev libsqlite3-dev \
 && wget -qO - https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang-${CLANG_VERSION} CXX=clang++-${CLANG_VERSION} cmake -S /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} -B /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
 && cmake --build /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
 && cmake --build /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build --target install \
 && rm -rf /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} \
 && git -C /tmp clone --recurse-submodules -b ${MULL_VERSION} https://github.com/mull-project/mull.git \
 && CC=clang-${CLANG_VERSION} CXX=clang++-${CLANG_VERSION} cmake -S /tmp/mull -B /tmp/mull/build \
 && cmake --build /tmp/mull/build \
 && cmake --build /tmp/mull/build --target install \
 && rm -rf /tmp/mull \
 && apt-get purge -y libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev libsqlite3-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install arm-gcc toolchain
COPY .devcontainer/gcc-${GCC_VERSION}/install-arm-none-eabi.sh /tmp/install-arm-none-eabi.sh
RUN /tmp/install-arm-none-eabi.sh && rm /tmp/install-arm-none-eabi.sh
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

# Update all tools alternatives to the correct version
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-${GCC_VERSION} 20 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-${GCC_VERSION} 20 \
 && update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION} 10 \
 && update-alternatives --install /usr/bin/iwyu iwyu /usr/local/bin/include-what-you-use 10 \
 && update-alternatives --install /usr/bin/mull-runner mull-runner /usr/local/bin/mull-runner-${CLANG_VERSION} 10 \
 && update-alternatives --install /usr/lib/mull-ir-frontend mull-ir-frontend /usr/local/lib/mull-ir-frontend-${CLANG_VERSION} 10 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10
