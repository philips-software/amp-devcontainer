# amp-devcontainer

<!-- markdownlint-disable -->
[![Linting & Formatting](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml/badge.svg)](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml) [![Continuous Integration](https://github.com/philips-software/amp-devcontainer/actions/workflows/continuous-integration.yml/badge.svg?branch=main)](https://github.com/philips-software/amp-devcontainer/actions/workflows/continuous-integration.yml) [![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9267/badge)](https://www.bestpractices.dev/projects/9267) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/philips-software/amp-devcontainer/badge)](https://securityscorecards.dev/viewer/?uri=github.com/philips-software/amp-devcontainer)
<!-- markdownlint enable -->

## Table of Contents

- [Overview](#overview)
- [State](#state)
- [Description](#description)
  - [Image flavors](#image-flavors)
  - [Versioning](#versioning)
  - [Visual Studio Code](#visual-studio-code)
- [Usage](#usage)
  - [Verify image signature](#verify-image-signature)
  - [Local development](#local-development)
  - [Continuous Integration](#continuous-integration)
- [Community](#community)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [Reporting vulnerabilities](#reporting-vulnerabilities)
- [Licenses](#licenses)

## Overview

This repository contains [devcontainers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/introduction-to-dev-containers) tailored towards modern, embedded, software development.

### Key Features

- **Batteries Included** 🔋: Pre-configured tools for local development and continuous integration.
- **Developer Experience** 👩‍💻: Minimal set-up time and maximal shift-left.
- **Multi-platform Support** ⚙️: Compatible with x64 and arm64 hardware on Windows, Linux, and macOS.
- **Image Flavors** 🍨: Dedicated containers for C++ and Rust development.
- **IDE Integration** 💻: Fully compatible with GitHub Codespaces and VS Code.
- **Semantic Versioning** 🔢: Clear versioning strategy for container images.
- **Secure** 🔒: Emphasis on supply-chain security and compatible with Dependabot.
- **Tested** ✅: Includes verification tests.

The containers try to be as "batteries included" as possible without being overly opinionated, and are usable for both local development and continuous integration.

All containers are multi-platform and can be used on x64 (x86-64) and arm64 hardware on an operating system that supports an [OCI](https://opencontainers.org/) compatible container engine.
This includes Windows, Linux, and macOS on both Intel and Apple silicon.

## State

This repository is under active development; see [pulse](https://github.com/philips-software/amp-devcontainer/pulse) for more details.

## Description

### Image flavors

The following devcontainers are published towards the [GitHub Container Registry](https://ghcr.io/):

- [amp-devcontainer-cpp](https://github.com/orgs/philips-software/packages/container/package/amp-devcontainer-cpp); the C++ container
- [amp-devcontainer-rust](https://github.com/orgs/philips-software/packages/container/package/amp-devcontainer-rust); the Rust container

All containers include a full [Visual Studio Code](https://code.visualstudio.com/) configuration that is compatible with [GitHub Codespaces](https://github.com/features/codespaces).

A summary of the included tools can be found below.
For the full list of all included tools and tool versions see the [Dependency Graph](https://github.com/philips-software/amp-devcontainer/network/dependencies), the SBOM published with a [release](https://github.com/philips-software/amp-devcontainer/releases), or the SBOM attached to the image.

#### amp-devcontainer-cpp

The amp-devcontainer-cpp built from this repository contains compilers and tools to facilitate modern, embedded, C++ development.
The amp-devcontainer-cpp includes support for host- and cross-compilation using gcc, arm-gcc and clang compilers.
Next to the compilers there is support for package management (using [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) and [Conan](https://conan.io/)) code-coverage measurement, mutation testing (using [mull](https://github.com/mull-project/mull)), fuzzing (using [libfuzzer](https://www.llvm.org/docs/LibFuzzer.html)) and static analysis and formatting (clang-format, clang-tidy, clangd, include-what-you-use).

The default build system is set up to use CMake, Ninja and CCache.

#### amp-devcontainer-rust

The amp-devcontainer-rust built from this repository contains the Rust ecosystem and additional tools to facilitate, embedded, Rust development.
The amp-devcontainer-rust includes support for host- and cross-compilation.
Next to the Rust ecosystem there is support for code-coverage measurement, mutation testing (using [cargo-mutants](https://mutants.rs/)), fuzzing (using [rust-fuzz](https://rust-fuzz.github.io/book/introduction.html)) and static analysis and formatting (clippy, rustfmt).

For embedded development and flashing and debugging [probe-rs](https://probe.rs/) and [flip-link](https://github.com/knurling-rs/flip-link) are included.

### Versioning

The amp-devcontainer repository follows a [semantic versioning](https://semver.org/spec/v2.0.0.html) strategy for its container images.
This ensures clear communication of updates and compatibility.
The versioning format used is `<major>.<minor>.<patch>`.
Released containers are tagged with `<major>`, `<major>.<minor>`, `<major>.<minor>.<patch>` and `v<major>.<minor>.<patch>`.
The latest build on the default branch is tagged with `edge` and pull request builds are tagged with `pr-<number>`.

| Branch       | Tag                        |
|--------------|----------------------------|
| Default      | `edge`                     |
| Pull Request | `pr-<number>`              |
| Release      | `v<major>.<minor>.<patch>` |
|              | `<major>.<minor>.<patch>`  |
|              | `<major>.<minor>`          |
|              | `<major>`                  |

Released containers will never be cleaned-up, pull request builds are cleaned up when the pull request is closed, and edge builds will be cleaned up shortly after a new edge version has been published.

The release notes always contain an overview of the corresponding image versions that include the full SHA next to the version number.
This makes it possible for humans to easily see what version is used while still pinning to an exact version.
This is the recommended way to refer to an image.

All container images are included in a release.
This might change in the future when the need arises to have separate releases per container.

This versioning strategy is implemented as GitHub Actions workflows, ensuring consistency and security across releases.
Only the GitHub Action workflow is allowed to create a release, and the resulting images are [signed](#verify-image-signature).

### Visual Studio Code

All containers can be used in Visual Studio Code or GitHub Codespaces without any additional configuration.
All included tools are preconfigured and necessary plug-ins will be installed at container start.
This behavior is implemented by appending devcontainer metadata to an image label according to these [specifications](https://containers.dev/implementors/reference/#labels).
It is possible to override, amend or change the options following this [merge logic](https://containers.dev/implementors/spec/#merge-logic).

## Usage

This chapter describes how to use amp-devcontainer for two common use-cases, and details how to verify the signature of the container images.

> [!IMPORTANT]
> While the following examples use the `latest` tag, it is recommended to pin to a specific version using vX.Y.Z. Or better yet, a specific SHA.
> See the 🔖 Packages section on the  [releases](https://github.com/philips-software/amp-devcontainer/releases) page for the unambiguous identifier corresponding to a specific release.

### Verify image signature

<details><summary>Prior to version 5.6.0</summary>

The container images are signed with [SigStore](https://www.sigstore.dev/) [Cosign](https://docs.sigstore.dev/cosign/signing/overview/) using a keyless signing method.

The signature can be [verified](https://docs.sigstore.dev/cosign/verifying/verify/) with the following command (using Docker), verifying that the image is actually signed by the GitHub CI system:

> amp-devcontainer-<🍨 flavor>

```sh
docker run --rm gcr.io/projectsigstore/cosign verify ghcr.io/philips-software/amp-devcontainer-<🍨 flavor> --certificate-oidc-issuer https://token.actions.githubusercontent.com --certificate-identity-regexp https://github.com/philips-software/amp-devcontainer
```

</details>

The container images are signed using the [attest-build-provenance](https://github.com/actions/attest-build-provenance) action.

The attestations can be checked with the following command, verifying that the image is actually built by the GitHub CI system:

> amp-devcontainer-<🍨 flavor>

```sh
gh attestation verify --repo philips-software/amp-devcontainer oci://ghcr.io/philips-software/amp-devcontainer-<🍨 flavor>
```

### Local development

The resulting containers can be used in a `.devcontainer.json` file or in a `.devcontainer` folder.

> .devcontainer/devcontainer.json or .devcontainer.json

```json
{
    "image": "ghcr.io/philips-software/amp-devcontainer-<🍨 flavor>:latest"
}
```

### Continuous integration

The resulting containers can be used in a GitHub workflow by using the [`container`](https://docs.github.com/en/actions/writing-workflows/choosing-where-your-workflow-runs/running-jobs-in-a-container) property on a job.

```yaml
jobs:
  container-job:
    runs-on: ubuntu-latest
    container: ghcr.io/philips-software/amp-devcontainer-<🍨 flavor>:latest
```

## Community

This project uses a [code of conduct](.github/CODE_OF_CONDUCT.md) to define expected conduct in our community. Instances of
abusive, harassing, or otherwise unacceptable behavior may be reported to the repository administrators by using the [report content](https://docs.github.com/en/communities/maintaining-your-safety-on-github/reporting-abuse-or-spam) functionality of GitHub.

## Changelog

See the [changelog](./CHANGELOG.md) for more info on what's been changed.

## Contributing

This project uses [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) and [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) please see the [contributing](.github/CONTRIBUTING.md) guideline for more information.

### Build & Test

<!-- markdownlint-disable -->
[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/philips-software/amp-devcontainer)
<!-- markdownlint enable -->

If you already have VS Code and a OCI compatible container engine installed, you can click the badge above or
[here](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/philips-software/amp-devcontainer)
to get started. Clicking these links will cause VS Code to automatically install the Dev Containers extension if needed,
clone the source code into a container volume, and spin up a dev container for use. Alternatively a GitHub Codespace can be started.

#### Running the Integration Tests

Run the included `bats` integration tests from the test explorer. Alternatively run all tests with <kbd>Ctrl</kbd> + <kbd>;</kbd> <kbd>A</kbd>.

#### Running the Acceptance Tests

Create a .env file in the root of the workspace with the following contents, this assumes a GitHub account that has rights to create a Codespace on this repository and is configured for time-based one-time password (TOTP) two-factor authentication (2FA).

```dotenv
GITHUB_USER=
GITHUB_PASSWORD=
GITHUB_TOTP_SECRET=
```

Test can now be run using the Test Explorer. The user interface is available on port 6080 by-default. When port 6080 is already taken another port will be exposed. This can be seen with the Ports view (<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>, Ports: Focus on Ports View).

## Reporting vulnerabilities

If you find a vulnerability, please report it to us!
See [security](.github/SECURITY.md) for more information.

## Licenses

amp-devcontainer is licensed under the MIT license.
See [license](./LICENSE) for more information.
