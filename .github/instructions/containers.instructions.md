---
description: "Use when changing a container flavor: Dockerfiles, apt-requirements, tool-inventory.json, devcontainer.json and devcontainer-metadata.json in .devcontainer, or dev container templates."
applyTo: ".devcontainer/**, templates/**"
---

# Container Guidelines

- Pin everything. Base images by digest, downloads with `ADD --checksum=sha256:…`, apt packages by exact version in `apt-requirements*.json` (`{"package": "version"}`), installed with `apt-get install --no-install-recommends`. Don't invent versions: look them up, or leave pin updates to the update-dependencies workflow and Dependabot.
- Keep the layers of a Dockerfile small and cache-friendly. Use the `SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]` and bind or cache mounts like [the base Dockerfile](../../.devcontainer/base/Dockerfile). A `# hadolint ignore=` needs a reason.
- A flavor derives from the base image (`ARG BASE_IMAGE`) and doesn't repeat what it provides. The containers run as the non-root user `code`.
- A tool that is not installed by a package manager is invisible in the SBOM: annotate it with `add-sbom-note` in the Dockerfile.
- Every tool a flavor promises is in its `tool-inventory.json`, and checked by its integration tests in `test/<flavor>`. Reuse other inventories with `includes`. Adding, removing or renaming a tool updates the inventories of all affected flavors, see [CONTRIBUTING.md](../CONTRIBUTING.md).
- Extensions and settings of the dev container are in `devcontainer-metadata.json`, which is merged with the one of the base image. `requirements.txt` is generated from `requirements.in`, don't edit it.
- Image size is a cost: justify what you add, and prefer removing caches in the same layer.
- The `version` fields of `/templates` are managed by release-please.
- Containers can't be built in every environment. When you can't build or run the tests, say so rather than implying they pass.
