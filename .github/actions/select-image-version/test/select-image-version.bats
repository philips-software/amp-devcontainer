#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SCRIPT="${BATS_TEST_DIRNAME}/../select-image-version.sh"
  export GITHUB_OUTPUT="${BATS_TEST_TMPDIR}/output"
}

# Usage: run_script EVENT_NAME REF_TYPE REF_NAME [PR_NUMBER]
run_script() {
  EVENT_NAME=${1:?} REF_TYPE=${2:?} REF_NAME=${3:?} PR_NUMBER=${4-} run bash "${SCRIPT}"
}

@test "a pull request uses the image of the pull request" {
  run_script pull_request branch 1234/merge 1234

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "version=pr-1234"
}

@test "a build of a tag uses the image of the release" {
  run_script push tag v1.2.3

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "version=v1.2.3"
}

@test "a manual run on a tag uses the image of the release" {
  run_script workflow_dispatch tag v1.2.3

  assert_success
  run cat "${GITHUB_OUTPUT}"
  assert_output "version=v1.2.3"
}

@test "the merge queue and a manual run on a branch use the edge image" {
  local event ref
  for event in merge_group workflow_dispatch; do
    for ref in main gh-readonly-queue/main/pr-1-abc; do
      rm -f "${GITHUB_OUTPUT}"
      run_script "${event}" branch "${ref}"

      assert_success
      run cat "${GITHUB_OUTPUT}"
      assert_output "version=edge"
    done
  done
}

@test "a pull request without a number fails" {
  run_script pull_request branch 1234/merge

  assert_failure
  assert_output --partial "pull request number required"
  refute [ -e "${GITHUB_OUTPUT}" ]
}

@test "fails without the event or the ref" {
  run env -u EVENT_NAME REF_TYPE=branch REF_NAME=main bash "${SCRIPT}"
  assert_failure
  assert_output --partial "event name required"

  run env -u REF_TYPE EVENT_NAME=push REF_NAME=main bash "${SCRIPT}"
  assert_failure
  assert_output --partial "ref type required"

  run env -u REF_NAME EVENT_NAME=push REF_TYPE=branch bash "${SCRIPT}"
  assert_failure
  assert_output --partial "ref name required"
}
