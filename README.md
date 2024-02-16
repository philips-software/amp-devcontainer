# amp-devcontainer

<!-- markdownlint-disable -->
[![Linting & Formatting](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml/badge.svg)](https://github.com/philips-software/amp-devcontainer/actions/workflows/linting-formatting.yml) [![Build & Push](https://github.com/philips-software/amp-devcontainer/actions/workflows/build-push.yml/badge.svg)](https://github.com/philips-software/amp-devcontainer/actions/workflows/build-push.yml) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/philips-software/amp-devcontainer/badge)](https://securityscorecards.dev/viewer/?uri=github.com/philips-software/amp-devcontainer)
<!-- markdownlint enable -->

## Overview

This repository contains a [devcontainer](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/introduction-to-dev-containers) tailored towards modern (embedded) C++ development.

## State

This repository is under active development; see [pulse](https://github.com/philips-software/amp-devcontainer/pulse) for more details.

## Description

The amp-devcontainer built from this repository contains compilers and tools to facilitate modern (embedded) C++ development.
The amp-devcontainer includes support for host- and cross-compilation using gcc, arm-gcc and clang compilers.
Next to the compilers there is support for code-coverage measurement, mutation testing (using [mull](https://github.com/mull-project/mull)), fuzzing (using [libfuzzer](https://www.llvm.org/docs/LibFuzzer.html)) and static analysis (clang-format, clang-tidy, clangd, include-what-you-use).
The default build system is set up to use CMake, Ninja and CCache.

For the full list of all included tools and tool versions see the [Dependency Graph](https://github.com/philips-software/amp-devcontainer/network/dependencies), the SBOM published with a [release](https://github.com/philips-software/amp-devcontainer/releases), or the SBOM attached to the image.

## Build & Test

The container can be built and tested locally by importing this repository in VS Code with the `Dev Containers` (ms-vscode-remote.remote-containers) plug-in installed. As a prerequisite Docker needs to be installed on the host system. As an alternative a GitHub Codespace can be started.

A test task is available to run the included `bats` tests. Choose `Tasks: Run Test Task` from the command pallette.

## Verify image signature

The container image is signed with [SigStore](https://www.sigstore.dev/) [Cosign](https://docs.sigstore.dev/signing/quickstart/) using a keyless signing method.

The signature can be verified with the following command (using Docker), verifying that the image is actually signed by the GitHub CI system:

```sh
docker run --rm gcr.io/projectsigstore/cosign verify ghcr.io/philips-software/amp-devcontainer --certificate-oidc-issuer https://token.actions.githubusercontent.com --certificate-identity-regexp https://github.com/philips-software/amp-devcontainer
```

## Usage

The resulting container can be used in a `.devcontainer` folder. While the example uses the `latest` tag, it is recommended to pin to a specific version. Or better yet, a specific SHA.

> .devcontainer/devcontainer.json

```json
{
    "image": "ghcr.io/philips-software/amp-devcontainer:latest"
}
```

## Community

This project uses the [CODE_OF_CONDUCT](./CODE_OF_CONDUCT.md) to define expected conduct in our community. Instances of
abusive, harassing, or otherwise unacceptable behavior may be reported by contacting a project [CODEOWNER](./.github/CODEOWNERS)

## Changelog

See [CHANGELOG](./CHANGELOG.md) for more info on what's been changed.

## Contributing

See [CONTRIBUTING](./CONTRIBUTING.md)

## Reporting vulnerabilities

If you find a vulnerability, please report it to us!
See [SECURITY.md](./SECURITY.md) for more information.

## Licenses

See [LICENSE](./LICENSE)
