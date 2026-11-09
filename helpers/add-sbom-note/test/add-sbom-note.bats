#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  ADD_SBOM_NOTE="${BATS_TEST_DIRNAME}/../add-sbom-note.sh"
  FAKE_NAME=fake-tool-alpha
  FAKE_VERSION=1.2.3-fake1
  FAKE_PURL=pkg:generic/fake-tool-alpha@1.2.3-fake1
}

# Create an ELF executable without a pre-existing .note.package section.
# Ubuntu ships some binaries with such a section, which would make the
# tests pass without the script doing any work.
make_fake_binary() {
  local binary=${1:?}

  cp "$(command -v bash)" "${binary}"
  chmod +x "${binary}"
  objcopy --remove-section .note.package "${binary}" 2> /dev/null || true
}

dump_note() {
  local binary=${1:?}
  local section="${BATS_TEST_TMPDIR}/note.bin"

  objcopy --dump-section .note.package="${section}" "${binary}" /dev/null
  cat "${section}"
}

# bats test_tags=Sbom
@test "add-sbom-note fails when required arguments are missing" {
  run bash "${ADD_SBOM_NOTE}"
  assert_failure
  assert_output --partial "tool name required"

  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}"
  assert_failure
  assert_output --partial "tool version required"

  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}"
  assert_failure
  assert_output --partial "tool purl required"
}

# bats test_tags=Sbom
@test "add-sbom-note fails when no binaries are given" {
  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}"

  assert_failure
  assert_output --partial "no binaries found to annotate for ${FAKE_NAME}"
}

# bats test_tags=Sbom
@test "add-sbom-note fails when none of the given binaries exist" {
  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}" \
    "${BATS_TEST_TMPDIR}/fake-missing-binary"

  assert_failure
  assert_output --partial "no binaries found to annotate for ${FAKE_NAME}"
}

# bats test_tags=Sbom
@test "add-sbom-note ignores files that are not executable" {
  local binary="${BATS_TEST_TMPDIR}/fake-binary"
  make_fake_binary "${binary}"
  chmod -x "${binary}"

  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}" "${binary}"

  assert_failure
  assert_output --partial "no binaries found to annotate for ${FAKE_NAME}"
}

# bats test_tags=Sbom
@test "add-sbom-note annotates an ELF binary with a .note.package section" {
  local binary="${BATS_TEST_TMPDIR}/fake-binary"
  make_fake_binary "${binary}"

  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}" "${binary}"
  assert_success

  run dump_note "${binary}"
  assert_success
  assert_output --partial "\"name\": \"${FAKE_NAME}\""
  assert_output --partial "\"version\": \"${FAKE_VERSION}\""
  assert_output --partial "\"purl\": \"${FAKE_PURL}\""
}

# bats test_tags=Sbom
@test "add-sbom-note annotates all existing binaries and skips the missing ones" {
  local first="${BATS_TEST_TMPDIR}/fake-binary-one"
  local second="${BATS_TEST_TMPDIR}/fake-binary-two"
  make_fake_binary "${first}"
  make_fake_binary "${second}"

  run bash "${ADD_SBOM_NOTE}" "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}" \
    "${first}" "${BATS_TEST_TMPDIR}/fake-missing-binary" "${second}"
  assert_success

  run dump_note "${first}"
  assert_output --partial "\"name\": \"${FAKE_NAME}\""
  run dump_note "${second}"
  assert_output --partial "\"name\": \"${FAKE_NAME}\""
}

# bats test_tags=Sbom
@test "add-sbom-note does not leave temporary files behind" {
  local binary="${BATS_TEST_TMPDIR}/fake-binary"
  make_fake_binary "${binary}"
  mkdir "${BATS_TEST_TMPDIR}/fake-tmp"

  TMPDIR="${BATS_TEST_TMPDIR}/fake-tmp" run bash "${ADD_SBOM_NOTE}" \
    "${FAKE_NAME}" "${FAKE_VERSION}" "${FAKE_PURL}" "${binary}"
  assert_success

  run ls -A "${BATS_TEST_TMPDIR}/fake-tmp"
  assert_output ""
}
