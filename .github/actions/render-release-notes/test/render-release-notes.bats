#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  load '../render.bash'

  RENDER="${BATS_TEST_DIRNAME}/../render.py"
  SCRIPT="${BATS_TEST_DIRNAME}/../render-release-notes.sh"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_DIR}/digests" "${FAKE_DIR}/inventory"

  START="<!-- render-release-notes:start -->"
  END="<!-- render-release-notes:end -->"

  FAKE_DIGEST_ALPHA=sha256:0000000000000000000000000000000000000000000000000000000000000001
  FAKE_DIGEST_BETA=sha256:0000000000000000000000000000000000000000000000000000000000000002

  # The script is started as a separate process, exported functions are
  # inherited by it and take precedence over the real commands.
  export FAKE_DIR
  export -f gh docker
}

# 'release view' prints the notes file, 'release edit' stores the new notes.
gh() {
  echo "$*" >> "${FAKE_DIR}/gh-calls"
  case "$1 $2" in
    "release view") cat "${FAKE_DIR}/notes" ;;
    "release edit") printf '%s' "$5" > "${FAKE_DIR}/edited-notes" ;;
    *) return 64 ;;
  esac
}

# 'buildx imagetools inspect' prints the manifest stored for the reference and
# 'run' runs the command in the container directly, in the mounted directory.
docker() {
  echo "$*" >> "${FAKE_DIR}/docker-calls"
  case "$1" in
    buildx)
      [[ "$2 $3" == "imagetools inspect" ]] || return 64
      cat "${FAKE_DIR}/digests/${4//\//_}"
      ;;
    run)
      local volume
      shift
      while [[ "$1" == -* ]]; do
        case "$1" in
          --volume) volume=${2%%:*}; shift 2 ;;
          --network | --cap-drop | --security-opt | --workdir) shift 2 ;;
          *) shift ;;
        esac
      done
      shift # the image
      (cd "${volume}" && "$@")
      ;;
    *) return 64 ;;
  esac
}

