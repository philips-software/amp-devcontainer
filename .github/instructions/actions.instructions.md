---
description: "Use when creating or changing a composite action in .github/actions: action.yml, its scripts, README, and Bats or node tests. Covers inputs, scripts, tests and releasing."
applyTo: ".github/actions/**"
---

# Actions Guidelines

The actions in `.github/actions` are re-usable by other repositories and released separately as `actions/vX.Y.Z`.

- An action does not know about the flavors of this repository. It takes images, names, files and tokens as inputs.
- `action.yml` only declares the inputs, outputs and a step that runs a script. Pass inputs to the script through `env:`, never interpolate `${{ inputs.* }}` in a `run:` script. Inputs and outputs are sorted alphabetically.
- Scripts are bash with `set -Eeuo pipefail`, start with a comment that documents the environment variables they read, validate required variables with `${VAR:?message}`, and write outputs to `GITHUB_OUTPUT`. Larger logic is a `.bash` library next to the script that the tests can source. See [extract-manifest-digest.sh](../actions/extract-manifest-digest/extract-manifest-digest.sh).
- Every action has a `README.md` with a description, usage example, an inputs and outputs table, and the permissions it needs. Add the action to the list in [the re-usable build system](../../docs/reusable-build-system.md).
- Every action has tests in `test/`, written as described in [the Bats guidelines](./bats-tests.instructions.md). Actions with Node.js code use `node:test`, have a `package-lock.json`, and are listed in [dependabot.yml](../dependabot.yml) and in the `node-action-tests` job of CI.
- Tools that run in the actions (`gh`, `jq`, `docker`) are stubbed in the tests, so they run without network or container engine.
- Failing safely matters more than succeeding: an action that edits something (a release) reads and validates everything first, and edits once.
- The inventory resolver exists twice, in `helpers/bats-tool-inventory/src/resolve-inventory.bash` and `.github/actions/generate-tool-inventory/resolve.sh`. Change both, a test checks that they agree.
- A new action or a behavior change is released by release-please from a `feat:` or `fix:` pull request. Workflows only use it after the actions release is published, see [the pinning rules](./workflows.instructions.md#pinning).
