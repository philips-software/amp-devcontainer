# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-base:edge
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

# Set default environment options
ENV PYTHONPYCACHEPREFIX=/cache/.python

# Install the base system with all tool dependencies
RUN --mount=type=bind,source=.devcontainer/docs/apt-requirements.json,target=/tmp/apt-requirements.json \
    --mount=type=bind,source=.devcontainer/docs/requirements.txt,target=/tmp/requirements.txt \
    --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked <<EOF

    # Install the base system with all tool dependencies
    apt-get update && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements.json | \
        xargs apt-get install -y --no-install-recommends

    # Install some tools via pip to get more recent versions, clean up afterwards
    python3 -m pip install --break-system-packages --require-hashes --no-cache-dir --no-compile -r /tmp/requirements.txt
    find / -regex '^.*\(__pycache__\|\.py[co]\)$' -delete
    rm -rf "$(pip cache dir)"

    # Update python alternative to the correct version
    update-alternatives --install /usr/bin/python python /usr/bin/python3 10
EOF
