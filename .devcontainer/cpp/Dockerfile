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

ARG CCACHE_VERSION=4.12
ARG CLANG_VERSION=19
ARG CPM_VERSION=0.40.2
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.23
ARG XWIN_VERSION=0.6.7

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set default environment options
ENV CCACHE_DIR=/cache/.ccache \
    CMAKE_EXPORT_COMPILE_COMMANDS="On" \
    CMAKE_GENERATOR="Ninja" \
    CONAN_HOME=/opt/conan \
    CPM_SOURCE_CACHE=/cache/.cpm \
    PATH="$PATH:/usr/lib/llvm-${CLANG_VERSION}/bin:/opt/gcc-arm-none-eabi/bin" \
    PYTHONPYCACHEPREFIX=/cache/.python

# Install the base system with all tool dependencies
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=bind,source=.devcontainer/cpp/requirements.txt,target=/tmp/requirements.txt \
    --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | \
    xargs apt-get install -y --no-install-recommends \
 # Include the Cisco Umbrella PKI Root
 # Checksum verified against official Cisco PKI website: https://www.cisco.com/security/pki/
 && wget --no-hsts -qO /tmp/cisco-root-ca.crt https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem \
 && echo "a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb  /tmp/cisco-root-ca.crt" | sha256sum -c - \
 && mv /tmp/cisco-root-ca.crt /usr/local/share/ca-certificates/Cisco_Umbrella_Root_CA.crt \
 && update-ca-certificates \
 # Install some tools via pip to get more recent versions, clean up afterwards
 && python3 -m pip install --break-system-packages --require-hashes --no-cache-dir --no-compile -r /tmp/requirements.txt \
 && find / -regex '^.*\(__pycache__\|\.py[co]\)$' -delete \
 && rm -rf "$(pip cache dir)"

# Install clang toolchain and mull mutation testing framework
# SECURITY NOTE: GPG keys are downloaded via HTTPS but fingerprints should be verified.
# Expected LLVM GPG key fingerprint: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
# Expected Mull GPG key fingerprint: Should be verified from https://cloudsmith.io/~mull-project/repos/mull-stable/
# TODO: Add GPG key fingerprint verification (see docs/SECURITY_ANALYSIS.md)
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-clang.json,target=/tmp/apt-requirements-clang.json \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
 wget --no-hsts -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot-keyring.gpg \
 && wget --no-hsts -qO - https://dl.cloudsmith.io/public/mull-project/mull-stable/gpg.41DB35380DE6BD6F.key | gpg --dearmor -o /usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg \
 && UBUNTU_CODENAME=$(grep '^UBUNTU_CODENAME=' /etc/os-release | cut -d= -f2) \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot-keyring.gpg] http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null \
 && echo "deb [signed-by=/usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/mull-project/mull-stable/deb/ubuntu ${UBUNTU_CODENAME} main" | tee /etc/apt/sources.list.d/mull-project-mull-stable.list > /dev/null \
 && echo -e 'Package: *\nPin: origin "apt.llvm.org"\nPin-Priority: 1000' > /etc/apt/preferences \
 && apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-clang.json | xargs apt-get install -y --no-install-recommends

# Install arm-gcc toolchain
# SECURITY NOTE: This download currently lacks checksum verification.
# Official checksums should be obtained from: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
# The ARM website provides checksums in their release notes. This should be updated to verify checksums
# before extraction to prevent supply-chain attacks. See docs/SECURITY_ANALYSIS.md for details.
# TODO: Add checksum verification for ARM GCC toolchain downloads
RUN mkdir /opt/gcc-arm-none-eabi \
 && wget --no-hsts -qO - "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-$(uname -m)-arm-none-eabi.tar.xz" | tar --exclude='*arm-none-eabi-gdb*' --exclude='share' --strip-components=1 -xJC /opt/gcc-arm-none-eabi

# Install bats
RUN --mount=from=extractor,target=/src \
 bash /src/bats-core/install.sh /usr/local \
 && cp -r /src/bats-support /usr/local/bats-support \
 && cp -r /src/bats-assert /usr/local/bats-assert

