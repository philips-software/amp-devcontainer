#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  RESOLVE="${BATS_TEST_DIRNAME}/../resolve.sh"
  GENERATE="${BATS_TEST_DIRNAME}/../generate-tool-inventory.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  # A Syft SPDX SBOM has many more fields, only the ones that are used are faked.
  cat > "${FAKE_DIR}/sbom.json" << 'EOF'
{
  "packages": [
    {"name": "fake-tool-zulu", "versionInfo": "9.9.9", "externalRefs": [{"referenceType": "purl", "referenceLocator": "pkg:fake/fake-tool-zulu@9.9.9"}]},
    {"name": "Fake-Tool-Alpha", "versionInfo": "1.2.3-fake1", "externalRefs": [{"referenceType": "other", "referenceLocator": "ignored"}, {"referenceType": "purl", "referenceLocator": "pkg:fake/fake-tool-alpha@1.2.3-fake1"}]},
    {"name": "fake-lib-beta", "versionInfo": "4.5.6", "externalRefs": [{"referenceType": "purl", "referenceLocator": "pkg:fake/fake-lib-beta@4.5.6"}]},
    {"name": "fake-lib-beta", "versionInfo": "4.5.6", "externalRefs": [{"referenceType": "purl", "referenceLocator": "pkg:fake/fake-lib-beta@4.5.6"}]},
    {"name": "fake-not-listed", "versionInfo": "0.0.1"},
    {"versionInfo": "0.0.0"}
  ]
}
EOF
}

write_json() {
  local file=${1:?}
  mkdir -p "$(dirname "${file}")"
  cat > "${file}"
}

run_generate() {
  SBOM="${FAKE_DIR}/sbom.json" \
    TOOL_INVENTORY="${FAKE_DIR}/inventory.json" \
    FLAVOR=fake-name \
    OUTPUT_FILE="${FAKE_DIR}/output.json" \
    run bash "${GENERATE}"
}

## generate-tool-inventory.sh

@test "the inventory contains the listed packages with version, purl, commands and files from the SBOM" {
  write_json "${FAKE_DIR}/inventory.json" << 'EOF'
{"packages": {
  "fake-tool-alpha": {"commands": ["fake-command-one", "fake-command-two"], "files": ["/fake/prefix/fake-file"]},
  "fake-lib-beta": {"files": ["/fake/prefix/fake-lib"]}
}}
EOF

  run_generate

  assert_success
  run jq -c . "${FAKE_DIR}/output.json"
  assert_output '{"flavor":"fake-name","tools":[{"name":"fake-lib-beta","version":"4.5.6","commands":[],"files":["/fake/prefix/fake-lib"],"purl":"pkg:fake/fake-lib-beta@4.5.6"},{"name":"Fake-Tool-Alpha","version":"1.2.3-fake1","commands":["fake-command-one","fake-command-two"],"files":["/fake/prefix/fake-file"],"purl":"pkg:fake/fake-tool-alpha@1.2.3-fake1"}]}'
}

@test "the inventory is also printed" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-lib-beta": {}}}'

  run_generate

  assert_success
  assert_output "$(cat "${FAKE_DIR}/output.json")"
}

@test "an empty entry means a single command with the name of the package" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-lib-beta": {}}}'

  run_generate

  assert_success
  run jq -c '.tools[0] | [.name, .commands, .files]' "${FAKE_DIR}/output.json"
  assert_output '["fake-lib-beta",["fake-lib-beta"],[]]'
}

@test "packages are matched regardless of case, and listed once, sorted by name" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-zulu": {}, "fake-tool-alpha": {}, "fake-lib-beta": {}}}'

  run_generate

  assert_success
  run jq -c '[.tools[].name]' "${FAKE_DIR}/output.json"
  assert_output '["fake-lib-beta","Fake-Tool-Alpha","fake-tool-zulu"]'
}

@test "packages of the SBOM that are not in the inventory are left out" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-lib-beta": {}}}'

  run_generate

  assert_success
  run jq -c '[.tools[].name]' "${FAKE_DIR}/output.json"
  assert_output '["fake-lib-beta"]'
}

@test "a package without a purl gets a null purl" {
  jq -c '.packages += [{"name": "fake-tool-gamma", "versionInfo": "7.7.7"}]' "${FAKE_DIR}/sbom.json" > "${FAKE_DIR}/sbom-new.json"
  mv "${FAKE_DIR}/sbom-new.json" "${FAKE_DIR}/sbom.json"
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-gamma": {}}}'

  run_generate

  assert_success
  run jq -c '.tools[0].purl' "${FAKE_DIR}/output.json"
  assert_output "null"
}

@test "inventories that are included are used" {
  write_json "${FAKE_DIR}/base/inventory.json" <<< '{"packages": {"fake-lib-beta": {"files": ["/fake/base-file"]}}}'
  write_json "${FAKE_DIR}/inventory.json" <<< '{"includes": ["base/inventory.json"], "packages": {"fake-tool-alpha": {}}}'

  run_generate

  assert_success
  run jq -c '[.tools[].name]' "${FAKE_DIR}/output.json"
  assert_output '["fake-lib-beta","Fake-Tool-Alpha"]'
}

