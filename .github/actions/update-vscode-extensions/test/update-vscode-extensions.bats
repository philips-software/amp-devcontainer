#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../update-vscode-extensions.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/marketplace" "${FAKE_DIR}/fake-flavor-alpha" "${FAKE_DIR}/fake-flavor-beta"
  cd "${FAKE_DIR}"

  # Fake dates, far enough in the past or the future to be on either side of any cooldown
  FAKE_PAST=2000-01-01T00:00:00.000Z
  FAKE_FUTURE=2999-01-01T00:00:00.000Z

  export FAKE_DIR
  export GITHUB_OUTPUT="${FAKE_DIR}/github-output"
  export RUNNER_TEMP="${FAKE_DIR}"
  export VSCE_BIN=fake_vsce
  export -f fake_vsce gh sleep
}

# The marketplace is queried with 'show --json <name>', it prints the prepared result
# for the extension, and fails for unknown extensions.
fake_vsce() {
  echo "${3}" >> "${FAKE_DIR}/vsce-calls"
  [[ "$1 $2" == "show --json" ]] || return 64
  cat "${FAKE_DIR}/marketplace/${3}"
}

# 'release list' prints the tags of the fake releases, 'release view' the notes of a release.
gh() {
  case "$1 $2" in
    "release list") echo "v-fake-release" ;;
    "release view") cat "${FAKE_DIR}/release-notes" ;;
    *) return 64 ;;
  esac
}

# Do not wait between the attempts to query the marketplace.
sleep() { :; }

# Usage: add_extension NAME VERSION_JSON...
# The versions are listed from the newest to the oldest, as the marketplace does.
add_extension() {
  local name=${1:?}
  shift
  printf '{"versions": [%s]}' "$(IFS=,; echo "$*")" > "${FAKE_DIR}/marketplace/${name}"
}

# Usage: version VERSION LAST_UPDATED [GITHUB_URL | prerelease]
version() {
  local properties='[]'
  case "${3-}" in
    prerelease) properties='[{"key": "Microsoft.VisualStudio.Code.PreRelease", "value": "true"}]' ;;
    "") ;;
    *) properties="[{\"key\": \"Microsoft.VisualStudio.Services.Links.GitHub\", \"value\": \"${3}\"}]" ;;
  esac
  printf '{"version": "%s", "lastUpdated": "%s", "properties": %s}' "${1:?}" "${2:?}" "${properties}"
}

# Usage: write_devcontainer FILE EXTENSION...
write_devcontainer() {
  local file=${1:?}
  shift
  jq -n '{customizations: {vscode: {extensions: $ARGS.positional}}}' --args "$@" > "${file}"
}

extensions_of() {
  jq -c '.customizations.vscode.extensions' "${1:?}"
}

# The time of a number of days ago, in the format of the marketplace.
fake_days_ago() {
  date -u -d "-${1:?} days" +"%Y-%m-%dT%H:%M:%S.000Z"
}

output_of() {
  sed -n "s/^${1:?}=//p" "${GITHUB_OUTPUT}"
}

@test "pinned extensions are updated to the latest version" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")" "$(version 1.1.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'
}

@test "the names of the updated extensions are an output, without duplicates" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  add_extension fake.extension-beta "$(version 2.0.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0 fake.extension-beta@2.0.0
  write_devcontainer fake-flavor-beta/devcontainer.json fake.extension-alpha@1.0.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json fake-flavor-beta/devcontainer.json

  assert_success
  run output_of updated-dependencies
  assert_output '["fake.extension-alpha"]'
}

@test "a version that is within the cooldown period is not adopted" {
  add_extension fake.extension-alpha "$(version 1.3.0 "${FAKE_FUTURE}")" "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'
}

@test "the cooldown period can be configured" {
  add_extension fake.extension-alpha "$(version 1.3.0 "$(fake_days_ago 1)")" "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  # A version of yesterday is within the default cooldown of 7 days, but not within a cooldown of 0 days
  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json
  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'

  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0
  COOLDOWN_DAYS=0 run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json
  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.3.0"]'
}

@test "the current version is kept when no version has cleared the cooldown yet" {
  add_extension fake.extension-alpha "$(version 1.3.0 "${FAKE_FUTURE}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  assert_output --partial "No version of fake.extension-alpha has cleared the 7-day cooldown yet"
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.1.0"]'
  run output_of updated-dependencies
  assert_output '[]'
}

