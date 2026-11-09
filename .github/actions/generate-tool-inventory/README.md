# generate-tool-inventory

Derives a curated tool inventory of a container image from its SBOM.
An inventory file lists the tools an image promises to provide: which packages, and the commands and files that can be used to check that they are really there.
This action combines that list with the SBOM of the built image, so the versions in the result always come from what was actually built.

The result is used for the release notes (see [render-release-notes](../render-release-notes/README.md)) and as an asset of a release.
The same inventory file is used by the [bats-tool-inventory](../../../helpers/bats-tool-inventory/README.md) helpers to check an image in an integration test.

## Usage

```yaml
- uses: actions/checkout@... # the inventory, and the inventories it includes, have to be checked out
- uses: philips-software/amp-devcontainer/.github/actions/generate-tool-inventory@...
  id: tool-inventory
  with:
    sbom: sbom.spdx.json
    tool-inventory: .devcontainer/my-image/tool-inventory.json
    flavor: my-image
    output-file: tool-inventory.json
```

The runner needs `jq`.

## Inputs and outputs

| Name             | Kind   | Description                                                                                 |
|------------------|--------|---------------------------------------------------------------------------------------------|
| `sbom`           | input  | Path to the Syft SPDX SBOM of the image. Required.                                          |
| `tool-inventory` | input  | Path to the inventory file of the image, see below. Required.                               |
| `flavor`         | input  | Name the inventory is reported under, stored in the `flavor` field of the result. Required. |
| `output-file`    | input  | Path the result is written to. Defaults to `tool-inventory.json`.                           |
| `inventory-file` | output | Path of the result.                                                                         |

The result is a JSON object with the `flavor` and a list of `tools`, sorted by name.
Every tool has a `name`, `version` and `purl` from the SBOM, and the `commands` and `files` from the inventory.
The action fails, without writing the result, when a package in the inventory is not in the SBOM, so a renamed or dropped tool is noticed.
Packages are matched regardless of case.

## Inventory format

An inventory file is a JSON object with an optional `includes` list and a `packages` object:

```json
{
  "includes": ["../base/tool-inventory.json"],
  "packages": {
    "my-tool": {},
    "my-package": {
      "commands": ["my-command"],
      "files": ["/usr/local/share/my-package/my-file"],
      "smoke-test-args": { "my-command": ["--version"] }
    }
  }
}
```

- An empty entry is shorthand for a single command with the name of the package.
- Includes are relative to the declaring file and applied in order. Local packages then replace inherited entries in full.
- Missing includes, include cycles and invalid files are errors.

[resolve.sh](./resolve.sh) resolves a file with its includes to a single object, and can be used on its own.
The bats-tool-inventory helper has its own resolver for this format, see the [version consistency tests](../../../test/repository/version-consistency.bats) that keep the two aligned.

## Tests

The tests use generated fake input. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/generate-tool-inventory/test
```
