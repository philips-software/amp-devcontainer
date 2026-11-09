# extract-manifest-digest

Inspects a container image in a registry and outputs the digest of its (multi-architecture) manifest.
The digest is what should be used to refer to an image from then on, for instance to attest, verify, or pin it, because a tag can move.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/extract-manifest-digest@...
  id: extract-digest
  with:
    container: ghcr.io/my-org/my-image:1.2.3
- run: echo "${{ steps.extract-digest.outputs.digest }}" # sha256:…
```

The runner needs a container engine with `buildx`, `jq`, and access to the registry.

## Inputs and outputs

| Name        | Kind   | Description                                                   |
|-------------|--------|---------------------------------------------------------------|
| `container` | input  | Fully qualified image reference, including the tag. Required. |
| `digest`    | output | The digest of the manifest, e.g. `sha256:…`.                  |

The action fails when the image cannot be inspected or the result contains no digest.

## Tests

The tests stub `docker` with a function and use generated fake data. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/extract-manifest-digest/test
```
