#!/usr/bin/env bats

# Checks that versions that are pinned in more than one place stay in sync.
# These tests inspect this repository, they do not need a container.

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
}

# Fail, listing the keys that have more than one value, when the "<key> <value>"
# lines on stdin are not consistent.
assert_single_value_per_key() {
  local description=${1:?}
  local conflicts

  conflicts=$(sort -u | awk '
    { count[$1]++; values[$1] = values[$1] "\n  " $2 }
    END { for (key in count) if (count[key] > 1) print key ":" values[key] }
  ')

  if [[ -n "${conflicts}" ]]; then
    batslib_decorate "${description}" <<< "${conflicts}" | fail
  fi
}

# Print the "<owner>/<repository> <ref>" of every action that is used.
used_actions() {
  grep -rhoE 'uses: [A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+[A-Za-z0-9_./-]*@[A-Za-z0-9._-]+' \
    --include='*.yml' --exclude-dir=node_modules \
    "${ROOT}/.github/workflows" "${ROOT}/.github/actions" \
    | sed -E 's/^uses: //' \
    | awk -F@ '{ split($1, path, "/"); print path[1] "/" path[2], $2 }'
}

# Print the "<image> <tag>@<digest>" of every container image reference that is pinned by digest.
pinned_images() {
  grep -rhoE '[a-z0-9._/-]+:[A-Za-z0-9._-]+@sha256:[0-9a-f]{64}' \
    --exclude-dir=node_modules \
    "${ROOT}/.github" "${ROOT}/.devcontainer" \
    | sed -E 's#^/+##; s#^([^:]+):(.+)$#\1 \2#'
}

# Succeed when "$1" is not smaller than "$2", both versions of the form x[.y[.z]].
version_at_least() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

# Succeed when version "$1" satisfies the caret range "$2", e.g. ^1.6 or ^0.3.
satisfies_caret_range() {
  local version=${1:?} range=${2:?}
  local lower=${range#^}
  local -a v l
  IFS=. read -ra v <<< "${version}"
  IFS=. read -ra l <<< "${lower}"

  version_at_least "${version}" "${lower}" || return 1
  [[ "${v[0]}" == "${l[0]}" ]] || return 1
  [[ "${l[0]}" != 0 ]] || [[ "${v[1]}" == "${l[1]:-0}" ]]
}

dockerfile_arg() {
  sed -nE "s/^ARG ${1:?}=(.+)$/\1/p" "${ROOT}/.devcontainer/base/Dockerfile"
}

# bats test_tags=Maintainability
@test "every GitHub action is pinned to a single version" {
  used_actions | assert_single_value_per_key "actions that are pinned to more than one version"
}

# bats test_tags=Maintainability
@test "every container image is pinned to a single version" {
  run pinned_images
  assert_success
  assert_output --partial "amp-devcontainer-docs"

  pinned_images | assert_single_value_per_key "container images that are pinned to more than one version"
}

# bats test_tags=Maintainability
@test "every workflow uses the same version of Node.js" {
  run bash -c "grep -rhoE 'node-version: *[0-9][0-9.]*' --exclude-dir=node_modules '${ROOT}/.github' | sed -E 's/node-version: *//' | sort -u"

  assert_success
  assert_equal "$(wc -l <<< "${output}")" 1
}

# bats test_tags=Maintainability,Bats
@test "the installed Bats satisfies the minimum version the tests require" {
  local installed required highest
  installed=$(dockerfile_arg BATS_CORE_VERSION)
  assert [ -n "${installed}" ]

  highest=$(grep -rhoE 'bats_require_minimum_version [0-9.]+' --include='*.bats' "${ROOT}/test" "${ROOT}/helpers" "${ROOT}/.github" | awk '{ print $2 }' | sort -V | tail -n1)
  assert [ -n "${highest}" ]

  run version_at_least "${installed}" "${highest}"
  assert_success
}

# bats test_tags=Maintainability,Bats
@test "the installed Bats libraries satisfy the peer dependencies of bats-tool-inventory" {
  local package="${ROOT}/helpers/bats-tool-inventory/package.json"
  local -A installed=(
    [bats]=$(dockerfile_arg BATS_CORE_VERSION)
    [bats-support]=$(dockerfile_arg BATS_SUPPORT_VERSION)
    [bats-assert]=$(dockerfile_arg BATS_ASSERT_VERSION)
  )
  local name range

  for name in "${!installed[@]}"; do
    range=$(jq -er --arg name "${name}" '.peerDependencies[$name]' "${package}")

    run satisfies_caret_range "${installed[${name}]}" "${range}"
    if [[ "${status}" -ne 0 ]]; then
      batslib_print_kv_single_or_multi 10 'package' "${name}" 'installed' "${installed[${name}]}" 'required' "${range}" \
        | batslib_decorate 'installed version does not satisfy the peer dependency' \
        | fail
    fi
  done
}
