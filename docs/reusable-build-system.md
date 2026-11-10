# The re-usable build system

amp-devcontainer is more than a set of containers: the way it builds, tests, and releases them is re-usable.
A repository that derives its own containers from amp-devcontainer can use the same workflows, actions and test helpers, and get the same supply-chain properties without maintaining them.

The build system does not know about the amp-devcontainer containers (the "flavors").
It builds one image, or many: a flavor is just a set of parameters (a Dockerfile, a name, some metadata) that a workflow in the calling repository passes in.
This document describes the building blocks, and the path we recommend to follow, the golden path.

## Building blocks

| Kind                | Location                                           | Purpose                                                                                                        |
|---------------------|----------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| Re-usable workflows | [.github/workflows/wc-*.yml](../.github/workflows) | Build, push, test, and document images. `wc-build-push-test.yml` is the entry point.                           |
| Actions             | [.github/actions](../.github/actions)              | Steps that the workflows are made of, and that can be used on their own. Released separately, as `actions/vX`. |
| Test helpers        | [helpers](../helpers)                              | Bats libraries and tools that are installed in the base image, to test the containers.                         |
| Base image          | [.devcontainer/base](../.devcontainer/base)        | The image to derive from; it contains Bats and the test helpers.                                               |

The actions have a README with their inputs and outputs:

- [container-size-diff](../.github/actions/container-size-diff/README.md): report the size difference between two images
- [extract-manifest-digest](../.github/actions/extract-manifest-digest/README.md): get the digest of an image
- [generate-release-summary](../.github/actions/generate-release-summary/README.md): let Copilot draft the summary of a release
- [generate-tool-inventory](../.github/actions/generate-tool-inventory/README.md): derive the tools of an image from its SBOM
- [merge-devcontainer-metadata](../.github/actions/merge-devcontainer-metadata/README.md): carry over the `devcontainer.metadata` label of the base image
- [render-release-notes](../.github/actions/render-release-notes/README.md): render the release notes of a release
- [update-apt-packages](../.github/actions/update-apt-packages/README.md): update pinned apt packages
- [update-vscode-extensions](../.github/actions/update-vscode-extensions/README.md): update pinned VS Code extensions
- [upload-release-assets](../.github/actions/upload-release-assets/README.md): attach the attestations and tool inventories of images to a release

The helpers are [bats-tool-inventory](../helpers/bats-tool-inventory/README.md), to check the installed tools and apt packages, and [add-sbom-note](../helpers/add-sbom-note/add-sbom-note.sh), to make tools that are not installed by a package manager show up in the SBOM.

## What `wc-build-push-test.yml` does

The workflow [wc-build-push-test.yml](../.github/workflows/wc-build-push-test.yml) takes the description of one image, and does everything from building to testing:

1. **Build**, on every architecture runner, and push by digest. The `devcontainer.metadata` label is merged with the one of the base image.
2. **Merge** the architectures into one multi-architecture image, and tag it: `pr-<number>` for a pull request, `edge` for the merge queue (when enabled), and the semantic versions for a release.
3. **Document the image**: create an SBOM, a build provenance attestation (which is verified right away), the tool inventory, a container diff, and a comment with the size difference with the `edge` image.
4. **Test the image**, by running Bats integration tests in it with Docker, and optionally Podman, and optionally an acceptance test in a Codespace.

The result is an image that is signed, can be traced back to its source, and has been tested with the container runtimes it supports.
Calling it with several images, in a matrix, gives you a family of containers: build the base image first, and pass it as `base-image` and as a build argument to the images that derive from it, like [build-push-test.yml](../.github/workflows/build-push-test.yml) does.

## The golden path

This is the path for a repository that builds its own containers on top of amp-devcontainer.
The files of amp-devcontainer itself follow it, so they can be used as an example.

### 1. Describe the image

Per image, add a directory `.devcontainer/<name>` with:

