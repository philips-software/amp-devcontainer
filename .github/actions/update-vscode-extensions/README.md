# update-vscode-extensions

Updates version-pinned VS Code extensions in dev container JSON files to the latest suitable versions on the Visual Studio Marketplace.
Extensions are pinned as `publisher.name@version` under `customizations.vscode.extensions`, so containers are reproducible.
This action is meant to run in a scheduled workflow that opens a pull request with the changes, see [update-dependencies.yml](../../workflows/update-dependencies.yml).

A version is adopted when it:

- is not a pre-release;
- has been public for at least the cooldown period (7 days by default), so a faulty release can be withdrawn before it is adopted.

The extensions in a file are sorted case-insensitively.
When an extension has a GitHub repository, the release notes of the versions that are adopted are added to the summary.
Links to GitHub are rewritten and at-mentions are defused, so the summary doesn't create backlinks or notifications.

## Usage

```yaml
- uses: actions/checkout@...
- uses: philips-software/amp-devcontainer/.github/actions/update-vscode-extensions@...
  id: update-extensions
  with:
    input-file: |
      .devcontainer/my-image/devcontainer.json
      .devcontainer/my-image/devcontainer-metadata.json
- run: cat "${{ steps.update-extensions.outputs.markdown-summary-file }}" # use it as pull request body
```

The files are updated in place; the action does not commit them.
The action sets up Node.js itself, and installs `jq` with apt, using sudo when it is not root, only when the runner doesn't have it.
A file that cannot be updated, e.g. because the marketplace could not be reached after three attempts, is left unchanged and fails the action after all other files have been processed.

## Inputs and outputs

| Name                    | Kind   | Description                                                                                      |
|-------------------------|--------|--------------------------------------------------------------------------------------------------|
| `input-file`            | input  | JSON file(s), separated by spaces or newlines. Required.                                         |
| `cooldown-days`         | input  | Minimum number of days a version must have been published before it is adopted. Defaults to `7`. |
| `updated-dependencies`  | output | JSON array with the names of the extensions that were updated, without duplicates.               |
| `markdown-summary-file` | output | Path to a markdown file with the changes per file, e.g. for the body of a pull request.          |

## Tests

The tests stub the marketplace client (`vsce`) and `gh` with functions and use generated fake extensions and dates. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/update-vscode-extensions/test
```
