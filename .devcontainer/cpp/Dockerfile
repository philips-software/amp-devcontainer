ARG DOCKER_VERSION=28.2.2

FROM scratch AS downloader-amd64

ADD --checksum=sha256:53dc06dc3f775282ddff93b2d0974bbe6480761018c61e7a797342a9c7f14e23 \
 https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz

FROM scratch AS downloader-arm64

ADD --checksum=sha256:c9506628d1845c69230df3d87e2eedd7980caf8bd966f5e6a5d7a2364de42497 \
 https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION}.tgz

FROM downloader-$TARGETARCH AS downloader

FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233

ARG BATS_VERSION=1.11.0
ARG CCACHE_VERSION=4.11
ARG CLANG_VERSION=18
ARG CPM_VERSION=0.40.2
ARG INCLUDE_WHAT_YOU_USE_VERSION=0.22
ARG XWIN_VERSION=0.6.5

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Include the Cisco Umbrella PKI Root
ADD --checksum=sha256:a122d4080a26c1da986bd0e7202b1630eb661a624915ef244f496fdd306e85fb \
 https://www.cisco.com/security/pki/certs/ciscoumbrellaroot.pem /usr/local/share/ca-certificates/ciscoumbrellaroot.pem

# Install the base system with all tool dependencies
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-base.json,target=/tmp/apt-requirements-base.json \
 apt-get update && apt-get install -y --no-install-recommends jq \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-base.json | xargs apt-get install -y --no-install-recommends \
 && update-ca-certificates \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install some tools via pip to get more recent versions
RUN --mount=type=bind,source=.devcontainer/cpp/requirements.txt,target=/tmp/requirements.txt \
 python3 -m pip install --break-system-packages --require-hashes --no-cache-dir -r /tmp/requirements.txt

# Set default environment options for CMake and ccache
ENV CMAKE_GENERATOR="Ninja"
ENV CMAKE_EXPORT_COMPILE_COMMANDS="On"
ENV CCACHE_DIR=/cache/.ccache
ENV CPM_SOURCE_CACHE=/cache/.cpm-cache

# Install clang toolchain and mull mutation testing framework
# hadolint ignore=SC1091
RUN --mount=type=bind,source=.devcontainer/cpp/apt-requirements-clang.json,target=/tmp/apt-requirements-clang.json \
 wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot-keyring.gpg \
 && wget -qO - https://dl.cloudsmith.io/public/mull-project/mull-stable/gpg.41DB35380DE6BD6F.key | gpg --dearmor -o /usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg \
 && UBUNTU_CODENAME=$(. /etc/os-release; echo "${UBUNTU_CODENAME/*, /}") \
 && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot-keyring.gpg] http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null \
 && echo "deb [signed-by=/usr/share/keyrings/mull-project-mull-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/mull-project/mull-stable/deb/ubuntu ${UBUNTU_CODENAME} main" | tee /etc/apt/sources.list.d/mull-project-mull-stable.list > /dev/null \
 && echo -e 'Package: *\nPin: origin "apt.llvm.org"\nPin-Priority: 1000' > /etc/apt/preferences \
 && apt-get update \
 && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements-clang.json | xargs apt-get install -y --no-install-recommends \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
ENV PATH="$PATH:/usr/lib/llvm-${CLANG_VERSION}/bin"

# Install arm-gcc toolchain
RUN mkdir /opt/gcc-arm-none-eabi \
 && wget -qO - "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-$(uname -m)-arm-none-eabi.tar.xz" | tar --exclude='*arm-none-eabi-gdb*' --exclude='share' --strip-components=1 -xJC /opt/gcc-arm-none-eabi
ENV PATH="$PATH:/opt/gcc-arm-none-eabi/bin"

# Install docker-cli for Docker-from-Docker tools
COPY --from=downloader /docker/docker/docker /usr/local/bin

# Install bats
RUN batstmp="$(mktemp -d /tmp/bats-core-${BATS_VERSION}.XXXX)" \
 && wget -qO - https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz | tar xz -C "${batstmp}" \
 && bash "${batstmp}/bats-core-${BATS_VERSION}/install.sh" /usr/local \
 && rm -rf "${batstmp}" \
 && git -C /usr/local clone -b v0.3.0 https://github.com/bats-core/bats-support.git \
 && git -C /usr/local clone -b v2.1.0 https://github.com/bats-core/bats-assert.git

# Install xwin
RUN wget -qO - "https://github.com/Jake-Shadle/xwin/releases/download/${XWIN_VERSION}/xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl.tar.gz" | tar -xzv -C /usr/local/bin --strip-components=1 "xwin-${XWIN_VERSION}-$(uname -m)-unknown-linux-musl/xwin"

# Compile and install additional clang tools; often necessary as binary arm64 builds are lacking, or packages are out-of-date
# Install ccache from source for a recent version
RUN wget -qO - https://github.com/ccache/ccache/archive/refs/tags/v${CCACHE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTING=Off -DENABLE_DOCUMENTATION=Off -S /tmp/ccache-${CCACHE_VERSION} -B /tmp/ccache-${CCACHE_VERSION}/build \
 && cmake --build /tmp/ccache-${CCACHE_VERSION}/build --target install \
 && rm -rf /tmp/ccache-${CCACHE_VERSION}

# Install include-what-you-use (iwyu) from source
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/root/.ccache,sharing=locked \
 apt-get update && apt-get install -y --no-install-recommends libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && wget -qO - https://github.com/include-what-you-use/include-what-you-use/archive/refs/tags/${INCLUDE_WHAT_YOU_USE_VERSION}.tar.gz | tar xz -C /tmp \
 && CC=clang CXX=clang++ cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -S /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} -B /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build \
 && cmake --build /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION}/build --target install \
 && rm -rf /tmp/include-what-you-use-${INCLUDE_WHAT_YOU_USE_VERSION} \
 && apt-get purge -y libclang-${CLANG_VERSION}-dev llvm-${CLANG_VERSION}-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Update all tool alternatives to the correct version
# and patch root's bashrc to include bash-completion
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 10 \
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
