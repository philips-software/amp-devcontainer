#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  load '../load'

  FAKE_BIN="${BATS_TEST_TMPDIR}/fake-bin"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_BIN}" "${FAKE_DIR}"
  PATH="${FAKE_BIN}:${PATH}"
}

write_json() {
  local file=${1:?}
  mkdir -p "$(dirname "${file}")"
  cat > "${file}"
}

make_stub() {
  local name=${1:?}
  printf '#!/usr/bin/env bash\n%s\n' "${2:-exit 0}" > "${FAKE_BIN}/${name}"
  chmod +x "${FAKE_BIN}/${name}"
}

## read_apt_requirements

@test "read_apt_requirements merges files and lets later files override earlier ones" {
  write_json "${FAKE_DIR}/first.json" <<< '{"fake-package-a": "1.0.0-1", "fake-package-b": "2.0.0-1"}'
  write_json "${FAKE_DIR}/second.json" <<< '{"fake-package-b": "2.1.0-1", "fake-package-c": "3.0.0-1"}'

  run read_apt_requirements "${FAKE_DIR}/first.json" "${FAKE_DIR}/second.json"

  assert_success
  run jq -c . <<< "${output}"
  assert_output '{"fake-package-a":"1.0.0-1","fake-package-b":"2.1.0-1","fake-package-c":"3.0.0-1"}'
}

@test "read_apt_requirements does not depend on the working directory" {
  write_json "${FAKE_DIR}/first.json" <<< '{"fake-package-a": "1.0.0-1"}'
  cd /

  run read_apt_requirements "${FAKE_DIR}/first.json"

  assert_success
}

@test "read_apt_requirements fails without files" {
  run read_apt_requirements

  assert_failure
  assert_output --partial "No apt requirements files given"
}

@test "read_apt_requirements fails when any of the files is missing" {
  write_json "${FAKE_DIR}/first.json" <<< '{"fake-package-a": "1.0.0-1"}'

  run read_apt_requirements "${FAKE_DIR}/first.json" "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "Apt requirements file not found: ${FAKE_DIR}/fake-missing.json"
}

@test "read_apt_requirements fails on malformed JSON" {
  write_json "${FAKE_DIR}/broken.json" <<< '{"fake-package-a": '

  run read_apt_requirements "${FAKE_DIR}/broken.json"

  assert_failure
}

## get_expected_version_for / get_expected_semver_for

@test "get_expected_version_for returns the upstream version of an exact package match" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool": "1.2.3-fake1", "fake-other": "9.9.9-1"}'

  run get_expected_version_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_success
  assert_output "1.2.3"
}

@test "get_expected_version_for matches packages that start with the tool name and a dash" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool-15": "15.2.0-1", "fake-toolbox": "9.9.9-1"}'

  run get_expected_version_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_success
  assert_output "15.2.0"
}

@test "get_expected_version_for accepts multiple matches that agree on the version" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool-a": "4.5.6-1", "fake-tool-b": "4.5.6-2"}'

  run get_expected_version_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_success
  assert_output "4.5.6"
}

@test "get_expected_version_for fails on matches with different versions" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool-a": "4.5.6-1", "fake-tool-b": "4.5.7-1"}'

  run get_expected_version_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_failure
  assert_output --partial "Ambiguous apt versions for fake-tool"
}

@test "get_expected_version_for fails when there is no match" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-other": "9.9.9-1"}'

  run get_expected_version_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_failure
  assert_output --partial "No apt version found for fake-tool"
}

@test "get_expected_version_for fails without a tool name" {
  run get_expected_version_for

  assert_failure
}

@test "get_expected_semver_for extracts the major, minor and patch version" {
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool": "1:2.3.4.5-fake1"}'

  run get_expected_semver_for fake-tool "${FAKE_DIR}/requirements.json"

  assert_success
  assert_output "2.3.4"
}

@test "get_expected_semver_for fails when the version cannot be determined" {
  run get_expected_semver_for fake-tool "${FAKE_DIR}/fake-missing.json"

  assert_failure
}

@test "to_semver prints the first semantic version in its input" {
  run to_semver <<< "fake-tool version 7.8.9 (build 1.2.3)"

  assert_success
  assert_output "7.8.9"
}

## assert_tool_version

@test "assert_tool_version succeeds when versions are equal" {
  run assert_tool_version fake-tool 1.2.3 1.2.3

  assert_success
}

@test "assert_tool_version fails with a decorated diagnostic when versions differ" {
  run assert_tool_version fake-tool 1.2.3 1.2.4

  assert_failure
  assert_output --partial "tool version does not match"
  assert_output --partial "fake-tool"
  assert_output --partial "1.2.3"
  assert_output --partial "1.2.4"
}