@test "pre-release versions are not adopted" {
  add_extension fake.extension-alpha "$(version 1.3.0 "${FAKE_PAST}" prerelease)" "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'
}

@test "extensions that are up to date are not reported" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.2.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run output_of updated-dependencies
  assert_output '[]'
  run cat "$(output_of markdown-summary-file)"
  assert_output ""
}

@test "the extensions are sorted, regardless of case" {
  add_extension fake.extension-gamma "$(version 1.0.0 "${FAKE_PAST}")"
  add_extension Fake.extension-beta "$(version 1.0.0 "${FAKE_PAST}")"
  add_extension fake.extension-alpha "$(version 1.0.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-gamma@1.0.0 fake.extension-alpha@1.0.0 Fake.extension-beta@1.0.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-alpha@1.0.0","Fake.extension-beta@1.0.0","fake.extension-gamma@1.0.0"]'
}

@test "the other settings in the file are kept" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  jq -n '{name: "fake-name", customizations: {vscode: {extensions: ["fake.extension-alpha@1.1.0"], settings: {"fake.setting": true}}}}' > fake-flavor-alpha/devcontainer.json

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run jq -c '[.name, .customizations.vscode.settings]' fake-flavor-alpha/devcontainer.json
  assert_output '["fake-name",{"fake.setting":true}]'
}

@test "an extension that is used in multiple files is only looked up once" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0
  write_devcontainer fake-flavor-beta/devcontainer.json fake.extension-alpha@1.0.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json fake-flavor-beta/devcontainer.json

  assert_success
  run cat vsce-calls
  assert_output "fake.extension-alpha"
  run extensions_of fake-flavor-beta/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'
}

@test "the summary names the changes per file, with the name of the directory of the file" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run cat "$(output_of markdown-summary-file)"
  assert_line "### 🍨 fake-flavor-alpha — devcontainer.json"
  assert_line 'Updates `fake.extension-alpha` from 1.1.0 to 1.2.0'
  refute_output --partial "Release notes"
}

@test "the summary contains the release notes, without backlinks and at-mentions" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}" https://github.com/fake-owner/fake-repo)" "$(version 1.1.0 "${FAKE_PAST}")"
  printf 'Fixed an issue for @fake-user, see https://github.com/fake-owner/fake-repo/issues/1\n' > release-notes
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_success
  run cat "$(output_of markdown-summary-file)"
  assert_line 'Updates `fake.extension-alpha` from 1.1.0 to 1.2.0'
  assert_line "<summary>Release notes</summary>"
  assert_line "Fixed an issue for [at]fake-user, see https://www.github.com/fake-owner/fake-repo/issues/1"
}

@test "a file that cannot be updated fails the script, the other files are still updated" {
  add_extension fake.extension-alpha "$(version 1.2.0 "${FAKE_PAST}")"
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-unknown@1.0.0
  write_devcontainer fake-flavor-beta/devcontainer.json fake.extension-alpha@1.1.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json fake-flavor-beta/devcontainer.json

  assert_failure
  assert_output --partial "Failed to query the marketplace for fake.extension-unknown"
  assert_output --partial "Failed to update VS Code extensions in: fake-flavor-alpha/devcontainer.json"
  run extensions_of fake-flavor-alpha/devcontainer.json
  assert_output '["fake.extension-unknown@1.0.0"]'
  run extensions_of fake-flavor-beta/devcontainer.json
  assert_output '["fake.extension-alpha@1.2.0"]'
}

@test "the marketplace is queried three times before giving up" {
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-unknown@1.0.0

  run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_failure
  run grep -c "fake.extension-unknown" vsce-calls
  assert_output "3"
}

@test "the script fails without files" {
  run bash "${SCRIPT}"

  assert_failure
  assert_output --partial "Usage:"
}

@test "the script fails on a cooldown that is not a number" {
  write_devcontainer fake-flavor-alpha/devcontainer.json fake.extension-alpha@1.0.0

  COOLDOWN_DAYS=fake run bash "${SCRIPT}" fake-flavor-alpha/devcontainer.json

  assert_failure
  assert_output --partial "COOLDOWN_DAYS must be a non-negative integer"
}
