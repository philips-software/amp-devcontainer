# Project Overview

This repository contains devcontainers tailored towards modern software development.
The containers try to be as "batteries included" as possible without being overly opinionated, and are usable for both local development and continuous integration.
All containers are multi-platform and can be used on x64 (x86-64) and arm64 hardware on an operating system that supports an [OCI](https://opencontainers.org/) compatible container engine.
This includes Windows, Linux, and macOS on both Intel and Apple silicon.

The devcontainers include modern, up-to-date, tooling for C++ and Rust development, and are fully compatible with GitHub Codespaces and Visual Studio Code.
The containers are versioned using [Semantic Versioning](https://semver.org/) and are designed with supply-chain security in mind.
They can be used with [Dependabot](https://dependabot.com/) to keep dependencies up to date.

The container images should provide a secure foundation for regulated software development in e.g. the medical, automotive, aviation, and railroad domains.

## Key Features

The key features of this project are described in the top-level README.md, read them from there to prevent duplication and mismatches.

## Folder Structure

The folder structure of amp-devcontainer is described below, adhere to the existing folder structure.

- `/.devcontainer`: Contains the source code for the container flavors with a top-level devcontainer.json file to enable `clone in container volume` of this repository.
- `/.devcontainer/[flavor]`: Contains the Dockerfile and configuration for each container flavor (e.g., `cpp`, `rust`).
- `/.devcontainer/[flavor]-test`: Contains a devcontainer.json file for testing the container flavor.
- `/.github`: Contains the GitHub workflows for CI/CD, linter configuration, issue templates and re-usable actions.
- `/test/[flavor]`: Contains [Bats](https://bats-core.readthedocs.io/en/stable/) integration- and Playwright verification tests for the containers.

## File Specific Instructions

When reviewing GitHub Action workflows, ensure that:

- Workflows that have a workflow_call trigger have the file name prefixed with `wc-`.
- For all re-usable workflows, only the top-level workflow has defaults and descriptions for inputs to avoid duplication. Top-level workflows are not called themselves by other workflows with workflow_call.
