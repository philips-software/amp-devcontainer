---
description: "Use when writing or changing GitHub Actions workflows, including re-usable workflows (wc-*.yml): pinning, permissions, hardening, calling actions and workflows of this repository."
applyTo: ".github/workflows/*.yml"
---

# GitHub Workflows Guidelines

When writing GitHub Action workflows, ensure that:

- Workflows that have a workflow_call trigger have their filename prefixed with `wc-`.
- For all re-usable workflows, only the top-level workflow (workflows that are not called themselves by other workflows with workflow_call) has defaults and descriptions for inputs to avoid duplication.
- All workflows and action definitions have a name that is descriptive and concise, using emoji where appropriate.
- The sorting order for inputs, secrets, and outputs is alphabetical.
- The sorting order of other keys is consistent across the repository.
- Don't use quotes for strings unless necessary (e.g., to avoid special characters being misinterpreted).
- Use multi-line syntax for longer strings (e.g., for `run` commands or descriptions).

## Pinning

- Pin every `uses:` to a full commit SHA with the version as a comment: `uses: actions/checkout@<sha> # v7.0.1`. Look up the SHA of the tag, never guess it.
- Container images are pinned by digest, and a pin that appears in several workflows has the same version everywhere. [test/repository](../../test/repository/version-consistency.bats) fails when they differ.
- Re-usable workflows (`wc-*.yml`) use the actions of this repository like any other action, by the SHA of a released actions version: `philips-software/amp-devcontainer/.github/actions/<name>@<sha> # actions/vX.Y.Z`. Derived repositories call them, so they must only depend on released actions. All uses move to a new release together.
- Top-level workflows call workflows and actions of the same repository with the self-repository syntax: `uses: $/.github/workflows/<name>.yml`. actionlint does not know it yet, which is ignored in [actionlint.yml](../linters/actionlint.yml).

## Security

- Start with `permissions: {}` for the workflow, and give each job only what it needs, with a comment why: `contents: write # is needed by <action> to <what>`.
- The first step of a job is `step-security/harden-runner` with `egress-policy: audit`, and `disable-sudo: true` or `disable-sudo-and-containers: true` when the job allows it. It doesn't monitor a job that runs in a container (`container:`), so run only the tests in a container with `docker run` on the host when the job needs monitoring.
- `actions/checkout` has `persist-credentials: false`.
- Never put `${{ }}` expressions with event data (branch names, titles, inputs) in a `run:` script. Pass them through `env:`, and start scripts with `set -Eeuo pipefail`.
- Give every job a `timeout-minutes`.
- zizmor and actionlint run in CI, don't copy their checks into tests.

## Structure

- Keep logic out of the YAML. A script of more than a few lines belongs in an [action](./actions.instructions.md) with tests, the workflow only wires things together.
- A job that calls a re-usable workflow (`uses:`) can't have `env` or `steps`, and its `with:` can't read `env`. The called workflow can't have more permissions than the calling job grants, so a permission it needs must be granted by the caller.
- `continue-on-error: true` at the job level is for optional work, e.g. the Copilot release summary. The release must not fail because of it.
- Release workflows only run for a tag or release, so they can't be verified in a pull request. Keep the change minimal and describe how to verify it with a pre-release.