## assert_apt_packages_at_pinned_versions

make_fake_dpkg() {
  export FAKE_DPKG_DB="${BATS_TEST_TMPDIR}/fake-dpkg"
  mkdir -p "${FAKE_DPKG_DB}"
  make_stub dpkg-query 'cat "${FAKE_DPKG_DB}/${3}"'
}

@test "assert_apt_packages_at_pinned_versions succeeds when all versions match" {
  make_fake_dpkg
  printf '1.0.0-1' > "${FAKE_DPKG_DB}/fake-package-a"
  printf '2.1.0-1' > "${FAKE_DPKG_DB}/fake-package-b"
  write_json "${FAKE_DIR}/first.json" <<< '{"fake-package-a": "1.0.0-1", "fake-package-b": "2.0.0-1"}'
  write_json "${FAKE_DIR}/second.json" <<< '{"fake-package-b": "2.1.0-1"}'

  run assert_apt_packages_at_pinned_versions "${FAKE_DIR}/first.json" "${FAKE_DIR}/second.json"

  assert_success
}

@test "assert_apt_packages_at_pinned_versions fails when a version differs" {
  make_fake_dpkg
  printf '1.0.0-1' > "${FAKE_DPKG_DB}/fake-package-a"
  printf '2.0.0-1' > "${FAKE_DPKG_DB}/fake-package-b"
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-package-a": "1.0.0-1", "fake-package-b": "2.0.0-2"}'

  run assert_apt_packages_at_pinned_versions "${FAKE_DIR}/requirements.json"

  assert_failure
  assert_output --partial "tool version does not match"
  assert_output --partial "fake-package-b"
}

@test "assert_apt_packages_at_pinned_versions fails when a package is not installed" {
  make_fake_dpkg
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-package-a": "1.0.0-1"}'

  run assert_apt_packages_at_pinned_versions "${FAKE_DIR}/requirements.json"

  assert_failure
}

@test "assert_apt_packages_at_pinned_versions fails without requirement files" {
  make_fake_dpkg

  run assert_apt_packages_at_pinned_versions

  assert_failure
  assert_output --partial "No apt requirements files given"
}

## resolve_inventory

@test "resolve_inventory returns the packages of an inventory without includes" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}, "fake-lib-beta": {"files": ["/fake/prefix/fake-file"]}}}'

  run resolve_inventory "${FAKE_DIR}/inventory.json"

  assert_success
  assert_output '{"fake-tool-alpha":{},"fake-lib-beta":{"files":["/fake/prefix/fake-file"]}}'
}

@test "resolve_inventory applies includes in order, relative to the declaring file" {
  write_json "${FAKE_DIR}/one/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}, "fake-tool-beta": {"commands": ["fake-from-one"]}}}'
  write_json "${FAKE_DIR}/two/inventory.json" <<< '{"packages": {"fake-tool-beta": {"commands": ["fake-from-two"]}, "fake-tool-gamma": {}}}'
  write_json "${FAKE_DIR}/nested/top/inventory.json" <<< '{"includes": ["../../one/inventory.json", "../../two/inventory.json"], "packages": {}}'

  run resolve_inventory "${FAKE_DIR}/nested/top/inventory.json"

  assert_success
  run jq -c . <<< "${output}"
  assert_output '{"fake-tool-alpha":{},"fake-tool-beta":{"commands":["fake-from-two"]},"fake-tool-gamma":{}}'
}

@test "resolve_inventory resolves includes of included inventories" {
  write_json "${FAKE_DIR}/root.json" <<< '{"packages": {"fake-tool-alpha": {}}}'
  write_json "${FAKE_DIR}/middle.json" <<< '{"includes": ["root.json"], "packages": {"fake-tool-beta": {}}}'
  write_json "${FAKE_DIR}/leaf.json" <<< '{"includes": ["middle.json"], "packages": {"fake-tool-gamma": {}}}'

  run resolve_inventory "${FAKE_DIR}/leaf.json"

  assert_success
  run jq -c 'keys' <<< "${output}"
  assert_output '["fake-tool-alpha","fake-tool-beta","fake-tool-gamma"]'
}

@test "resolve_inventory lets local packages replace inherited entries in full" {
  write_json "${FAKE_DIR}/base.json" <<< '{"packages": {"fake-tool-alpha": {"commands": ["fake-one", "fake-two"], "files": ["/fake/file"]}}}'
  write_json "${FAKE_DIR}/leaf.json" <<< '{"includes": ["base.json"], "packages": {"fake-tool-alpha": {"commands": ["fake-three"]}}}'

  run resolve_inventory "${FAKE_DIR}/leaf.json"

  assert_success
  assert_output '{"fake-tool-alpha":{"commands":["fake-three"]}}'
}

