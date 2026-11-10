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
- `/.github/actions/[action]`: Contains a composite action with its scripts, README and Bats tests, released separately as `actions/vX.Y.Z`.
- `/.github/workflows`: Contains the workflows. `wc-*.yml` are re-usable workflows (`workflow_call`), the others are triggered by events.
- `/docs`: Contains documentation that does not belong in a README, e.g. [the re-usable build system](../docs/reusable-build-system.md) and architecture decision records in `/docs/adr`.
- `/helpers/[helper]`: Contains re-usable Bats helper packages (e.g. `bats-tool-inventory`) and scripts that are installed in the base image, each with its own tests in `/helpers/[helper]/test`.
- `/templates`: Contains the dev container templates that are published for each flavor.
- `/test/[flavor]`: Contains [Bats](https://bats-core.readthedocs.io/en/stable/) integration- and Playwright verification tests for the containers.
- `/test/repository`: Contains Bats tests that check the repository itself, e.g. that versions that are pinned in multiple places are in sync. These don't need a container.

## Where to Look

Details that apply to specific files are in `.github/instructions/`, they are loaded when you work on those files: workflows, actions, Dockerfiles and container configuration, Bats tests, and documentation.
Read these documents instead of guessing, and link to them instead of copying them:

- [CONTRIBUTING.md](./CONTRIBUTING.md): pull request titles, tests, and the tool inventory.
- [docs/reusable-build-system.md](../docs/reusable-build-system.md): how images are built, tested and released, and how derived repositories re-use that.
- The README of an action or helper: its inputs, outputs and behavior.

## Principles

- **No flavors in re-usable parts.** Workflows, actions and helpers are used by derived repositories that build one or many containers, so they take the images, names and paths as parameters. Only the `.devcontainer`, `/test/[flavor]` and `/templates` folders and the top-level workflows know the flavors.
- **Supply-chain security first.** Everything that is downloaded is pinned: actions by commit SHA, base images by digest, apt packages by version, downloads by checksum. Never use a floating reference like `latest` or a branch, and don't pin to something you have not looked up.
- **Least privilege.** Workflows start with `permissions: {}`, and every job and every permission is justified with a comment.
- **Keep the delta small.** Change what is asked, don't reformat or refactor unrelated files, and don't fix unrelated pre-existing issues.
- **Tests come with the change.** A change to an action, helper, inventory or pinned version updates or adds its tests, and the documentation that describes it.
- **Don't duplicate what a tool enforces.** Linters (MegaLinter, zizmor, hadolint, markdownlint) and the consistency tests already check formatting, pinning and permissions; read their findings instead of re-implementing them.
- **Generated or release-managed files are not edited by hand:** `CHANGELOG.md` files, `.release-please-manifest.json`, the version fields of `/templates` and `requirements.txt` (generated from `requirements.in` with `pip-compile --generate-hashes`).

## Build and Test

The development container (`.devcontainer/devcontainer.json`) has Bats and its libraries installed in `/usr/local`; outside of it set `BATS_LIB_PATH=/usr/local`. A container engine is not needed for the first command.

```shell
# Actions, helpers and repository consistency, no container needed
bats helpers/*/test .github/actions/*/test test/repository

# Actions written in JavaScript, currently only container-size-diff (node:test)
npm ci --ignore-scripts --prefix .github/actions/container-size-diff && npm test --prefix .github/actions/container-size-diff

# Integration tests of a flavor, run inside that flavor's container
bats test/<flavor>/integration-tests.bats
```

CI runs these in [continuous-integration.yml](./workflows/continuous-integration.yml), and the linters in [linting-formatting.yml](./workflows/linting-formatting.yml) with [.mega-linter.yml](../.mega-linter.yml).
The workflows themselves can only be tested by running them in GitHub, say so in your summary instead of claiming they work.

## Commits and Pull Requests

- The title of a pull request follows [Conventional Commits](https://www.conventionalcommits.org) (`<type>[(scope)][!]: <description>`, where the description starts with a lowercase letter), and decides the next release: `feat` is a minor, `fix` a patch, `!` a major version. Use `ci:`, `docs:`, `test:` or `chore:` for changes that don't change the behavior of the images or actions.
- Branches are kebab-case, e.g. `feat/add-required-tool`.
- Commit messages are descriptive, and only the pull request title is enforced.
- Never commit or push unless asked to, and never force-push over history that is not yours.

## Writing Style

- Documentation is written for the reader that does not know the repository: say what something is for, not only what it does.
- Comment code only where the intent is not obvious, e.g. why a permission is needed or why a workaround exists.