@test "the script fails, listing the tools that are not in the SBOM, without writing the inventory" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-lib-beta": {}, "fake-tool-missing": {}, "fake-tool-gone": {}}}'

  run_generate

  assert_failure
  assert_output --partial "were not found in the SBOM"
  assert_line "  - fake-tool-gone"
  assert_line "  - fake-tool-missing"
  refute_output --partial "fake-lib-beta"
  refute [ -e "${FAKE_DIR}/output.json" ]
}

@test "the script fails on an invalid inventory" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": []}'

  run_generate

  assert_failure
  assert_output --partial "invalid inventory"
  refute [ -e "${FAKE_DIR}/output.json" ]
}

@test "the script fails when the SBOM does not exist" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-lib-beta": {}}}'
  rm "${FAKE_DIR}/sbom.json"

  run_generate

  assert_failure
  refute [ -e "${FAKE_DIR}/output.json" ]
}

@test "the script fails without its inputs" {
  run env -u SBOM TOOL_INVENTORY=fake FLAVOR=fake OUTPUT_FILE=fake bash "${GENERATE}"
  assert_failure
  assert_output --partial "SBOM required"

  run env -u TOOL_INVENTORY SBOM=fake FLAVOR=fake OUTPUT_FILE=fake bash "${GENERATE}"
  assert_failure
  assert_output --partial "TOOL_INVENTORY required"

  run env -u FLAVOR SBOM=fake TOOL_INVENTORY=fake OUTPUT_FILE=fake bash "${GENERATE}"
  assert_failure
  assert_output --partial "FLAVOR required"

  run env -u OUTPUT_FILE SBOM=fake TOOL_INVENTORY=fake FLAVOR=fake bash "${GENERATE}"
  assert_failure
  assert_output --partial "OUTPUT_FILE required"
}

## resolve.sh

@test "resolve.sh prints the packages of an inventory" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}, "fake-lib-beta": {"files": ["/fake/file"]}}}'

  run bash "${RESOLVE}" "${FAKE_DIR}/inventory.json"

  assert_success
  assert_output '{"fake-tool-alpha":{},"fake-lib-beta":{"files":["/fake/file"]}}'
}

@test "resolve.sh applies includes in order, and lets local packages replace inherited entries in full" {
  write_json "${FAKE_DIR}/one/inventory.json" <<< '{"packages": {"fake-tool-alpha": {"commands": ["fake-one", "fake-two"]}, "fake-tool-beta": {"commands": ["fake-from-one"]}}}'
  write_json "${FAKE_DIR}/two/inventory.json" <<< '{"packages": {"fake-tool-beta": {"commands": ["fake-from-two"]}}}'
  write_json "${FAKE_DIR}/top/inventory.json" <<< '{"includes": ["../one/inventory.json", "../two/inventory.json"], "packages": {"fake-tool-alpha": {"commands": ["fake-local"]}}}'

  run bash "${RESOLVE}" "${FAKE_DIR}/top/inventory.json"

  assert_success
  run jq -cS . <<< "${output}"
  assert_output '{"fake-tool-alpha":{"commands":["fake-local"]},"fake-tool-beta":{"commands":["fake-from-two"]}}'
}

@test "resolve.sh fails when the inventory or an include does not exist" {
  run bash "${RESOLVE}" "${FAKE_DIR}/fake-missing.json"
  assert_failure
  assert_output --partial "inventory file not found"

  write_json "${FAKE_DIR}/inventory.json" <<< '{"includes": ["fake-missing.json"], "packages": {}}'
  run bash "${RESOLVE}" "${FAKE_DIR}/inventory.json"
  assert_failure
  assert_output --partial "inventory file not found"
}

@test "resolve.sh fails on include cycles" {
  write_json "${FAKE_DIR}/one.json" <<< '{"includes": ["two.json"], "packages": {}}'
  write_json "${FAKE_DIR}/two.json" <<< '{"includes": ["one.json"], "packages": {}}'

  run bash "${RESOLVE}" "${FAKE_DIR}/one.json"

  assert_failure
  assert_output --partial "inventory include cycle"
}

@test "resolve.sh fails on invalid documents" {
  local documents=(
    '{'
    '[]'
    '{"packages": []}'
    '{"packages": {}, "fake-unknown": 1}'
    '{"packages": {"fake-tool": {"fake-unknown": []}}}'
    '{"packages": {"fake-tool": {"commands": "fake-command"}}}'
    '{"packages": {"fake-tool": {"commands": [""]}}}'
    '{"packages": {"fake-tool": {"commands": []}}}'
    '{"packages": {"fake-tool": {"commands": ["fake-command"], "smoke-test-args": {"fake-other": ["--fake"]}}}}'
    '{"packages": {"fake-tool": {"commands": ["fake-command"], "smoke-test-args": {"fake-command": []}}}}'
    '{"includes": ["/fake/absolute.json"], "packages": {}}'
  )
  local document

  for document in "${documents[@]}"; do
    write_json "${FAKE_DIR}/invalid.json" <<< "${document}"

    run bash "${RESOLVE}" "${FAKE_DIR}/invalid.json"

    assert_failure
    assert_output --partial "invalid inventory"
  done
}

@test "resolve.sh fails without an inventory" {
  run bash "${RESOLVE}"

  assert_failure
  assert_output --partial "Usage: resolve.sh INVENTORY"
}