# Usage: add_image IMAGE TAG DIGEST [INVENTORY_JSON]
add_image() {
  local image=${1:?} tag=${2:?} digest=${3:?}
  local inventory=${4-}
  local basename=${image##*/}

  printf '{"manifest": {"digest": "%s"}}' "${digest}" > "${FAKE_DIR}/digests/${image//\//_}:${tag}"
  if [[ -n "${inventory}" ]]; then
    mkdir -p "${FAKE_DIR}/inventory/tool-inventory-${basename}"
    printf '%s' "${inventory}" > "${FAKE_DIR}/inventory/tool-inventory-${basename}/tool-inventory.json"
  fi
}

# Usage: write_template CONTENT
write_template() {
  printf '%s\n' "${1:?}" > "${FAKE_DIR}/template.md.j2"
}

run_script() {
  RELEASE_TAG=9.9.9-fake \
    RENDER_IMAGE=fake-registry.invalid/fake-owner/fake-render-image:1.2.3-fake \
    TEMPLATE_FILE="${FAKE_DIR}/template.md.j2" \
    INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" \
    run bash "${SCRIPT}"
}

## render.py

@test "render.py renders variables and loops" {
  printf '%s' '{"fake_items": {"alpha": {"value": 1}, "beta": {"value": 2}}, "fake_name": "fake"}' > "${FAKE_DIR}/data.json"
  write_template $'{{ fake_name }}\n{% for name, item in fake_items.items() %}\n{{ name }}={{ item.value }}\n{% endfor %}\ndone'

  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/data.json"

  assert_success
  assert_output $'fake\nalpha=1\nbeta=2\ndone'
}

@test "render.py inserts values literally" {
  printf '%s' '{"fake_value": "<b>a & b</b> \\1 $x {{ fake_value }} {% raw %} \"q\""}' > "${FAKE_DIR}/data.json"
  write_template '{{ fake_value }}'

  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/data.json"

  assert_success
  assert_output '<b>a & b</b> \1 $x {{ fake_value }} {% raw %} "q"'
}

@test "render.py fails on an undefined variable" {
  printf '%s' '{}' > "${FAKE_DIR}/data.json"
  write_template 'a {{ fake_missing }} b'

  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/data.json"

  assert_failure 1
  assert_output --partial "error: 'fake_missing' is undefined"
}

@test "render.py fails on an undefined attribute" {
  printf '%s' '{"fake_item": {"known": 1}}' > "${FAKE_DIR}/data.json"
  write_template '{{ fake_item.unknown }}'

  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/data.json"

  assert_failure 1
  assert_output --partial "unknown"
}

@test "render.py fails on a template with a syntax error" {
  printf '%s' '{}' > "${FAKE_DIR}/data.json"
  write_template '{% for %}'

  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/data.json"

  assert_failure 1
  assert_output --partial "error:"
}

@test "render.py fails when the template or data do not exist or are invalid" {
  printf '%s' '{}' > "${FAKE_DIR}/data.json"
  printf '%s' '[]' > "${FAKE_DIR}/array.json"
  printf '%s' '{' > "${FAKE_DIR}/broken.json"
  write_template 'fake'

  run python3 "${RENDER}" "${FAKE_DIR}/fake-missing.md.j2" "${FAKE_DIR}/data.json"
  assert_failure 1
  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/fake-missing.json"
  assert_failure 1
  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/array.json"
  assert_failure 1
  assert_output --partial "the data must be a JSON object"
  run python3 "${RENDER}" "${FAKE_DIR}/template.md.j2" "${FAKE_DIR}/broken.json"
  assert_failure 1
}

@test "render.py shows its usage without the right arguments" {
  run python3 "${RENDER}" only-one-argument

  assert_failure 2
  assert_output --partial "Usage: render.py"
}

## insert_after_header

@test "insert_after_header inserts the text directly after the first header" {
  printf 'fake text line 1\nfake text line 2\n' > "${FAKE_DIR}/text.md"

  run insert_after_header $'## [9.9.9-fake] (2000-01-01)\n\n### Features\n\n* fake feature' "${FAKE_DIR}/text.md"

  assert_success
  assert_output $'## [9.9.9-fake] (2000-01-01)\nfake text line 1\nfake text line 2\n\n### Features\n\n* fake feature'
}

@test "insert_after_header only uses the first header" {
  printf 'fake text\n' > "${FAKE_DIR}/text.md"

  run insert_after_header $'## first\n## second' "${FAKE_DIR}/text.md"

  assert_success
  assert_output $'## first\nfake text\n## second'
}

@test "insert_after_header keeps the notes when they have no header" {
  printf 'fake text\n' > "${FAKE_DIR}/text.md"

  run insert_after_header $'fake notes\nwithout header' "${FAKE_DIR}/text.md"

  assert_success
  assert_output $'fake text\nfake notes\nwithout header'
}

@test "insert_after_header does not join text without a final newline with the notes" {
  printf 'fake text' > "${FAKE_DIR}/text.md"

  run insert_after_header $'fake notes\nwithout header' "${FAKE_DIR}/text.md"
  assert_success
  assert_output $'fake text\nfake notes\nwithout header'

  run insert_after_header $'## fake header\nfake notes' "${FAKE_DIR}/text.md"
  assert_success
  assert_output $'## fake header\nfake text\nfake notes'

  run insert_after_header "" "${FAKE_DIR}/text.md"
  assert_success
  assert_output "fake text"
}

@test "insert_after_header handles empty notes" {
  printf 'fake text\n' > "${FAKE_DIR}/text.md"

  run insert_after_header "" "${FAKE_DIR}/text.md"

  assert_success
  assert_output "fake text"
}

@test "insert_after_header fails when the text file does not exist" {
  run insert_after_header "## fake" "${FAKE_DIR}/fake-missing.md"

  assert_failure
  assert_output --partial "file not found"
}

## wrap_in_markers and remove_marked_block

@test "wrap_in_markers puts the text between the markers, ending with a newline" {
  printf 'fake text' > "${FAKE_DIR}/text.md"

  run wrap_in_markers "${FAKE_DIR}/text.md"

  assert_success
  assert_output "${START}"$'\nfake text\n'"${END}"
}

@test "wrap_in_markers fails when the text file does not exist" {
  run wrap_in_markers "${FAKE_DIR}/fake-missing.md"

  assert_failure
  assert_output --partial "file not found"
}

@test "remove_marked_block removes the marked text and keeps all the other text" {
  run remove_marked_block "$(printf '%s\n' 'fake before' "${START}" 'fake rendered' 'more rendered' "${END}" 'fake after')"

  assert_success
  assert_output $'fake before\nfake after'
}

@test "remove_marked_block removes every marked block" {
  run remove_marked_block "$(printf '%s\n' "${START}" 'one' "${END}" 'fake between' "${START}" 'two' "${END}")"

  assert_success
  assert_output "fake between"
}

@test "remove_marked_block leaves notes without markers as they are" {
  run remove_marked_block $'## fake\n\n* fake feature'

  assert_success
  assert_output $'## fake\n\n* fake feature'
}

@test "remove_marked_block only recognizes markers that are a line on their own" {
  local text="fake text ${START} in a line"

  run remove_marked_block "${text}"

  assert_success
  assert_output "${text}"
}

@test "remove_marked_block fails on markers that do not match" {
  run remove_marked_block "$(printf '%s\n' 'fake before' "${START}" 'fake rendered')"
  assert_failure 2
  assert_output --partial "start marker without an end marker"

  run remove_marked_block "$(printf '%s\n' "${START}" "${START}" "${END}")"
  assert_failure 2

  run remove_marked_block "$(printf '%s\n' 'fake before' "${END}")"
  assert_failure 3
  assert_output --partial "end marker without a start marker"
}

## image_data

@test "image_data combines the image and the tools of its inventory" {
  printf '%s' '{"flavor": "fake-flavor", "tools": [{"name": "fake-tool-alpha", "version": "1.2.3", "commands": ["fake-command"], "files": []}]}' > "${FAKE_DIR}/inventory.json"

  run image_data fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" "${FAKE_DIR}/inventory.json"

  assert_success
  assert_output "{\"reference\":\"fake-registry.invalid/fake-image-alpha\",\"version\":\"9.9.9-fake\",\"digest\":\"${FAKE_DIGEST_ALPHA}\",\"tools\":[{\"name\":\"fake-tool-alpha\",\"version\":\"1.2.3\",\"commands\":[\"fake-command\"],\"files\":[]}]}"
}

@test "image_data fails when the inventory does not exist" {
  run image_data fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "tool inventory not found"
}

@test "image_data fails on an inventory without tools" {
  printf '%s' '{"fake": true}' > "${FAKE_DIR}/inventory.json"

  run image_data fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" "${FAKE_DIR}/inventory.json"

  assert_failure
  assert_output --partial "invalid tool inventory"
}

## render-release-notes.sh

@test "the script renders all images in a single release edit" {
  add_image fake-registry.invalid/fake-owner/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" \
    '{"tools": [{"name": "fake-tool-alpha", "version": "1.2.3", "commands": ["fake-command"], "files": []}]}'
  add_image fake-registry.invalid/fake-owner/fake-image-beta 9.9.9-fake "${FAKE_DIGEST_BETA}" \
    '{"tools": []}'
  printf '## [9.9.9-fake] (2000-01-01)\n\n### Features\n' > "${FAKE_DIR}/notes"
  write_template $'{% for name, image in images.items() %}\n{{ name }} {{ image.reference }}:{{ image.version }}@{{ image.digest }} tools={{ image.tools | length }} release={{ release.tag }}\n{% endfor %}'

  IMAGES=$'fake-registry.invalid/fake-owner/fake-image-alpha\n\n  fake-registry.invalid/fake-owner/fake-image-beta  \n' run_script

  assert_success
  run grep -c "^release edit" "${FAKE_DIR}/gh-calls"
  assert_output "1"
  run cat "${FAKE_DIR}/edited-notes"
  assert_output "$(printf '%s\n' \
    '## [9.9.9-fake] (2000-01-01)' \
    "${START}" \
    "fake-image-alpha fake-registry.invalid/fake-owner/fake-image-alpha:9.9.9-fake@${FAKE_DIGEST_ALPHA} tools=1 release=9.9.9-fake" \
    "fake-image-beta fake-registry.invalid/fake-owner/fake-image-beta:9.9.9-fake@${FAKE_DIGEST_BETA} tools=0 release=9.9.9-fake" \
    "${END}" \
    '' \
    '### Features')"
}

@test "the script reads and edits the release and renders in the container with the given tag and image" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template 'fake'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_line "release view 9.9.9-fake --json body -q .body"
  assert_line --regexp "^release edit 9.9.9-fake --notes "
  run cat "${FAKE_DIR}/docker-calls"
  assert_line --regexp "^buildx imagetools inspect fake-registry.invalid/fake-image-alpha:9.9.9-fake --format "
  assert_line --regexp "^run --rm --network none --cap-drop ALL --security-opt no-new-privileges --volume [^ ]+:/work:ro --workdir /work fake-registry.invalid/fake-owner/fake-render-image:1.2.3-fake python3 render.py template.md.j2 data.json$"
}

