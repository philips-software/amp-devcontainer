# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/philips-software/amp-devcontainer-base:edge
FROM ${BASE_IMAGE}

USER 0:0

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

# Set default environment options
ENV PYTHONPYCACHEPREFIX=/home/code/.cache/python

# The sequence is important. Hadolint (2.15) forgets the shell when there are other options in between SHELL and RUN
SHELL ["/bin/bash", "-Eeuo", "pipefail", "-c"]

RUN --mount=type=bind,source=.devcontainer/docs/apt-requirements.json,target=/tmp/apt-requirements.json \
    --mount=type=bind,source=.devcontainer/docs/requirements.txt,target=/tmp/requirements.txt \
    --mount=type=cache,target=/cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/log,sharing=locked <<EOF

    export PYTHONPYCACHEPREFIX=/cache/.python

    # Install the base system with all tool dependencies
    apt-get update && jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt-requirements.json | \
        xargs apt-get install -y --no-install-recommends

    # Install some tools via pip to get more recent versions, clean up afterwards
    # SBDL publishes only source archives; its reviewed setuptools packaging is version- and hash-locked.
    python3 -m pip install --break-system-packages --require-hashes --only-binary :all: --no-binary sbdl --no-cache-dir --no-compile -r /tmp/requirements.txt
    find / -regex '^.*\(__pycache__\|\.py[co]\)$' -delete
    rm -rf "$(pip cache dir)"

    # Update python alternative to the correct version
    update-alternatives --install /usr/bin/python python /usr/bin/python3 10
EOF

# Create runtime directories outside the BuildKit cache mount so they persist in the image.
RUN install -d -m 0755 -o code -g code /home/code/.cache /home/code/.cache/python

USER 1000:1000