@test "resolve_inventory fails when the inventory does not exist" {
  run resolve_inventory "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "inventory file not found"
}

@test "resolve_inventory fails when an include does not exist" {
  write_json "${FAKE_DIR}/leaf.json" <<< '{"includes": ["fake-missing.json"], "packages": {}}'

  run resolve_inventory "${FAKE_DIR}/leaf.json"

  assert_failure
  assert_output --partial "inventory file not found"
}

@test "resolve_inventory fails on include cycles" {
  write_json "${FAKE_DIR}/one.json" <<< '{"includes": ["two.json"], "packages": {}}'
  write_json "${FAKE_DIR}/two.json" <<< '{"includes": ["one.json"], "packages": {}}'

  run resolve_inventory "${FAKE_DIR}/one.json"

  assert_failure
  assert_output --partial "inventory include cycle"
}

@test "resolve_inventory fails on invalid documents" {
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

    run resolve_inventory "${FAKE_DIR}/invalid.json"

    assert_failure
    assert_output --partial "invalid inventory"
  done
}

@test "resolve_inventory does not depend on the working directory" {
  write_json "${FAKE_DIR}/base.json" <<< '{"packages": {"fake-tool-alpha": {}}}'
  write_json "${FAKE_DIR}/leaf.json" <<< '{"includes": ["base.json"], "packages": {}}'
  cd /

  run resolve_inventory "${FAKE_DIR}/leaf.json"

  assert_success
  assert_output '{"fake-tool-alpha":{}}'
}

## read_inventory_tools

@test "read_inventory_tools lists commands with default and custom arguments and files" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{
    "packages": {
      "fake-tool-alpha": {},
      "fake-package-gamma": {
        "commands": ["fake-command-one", "fake-command-two"],
        "files": ["/fake/prefix/fake-file"],
        "smoke-test-args": {"fake-command-two": ["--fake flag", "value"]}
      }
    }
  }'

  run read_inventory_tools "${FAKE_DIR}/inventory.json"

  assert_success
  assert_line --index 0 '{"package":"fake-tool-alpha","kind":"command","tool":"fake-tool-alpha","args":["--version"]}'
  assert_line --index 1 '{"package":"fake-package-gamma","kind":"command","tool":"fake-command-one","args":["--version"]}'
  assert_line --index 2 '{"package":"fake-package-gamma","kind":"command","tool":"fake-command-two","args":["--fake flag","value"]}'
  assert_line --index 3 '{"package":"fake-package-gamma","kind":"file","tool":"/fake/prefix/fake-file"}'
}

@test "read_inventory_tools fails without an inventory" {
  run read_inventory_tools

  assert_failure
}

@test "read_inventory_tools fails when the inventory cannot be resolved" {
  run read_inventory_tools "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "inventory file not found"
}

## assert_commands_available

@test "assert_commands_available succeeds when all commands are on the PATH" {
  make_stub fake-command-one
  make_stub fake-command-two

  run assert_commands_available fake-command-one fake-command-two

  assert_success
}

@test "assert_commands_available fails on the first command that is missing" {
  make_stub fake-command-one

  run assert_commands_available fake-command-one fake-command-missing fake-command-other

  assert_failure
  assert_output --partial "command not found on PATH"
  assert_output --partial "fake-command-missing"
  refute_output --partial "fake-command-other"
}

## assert_inventory_tools_available

@test "assert_inventory_tools_available succeeds when commands and files are present" {
  make_stub fake-tool-alpha
  make_stub fake-command-one
  printf 'fake' > "${FAKE_DIR}/fake-file"
  write_json "${FAKE_DIR}/inventory.json" <<< "{
    \"packages\": {
      \"fake-tool-alpha\": {},
      \"fake-package-gamma\": {\"commands\": [\"fake-command-one\"], \"files\": [\"${FAKE_DIR}/fake-file\"]}
    }
  }"

  run assert_inventory_tools_available "${FAKE_DIR}/inventory.json"

  assert_success
}

@test "assert_inventory_tools_available fails when a command is missing" {
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-missing": {}}}'

  run assert_inventory_tools_available "${FAKE_DIR}/inventory.json"

  assert_failure
  assert_output --partial "command not found on PATH"
  assert_output --partial "fake-tool-missing"
}

@test "assert_inventory_tools_available fails when a file is missing" {
  write_json "${FAKE_DIR}/inventory.json" <<< "{\"packages\": {\"fake-package-gamma\": {\"files\": [\"${FAKE_DIR}/fake-missing-file\"]}}}"

  run assert_inventory_tools_available "${FAKE_DIR}/inventory.json"

  assert_failure
  assert_output --partial "inventory file not found"
  assert_output --partial "fake-package-gamma"
  assert_output --partial "${FAKE_DIR}/fake-missing-file"
}