@test "the script does not interpret the existing notes as template" {
  printf '## fake\n\n* fix: handle {{ fake_value }} and {%% fake %%} in text\n' > "${FAKE_DIR}/notes"
  write_template 'rendered'

  IMAGES="" run_script

  assert_success
  run cat "${FAKE_DIR}/edited-notes"
  assert_output $'## fake\n'"${START}"$'\nrendered\n'"${END}"$'\n\n* fix: handle {{ fake_value }} and {% fake %} in text'
}

@test "rendering again replaces the text of the earlier rendering instead of adding it again" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '## [9.9.9-fake]\n\n### Features\n' > "${FAKE_DIR}/notes"
  write_template 'image {{ images["fake-image-alpha"].digest }}'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script
  assert_success
  cp "${FAKE_DIR}/edited-notes" "${FAKE_DIR}/first-notes"

  cp "${FAKE_DIR}/edited-notes" "${FAKE_DIR}/notes"
  IMAGES=fake-registry.invalid/fake-image-alpha run_script
  assert_success

  run cat "${FAKE_DIR}/edited-notes"
  assert_output "$(cat "${FAKE_DIR}/first-notes")"
  run grep -c "^image " "${FAKE_DIR}/edited-notes"
  assert_output "1"
}

@test "rendering again with a changed template updates the text, and keeps the other text of the notes" {
  printf '## [9.9.9-fake]\n\n### Features\n\n* fake feature\n' > "${FAKE_DIR}/notes"
  write_template 'first rendering'
  IMAGES="" run_script
  assert_success

  # Text was added above and below the rendered text, by hand
  printf 'Fake summary written by hand\n\n%s\n' "$(cat "${FAKE_DIR}/edited-notes")" > "${FAKE_DIR}/notes"
  printf '\nFake note added by hand\n' >> "${FAKE_DIR}/notes"
  write_template 'second rendering'
  IMAGES="" run_script
  assert_success

  run cat "${FAKE_DIR}/edited-notes"
  assert_output "$(printf '%s\n' \
    'Fake summary written by hand' \
    '' \
    '## [9.9.9-fake]' \
    "${START}" \
    'second rendering' \
    "${END}" \
    '' \
    '### Features' \
    '' \
    '* fake feature' \
    '' \
    'Fake note added by hand')"
}

