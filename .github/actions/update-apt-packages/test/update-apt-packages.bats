#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../update-apt-packages.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  # The script writes its result to the working directory
  cd "${FAKE_DIR}"

  export FAKE_DIR
  export -f apt-cache
}

# Prints the policy of a package as stored in the fake package database, nothing for unknown packages.
apt-cache() {
  [[ "$1" == "policy" ]] || return 64
  [[ -f "${FAKE_DIR}/apt/${2}" ]] || return 0
  cat "${FAKE_DIR}/apt/${2}"
}

# Usage: add_package NAME INSTALLED CANDIDATE
add_package() {
  mkdir -p "${FAKE_DIR}/apt"
  printf '%s:\n  Installed: %s\n  Candidate: %s\n  Version table:\n' "${1:?}" "${2:?}" "${3:?}" > "${FAKE_DIR}/apt/${1}"
}

@test "pinned versions are updated to the candidate versions" {
  add_package fake-package-alpha 1.0.0-1 1.1.0-1
  add_package fake-package-beta 2.0.0-1 2.0.0-1
  printf '{"fake-package-alpha": "1.0.0-1", "fake-package-beta": "2.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_success
  run jq -c . requirements.json
  assert_output '{"fake-package-alpha":"1.1.0-1","fake-package-beta":"2.0.0-1"}'
}

@test "the names of the packages that are updated are reported" {
  add_package fake-package-alpha 1.0.0-1 1.1.0-1
  add_package fake-package-beta 2.0.0-1 2.0.0-1
  add_package fake-package-gamma 3.0.0-1 3.1.0-1
  printf '{"fake-package-alpha": "1.0.0-1", "fake-package-beta": "2.0.0-1", "fake-package-gamma": "3.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_success
  run jq -c . updated-packages.json
  assert_output '["fake-package-alpha","fake-package-gamma"]'
}

@test "nothing is reported when all packages are up to date" {
  add_package fake-package-alpha 1.0.0-1 1.0.0-1
  printf '{"fake-package-alpha": "1.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_success
  run jq -c . updated-packages.json
  assert_output '[]'
  run jq -c . requirements.json
  assert_output '{"fake-package-alpha":"1.0.0-1"}'
}

@test "multiple files are updated and reported together" {
  add_package fake-package-alpha 1.0.0-1 1.1.0-1
  add_package fake-package-beta 2.0.0-1 2.1.0-1
  printf '{"fake-package-alpha": "1.0.0-1"}' > first.json
  printf '{"fake-package-beta": "2.0.0-1"}' > second.json

  run bash "${SCRIPT}" first.json second.json

  assert_success
  run jq -c . first.json second.json
  assert_line --index 0 '{"fake-package-alpha":"1.1.0-1"}'
  assert_line --index 1 '{"fake-package-beta":"2.1.0-1"}'
  run jq -c . updated-packages.json
  assert_output '["fake-package-alpha","fake-package-beta"]'
}

@test "a package that is installed in another version than the candidate counts as updated" {
  add_package fake-package-alpha 0.9.0-1 1.0.0-1
  printf '{"fake-package-alpha": "1.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_success
  run jq -c . updated-packages.json
  assert_output '["fake-package-alpha"]'
}

@test "the files are written as formatted JSON" {
  add_package fake-package-alpha 1.0.0-1 1.1.0-1
  printf '{"fake-package-alpha":"1.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_success
  run cat requirements.json
  assert_output $'{\n  "fake-package-alpha": "1.1.0-1"\n}'
}

@test "the script fails for a package that is not known to apt, without changing the file" {
  printf '{"fake-package-unknown": "1.0.0-1"}' > requirements.json

  run bash "${SCRIPT}" requirements.json

  assert_failure
  assert_equal "$(cat requirements.json)" '{"fake-package-unknown": "1.0.0-1"}'
}

@test "the script fails when a file does not exist" {
  run bash "${SCRIPT}" fake-missing.json

  assert_failure
}
