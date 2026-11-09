#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-tool-inventory

  DEVCONTAINER_DIR="${BATS_TEST_DIRNAME}/../../.devcontainer"
  INVENTORY="${DEVCONTAINER_DIR}/base/tool-inventory.json"
  APT_REQUIREMENTS=("${DEVCONTAINER_DIR}/base"/apt-requirements*.json)
}

@test "cisco umbrella root certificate is included in system certificate store" {
  run openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/cisco-umbrella-root.pem
  assert_success
  assert_output --partial "OK"
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

# bats test_tags=Compatibility
@test "the C.UTF-8 locale is generated and set as the default" {
  run locale -a
  assert_success
  assert_output --partial "C.utf8"

  assert_equal "${LANG}" "C.UTF-8"
}

@test "default developer account is 'code' with UID and GID 1000" {
  run id -u code
  assert_success
  assert_output "1000"

  run id -g code
  assert_success
  assert_output "1000"

  run id -gn code
  assert_success
  assert_output "code"

  run getent passwd ubuntu
  assert_failure

  run getent group ubuntu
  assert_failure
}

@test "devcontainer metadata selects code as the container user" {
  METADATA="${BATS_TEST_DIRNAME}/../../.devcontainer/base/devcontainer-metadata.json"

  run jq -e '.containerUser == "code"' "${METADATA}"
  assert_success
}

# bats test_tags=Compatibility,Version
@test "GitHub CLI is installed and reports its version" {
  run gh --version
  assert_success
  assert_output --regexp '^gh version [0-9]+\.[0-9]+\.[0-9]+'
}

# bats test_tags=Maintainability
@test "bash-completion is enabled for the code user" {
  run grep -q "bash_completion" /home/code/.bashrc
  assert_success
}

# bats test_tags=Sbom
@test "add-sbom-note tool is installed and executable" {
  run command -v add-sbom-note
  assert_success

  assert [ -x /usr/local/bin/add-sbom-note ]
}
