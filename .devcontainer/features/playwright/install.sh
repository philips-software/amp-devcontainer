#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

npm exec --yes --package="playwright@${VERSION}" -- playwright install-deps chromium
