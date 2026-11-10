# merge-devcontainer-metadata

Assembles the `devcontainer.metadata` label of an image that is derived from another image.
Dev container tooling reads this label to configure the container, e.g. the VS Code extensions and settings.
A derived image should keep the metadata of the image it is built from, and add its own, so the label of the base image has to be carried over instead of replaced.

The action concatenates the entries of the base image's label with the image's own metadata entry, and outputs the result as a value for `docker build --label`.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/merge-devcontainer-metadata@...
  id: devcontainer-metadata
  with:
    base-image: ghcr.io/my-org/my-base-image@sha256:…
    devcontainer-metadata-file: .devcontainer/my-image/devcontainer-metadata.json
- uses: docker/build-push-action@...
  with:
    labels: ${{ steps.devcontainer-metadata.outputs.label }}
```

The runner needs a container engine with `buildx` and `jq`, and access to the registry of the base image.

## Inputs and outputs

| Name                         | Kind   | Description                                                                                                     |
|------------------------------|--------|-----------------------------------------------------------------------------------------------------------------|
| `base-image`                 | input  | Reference of the image the image is built from. Optional, without it the label only has the entry of the image. |
| `devcontainer-metadata-file` | input  | JSON file with the metadata entry (an object) of the image. Optional, without it no label is produced.          |
| `label`                      | output | `devcontainer.metadata=<json-array>`, or empty when there is no metadata file.                                  |

A base image without the label, or with a label that is not a JSON array, counts as having no entries.
For a multi-platform base image the label of the first platform is used, the label is the same for all platforms.
The label has a space after the commas between strings, otherwise `docker build --label` splits the value at the comma and produces invalid JSON.

## Tests

The tests stub `docker` with a function and use generated fake data. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/merge-devcontainer-metadata/test
```
