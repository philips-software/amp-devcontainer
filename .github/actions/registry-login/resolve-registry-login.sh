#!/usr/bin/env bash
# Decide how to log in to a container registry, see README.md.
#
# The token of a workflow is only valid for the GitHub Container Registry, so it is never sent to
# another registry. Without credentials such a registry is used anonymously, which is enough to pull
# public images but not to push.
#
# Environment:
#   REGISTRY             registry to log in to, e.g. ghcr.io
#   REGISTRY_USERNAME    username of the registry (optional)
#   REGISTRY_PASSWORD    password or token of the registry (optional)
#   REQUIRE_CREDENTIALS  true when anonymous access is not enough, e.g. to push images (default: false)
#   GITHUB_OUTPUT        file the output `authentication` is appended to

set -Eeuo pipefail

registry=${REGISTRY:?registry required}
username=${REGISTRY_USERNAME-}
password=${REGISTRY_PASSWORD-}
require_credentials=${REQUIRE_CREDENTIALS:-false}

if [[ -n "${username}" && -n "${password}" ]]; then
  authentication=credentials
elif [[ -n "${username}" || -n "${password}" ]]; then
  echo "::error::Only one of the username and the password of ${registry} is set, set both or neither" >&2
  exit 1
elif [[ "${registry,,}" == "ghcr.io" ]]; then
  authentication=github
elif [[ "${require_credentials}" == "true" ]]; then
  echo "::error::No credentials for ${registry}, which can't be used anonymously here. The identity of the workflow is only valid for ghcr.io" >&2
  exit 1
else
  echo "::notice::No credentials for ${registry}, using it anonymously"
  authentication=anonymous
fi

printf 'authentication=%s\n' "${authentication}" >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT required}"
