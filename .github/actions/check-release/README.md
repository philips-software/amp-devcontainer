# check-release

Checks that the draft release of a tag exists, and that it is not published yet.
A release workflow that starts with this check fails right away when there is nothing to attach the assets to, instead of after the build.

release-please creates the tag, which starts the release workflow, before it creates the draft release.
The action therefore waits for about a minute for the draft to appear, and then fails with the command to create the draft.
It also fails for a release that is already published, because the assets of an immutable release can't be changed anymore.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/check-release@...
  with:
    release-tag: ${{ github.ref_name }}
```

The caller needs `contents: write`, because a draft release is only visible with write access, and the GitHub CLI on the runner.
The re-usable workflow [wc-check-release.yml](../../workflows/wc-check-release.yml) runs it in a job of its own.

## Inputs

| Name           | Required | Description                                                     |
|----------------|----------|-----------------------------------------------------------------|
| `release-tag`  | yes      | Tag of the release to check.                                    |
| `github-token` | no       | Token used to read the release. Defaults to the workflow token. |

## Tests

The tests stub `gh` and `sleep` with functions. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/check-release/test
```
