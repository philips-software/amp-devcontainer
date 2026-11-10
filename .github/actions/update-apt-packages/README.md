# update-apt-packages

Updates version-pinned apt packages in JSON files to the versions that apt currently offers.
The packages of an image are pinned in files that map a package name to a version, e.g. `{"my-package": "1.2.3-1"}`, so builds are reproducible.
This action is meant to run in a scheduled workflow that opens a pull request with the changes, see [update-dependencies.yml](../../workflows/update-dependencies.yml).

For every package in the files the candidate version is looked up with `apt-cache policy`, and the file is rewritten with it.
Packages that are installed in another version than the candidate are reported as updated.

## Usage

```yaml
# in a container with the same apt sources as the image the files are used for
- uses: philips-software/amp-devcontainer/.github/actions/update-apt-packages@...
  id: update-apt-packages
  with:
    input-file: .devcontainer/base/apt-requirements-base.json .devcontainer/cpp/apt-requirements.json
- run: echo '${{ steps.update-apt-packages.outputs.updated-dependencies }}' # ["my-package"]
```

The action must run as root, in an environment with the apt sources of the image the files are for, because it runs `apt-get update` and installs `jq`.
It does not commit the changes, the caller decides what to do with them.

## Inputs and outputs

| Name                   | Kind   | Description                                                           |
|------------------------|--------|-----------------------------------------------------------------------|
| `input-file`           | input  | The JSON file(s) with pinned packages, separated by spaces. Required. |
| `updated-dependencies` | output | JSON array with the names of the packages that were updated.          |

The action fails when a package is not known to apt.

## Tests

The tests stub `apt-cache` with a function and use generated fake packages. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/update-apt-packages/test
```
