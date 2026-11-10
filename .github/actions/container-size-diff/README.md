# container-size-diff

Creates a markdown report of the size difference between two versions of a container image, per platform.
It is meant to be posted as a comment on a pull request, so reviewers see what a change does to the size of the image, e.g. by comparing the image of the pull request with the latest image of the default branch.

The size of an image is the compressed size of its layers.
The report has the sizes before and after, the change in size and percentage, and a trend icon per platform.
The two images must be built for the same platforms.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/container-size-diff@...
  id: container-size-diff
  with:
    from-container: ghcr.io/my-org/my-image:edge
    to-container: ghcr.io/my-org/my-image:pr-123
- uses: marocchino/sticky-pull-request-comment@...
  with:
    message: ${{ steps.container-size-diff.outputs.size-diff-markdown }}
```

The runner needs a container engine with access to the registry.
The action installs Node.js and its own dependencies.

## Inputs and outputs

| Name                 | Kind   | Description                                           |
|----------------------|--------|-------------------------------------------------------|
| `from-container`     | input  | The baseline image to compare with. Required.         |
| `to-container`       | input  | The image that is compared to the baseline. Required. |
| `size-diff-markdown` | output | The markdown report.                                  |

The action fails when an image cannot be inspected, has no platforms, or when the platforms of the images differ.

## Tests

The logic is in [container-size-diff.js](./container-size-diff.js), and is tested with the Node.js test runner using generated fake manifests, without a container engine.
Install the dependencies and run the tests in this directory:

```bash
npm ci --ignore-scripts
npm test
```