@test "assert_inventory_tools_available fails when the inventory cannot be resolved" {
  run assert_inventory_tools_available "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "inventory file not found"
}

## assert_inventory_tools_run

@test "assert_inventory_tools_run starts commands with default and custom arguments" {
  make_stub fake-tool-alpha 'printf "%s\n" "$@" > "${FAKE_DIR}/alpha-args"'
  make_stub fake-command-two 'printf "%s\n" "$@" > "${FAKE_DIR}/two-args"'
  export FAKE_DIR
  write_json "${FAKE_DIR}/inventory.json" <<< '{
    "packages": {
      "fake-tool-alpha": {},
      "fake-package-gamma": {
        "commands": ["fake-command-two"],
        "smoke-test-args": {"fake-command-two": ["--fake flag", "value"]}
      }
    }
  }'

  run assert_inventory_tools_run "${FAKE_DIR}/inventory.json"

  assert_success
  run cat "${FAKE_DIR}/alpha-args"
  assert_output "--version"
  run cat "${FAKE_DIR}/two-args"
  assert_line --index 0 "--fake flag"
  assert_line --index 1 "value"
}

@test "assert_inventory_tools_run does not run files" {
  write_json "${FAKE_DIR}/inventory.json" <<< "{\"packages\": {\"fake-package-gamma\": {\"files\": [\"${FAKE_DIR}/fake-file\"]}}}"

  run assert_inventory_tools_run "${FAKE_DIR}/inventory.json"

  assert_success
}

@test "assert_inventory_tools_run fails with a diagnostic when a command exits non-zero" {
  make_stub fake-tool-alpha 'echo "fake failure output"; exit 3'
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}}}'

  run assert_inventory_tools_run "${FAKE_DIR}/inventory.json"

  assert_failure
  assert_output --partial "inventory command failed to start successfully"
  assert_output --partial "fake-tool-alpha"
  assert_output --partial "--version"
  assert_output --partial "3"
  assert_output --partial "fake failure output"
}

@test "assert_inventory_tools_run fails when a command is stopped by the timeout" {
  make_stub fake-tool-alpha
  make_stub timeout 'exit 124'
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}}}'

  run assert_inventory_tools_run "${FAKE_DIR}/inventory.json"

  assert_failure
  assert_output --partial "exit code"
  assert_output --partial "124"
}

@test "assert_inventory_tools_run fails when the inventory cannot be resolved" {
  run assert_inventory_tools_run "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "inventory file not found"
}

## packaging

@test "loading the package does not change the shell options" {
  run bash -c '
    bats_load_library() { :; }
    before=$(set +o; shopt -p)
    source "$1"
    after=$(set +o; shopt -p)
    [[ "${before}" == "${after}" ]]
  ' _ "${BATS_TEST_DIRNAME}/../load.bash"

  assert_success
}

@test "loading the package makes the assertions of its dependencies available" {
  run type -t assert_success refute_output fail

  assert_success
  assert_output "$(printf 'function\nfunction\nfunction')"
}

@test "loading the package fails when a dependency cannot be found" {
  cat > "${BATS_TEST_TMPDIR}/missing-dependency.bats" << EOF
@test "missing dependency" {
  load '${BATS_TEST_DIRNAME}/../load'
}
EOF

  run -1 env BATS_LIB_PATH="${BATS_TEST_TMPDIR}/fake-empty-lib-path" bats "${BATS_TEST_TMPDIR}/missing-dependency.bats"

  assert_output --partial "Could not find library 'bats-support'"
}

@test "the package works from a relocated prefix that contains only the installable files" {
  local prefix="${BATS_TEST_TMPDIR}/fake-prefix/bats-tool-inventory"
  local package="${BATS_TEST_DIRNAME}/.."

  mkdir -p "${prefix}"
  cp -r "${package}"/{load.bash,package.json,LICENSE,src} "${prefix}/"
  make_stub fake-tool-alpha
  write_json "${FAKE_DIR}/inventory.json" <<< '{"packages": {"fake-tool-alpha": {}}}'
  write_json "${FAKE_DIR}/requirements.json" <<< '{"fake-tool": "1.2.3-fake1"}'
  cat > "${BATS_TEST_TMPDIR}/relocated.bats" << EOF
setup() {
  load '${prefix}/load'
}

@test "relocated package" {
  assert_inventory_tools_available '${FAKE_DIR}/inventory.json'
  assert_inventory_tools_run '${FAKE_DIR}/inventory.json'
  run get_expected_semver_for fake-tool '${FAKE_DIR}/requirements.json'
  assert_output '1.2.3'
}
EOF

  run -0 env BATS_LIB_PATH="${BATS_LIB_PATH-}" bats "${BATS_TEST_TMPDIR}/relocated.bats"
}
