#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../merge-devcontainer-metadata.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"
  printf '%s' '{"id": "fake-entry", "customizations": {"vscode": {"extensions": ["fake.extension-alpha@1.2.3", "fake.extension-beta@4.5.6"]}}}' > "${FAKE_DIR}/metadata.json"

  export FAKE_DIR
  export GITHUB_OUTPUT="${FAKE_DIR}/output"
  export -f docker
}

# Prints the prepared '.Image' result, the script only asks for that.
docker() {
  echo "$*" >> "${FAKE_DIR}/docker-calls"
  [[ "$1 $2 $3" == "buildx imagetools inspect" ]] || return 64
  [[ "$5 $6" == "--format {{json .Image}}" ]] || return 64
  cat "${FAKE_DIR}/image-config"
}

# Usage: set_single_platform_image LABEL_VALUE
set_single_platform_image() {
  jq -cn --arg label "${1-}" '{config: {Labels: {"devcontainer.metadata": $label}}}' > "${FAKE_DIR}/image-config"
}

run_script() {
  DEVCONTAINER_METADATA_FILE="${FAKE_DIR}/metadata.json" run bash "${SCRIPT}"
}

# The label value without its 'devcontainer.metadata=' prefix.
label_value() {
  sed -n 's/^label=devcontainer.metadata=//p' "${GITHUB_OUTPUT}"
}

@test "the label is empty when no metadata file is given" {
  run env -u DEVCONTAINER_METADATA_FILE bash "${SCRIPT}"

  assert_success
  assert_output --partial "skipping devcontainer.metadata label"
  run cat "${GITHUB_OUTPUT}"
  assert_output "label="
}

@test "the label is empty when the metadata file does not exist" {
  DEVCONTAINER_METADATA_FILE="${FAKE_DIR}/fake-missing.json" run bash "${SCRIPT}"

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "label="
}

@test "the label only contains the entry of the image when there is no base image" {
  run_script

  assert_success
  refute [ -e "${FAKE_DIR}/docker-calls" ]
  run jq -c . <<< "$(label_value)"
  assert_output '[{"id":"fake-entry","customizations":{"vscode":{"extensions":["fake.extension-alpha@1.2.3","fake.extension-beta@4.5.6"]}}}]'
}

@test "the entries of the base image come before the entry of the image" {
  set_single_platform_image '[{"id": "fake-base-one"}, {"id": "fake-base-two"}]'

  BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

  assert_success
  run jq -c 'map(.id)' <<< "$(label_value)"
  assert_output '["fake-base-one","fake-base-two","fake-entry"]'
  run cat "${FAKE_DIR}/docker-calls"
  assert_output "buildx imagetools inspect fake-registry.invalid/fake-base:1.2.3 --format {{json .Image}}"
}

@test "the label of a multi-platform base image is read from its first platform" {
  jq -cn --arg label '[{"id": "fake-base-one"}]' '{"linux/amd64": {config: {Labels: {"devcontainer.metadata": $label}}}, "linux/arm64": {config: {Labels: {"devcontainer.metadata": "[]"}}}}' > "${FAKE_DIR}/image-config"

  BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

  assert_success
  run jq -c 'map(.id)' <<< "$(label_value)"
  assert_output '["fake-base-one","fake-entry"]'
}

@test "a space is added after commas between strings so the label survives docker build --label" {
  set_single_platform_image '[{"id": "fake-base-one"}]'

  BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

  assert_success
  assert_output ""
  run label_value
  assert_output --partial '"fake-entry", "customizations"'
  assert_output --partial '"extensions":["fake.extension-alpha@1.2.3", "fake.extension-beta@4.5.6"]'
}

@test "a base image without the label or with an unusable label is ignored" {
  local labels=('' 'not json' '{"id": "fake-not-an-array"}' '"fake-string"' 'null')
  local label

  for label in "${labels[@]}"; do
    rm -f "${GITHUB_OUTPUT}"
    set_single_platform_image "${label}"

    BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

    assert_success
    run jq -c 'map(.id)' <<< "$(label_value)"
    assert_output '["fake-entry"]'
  done
}

@test "a base image without any labels is ignored" {
  printf '{"config": {}}' > "${FAKE_DIR}/image-config"

  BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

  assert_success
  run jq -c 'map(.id)' <<< "$(label_value)"
  assert_output '["fake-entry"]'
}

@test "the script fails when the base image cannot be inspected" {
  rm -f "${FAKE_DIR}/image-config"

  BASE_IMAGE=fake-registry.invalid/fake-base:1.2.3 run_script

  assert_failure
  refute [ -e "${GITHUB_OUTPUT}" ]
}

@test "the script fails when the metadata file is not valid JSON" {
  printf '{' > "${FAKE_DIR}/metadata.json"

  run_script

  assert_failure
}

@test "the script fails without an output file" {
  run env -u GITHUB_OUTPUT DEVCONTAINER_METADATA_FILE="${FAKE_DIR}/metadata.json" bash "${SCRIPT}"

  assert_failure
  assert_output --partial "GITHUB_OUTPUT required"
}
