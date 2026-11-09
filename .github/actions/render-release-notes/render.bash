# Functions to render release notes. This file only defines functions, it is
# sourced by render-release-notes.sh and by the tests and sets no shell options.

# Matches a placeholder: {{ <namespace>.<subject>.<attribute> }}, see README.md.
readonly RELEASE_NOTES_PLACEHOLDER_REGEX='\\{\\{\\s*(?<key>[a-z][a-z0-9-]*(?:\\.[a-z0-9-]+)+)\\s*\\}\\}'

# Insert the template, read from a file, directly after the first '## ' header
# line of the notes. Notes without a header get the template prepended.
#
# Usage: apply_template NOTES TEMPLATE_FILE
function apply_template() {
  local notes=${1-}
  local template_file=${2:?}

  if [[ ! -f "${template_file}" ]]; then
    echo "error: template file not found: ${template_file}" >&2
    return 1
  fi

  if ! grep -q '^## ' <<< "${notes}"; then
    cat "${template_file}"
    [[ -z "${notes}" ]] || printf '%s\n' "${notes}"
    return 0
  fi

  awk -v template_file="${template_file}" '
    { print }
    !inserted && /^## / {
      while ((getline line < template_file) > 0) print line
      close(template_file)
      inserted = 1
    }
  ' <<< "${notes}"
}

# Print a markdown table of the tools in a generate-tool-inventory report.
#
# Usage: tools_table INVENTORY_JSON
function tools_table() {
  local inventory=${1:?}

  if [[ ! -f "${inventory}" ]]; then
    echo "error: tool inventory not found: ${inventory}" >&2
    return 1
  fi

  jq -r '
    "| Package | Version | Included commands | Included files |\n| --- | --- | --- | --- |\n" +
    ([.tools[] | "| \(.name) | \(.version) | \(.commands | join(", ")) | \(.files | join(", ")) |"] | join("\n"))
  ' "${inventory}"
}

# Print a JSON object with the placeholder values of a single image.
#
# Usage: image_values IMAGE_BASENAME VERSION DIGEST TOOLS_TABLE
function image_values() {
  jq -n \
    --arg image "${1:?}" \
    --arg version "${2:?}" \
    --arg digest "${3:?}" \
    --arg tools "${4-}" \
    '{
      ("image." + $image + ".version"): $version,
      ("image." + $image + ".digest"): $digest,
      ("image." + $image + ".tools"): $tools
    }'
}

# Replace all placeholders in a text with the values of a JSON object that maps
# placeholder names to strings. Fails, listing the names, when a placeholder has
# no value. Text that does not match the placeholder grammar is left untouched.
#
# Usage: render_placeholders TEXT VALUES_JSON
function render_placeholders() {
  local text=${1-}
  local values=${2:?}
  local unresolved

  unresolved=$(jq -Rrs --argjson values "${values}" \
    "[match(\"${RELEASE_NOTES_PLACEHOLDER_REGEX}\"; \"g\").captures[0].string] | unique - (\$values | keys) | .[]" \
    <<< "${text}") || return

  if [[ -n "${unresolved}" ]]; then
    echo "error: no value for the following placeholders:" >&2
    sed 's/^/  - /' <<< "${unresolved}" >&2
    return 1
  fi

  # Replacement values are taken literally, unlike in bash pattern substitution
  # where an '&' stands for the matched text.
  jq -Rjs --argjson values "${values}" \
    "gsub(\"${RELEASE_NOTES_PLACEHOLDER_REGEX}\"; \$values[.key])" \
    <<< "${text}"
}
