# Project Overview

This repository contains devcontainers tailored towards modern software development. The containers try to be as "batteries included" as possible without being overly opinionated, and are usable for both local development and continuous integration. All containers are multi-platform and can be used on x64 (x86-64) and arm64 hardware on an operating system that supports an [OCI](https://opencontainers.org/) compatible container engine. This includes Windows, Linux, and macOS on both Intel and Apple silicon.

The devcontainers include modern, up-to-date, tooling for C++ and Rust development, and are fully compatible with GitHub Codespaces and Visual Studio Code. The containers are versioned using [Semantic Versioning](https://semver.org/) and are designed with supply-chain security in mind. They can be used with [Dependabot](https://dependabot.com/) to keep dependencies up to date.

The container images should provide a secure foundation for regulated software development in e.g. the medical, automotive, aviation, and railroad domains.

## Key Features

- **Batteries Included** 🔋: Pre-configured tools for local development and continuous integration.
- **Multi-platform Support** ⚙️: Compatible with x64 and arm64 hardware on Windows, Linux, and macOS.
- **Image Flavors** 🍨: Dedicated containers for C++ and Rust development.
- **IDE Integration** 💻: Fully compatible with GitHub Codespaces and VS Code.
- **Semantic Versioning** 🔢: Clear versioning strategy for container images.
- **Secure** 🔒: Emphasis on supply-chain security and compatible with Dependabot.
- **Tested** ✅: Includes verification tests.

## Folder Structure

- `/.devcontainer`: Contains the source code for the container flavors with a top-level devcontainer.json file to enable `clone in container volume` of this repository.
- `/.devcontainer/[flavor]`: Contains the Dockerfile and configuration for each container flavor (e.g., `cpp`, `rust`).
- `/.devcontainer/[flavor]-test`: Contains a devcontainer.json file for testing the container flavor.
- `/.github`: Contains the GitHub workflows for CI/CD, linter configuration, issue templates and re-usable actions.
- `/test/[flavor]`: Contains [Bats](https://bats-core.readthedocs.io/en/stable/) integration- and Playwright verification tests for the containers.

## Libraries and Frameworks

- Dockerfiles for building the container images.
- Python and pip to install and manage dependencies.
- GitHub Actions for CI/CD workflows.
- CMake, Conan, CPM, Mull, and other tools for C++ development.
- Rust, Cargo, Clippy, cargo-binstall for Rust development.
- Visual Studio Code for development environment.
- MegaLinter for code linting.
- Google's release-please for automated releases.

## Values

- **Security First**: Prioritizing supply-chain security and best practices.
- **Developer Experience**: Focusing on ease of use and seamless integration with popular IDEs.
- **Open Source**: Committed to transparency and community collaboration.
- **Quality Assurance**: Emphasizing consistency, testing and reliability.
- **Continuous Improvement**: Regular updates and enhancements based on user feedback.
