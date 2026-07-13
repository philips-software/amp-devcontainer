#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '/usr/local/bats-support/load'
  load '/usr/local/bats-assert/load'
}

@test "cisco umbrella root certificate is included in system certificate store" {
  run openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/cisco-umbrella-root.pem
  assert_success
  assert_output --partial "OK"
}

# bats test_tags=Compatibility,Version
@test "apt packages are installed at their pinned versions" {
  APT_REQUIREMENTS="${BATS_TEST_DIRNAME}/../../.devcontainer/base/apt-requirements.json"

  while IFS="=" read -r PACKAGE EXPECTED_VERSION; do
    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' "${PACKAGE}")
    assert_equal "${INSTALLED_VERSION}" "${EXPECTED_VERSION}"
  done < <(jq -r 'to_entries[] | .key + "=" + .value' "${APT_REQUIREMENTS}")
}

# bats test_tags=Sbom
@test "tools listed in the inventory are present in the image" {
  TOOL_INVENTORY="${BATS_TEST_DIRNAME}/../../.devcontainer/base/tool-inventory.json"

  for TOOL in $(jq -r '.[]' "${TOOL_INVENTORY}"); do
    case "${TOOL}" in
      bats-support | bats-assert)
        assert [ -f "/usr/local/${TOOL}/load.bash" ]
        ;;
      gnupg2)
        # The gnupg2 package provides the gpg command
        run command -v gpg
        assert_success
        ;;
      *)
        run command -v "${TOOL}"
        assert_success
        ;;
    esac
  done
}

# bats test_tags=Compatibility
@test "the C.UTF-8 locale is generated and set as the default" {
  run locale -a
  assert_success
  assert_output --partial "C.utf8"

  assert_equal "${LANG}" "C.UTF-8"
}

# bats test_tags=Maintainability
@test "bash-completion is enabled for the root user" {
  run grep -q "bash_completion" /root/.bashrc
  assert_success
}

# bats test_tags=Sbom
@test "add-sbom-note tool is installed and executable" {
  run command -v add-sbom-note
  assert_success

  assert [ -x /usr/local/bin/add-sbom-note ]
}

# bats test_tags=Sbom
@test "add-sbom-note fails when required arguments are missing" {
  run add-sbom-note only-a-name
  assert_failure
}

# bats test_tags=Sbom
@test "add-sbom-note fails when none of the given binaries exist" {
  run add-sbom-note example 1.2.3 pkg:generic/example@1.2.3 /nonexistent/binary

  assert_failure
  assert_output --partial "no binaries found to annotate for example"
}

# bats test_tags=Sbom
@test "add-sbom-note annotates an ELF binary with a .note.package section" {
  BINARY=$(mktemp)
  cp "$(command -v bash)" "$BINARY"
  chmod +x "$BINARY"
  # Ubuntu ships some binaries with a pre-existing .note.package section; start
  # from a clean binary so the test exercises add-sbom-note's own annotation.
  objcopy --remove-section .note.package "$BINARY" 2> /dev/null || true

  run add-sbom-note example 1.2.3 pkg:generic/example@1.2.3 "$BINARY"
  assert_success

  SECTION=$(mktemp)
  objcopy --dump-section .note.package="$SECTION" "$BINARY" /dev/null

  run cat "$SECTION"
  assert_success
  assert_output --partial '"name": "example"'
  assert_output --partial '"version": "1.2.3"'
  assert_output --partial '"purl": "pkg:generic/example@1.2.3"'

  rm -f "$BINARY" "$SECTION"
}
