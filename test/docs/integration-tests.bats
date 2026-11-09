#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-tool-inventory

  DEVCONTAINER_DIR="${BATS_TEST_DIRNAME}/../../.devcontainer"
  INVENTORY="${DEVCONTAINER_DIR}/docs/tool-inventory.json"
  APT_REQUIREMENTS=("${DEVCONTAINER_DIR}"/{base,docs}/apt-requirements*.json)

  pushd ${BATS_TEST_DIRNAME}/workspace
}

teardown() {
  rm -rf build

  popd
}

# bats test_tags=Compatibility,Version
@test "apt packages are installed at their pinned versions" {
  assert_apt_packages_at_pinned_versions "${APT_REQUIREMENTS[@]}"
}

# bats test_tags=Sbom
@test "tools listed in the inventory are present in the image" {
  assert_inventory_tools_available "${INVENTORY}"
}

# bats test_tags=Functional
@test "commands listed in the inventory start successfully" {
  assert_inventory_tools_run "${INVENTORY}"
}

# bats test_tags=Version,Sbdl
@test "sbdl version should be aligned with the expected version" {
  EXPECTED_VERSION=$(grep sbdl ${BATS_TEST_DIRNAME}/../../.devcontainer/docs/requirements.in | to_semver)
  INSTALLED_VERSION=$(sbdl --version | to_semver)

  assert_tool_version sbdl "${INSTALLED_VERSION}" "${EXPECTED_VERSION}"
}

@test "python cache directory is writable by the code user" {
  assert_equal "$(id -un)" code
  run touch /home/code/.cache/.write-test /home/code/.cache/python/.write-test
  assert_success

  rm -f /home/code/.cache/.write-test /home/code/.cache/python/.write-test
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
