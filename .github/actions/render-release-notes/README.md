# render-release-notes

Renders a [Jinja2](https://jinja.palletsprojects.com) template with the data of released container images, and inserts the result into the notes of a GitHub release.
The action does not know anything about container flavors; it renders the images it is given.
Which images exist, and what they are called, is decided by the calling workflow, and a template can loop over the images without naming any of them.

The template is rendered by [render.py](./render.py) in a container, so no tooling needs to be installed on the runner.
Only the rendered template is inserted, directly after the first level-2 (`##`) header of the notes, the existing notes are never interpreted as a template.
The inserted text is put between two marker comments, `<!-- render-release-notes:start -->` and `<!-- render-release-notes:end -->`, which are not shown in the release notes.
Rendering a release again replaces the text between the markers, so it is safe to run more than once, and text that was added by hand outside of the markers is kept.
The action fails, without editing the release, when the markers in the notes don't match up.
The release is read once, rendered completely, and edited once.
When anything fails, for instance an image digest that cannot be resolved or a variable that does not exist, the release is left untouched.

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
    render-image: ghcr.io/philips-software/amp-devcontainer-docs:<version>@<digest>
```

The caller needs `contents: write` to edit the release, and a container engine to resolve digests and render.
Log in to the registry of the images before the action when they are private.

To get the release notes together with the release assets, and optionally a Copilot-drafted summary, use the re-usable workflow [wc-release-notes.yml](../../workflows/wc-release-notes.yml) instead, which also takes care of the login, see the [release step](../../../docs/reusable-build-system.md#release-notes-workflow) of the golden path.

### Inputs

| Input                 | Required | Description                                                                                                                                                                                                                    |
|-----------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `images`              | yes      | Newline-separated image references without tag. The last path segment is the *image basename*, the key of the image in the template.                                                                                           |
| `release-tag`         | yes      | Tag of the release to render. The images are expected to carry the same tag.                                                                                                                                                   |
| `render-image`        | yes      | Container image with python3 and jinja2, e.g. an amp-devcontainer-docs image. The rendering runs without network access.                                                                                                       |
| `template-file`       | no       | Path to the Jinja2 template. Defaults to the [default template](./default-template.md.j2) of the action.                                                                                                                       |
| `summary-file`        | no       | File with a summary of the release, e.g. from [generate-release-summary](../generate-release-summary/README.md), available in the template as `release.summary`. A file that does not exist counts as no summary.              |
| `inventory-directory` | no       | Directory with a `tool-inventory-<image-basename>/tool-inventory.json` file per image, as produced by the [generate-tool-inventory](../generate-tool-inventory/action.yml) action and downloaded as artifact. Defaults to `.`. |
| `github-token`        | no       | Token used to read and edit the release. Defaults to the workflow token.                                                                                                                                                       |

## Default template

Without a `template-file` the [default template](./default-template.md.j2) is used.
It lists the images in a table with their full identifiers, and the included tools of every image in a collapsible section.
The summary is the `release.summary` when there is one, with a note that it was drafted by GitHub Copilot, and a placeholder for the release manager to fill in when there is not.
It loops over the images instead of naming them, so the same layout can be reused for any set of images.
To change the layout, pass your own template; copying the default template is a good starting point.

## Migrating a template

A template that substitutes placeholders (`{{ my-placeholder }}` that is replaced by a script) has to be a Jinja2 template: a name with dashes is not a valid variable, it is a subtraction, and a variable that does not exist is an error.
Use the variables below instead of placeholders:

| Placeholder of a script       | Template variable                                                        |
|-------------------------------|--------------------------------------------------------------------------|
| The version of the release    | `{{ release.tag }}`                                                      |
| The digest of the image       | `{{ images["<image basename>"].digest }}`                                |
| A table of the included tools | A loop over `images["<image basename>"].tools`, see the default template |

The action inserts the rendered template itself, so a step that inserts the template into the release notes and a second step that substitutes the placeholders can both be replaced by one call of the action.

## Template variables

The template has the following variables.
Using a variable, or an attribute of a variable, that does not exist is an error, so typos never end up in a published release.
Values are inserted as they are; there is no HTML escaping.

| Variable                      | Value                                                                                    |
|-------------------------------|------------------------------------------------------------------------------------------|
| `release.tag`                 | The tag of the release.                                                                  |
| `release.summary`             | A summary of the release from the `summary-file`, or an empty text when there is none.   |
| `images`                      | The images of the release by image basename, in the order they were given to the action. |
| `images[<name>].reference`    | The image reference without tag, e.g. `ghcr.io/my-org/my-image-alpha`.                   |
| `images[<name>].version`      | The tag of the image, which is the release tag.                                          |
| `images[<name>].digest`       | The digest of the multi-architecture image manifest, e.g. `sha256:…`.                    |
| `images[<name>].tools`        | The tools of the image's tool inventory.                                                 |
| `images[<name>].tools[].name` | The name of a tool, followed by `version`, `commands` (list) and `files` (list).         |

The image basename is the last path segment of the image reference, so `ghcr.io/my-org/my-image-alpha` is named `my-image-alpha`.
Images are looked up by name, which is not a valid identifier because of the dashes: use `images["my-image-alpha"].digest`, or loop over the images:

```jinja
{% for name, image in images.items() %}
| {{ name }} | {{ image.reference }}:{{ image.version }}@{{ image.digest }} |
{% endfor %}
```

Naming conventions for variables, to keep templates predictable:

- The first segment says what kind of thing a variable is (`release`, `images`); plural names are collections that are looped over or looked up by name, singular names are a single thing.
- Attributes are lowercase and describe a single property (`tag`, `digest`); nothing is encoded in a longer name.
- When adding a new kind of value, add a new top-level variable (or a new attribute of an existing one) in the data assembly of [render-release-notes.sh](./render-release-notes.sh) and to the table above.

Blocks (`{% … %}`) do not leave an empty line behind: the first newline after a block is removed, and whitespace before a block is stripped.

## Tests

The tests use generated fake input, and stub the `gh` and `docker` commands with functions.
They need Bats, jq, python3 and jinja2, which the amp-devcontainer-docs image provides. Run them from the repository root:

```bash
bats .github/actions/render-release-notes/test
```
