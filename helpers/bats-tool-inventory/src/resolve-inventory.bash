# Resolve a tool inventory file, including its `includes`, into a single compact
# JSON object that maps package names to their entries.
#
# Usage: resolve_inventory INVENTORY_JSON
#
# Includes are applied in order, then local packages replace inherited entries
# in full. Missing files, invalid documents, and include cycles fail.
# Paths of includes are relative to the declaring file.
function resolve_inventory() {
  local file=${1:?}
  shift
  local ancestor include inherited document packages
  local merged='{}'

  if [[ ! -f "${file}" ]]; then
    echo "error: inventory file not found: ${file}" >&2
    return 1
  fi
  file=$(realpath "${file}")
  for ancestor in "$@"; do
    if [[ "${file}" == "${ancestor}" ]]; then
      echo "error: inventory include cycle: $* -> ${file}" >&2
      return 1
    fi
  done

  document=$(jq -ces '
    def paths: type == "array" and all(.[]; type == "string" and length > 0 and (test("[\\t\\r\\n]") | not));
    def entry:
      type == "object" and (
        . as $entry |
        (keys - ["commands", "files", "smoke-test-args"] | length == 0) and
        (del(.["smoke-test-args"]) | all(.[]; paths)) and
        (. == {} or ((.commands // []) + (.files // []) | length > 0)) and
        (if has("smoke-test-args") then
          .["smoke-test-args"] | type == "object" and all(to_entries[];
            (.key as $command | $entry.commands // [] | index($command) != null) and
            (.value | paths and length > 0)
          )
        else true end)
      );
    if length == 1 and (.[0] |
      type == "object" and
      (keys - ["includes", "packages"] | length == 0) and
      (.packages | type == "object" and all(to_entries[];
        (.key | length > 0 and (test("[\\t\\r\\n]") | not)) and (.value | entry)
      )) and
      (if has("includes") then
        .includes | paths and all(.[]; startswith("/") | not)
      else true end)
    ) then .[0] else error("invalid package-to-commands/files inventory") end
  ' "${file}") || {
    echo "error: invalid inventory: ${file}" >&2
    return 1
  }

  while IFS= read -r include; do
    inherited=$(resolve_inventory "${file%/*}/${include}" "$@" "${file}") || return
    merged=$(jq -cn --argjson inherited "${inherited}" --argjson merged "${merged}" \
      '$merged + $inherited') || return
  done < <(jq -r '.includes[]?' <<< "${document}")

  packages=$(jq -c '.packages' <<< "${document}") || return
  jq -cn --argjson merged "${merged}" --argjson packages "${packages}" '$merged + $packages'
}
