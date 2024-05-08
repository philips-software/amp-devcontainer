# amp-devcontainer

<!-- markdownlint-disable -->
[![Linting & Formatting](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml/badge.svg)](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml) [![Build & Push](https://github.com/philips-software/amp-devcontainer/actions/workflows/build-push.yml/badge.svg)](https://github.com/philips-software/amp-devcontainer/actions/workflows/build-push.yml) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/philips-software/amp-devcontainer/badge)](https://securityscorecards.dev/viewer/?uri=github.com/philips-software/amp-devcontainer)
<!-- markdownlint enable -->

## Overview

This repository contains [devcontainers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/introduction-to-dev-containers) tailored towards modern, embedded, C++ and Rust development.

## State

This repository is under active development; see [pulse](https://github.com/philips-software/amp-devcontainer/pulse) for more details.

## Description

### Image variants

Two devcontainers are published towards the [GitHub Container Registry](https://ghcr.io/):

- [amp-devcontainer-cpp](https://github.com/orgs/philips-software/packages/container/package/amp-devcontainer-cpp); the C++ container
- [amp-devcontainer-rust](https://github.com/orgs/philips-software/packages/container/package/amp-devcontainer-rust); the Rust container

Both containers include a full [Visual Studio Code](https://code.visualstudio.com/) configuration that is compatible with [GitHub Codespaces](https://github.com/features/codespaces).

A summary of the included tools can be found below. For the full list of all included tools and tool versions see the [Dependency Graph](https://github.com/philips-software/amp-devcontainer/network/dependencies), the SBOM published with a [release](https://github.com/philips-software/amp-devcontainer/releases), or the SBOM attached to the image.

#### amp-devcontainer-cpp

The amp-devcontainer-cpp built from this repository contains compilers and tools to facilitate modern, embedded, C++ development.
The amp-devcontainer-cpp includes support for host- and cross-compilation using gcc, arm-gcc and clang compilers.
Next to the compilers there is support for code-coverage measurement, mutation testing (using [mull](https://github.com/mull-project/mull)), fuzzing (using [libfuzzer](https://www.llvm.org/docs/LibFuzzer.html)) and static analysis and formatting (clang-format, clang-tidy, clangd, include-what-you-use).

The default build system is set up to use CMake, Ninja and CCache.

#### amp-devcontainer-rust

The amp-devcontainer-rust built from this repository contains the Rust ecosystem and additional tools to facilitate, embedded, Rust development.
The amp-devcontainer-rust includes support for host- and cross-compilation.
Next to the Rust ecosystem there is support for code-coverage measurement, mutation testing (using [cargo-mutants](https://mutants.rs/)), fuzzing (using [rust-fuzz](https://rust-fuzz.github.io/book/introduction.html)) and static analysis and formatting (clippy, rustfmt).

For embedded development and flashing and debugging [probe-rs](https://probe.rs/) and [flip-link](https://github.com/knurling-rs/flip-link) are included.

### Visual Studio Code

Both containers can be used in Visual Studio Code or GitHub Codespaces without any additional configuration. All included tools are set-up and necessary plug-ins will be installed at container start. This behavior is implemented by appending devcontainer metadata to an image label according to the [specifications](https://containers.dev/implementors/reference/#labels). It is possible to override, amend or change the options following this [merge logic](https://containers.dev/implementors/spec/#merge-logic).

## Usage

### Verify image signature

The container images are signed with [SigStore](https://www.sigstore.dev/) [Cosign](https://docs.sigstore.dev/signing/quickstart/) using a keyless signing method.

The signature can be verified with the following command (using Docker), verifying that the image is actually signed by the GitHub CI system:

> amp-devcontainer-cpp

```sh
docker run --rm gcr.io/projectsigstore/cosign verify ghcr.io/philips-software/amp-devcontainer-cpp --certificate-oidc-issuer https://token.actions.githubusercontent.com --certificate-identity-regexp https://github.com/philips-software/amp-devcontainer
```

> amp-devcontainer-rust

```sh
docker run --rm gcr.io/projectsigstore/cosign verify ghcr.io/philips-software/amp-devcontainer-rust --certificate-oidc-issuer https://token.actions.githubusercontent.com --certificate-identity-regexp https://github.com/philips-software/amp-devcontainer
```

The resulting containers can be used in a `.devcontainer.json` file or in a `.devcontainer` folder.

> [!NOTE]
> While the following examples use the `latest` tag, it is recommended to pin to a specific version. Or better yet, a specific SHA.

### amp-devcontainer-cpp

> .devcontainer/devcontainer.json or .devcontainer.json

```json
{
    "image": "ghcr.io/philips-software/amp-devcontainer-cpp:latest"
}
```

### amp-devcontainer-rust

> .devcontainer/devcontainer.json or .devcontainer.json

```json
{
    "image": "ghcr.io/philips-software/amp-devcontainer-rust:latest"
}
```

## Community

This project uses a [code of conduct](.github/CODE_OF_CONDUCT.md) to define expected conduct in our community. Instances of
abusive, harassing, or otherwise unacceptable behavior may be reported to the repository administrators by using the [Report content](https://docs.github.com/en/communities/maintaining-your-safety-on-github/reporting-abuse-or-spam) functionality of GitHub.

## Changelog

See the [changelog](./CHANGELOG.md) for more info on what's been changed.

## Contributing

This project uses [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) please see the [contributing](.github/CONTRIBUTING.md) guideline for more information.

### Build & Test

The containers can be built and tested locally by importing this repository in VS Code with the [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) plug-in installed. As a prerequisite Docker needs to be installed on the host system. Alternatively a GitHub Codespace can be started.

A test task is available to run the included `bats` tests. Choose `Tasks: Run Test Task` from the command pallette (<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>).

## Reporting vulnerabilities

If you find a vulnerability, please report it to us!
See [security](.github/SECURITY.md) for more information.

## Licenses

See [license](./LICENSE)