@test "the script does not edit the release when the markers in the notes do not match" {
  printf '## fake\n%s\nfake text\n' "${START}" > "${FAKE_DIR}/notes"
  write_template 'fake'

  IMAGES="" run_script

  assert_failure
  assert_output --partial "start marker without an end marker"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script resolves the digest of a manifest list" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "unused" '{"tools": []}'
  printf '{"manifests": [{"digest": "%s"}]}' "${FAKE_DIGEST_BETA}" > "${FAKE_DIR}/digests/fake-registry.invalid_fake-image-alpha:9.9.9-fake"
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template '{{ images["fake-image-alpha"].digest }}'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_success
  run cat "${FAKE_DIR}/edited-notes"
  assert_line --index 2 "${FAKE_DIGEST_BETA}"
}

@test "the script does not edit the release when the digest cannot be resolved" {
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template 'fake'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when an inventory is missing" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}"
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template 'fake'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  assert_output --partial "tool inventory not found"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when the template cannot be rendered" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template '{{ fake_missing }}'

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  assert_output --partial "'fake_missing' is undefined"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when the template is missing" {
  printf '## fake\n' > "${FAKE_DIR}/notes"

  IMAGES="" run_script

  assert_failure
  assert_output --partial "template file not found"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script fails when images have the same basename" {
  add_image fake-registry.invalid/fake-owner-one/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  add_image fake-registry.invalid/fake-owner-two/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_BETA}" '{"tools": []}'
  printf '## fake\n' > "${FAKE_DIR}/notes"
  write_template 'fake'

  IMAGES=$'fake-registry.invalid/fake-owner-one/fake-image-alpha\nfake-registry.invalid/fake-owner-two/fake-image-alpha' run_script

  assert_failure
  assert_output --partial "more than one image with the basename: fake-image-alpha"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script fails without a release tag or render image" {
  run env -u RELEASE_TAG RENDER_IMAGE=fake bash "${SCRIPT}"
  assert_failure
  assert_output --partial "release tag required"

  run env -u RENDER_IMAGE RELEASE_TAG=fake bash "${SCRIPT}"
  assert_failure
  assert_output --partial "render image required"
}