- a `Dockerfile` that starts `FROM` an amp-devcontainer image, pinned by digest. Let it take the image from an `ARG BASE_IMAGE`, so the same image can be given to the workflow in step 3;
- `apt-requirements*.json` files that pin the apt packages that the Dockerfile installs, as `{"package": "version"}`;
- a `devcontainer-metadata.json` with the settings and VS Code extensions for the dev container;
- a `tool-inventory.json` with the tools that the image promises to provide, see the [inventory format](../.github/actions/generate-tool-inventory/README.md#inventory-format).

Tools that are not installed with a package manager are invisible for SBOM tooling. Annotate them with `add-sbom-note` in the Dockerfile.

### 2. Test the image

Add a Bats file `test/<name>/integration-tests.bats` that uses the helpers from the base image:

```bash
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-tool-inventory

  DEVCONTAINER_DIR="${BATS_TEST_DIRNAME}/../../.devcontainer"
  INVENTORY="${DEVCONTAINER_DIR}/<name>/tool-inventory.json"
  APT_REQUIREMENTS=("${DEVCONTAINER_DIR}"/<name>/apt-requirements*.json)
}

@test "apt packages are installed at their pinned versions" {
  assert_apt_packages_at_pinned_versions "${APT_REQUIREMENTS[@]}"
}

@test "tools listed in the inventory are present in the image" {
  assert_inventory_tools_available "${INVENTORY}"
}

@test "commands listed in the inventory start successfully" {
  assert_inventory_tools_run "${INVENTORY}"
}
```

The tests run inside the image, so the same tests verify the pins, the inventory, and your own checks.
The helpers do not know about flavors: they get the files to check as arguments, so an image that is derived from another can pass the files of both.

### 3. Build, push and test in a workflow

Call the re-usable workflow. Pin it by commit SHA of a release, so your build only changes when you decide:

```yaml
jobs:
  build-push-test:
    uses: philips-software/amp-devcontainer/.github/workflows/wc-build-push-test.yml@<sha> # <version>
    permissions:
      actions: read
      artifact-metadata: write
      attestations: write
      contents: write
      id-token: write
      packages: write
      pull-requests: write
    with:
      base-image: ghcr.io/philips-software/amp-devcontainer-<flavor>@sha256:<digest>
      build-args: BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-<flavor>@sha256:<digest>
      dockerfile: .devcontainer/<name>/Dockerfile
      image-name: ${{ github.repository }}-<name>
      devcontainer-metadata-file: .devcontainer/<name>/devcontainer-metadata.json
      integration-test-file: test/<name>/integration-tests.bats
      tool-inventory-file: .devcontainer/<name>/tool-inventory.json
```

The permissions are what the jobs in the workflow need, the workflow has a comment per permission.
The inputs of the workflow are documented in the workflow file.
The `base-image` is the image of the `FROM` line.
Without it the `devcontainer.metadata` label of your image only has your own metadata, and the VS Code extensions and settings of the base image are lost.
Run the workflow for pull requests, and for the merge queue with `enable-edge-tag` so there is always an `edge` image to compare with.

### 4. Keep the pins up to date

Pinned apt packages and VS Code extensions are updated by [update-apt-packages](../.github/actions/update-apt-packages/README.md) and [update-vscode-extensions](../.github/actions/update-vscode-extensions/README.md), run in a schedule that opens a pull request, see [update-dependencies.yml](../.github/workflows/update-dependencies.yml).
Dependabot keeps the pinned actions, Dockerfile base images and other dependencies up to date.
The integration tests of step 2 fail when a pin and the installed package disagree.

### 5. Release

Releases are created with [release-please](https://github.com/googleapis/release-please) from [conventional commits](https://www.conventionalcommits.org), see [release-please.yml](../.github/workflows/release-please.yml).
Publishing the release runs [release-build.yml](../.github/workflows/release-build.yml): it builds, pushes and tests the images again, now with the semantic version tags, and then:

- writes the release notes with the re-usable workflow [wc-release-notes.yml](../.github/workflows/wc-release-notes.yml), which is given the images, the tag and the image to render with (see its [usage](#release-notes-workflow)):
  - drafts a summary of the release with Copilot, in a job with a read-only token that is billed to the organization with [generate-release-summary](../.github/actions/generate-release-summary/README.md). A summary that can't be generated never fails the release;
  - renders the release notes with [render-release-notes](../.github/actions/render-release-notes/README.md), with the summary, and the digests and tool inventories of the images, and can be run again without duplicating text;
  - uploads the attestations and tool inventories as release assets with [upload-release-assets](../.github/actions/upload-release-assets/README.md);
- generates the documents (see [wc-document-generation.yml](../.github/workflows/wc-document-generation.yml)) and publishes the dev container templates.

#### Release notes workflow

Call it from the workflow that builds your release, after the images are built, and list the images of the release once:

```yaml
release-notes:
  needs: [build-push-test]
  uses: philips-software/amp-devcontainer/.github/workflows/wc-release-notes.yml@<sha> # <version>
  with:
    images: |
      ghcr.io/my-org/my-image-alpha
      ghcr.io/my-org/my-image-beta
    release-tag: ${{ github.ref_name }}
    render-image: ghcr.io/philips-software/amp-devcontainer-docs # the version of the release is used as tag
  permissions:
    actions: read # to download the tool inventories
    contents: write # to modify the release
    copilot-requests: write # to bill Copilot CLI to the organization, the workflow can't request more than the caller grants
```

The tool inventories are the artifacts `tool-inventory-<image basename>` of the same workflow run, which [wc-build-push-test.yml](../.github/workflows/wc-build-push-test.yml) creates.
Optionally pass `template-file` with a template of your own, see [render-release-notes](../.github/actions/render-release-notes/README.md).

### 6. Verify

Everyone that uses an image can verify where it comes from:

```sh
gh attestation verify --repo <owner>/<repository> \
  --signer-workflow philips-software/amp-devcontainer/.github/workflows/wc-build-push.yml \
  oci://<registry>/<image>@<digest>
```

The attestation is signed by the re-usable workflow [wc-build-push.yml](../.github/workflows/wc-build-push.yml) of amp-devcontainer, not by a workflow in your repository.
Without `--signer-workflow`, the verification expects the signing workflow in `<owner>/<repository>` and fails.
The workflows of this repository and the [upload-release-assets](../.github/actions/upload-release-assets/README.md) action do this for you.

## Versioning and pinning

The workflows and actions are referenced by commit SHA, with the version as a comment, so they never change without a pull request.
The workflows are released together with the containers (`vX.Y.Z`), and the actions are released on their own (`actions/vX.Y.Z`).
Inside this repository the workflows call each other with `$/.github/workflows/...`, which means the same repository and version as the calling workflow.

Versions that are pinned in more than one place are checked by the [version consistency tests](../test/repository/version-consistency.bats), so all uses of an action, container image or tool are updated together.

## Testing the build system itself

The actions, helpers and the consistency of the pins have tests that do not need a container build:

```bash
bats helpers/*/test .github/actions/*/test test/repository                    # in the amp-devcontainer-docs container, or with Bats installed
npm ci --ignore-scripts --prefix .github/actions/container-size-diff && npm test --prefix .github/actions/container-size-diff
```

They run in the pull request checks, in the jobs `Helper, Action & Repository Tests` and `Node.js Action Tests` of [continuous-integration.yml](../.github/workflows/continuous-integration.yml), independent of building the containers.
The tests use generated fake input, and stub the commands that talk to a registry or to GitHub.
