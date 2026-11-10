# Functions to render release notes. This file only defines functions, it is
# sourced by render-release-notes.sh and by the tests and sets no shell options.

# The lines that mark the text that was inserted into the notes, so it can be found again.
# They are HTML comments, which are not shown in the release notes.
RENDERED_BLOCK_START='<!-- render-release-notes:start -->'
RENDERED_BLOCK_END='<!-- render-release-notes:end -->'

# Print the text of a file between the marker lines, with a newline at the end of the text.
#
# Usage: wrap_in_markers TEXT_FILE
function wrap_in_markers() {
  local text_file=${1:?}

  if [[ ! -f "${text_file}" ]]; then
    echo "error: file not found: ${text_file}" >&2
    return 1
  fi

  printf '%s\n' "${RENDERED_BLOCK_START}"
  sed -e '$a\' "${text_file}"
  printf '%s\n' "${RENDERED_BLOCK_END}"
}

# Print the notes without the text that was inserted earlier, so that inserting it again
# replaces it instead of adding it a second time. Fails when the markers don't match up,
# rather than risk removing text that is not ours.
#
# Usage: remove_marked_block NOTES
function remove_marked_block() {
  local notes=${1-}
  local status=0

  awk -v start="${RENDERED_BLOCK_START}" -v end="${RENDERED_BLOCK_END}" '
    $0 == start { if (skipping) exit 2; skipping = 1; next }
    $0 == end   { if (!skipping) exit 3; skipping = 0; next }
    !skipping   { print }
    END         { if (skipping) exit 2 }
  ' <<< "${notes}" || status=$?

  case "${status}" in
    0) ;;
    2) echo "error: the release notes have a start marker without an end marker: ${RENDERED_BLOCK_START}" >&2 ;;
    3) echo "error: the release notes have an end marker without a start marker: ${RENDERED_BLOCK_END}" >&2 ;;
    *) echo "error: the release notes could not be processed" >&2 ;;
  esac
  return "${status}"
}

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
