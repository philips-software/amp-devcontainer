#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  popd
}

## This section contains tests for version correctness of the installed tools.
#  Comparing the versions of the installed tools with the expected versions as
#  pinned in the flavor's apt- and pip-requirements.

# bats test_tags=Version,Graphviz
@test "graphviz version should be aligned with the expected version" {
  EXPECTED_VERSION=$(get_expected_semver_for graphviz)
  INSTALLED_VERSION=$(dot -V 2>&1 | to_semver)

  assert_equal "$INSTALLED_VERSION" "$EXPECTED_VERSION"
}

# bats test_tags=Version,Pip
@test "pip version should be aligned with the expected version" {
  EXPECTED_VERSION=$(get_expected_semver_for python3-pip)
  INSTALLED_VERSION=$(pip --version | to_semver)

  assert_equal "$INSTALLED_VERSION" "$EXPECTED_VERSION"
}

# bats test_tags=Version,Sbdl
@test "sbdl version should be aligned with the expected version" {
  EXPECTED_VERSION=$(grep sbdl ${BATS_TEST_DIRNAME}/../../.devcontainer/docs/requirements.in | to_semver)
  INSTALLED_VERSION=$(sbdl --version | to_semver)

  assert_equal "$INSTALLED_VERSION" "$EXPECTED_VERSION"
}

## This section contains tests for the functional correctness of the installed tools.

# bats test_tags=Functional,Plantuml
@test "plantuml should render a diagram to a png image" {
  run plantuml -o build -tpng diagram.puml

  assert_success
  assert [ -f build/diagram.png ]
}

# bats test_tags=Functional,Graphviz
@test "graphviz should render a graph to an svg image" {
  run dot -Tsvg graph.dot

  assert_success
  assert_output --partial "<svg"
}

# bats test_tags=Functional,Sbdl
@test "sbdl should compile a requirements model" {
  run sbdl -m compile sample.sbdl

  assert_success
  assert_output --partial "req-doc-0001 is requirement"
}

function to_semver() {
  grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n1
}

function get_expected_version_for() {
  local TOOL=${1:?}

  jq -r "to_entries[] | select(.key | startswith(\"${TOOL}\")) | .value | sub(\"-.*\"; \"\")" \
    ${BATS_TEST_DIRNAME}/../../.devcontainer/docs/apt-requirements.json
}

function get_expected_semver_for() {
  local TOOL=${1:?}

  get_expected_version_for ${TOOL} | to_semver
}
