# replicate-image-tags

Verifies the attestation of a released container image, and copies the image to more tags, in the same registry or in other registries.
This makes the images of a release available in more than one registry, such as Docker Hub or Artifactory, without building them again.
The copy has the same digest as the image of the release, so the attestation, SBOM and tool inventory of the release are valid for it too.

The action:

1. resolves the digest of `source-image:release-tag`;
2. verifies the attestation of that digest, against the repository that built it and optionally the re-usable workflow that signed it;
3. checks every tag: a tag that does not exist is going to be created, a tag that has the digest is left alone, and a tag that has another digest fails the action, because a tag is never moved;
4. creates all missing tags in one `docker buildx imagetools create`, which copies the manifests and blobs between registries and keeps the digest;
5. checks that every tag resolves to the verified digest.

Everything is checked before the first tag is written, and writing a tag that is in place does nothing, so the action can be run again after a failure.
A registry that can't be read, for example because of a login that is not valid, fails the action: it is not taken for a tag that does not exist.

## Usage

Log in to the registry of the image and to the target registry first, with [registry-login](../registry-login/README.md):

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/registry-login@...
  with:
    registry: ghcr.io
- uses: philips-software/amp-devcontainer/.github/actions/registry-login@...
  with:
    password: ${{ secrets.MY_REGISTRY_PASSWORD }}
    registry: registry.example.invalid
    require-credentials: true
    username: ${{ secrets.MY_REGISTRY_USERNAME }}
- uses: philips-software/amp-devcontainer/.github/actions/replicate-image-tags@...
  with:
    release-tag: ${{ github.ref_name }}
    source-image: ghcr.io/my-org/my-image
    tags: |
      registry.example.invalid/my-org/my-image:1.2.3
      registry.example.invalid/my-org/my-image:latest
```

The tags can come from `docker/metadata-action`, which is what [wc-replicate-images.yml](../../workflows/wc-replicate-images.yml) does to give the copies the tags of the release.
The caller needs `attestations: read` for private and internal repositories, `packages: read` when the image is in a private GitHub Container Registry, and a container engine with `buildx`, the GitHub CLI and `jq` on the runner.

## Inputs and outputs

| Name              | Kind   | Required | Description                                                                                                                                                  |
|-------------------|--------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `github-token`    | input  | no       | Token used to verify the attestation. Defaults to the workflow token.                                                                                        |
| `release-tag`     | input  | yes      | Tag of the source image that identifies the image to copy.                                                                                                   |
| `signer-workflow` | input  | no       | Re-usable workflow that signed the attestation, as `<owner>/<repository>/<path>`. Defaults to `wc-build-push.yml` of amp-devcontainer.                       |
| `source-image`    | input  | yes      | The image to copy, without tag.                                                                                                                              |
| `tags`            | input  | yes      | Newline-separated image references, including the tag, that the image is copied to. At least one.                                                            |
| `digest`          | output | -        | Digest of the image that all the tags have.                                                                                                                  |

The action fails when the image of the release does not exist, when its attestation can't be verified, when a tag has another digest, when a registry can't be read or written, when a reference has no tag, or when there are no tags.

> [!NOTE]
> The check of a tag and the write are not atomic, because registries have no conditional write for a tag. A tag that another run creates in between, with another digest, is overwritten. Don't run two replications of the same tags at the same time.
> Registries differ in the message for a tag or repository that does not exist. The action recognizes `not found`, `manifest unknown`, `name unknown` and `does not exist`, and fails on anything else, so a new message is reported as an error and not as a missing tag.

## Tests

The tests stub `gh` and `docker` with functions and use generated fake images, digests and registries. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/replicate-image-tags/test
```
