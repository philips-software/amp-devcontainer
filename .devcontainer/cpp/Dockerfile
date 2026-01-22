# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-base:edge
ARG XWIN_VERSION=0.7.0

# Downloader stage for AMD64 architecture
FROM scratch AS downloader-amd64

ARG XWIN_VERSION

ADD --checksum=sha256:f1bffe5319728fca9cde5bb03fcb6c88cdf44922bd003fca8b4b9ce5b6f259d2 \
 https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-x86_64-unknown-linux-musl.tar.gz /xwin.tar.gz

# Downloader stage for ARM64 architecture
FROM scratch AS downloader-arm64

ARG XWIN_VERSION

ADD --checksum=sha256:b85cd1e0c94f249338b02a6e54b380154a5af6b5dd754121b15722125a67cf9f \
 https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-aarch64-unknown-linux-musl.tar.gz /xwin.tar.gz

# hadolint ignore=DL3006
# trivy:ignore:AVD-DS-0001
# Select downloader stage based on target architecture.
# Linters don't recognize the TARGETARCH variable, so we ignore warnings here.
FROM downloader-${TARGETARCH} AS downloader

# Extractor stage using target architecture specific downloader
FROM ${BASE_IMAGE} AS extractor

ARG XWIN_VERSION

WORKDIR /

RUN --mount=from=downloader,target=/dl \
 tar xzf /dl/xwin.tar.gz --strip-components=1 "xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl/xwin"

# Final development container image
FROM ${BASE_IMAGE}

ARG CCACHE_VERSION=4.12
ARG CLANG_VERSION=19
ARG CPM_VERSION=0.40.2
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.23

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

# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
    --mount=type=bind,source=.devcontainer/cpp/requirements.txt,target=/tmp/requirements.txt \
    --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked \
    --mount=from=extractor,target=/src <<EOF

    # Install the base system with all tool dependencies
    apt-get update && \
    jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | \
        xargs apt-get install -y --no-install-recommends

    # Install some tools via pip to get more recent versions, clean up afterwards
    python3 -m pip install --break-system-packages --require-hashes --no-cache-dir --no-compile -r /tmp/requirements.txt
    find / -regex '^.*\(__pycache__\|\.py[co]\)$' -delete
    rm -rf "$(pip cache dir)"

    # Install xwin
    cp /src/xwin /usr/local/bin/xwin
EOF

# Install clang toolchain and mull mutation testing framework
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
RUN mkdir /opt/gcc-arm-none-eabi \
 && wget --no-hsts -qO - "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-$(uname -m)-arm-none-eabi.tar.xz" | tar --exclude='*arm-none-eabi-gdb*' --exclude='share' --strip-components=1 -xJC /opt/gcc-arm-none-eabi

# Install ccache
RUN wget --no-hsts -qO - "https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}-linux-$(uname -m).tar.xz" | tar -xJ -C /usr/local/bin --strip-components=1 "ccache-${CCACHE_VERSION}-linux-$(uname -m)/ccache"

# Install include-what-you-use (iwyu) from source
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && wget --no-hsts -qO - https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz | tar xz -C /tmp \
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
RUN --mount=type=cache,target=/cache,sharing=locked \
 wget --no-hsts -qP /usr/local/lib/python*/dist-packages/cmake/data/share/cmake-*/Modules/ https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_VERSION}/CPM.cmake \
 && conan profile detect \
 && echo -e "\n[conf]\ntools.cmake.cmaketoolchain:generator=Ninja" >> "$(conan profile path default)"
