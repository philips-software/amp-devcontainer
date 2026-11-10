# verify-immutable-release

Verifies that a published release is immutable: the release and its tag can't be changed, and GitHub has created the release attestation that binds the tag, the commit and the assets together.
The check is `gh release verify`, which fails for a release that was published while immutable releases were not enabled for the repository.

GitHub creates the release attestation after the release is published, so the action retries for a short while before it fails.
Use it after the publication, for instance in a workflow for the `release` event, to notice that the setting was switched off.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/verify-immutable-release@...
  with:
    release-tag: ${{ github.ref_name }}
```

The caller needs `contents: read` and `attestations: read`, and the GitHub CLI on the runner.
The re-usable workflow [wc-release-published.yml](../../workflows/wc-release-published.yml) runs it in a job of its own.

## Inputs

| Name           | Required | Description                                                                     |
|----------------|----------|---------------------------------------------------------------------------------|
| `release-tag`  | yes      | Tag of the release to verify.                                                   |
| `github-token` | no       | Token used to read the release and attestation. Defaults to the workflow token. |

## Tests

The tests stub `gh` and `sleep` with functions. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/verify-immutable-release/test
```
