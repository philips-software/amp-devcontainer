# publish-release

Publishes a draft release, after it has checked that the assets that the release has to have are attached.
The assets of an immutable release can't be changed after publication, so this is the last moment to find out that one is missing.

The check is the one of [upload-release-assets](../upload-release-assets/README.md), run again right before publication: the assets are present on the release with the `uploaded` state.
It also runs for a release that has already been published, for instance by hand while a reviewer was still to approve, so a missing asset is noticed either way.
A release that is already published is left as it is.

## Usage

```yaml
- id: assets
  uses: philips-software/amp-devcontainer/.github/actions/upload-release-assets@...
  with:
    images: ...
    release-tag: ${{ github.ref_name }}
    sbom-directory: ...
- uses: philips-software/amp-devcontainer/.github/actions/publish-release@...
  with:
    expected-assets: ${{ steps.assets.outputs.asset-names }}
    release-tag: ${{ github.ref_name }}
```

The caller needs `contents: write` and the GitHub CLI and `jq` on the runner.
A release that is published with the token of a workflow does not trigger a workflow for the `release` event. Pass the token of a GitHub App as `github-token` when it has to.
The re-usable workflow [wc-publish-release.yml](../../workflows/wc-publish-release.yml) does that, and asks for the approval of an environment first.

## Inputs

| Name              | Required | Description                                                           |
|-------------------|----------|-----------------------------------------------------------------------|
| `expected-assets` | yes      | JSON array with the names of the assets that the release has to have. |
| `release-tag`     | yes      | Tag of the release to publish.                                        |
| `github-token`    | no       | Token used to publish the release. Defaults to the workflow token.    |

The action fails, without publishing, when the list of expected assets is missing, empty or invalid, when an asset is missing or not uploaded, when the release cannot be looked up, or when its draft state is unexpected.

## Tests

The tests stub `gh` with a function. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/publish-release/test
```