# Install xwin and ccache
# Checksums verified against GitHub releases
# xwin: https://github.com/Jake-Shadle/xwin/releases/tag/0.6.7
# ccache: https://github.com/ccache/ccache/releases/tag/v4.12
# VERIFICATION: Checksums obtained by downloading the release artifacts and computing sha256sum
# Examples:
#   wget -qO - "https://github.com/Jake-Shadle/xwin/releases/download/0.6.7/xwin-0.6.7-x86_64-unknown-linux-musl.tar.gz" | sha256sum
#   wget -qO - "https://github.com/ccache/ccache/releases/download/v4.12/ccache-4.12-linux-x86_64.tar.xz" | sha256sum
ARG XWIN_X86_64_SHA256=0a2411665ba8cce7d841528566d2eedc7c88dccb12b087aac394811c61e6751b
ARG XWIN_AARCH64_SHA256=33c6bc0d777df45229a0c9d84b51ae621238445fe6ac7ed6e95ecbaf598c5ff1
ARG CCACHE_X86_64_SHA256=d77e140d0403175b93f979f0b0d36e821bf31728b282f4bfda939f65836bcabe
ARG CCACHE_AARCH64_SHA256=378ed4b9f645f5aab691447e4ec45b4c68508a424ac37c9be7baa28ded385791
RUN ARCH=$(uname -m) && \
    # Install xwin
    if [ "$ARCH" = "x86_64" ]; then XWIN_SHA256=$XWIN_X86_64_SHA256; \
    elif [ "$ARCH" = "aarch64" ]; then XWIN_SHA256=$XWIN_AARCH64_SHA256; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    wget --no-hsts -qO /tmp/xwin.tar.gz "https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" && \
    echo "${XWIN_SHA256}  /tmp/xwin.tar.gz" | sha256sum -c - && \
    tar -xzv -C /usr/local/bin --strip-components=1 -f /tmp/xwin.tar.gz "xwin-${XWIN_VERSION}-${ARCH}-unknown-linux-musl/xwin" && \
    rm /tmp/xwin.tar.gz && \
    # Install ccache
    if [ "$ARCH" = "x86_64" ]; then CCACHE_SHA256=$CCACHE_X86_64_SHA256; \
    elif [ "$ARCH" = "aarch64" ]; then CCACHE_SHA256=$CCACHE_AARCH64_SHA256; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    wget --no-hsts -qO /tmp/ccache.tar.xz "https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}-linux-${ARCH}.tar.xz" && \
    echo "${CCACHE_SHA256}  /tmp/ccache.tar.xz" | sha256sum -c - && \
    tar -xJ -C /usr/local/bin --strip-components=1 -f /tmp/ccache.tar.xz "ccache-${CCACHE_VERSION}-linux-${ARCH}/ccache" && \
    rm /tmp/ccache.tar.xz

# Install include-what-you-use (iwyu) from source
# Checksum verified against GitHub release: https://github.com/include-what-you-use/include-what-you-use/releases/tag/0.23
# hadolint ignore=DL3008
ARG INCLUDE_WHAT_YOU_USE_SHA256=16672743fdf781d7db313f48c7f4b34bc6517eddfd92d7db793790fe793a306c
RUN --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && wget --no-hsts -qO /tmp/iwyu.tar.gz https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz \
 && echo "${INCLUDE_WHAT_YOU_USE_SHA256}  /tmp/iwyu.tar.gz" | sha256sum -c - \
 && tar xz -C /tmp -f /tmp/iwyu.tar.gz \
 && rm /tmp/iwyu.tar.gz \
 && CC=clang CXX=clang++ cmake -S /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} -B /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
 && cmake --build /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build --target install \
 && rm -rf /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} \
 && apt-get purge -y libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && apt-get autoremove -y \
 && apt-get clean

# Update all tool alternatives to the correct version
# and patch root's bashrc to include bash-completion
RUN --mount=type=cache,target=/var/log,sharing=locked \
 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 10 \
                        --slave /usr/bin/g++ g++ /usr/bin/g++-14 \
                        --slave /usr/bin/gcov gcov /usr/bin/gcov-14 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-14 10 \
                        --slave /usr/bin/c++ c++ /usr/bin/g++-14 \
 && update-alternatives --install /usr/bin/iwyu iwyu /usr/local/bin/include-what-you-use 10 \
 && update-alternatives --install /usr/bin/mull-runner mull-runner /usr/bin/mull-runner-${CLANG_VERSION} 10 \
                        --slave /usr/bin/mull-reporter mull-reporter /usr/bin/mull-reporter-${CLANG_VERSION} \
                        --slave /usr/lib/mull-ir-frontend mull-ir-frontend /usr/lib/mull-ir-frontend-${CLANG_VERSION} \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
 && mkdir /root/.amp \
 && cp /etc/skel/.bashrc /root/.bashrc

# Set up package managers CPM and Conan
# - Install CPM.cmake to the CMake module path
# - Configure a default profile for Conan and set the CMake generator to Ninja
# Checksum verified against GitHub release: https://github.com/cpm-cmake/CPM.cmake/releases/tag/v0.40.2
ARG CPM_SHA256=c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d
RUN --mount=type=cache,target=/cache,sharing=locked \
 wget --no-hsts -qO /tmp/CPM.cmake https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_VERSION}/CPM.cmake \
 && echo "${CPM_SHA256}  /tmp/CPM.cmake" | sha256sum -c - \
 && cp /tmp/CPM.cmake /usr/local/lib/python*/dist-packages/cmake/data/share/cmake-*/Modules/ \
 && rm /tmp/CPM.cmake \
 && conan profile detect \
 && echo -e "\n[conf]\ntools.cmake.cmaketoolchain:generator=Ninja" >> "$(conan profile path default)"
