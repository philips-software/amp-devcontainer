#!/usr/bin/env bats

# Checks which image the acceptance test of wc-acceptance-test.yml selects, by running the
# step that starts the Codespace with a stub for gh.
# These tests inspect this repository, they do not need a container.

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}"

  export FAKE_DIR GITHUB_ENV="${FAKE_DIR}/github-env"
  export -f gh
}

# 'secret set' records the value of the secret, 'codespace create' prints a fake name.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  case "$1 $2" in
    "secret set") ;;
    "codespace create") echo fake-codespace ;;
    *) return 64 ;;
  esac
}

# Usage: run_start_codespace EVENT_NAME REF_TYPE REF_NAME [PR_NUMBER]
run_start_codespace() {
  awk '
    $0 == "      - name: Start Codespace" { in_step = 1; next }
    in_step && $0 == "        env:" { exit }
    in_step && /^          / { sub(/^          /, ""); print }
  ' "${ROOT}/.github/workflows/wc-acceptance-test.yml" > "${FAKE_DIR}/step.sh"

  EVENT_NAME=${1:?} REF_TYPE=${2:?} REF_NAME=${3:?} PR_NUMBER=${4-} \
    GITHUB_REPOSITORY=fake-owner/fake-repo DEVCONTAINER_FILE=fake.json HEAD_REF=fake-head \
    run bash "${FAKE_DIR}/step.sh"
}

@test "a pull request tests the image of the pull request" {
  run_start_codespace pull_request branch 1234/merge 1234

  assert_success
  run grep "^secret set" "${FAKE_DIR}/gh-calls"
  assert_output "secret set -a codespaces IMAGE_VERSION --body pr-1234"
}

@test "a build of a tag tests the image of the release" {
  run_start_codespace push tag v1.2.3

  assert_success
  run grep "^secret set" "${FAKE_DIR}/gh-calls"
  assert_output "secret set -a codespaces IMAGE_VERSION --body v1.2.3"
}

@test "a manual run on a tag tests the image of the release" {
  run_start_codespace workflow_dispatch tag v1.2.3

  assert_success
  run grep "^secret set" "${FAKE_DIR}/gh-calls"
  assert_output "secret set -a codespaces IMAGE_VERSION --body v1.2.3"
}

@test "a merge queue and a manual run on a branch test the edge image" {
  local event ref
  for event in merge_group workflow_dispatch; do
    for ref in main gh-readonly-queue/main/pr-1-abc; do
      rm -f "${FAKE_DIR}/gh-calls"
      run_start_codespace "${event}" branch "${ref}"

      assert_success
      run grep "^secret set" "${FAKE_DIR}/gh-calls"
      assert_output "secret set -a codespaces IMAGE_VERSION --body edge"
    done
  done
}

@test "the codespace is created and its name is kept for the next steps" {
  run_start_codespace push tag v1.2.3

  assert_success
  run cat "${FAKE_DIR}/github-env"
  assert_output "CODESPACE_NAME=fake-codespace"
}