@test "the script uses the default template of the action when no template is given" {
  add_image fake-registry.invalid/fake-owner/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" \
    '{"tools": [{"name": "fake-tool-alpha", "version": "1.2.3", "commands": ["fake-command"], "files": ["/fake/file"]}]}'
  add_image fake-registry.invalid/fake-owner/fake-image-beta 9.9.9-fake "${FAKE_DIGEST_BETA}" '{"tools": []}'
  printf '## [9.9.9-fake] (2000-01-01)\n\n### Features\n\n* fake feature\n' > "${FAKE_DIR}/notes"

  IMAGES=$'fake-registry.invalid/fake-owner/fake-image-alpha\nfake-registry.invalid/fake-owner/fake-image-beta' \
    RELEASE_TAG=9.9.9-fake \
    RENDER_IMAGE=fake-registry.invalid/fake-owner/fake-render-image:1.2.3-fake \
    INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" \
    run -0 env -u TEMPLATE_FILE bash "${SCRIPT}"

  run cat "${FAKE_DIR}/edited-notes"
  assert_line --index 0 "## [9.9.9-fake] (2000-01-01)"
  assert_line "| fake-image-alpha | <pre><code>fake-registry.invalid/fake-owner/fake-image-alpha:9.9.9-fake@${FAKE_DIGEST_ALPHA}</code></pre><tr/> |"
  assert_line "| fake-image-beta | <pre><code>fake-registry.invalid/fake-owner/fake-image-beta:9.9.9-fake@${FAKE_DIGEST_BETA}</code></pre> |"
  assert_line "<summary>fake-image-alpha</summary>"
  assert_line "| fake-tool-alpha | 1.2.3 | fake-command | /fake/file |"
  assert_line "* fake feature"
  refute_output --partial "{{"
  refute_output --partial "{%"
}

@test "loading the render functions does not change the shell options" {
  run bash -c '
    before=$(set +o; shopt -p)
    source "$1"
    after=$(set +o; shopt -p)
    [[ "${before}" == "${after}" ]]
  ' _ "${BATS_TEST_DIRNAME}/../render.bash"

  assert_success
}
