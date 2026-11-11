# select-image-version

Selects the version of the image that an acceptance test of a workflow uses, following the tags that [wc-build-push.yml](../../workflows/wc-build-push.yml) pushes:

| Event of the workflow                                 | Version             |
|-------------------------------------------------------|---------------------|
| a pull request                                        | `pr-<number>`       |
| any event on a tag, e.g. a release or a manual run    | the name of the tag |
| anything else, e.g. the merge queue or a push to main | `edge`              |

## Usage

```yaml
- id: version
  uses: philips-software/amp-devcontainer/.github/actions/select-image-version@...
- run: echo "${VERSION}"
  env:
    VERSION: ${{ steps.version.outputs.version }}
```

The inputs default to the event and ref of the workflow, so a workflow does not have to pass anything.

## Inputs and outputs

| Name         | Kind   | Description                                                   |
|--------------|--------|---------------------------------------------------------------|
| `event-name` | input  | Name of the event. Defaults to `github.event_name`.           |
| `pr-number`  | input  | Number of the pull request. Defaults to the one of the event. |
| `ref-name`   | input  | Name of the ref. Defaults to `github.ref_name`.               |
| `ref-type`   | input  | Type of the ref. Defaults to `github.ref_type`.               |
| `version`    | output | The tag of the image.                                         |

## Tests

Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/select-image-version/test
```
