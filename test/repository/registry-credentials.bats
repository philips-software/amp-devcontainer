#!/usr/bin/env bats

# Checks that the token of a workflow is only sent to the registry it is valid for, ghcr.io.
# These tests inspect this repository, they do not need a container.

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
}

@test "the identity of the workflow is never the fallback for the credentials of any registry" {
  # `secrets.X || github.token` sends the token to whatever registry is configured, e.g. Docker Hub.
  # The fallback has to be conditional on ghcr.io, as done by the registry-login action.
  run grep -rnE --include='*.yml' --exclude-dir=node_modules \
    'DOCKER_REGISTRY_(USERNAME|PASSWORD) *\|\| *github\.' \
    "${ROOT}/.github"

  assert_failure
  assert_output ""
}

@test "every login to a registry that is not fixed to ghcr.io goes through the registry-login action" {
  run bash -c 'grep -rlE --include="*.yml" --exclude-dir=node_modules "uses: docker/login-action@" "$1" | sort' _ "${ROOT}/.github"

  assert_success
  assert_output "${ROOT}/.github/actions/registry-login/action.yml
${ROOT}/.github/workflows/wc-publish-templates.yml"
}
