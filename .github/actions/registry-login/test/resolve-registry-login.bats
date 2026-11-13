#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../resolve-registry-login.sh"
  GITHUB_OUTPUT="${BATS_TEST_TMPDIR}/github-output"
  : > "${GITHUB_OUTPUT}"

  export GITHUB_OUTPUT
  unset REGISTRY REGISTRY_USERNAME REGISTRY_PASSWORD REQUIRE_CREDENTIALS
}

# The decision is the only output of the script.
authentication() {
  sed -n 's/^authentication=//p' "${GITHUB_OUTPUT}"
}

@test "given credentials are used for any registry" {
  for registry in ghcr.io registry.example.invalid; do
    : > "${GITHUB_OUTPUT}"
    REGISTRY=${registry} REGISTRY_USERNAME=fake-user REGISTRY_PASSWORD=fake-password run bash "${SCRIPT}"

    assert_success
    assert_equal "$(authentication)" credentials
  done
}

@test "the identity of the workflow is used for ghcr.io without credentials" {
  REGISTRY=ghcr.io run bash "${SCRIPT}"

  assert_success
  assert_equal "$(authentication)" github
}

@test "ghcr.io is recognized in any case, and only as the whole registry" {
  REGISTRY=GHCR.io run bash "${SCRIPT}"
  assert_success
  assert_equal "$(authentication)" github

  : > "${GITHUB_OUTPUT}"
  for registry in ghcr.io.example.invalid fake-ghcr.io example.invalid:5000; do
    REGISTRY=${registry} run bash "${SCRIPT}"
    assert_success
    assert_equal "$(authentication)" anonymous
    : > "${GITHUB_OUTPUT}"
  done
}

@test "other registries are used anonymously without credentials" {
  REGISTRY=registry.example.invalid run bash "${SCRIPT}"

  assert_success
  assert_output --partial "using it anonymously"
  assert_equal "$(authentication)" anonymous
}

@test "other registries without credentials fail when credentials are required" {
  REGISTRY=registry.example.invalid REQUIRE_CREDENTIALS=true run bash "${SCRIPT}"

  assert_failure
  assert_output --partial "No credentials for registry.example.invalid"
  assert_equal "$(authentication)" ""
}

@test "credentials are not required for ghcr.io, the identity of the workflow can push" {
  REGISTRY=ghcr.io REQUIRE_CREDENTIALS=true run bash "${SCRIPT}"

  assert_success
  assert_equal "$(authentication)" github
}

@test "credentials are only required when asked for" {
  REGISTRY=registry.example.invalid REQUIRE_CREDENTIALS=false run bash "${SCRIPT}"

  assert_success
  assert_equal "$(authentication)" anonymous
}

@test "a username without a password or the other way around is refused" {
  for registry in ghcr.io registry.example.invalid; do
    REGISTRY=${registry} REGISTRY_USERNAME=fake-user run bash "${SCRIPT}"
    assert_failure
    assert_output --partial "Only one of the username and the password of ${registry}"

    REGISTRY=${registry} REGISTRY_PASSWORD=fake-password run bash "${SCRIPT}"
    assert_failure
    assert_output --partial "Only one of the username and the password of ${registry}"
  done
  assert_equal "$(authentication)" ""
}

@test "the credentials are never printed" {
  REGISTRY=registry.example.invalid REGISTRY_USERNAME=fake-user REGISTRY_PASSWORD=fake-password run bash "${SCRIPT}"

  assert_success
  refute_output --partial fake-password
  run cat "${GITHUB_OUTPUT}"
  refute_output --partial fake-password
}

@test "the script fails without a registry or output file" {
  run env -u REGISTRY bash "${SCRIPT}"
  assert_failure
  assert_output --partial "registry required"

  run env -u GITHUB_OUTPUT REGISTRY=ghcr.io bash "${SCRIPT}"
  assert_failure
  assert_output --partial "GITHUB_OUTPUT required"
}
