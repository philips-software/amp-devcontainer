# render-release-notes

Renders the placeholders in the notes of a GitHub release, optionally after applying a template.
The action does not know anything about container flavors; it renders the images it is given.
Which images exist, and what they are called, is decided by the calling workflow.

The release is read once, rendered completely in memory, and edited once.
When anything fails, for instance an image digest that cannot be resolved or a placeholder without a value, the release is left untouched.

## Usage

```yaml
- uses: actions/download-artifact@... # downloads tool-inventory-<image-basename>/tool-inventory.json
  with:
    pattern: tool-inventory-*
- uses: philips-software/amp-devcontainer/.github/actions/render-release-notes@...
  with:
    images: |
      ghcr.io/my-org/my-image-alpha
      ghcr.io/my-org/my-image-beta
    release-tag: ${{ github.ref_name }}
    template-file: .github/RELEASE_TEMPLATE.md
```

The caller needs `contents: write` to edit the release.

### Inputs

| Input | Required | Description |
| --- | --- | --- |
| `images` | yes | Newline-separated image references without tag. The last path segment is the *image basename* used in placeholders. |
| `release-tag` | yes | Tag of the release to render. The images are expected to carry the same tag. |
| `inventory-directory` | no | Directory with a `tool-inventory-<image-basename>/tool-inventory.json` file per image, as produced by the [generate-tool-inventory](../generate-tool-inventory/action.yml) action and downloaded as artifact. Defaults to `.`. |
| `template-file` | no | Template that is inserted directly after the first `## ` header of the notes before rendering. Notes without a header get the template prepended. |
| `github-token` | no | Token used to read and edit the release. Defaults to the workflow token. |

## Placeholders

A placeholder has the form

```text
{{ <namespace>[.<subject>].<attribute> }}
```

- The **namespace** is the first dot-separated segment, and says what kind of thing the placeholder refers to.
- The **attribute** is the last segment, and says which property of it is rendered.
- The **subject** is everything in between, and identifies one particular thing of that kind. It can contain dots and dashes.
- Names consist of lowercase letters, digits and dashes, and start with a letter. Whitespace inside the braces is ignored; use a single space by convention.
- Text between double braces that does not follow this form is not a placeholder and is left as is.
- A placeholder without a value is an error that fails the render, so typos never end up in a published release.
- Values are inserted literally; they are never interpreted again.

### Namespaces

| Placeholder | Value |
| --- | --- |
| `{{ image.<image-basename>.version }}` | The tag of the image, which is the release tag. |
| `{{ image.<image-basename>.digest }}` | The digest of the multi-architecture image manifest, e.g. `sha256:…`. |
| `{{ image.<image-basename>.tools }}` | A markdown table with the packages, versions, commands and files of the image's tool inventory. |
| `{{ release.<attribute> }}` | Reserved for values of the release itself. No attributes are defined yet. |

The image basename is the last path segment of the image reference, so `ghcr.io/my-org/my-image-alpha` is referred to as `my-image-alpha`, as in `{{ image.my-image-alpha.digest }}`.

When adding a new kind of value, pick a new namespace (or a new attribute of an existing one) instead of encoding the meaning in a longer name, and add it to the table above.

## Tests

The tests use generated fake input and stub the `gh` and `docker` commands. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/render-release-notes/test
```
