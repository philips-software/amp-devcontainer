# syntax=docker/dockerfile:1

ARG BATS_VERSION=1.12.0
ARG DOCKER_VERSION=28.2.2
ARG XWIN_VERSION=0.6.5

FROM scratch AS downloader-amd64
ARG DOCKER_VERSION
ARG XWIN_VERSION
ADD --checksum=sha256:53dc06dc3f775282ddff93b2d0974bbe6480761018c61e7a797342a9c7f14e23 \
 https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz /docker.tgz
ADD --checksum=sha256:62a63b981fe391a9cbad7ef51b17e49aeaa3e7b0d029b36ca1e9c3b2a9b78823 \
 https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz /arm-gnu-toolchain.tar.xz
ADD --checksum=sha256:9fd53950b064d067f42428a69453b927656cae68dbd7f8d3f86dcb81c80dd22d \
 https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-x86_64-unknown-linux-musl.tar.gz /xwin.tar.gz

FROM scratch AS downloader-arm64
ARG DOCKER_VERSION
ARG XWIN_VERSION
ADD --checksum=sha256:c9506628d1845c69230df3d87e2eedd7980caf8bd966f5e6a5d7a2364de42497 \
 https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION}.tgz /docker.tgz
ADD --checksum=sha256:87330bab085dd8749d4ed0ad633674b9dc48b237b61069e3b481abd364d0a684 \
 https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-aarch64-arm-none-eabi.tar.xz /arm-gnu-toolchain.tar.xz
ADD --checksum=sha256:5e131007fad7c5f30d2f41090b49937fb8f16a787e5a95b4b3140e88d174dab2 \
 https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-aarch64-unknown-linux-musl.tar.gz /xwin.tar.gz

FROM downloader-$TARGETARCH AS downloader
ARG BATS_VERSION
ADD --checksum=sha256:ce6eee4130298f79b0e0f09a89f93c1bc711cd68e7e3182d37c8e96c5227e2f0 \
 https://apt.llvm.org/llvm-snapshot.gpg.key /llvm.gpg.key
ADD --checksum=sha256:db2938ce5fd422f2db7a07508452772c945135d99274004c462190c323fefcf1 \
 https://dl.cloudsmith.io/public/mull-project/mull-stable/gpg.41DB35380DE6BD6F.key /mull.gpg.key
ADD --checksum=sha256:e36b020436228262731e3319ed013d84fcd7c4bd97a1b34dee33d170e9ae6bab \
 https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz /bats-core.tar.gz
ADD --checksum=sha256:a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb \
 https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem /cisco-umbrella.crt
ADD https://github.com/bats-core/bats-support#v0.3.0 /
ADD https://github.com/bats-core/bats-assert#v2.1.0 /

FROM ubuntu:24.04@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f AS extractor

ARG XWIN_VERSION

WORKDIR /

# hadolint ignore=DL3008
RUN --mount=from=downloader,target=/dl \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends xz-utils \
 && tar xzf /dl/bats-core.tar.gz && mv bats-core-*/ bats-core \
 && tar xzf /dl/docker.tgz \
 && tar xzf /dl/xwin.tar.gz --strip-components=1 "xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl/xwin" \
 && tar xJf /dl/arm-gnu-toolchain.tar.xz --exclude='*arm-none-eabi-gdb*' --exclude='share' \
 && mv arm-gnu-toolchain-*/ gcc-arm-none-eabi

FROM ubuntu:24.04@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f

ARG CCACHE_VERSION=4.11
ARG CLANG_VERSION=18
ARG CPM_VERSION=0.40.2
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.22

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set default environment options for CMake, ccache, and CPM
# and update the PATH to include the toolchain binaries
ENV CMAKE_GENERATOR="Ninja" \
    CMAKE_EXPORT_COMPILE_COMMANDS="On" \
    CCACHE_DIR=/cache/.ccache \
    CONAN_HOME=/opt/conan \
    CPM_SOURCE_CACHE=/cache/.cpm-cache \
    PATH="$PATH:/usr/lib/llvm-${CLANG_VERSION}/bin:/opt/gcc-arm-none-eabi/bin"

# Install the base system with all tool dependencies
# Some tools are installed via pip to get more recent versions
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=bind,source=.devcontainer/cpp/apt-requirements-clang.json,target=/tmp/apt-requirements-clang.json \
    --mount=type=bind,source=.devcontainer/cpp/requirements.txt,target=/tmp/requirements.txt \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
    --mount=type=cache,target=/tmp,sharing=locked,mode=1777 \
    --mount=from=downloader,target=/dl \
    --mount=from=extractor,target=/src \
 apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | \
    xargs apt-get install -y --no-install-recommends \
 && cp /dl/cisco-umbrella.crt /usr/local/share/ca-certificates/cisco-umbrella.crt \
 && update-ca-certificates \
 && python3 -m pip install --break-system-packages --require-hashes --no-cache-dir -r /tmp/requirements.txt \
 # Copy and install tools from the extractor stage
 && bash /src/bats-core/install.sh /usr/local \
 && cp -r /dl/bats-support /usr/local/bats-support \
 && cp -r /dl/bats-assert /usr/local/bats-assert \
 && cp /src/docker/docker /usr/local/bin \
 && cp /src/xwin /usr/local/bin/xwin \
 && cp -r /src/gcc-arm-none-eabi /opt/gcc-arm-none-eabi \
 # Install clang toolchain and mull mutation testing framework
 && cat /dl/llvm.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot-keyring.gpg \
 && cat /dl/mull.gpg.key | gpg --dearmor -o /usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg \
 && UBUNTU_CODENAME=$(grep '^UBUNTU_CODENAME=' /etc/os-release | cut -d= -f2) \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot-keyring.gpg] http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null \
 && echo "deb [signed-by=/usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/mull-project/mull-stable/deb/ubuntu ${UBUNTU_CODENAME} main" | tee /etc/apt/sources.list.d/mull-project-mull-stable.list > /dev/null \
 && echo -e 'Package: *\nPin: origin "apt.llvm.org"\nPin-Priority: 1000' > /etc/apt/preferences \
 && apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-clang.json | \
    xargs apt-get install -y --no-install-recommends

# Compile and install additional clang tools; often necessary as binary arm64 builds are lacking, or packages are out-of-date
# Install ccache from source for a recent version
RUN wget -qO - https://github.com/ccache/ccache/archive/refs/tags/v${CCACHE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTING=Off -DENABLE_DOCUMENTATION=Off -S /tmp/ccache-${CCACHE_VERSION} -B /tmp/ccache-${CCACHE_VERSION}/build \
 && cmake --build /tmp/ccache-${CCACHE_VERSION}/build --target install \
 && rm -rf /tmp/ccache-${CCACHE_VERSION}

# Install include-what-you-use (iwyu) from source
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/root/.ccache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && wget -qO - https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -S /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} -B /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
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
 && cp /etc/skel/.bashrc /root/.bashrc

# Set up package managers CPM and Conan
# - Install CPM.cmake to the CMake module path
# - Configure a default profile for Conan and set the CMake generator to Ninja
RUN wget -qP /usr/local/lib/python*/dist-packages/cmake/data/share/cmake-*/Modules/ https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_VERSION}/CPM.cmake \
 && conan profile detect \
 && echo -e "\n[conf]\ntools.cmake.cmaketoolchain:generator=Ninja" >> "$(conan profile path default)"
