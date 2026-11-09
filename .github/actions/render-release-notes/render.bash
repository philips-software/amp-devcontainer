# Functions to render release notes. This file only defines functions, it is
# sourced by render-release-notes.sh and by the tests and sets no shell options.

# Insert rendered text, read from a file, directly after the first '## ' header
# line of the notes. Notes without a header get the text prepended.
#
# Usage: insert_after_header NOTES TEXT_FILE
function insert_after_header() {
  local notes=${1-}
  local text_file=${2:?}

  if [[ ! -f "${text_file}" ]]; then
    echo "error: file not found: ${text_file}" >&2
    return 1
  fi

  if ! grep -q '^## ' <<< "${notes}"; then
    # Make sure the text ends with a newline, so it is not joined with the first line of the notes
    sed -e '$a\' "${text_file}"
    [[ -z "${notes}" ]] || printf '%s\n' "${notes}"
    return 0
  fi

  awk -v text_file="${text_file}" '
    { print }
    !inserted && /^## / {
      while ((getline line < text_file) > 0) print line
      close(text_file)
      inserted = 1
    }
  ' <<< "${notes}"
}

# Print the template data of a single image as a JSON object. The tools are
# taken from a generate-tool-inventory report.
#
# Usage: image_data REFERENCE VERSION DIGEST INVENTORY_JSON
function image_data() {
  local reference=${1:?}
  local version=${2:?}
  local digest=${3:?}
  local inventory=${4:?}

  if [[ ! -f "${inventory}" ]]; then
    echo "error: tool inventory not found: ${inventory}" >&2
    return 1
  fi

  jq -ce \
    --arg reference "${reference}" \
    --arg version "${version}" \
    --arg digest "${digest}" \
    '(.tools | arrays) as $tools |
      {reference: $reference, version: $version, digest: $digest, tools: $tools}' \
    "${inventory}" || {
      echo "error: invalid tool inventory: ${inventory}" >&2
      return 1
    }
}
