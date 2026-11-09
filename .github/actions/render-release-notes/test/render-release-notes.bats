#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  load '../render.bash'

  SCRIPT="${BATS_TEST_DIRNAME}/../render-release-notes.sh"
  FAKE_BIN="${BATS_TEST_TMPDIR}/fake-bin"
  FAKE_DIR="${BATS_TEST_TMPDIR}/fake-dir"
  mkdir -p "${FAKE_BIN}" "${FAKE_DIR}/digests" "${FAKE_DIR}/inventory"
  PATH="${FAKE_BIN}:${PATH}"

  export FAKE_DIR
  FAKE_DIGEST_ALPHA=sha256:0000000000000000000000000000000000000000000000000000000000000001
  FAKE_DIGEST_BETA=sha256:0000000000000000000000000000000000000000000000000000000000000002

  # gh: 'release view' prints the notes file, 'release edit' stores the new notes.
  cat > "${FAKE_BIN}/gh" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "${FAKE_DIR}/gh-calls"
case "$1 $2" in
  "release view") cat "${FAKE_DIR}/notes" ;;
  "release edit") printf '%s' "$5" > "${FAKE_DIR}/edited-notes" ;;
  *) exit 64 ;;
esac
EOF

  # docker: 'buildx imagetools inspect' prints the manifest stored for the reference.
  cat > "${FAKE_BIN}/docker" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "${FAKE_DIR}/docker-calls"
[[ "$1 $2 $3" == "buildx imagetools inspect" ]] || exit 64
cat "${FAKE_DIR}/digests/${4//\//_}"
EOF
  chmod +x "${FAKE_BIN}/gh" "${FAKE_BIN}/docker"
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

run_script() {
  RELEASE_TAG=9.9.9-fake \
    INVENTORY_DIRECTORY="${FAKE_DIR}/inventory" \
    run bash "${SCRIPT}"
}

## apply_template

@test "apply_template inserts the template directly after the first header" {
  printf 'fake template line 1\nfake template line 2\n' > "${FAKE_DIR}/template.md"

  run apply_template $'## [9.9.9-fake] (2000-01-01)\n\n### Features\n\n* fake feature' "${FAKE_DIR}/template.md"

  assert_success
  assert_output $'## [9.9.9-fake] (2000-01-01)\nfake template line 1\nfake template line 2\n\n### Features\n\n* fake feature'
}

@test "apply_template only uses the first header" {
  printf 'fake template\n' > "${FAKE_DIR}/template.md"

  run apply_template $'## first\n## second' "${FAKE_DIR}/template.md"

  assert_success
  assert_output $'## first\nfake template\n## second'
}

@test "apply_template keeps the notes when they have no header" {
  printf 'fake template\n' > "${FAKE_DIR}/template.md"

  run apply_template $'fake notes\nwithout header' "${FAKE_DIR}/template.md"

  assert_success
  assert_output $'fake template\nfake notes\nwithout header'
}

@test "apply_template handles empty notes" {
  printf 'fake template\n' > "${FAKE_DIR}/template.md"

  run apply_template "" "${FAKE_DIR}/template.md"

  assert_success
  assert_output "fake template"
}

@test "apply_template fails when the template does not exist" {
  run apply_template "## fake" "${FAKE_DIR}/fake-missing.md"

  assert_failure
  assert_output --partial "template file not found"
}

## tools_table

@test "tools_table renders the tools of an inventory" {
  printf '%s' '{"flavor": "fake-flavor", "tools": [
    {"name": "fake-tool-alpha", "version": "1.2.3", "commands": ["fake-command-one", "fake-command-two"], "files": []},
    {"name": "fake-lib-beta", "version": "9.9.9", "commands": [], "files": ["/fake/prefix/fake-file"]}
  ]}' > "${FAKE_DIR}/inventory.json"

  run tools_table "${FAKE_DIR}/inventory.json"

  assert_success
  assert_output "$(printf '%s\n' \
    '| Package | Version | Included commands | Included files |' \
    '| --- | --- | --- | --- |' \
    '| fake-tool-alpha | 1.2.3 | fake-command-one, fake-command-two |  |' \
    '| fake-lib-beta | 9.9.9 |  | /fake/prefix/fake-file |')"
}

@test "tools_table renders only the header for an inventory without tools" {
  printf '%s' '{"tools": []}' > "${FAKE_DIR}/inventory.json"

  run tools_table "${FAKE_DIR}/inventory.json"

  assert_success
  assert_line --index 0 '| Package | Version | Included commands | Included files |'
  assert_line --index 1 '| --- | --- | --- | --- |'
}

@test "tools_table fails when the inventory does not exist" {
  run tools_table "${FAKE_DIR}/fake-missing.json"

  assert_failure
  assert_output --partial "tool inventory not found"
}

@test "tools_table fails on an invalid inventory" {
  printf '%s' '{"fake": true}' > "${FAKE_DIR}/inventory.json"

  run tools_table "${FAKE_DIR}/inventory.json"

  assert_failure
}

## image_values

@test "image_values uses the image.<image-basename>.<attribute> scheme" {
  run image_values fake-image-alpha 1.2.3 "${FAKE_DIGEST_ALPHA}" "fake tools"

  assert_success
  run jq -c . <<< "${output}"
  assert_output "{\"image.fake-image-alpha.version\":\"1.2.3\",\"image.fake-image-alpha.digest\":\"${FAKE_DIGEST_ALPHA}\",\"image.fake-image-alpha.tools\":\"fake tools\"}"
}

## render_placeholders

@test "render_placeholders replaces placeholders, tolerating whitespace, and repeats" {
  run render_placeholders $'{{ fake.alpha.one }}|{{fake.alpha.one}}|{{   fake.alpha.two\t}}' '{"fake.alpha.one": "ONE", "fake.alpha.two": "TWO"}'

  assert_success
  assert_output "ONE|ONE|TWO"
}

@test "render_placeholders replaces values literally" {
  run render_placeholders $'start {{ fake.alpha.one }} end' "$(jq -cn --arg v $'a & b \\1 $x \\n "q"\nsecond line' '{"fake.alpha.one": $v}')"

  assert_success
  assert_output $'start a & b \\1 $x \\n "q"\nsecond line end'
}

@test "render_placeholders supports subjects that contain dots and dashes" {
  run render_placeholders '{{ image.fake-registry.example.fake-image-alpha.digest }}' '{"image.fake-registry.example.fake-image-alpha.digest": "fake-digest"}'

  assert_success
  assert_output "fake-digest"
}

@test "render_placeholders leaves text that is not a placeholder untouched" {
  local text=$'{{ not a placeholder }} {single} {{nodot}} {{ Fake.Upper.Case }} ${var} {{ fake. }}'

  run render_placeholders "${text}" '{}'

  assert_success
  assert_output "${text}"
}

@test "render_placeholders fails listing all unresolved placeholders once" {
  run render_placeholders $'{{ fake.alpha.one }} {{ fake.alpha.two }} {{ fake.beta.one }} {{ fake.beta.one }}' '{"fake.alpha.one": "ONE"}'

  assert_failure
  assert_output --partial "no value for the following placeholders"
  assert_line "  - fake.alpha.two"
  assert_line "  - fake.beta.one"
  refute_output --partial "fake.alpha.one"
}

@test "render_placeholders does not substitute inside values" {
  run render_placeholders '{{ fake.alpha.one }}' '{"fake.alpha.one": "{{ fake.alpha.two }}"}'

  assert_success
  assert_output "{{ fake.alpha.two }}"
}

@test "render_placeholders fails on invalid values" {
  run render_placeholders '{{ fake.alpha.one }}' 'not json'

  assert_failure
}

## render-release-notes.sh

@test "the script renders all placeholders of multiple images in a single release edit" {
  add_image fake-registry.invalid/fake-owner/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" \
    '{"tools": [{"name": "fake-tool-alpha", "version": "1.2.3", "commands": ["fake-command"], "files": []}]}'
  add_image fake-registry.invalid/fake-owner/fake-image-beta 9.9.9-fake "${FAKE_DIGEST_BETA}" \
    '{"tools": [{"name": "fake-lib-beta", "version": "4.5.6", "commands": [], "files": ["/fake/file"]}]}'
  cat > "${FAKE_DIR}/notes" << 'EOF'
## [9.9.9-fake] (2000-01-01)

alpha {{ image.fake-image-alpha.version }}@{{ image.fake-image-alpha.digest }}
beta {{ image.fake-image-beta.version }}@{{ image.fake-image-beta.digest }}

{{ image.fake-image-alpha.tools }}

{{ image.fake-image-beta.tools }}
EOF

  IMAGES=$'fake-registry.invalid/fake-owner/fake-image-alpha\n\n  fake-registry.invalid/fake-owner/fake-image-beta  \n' run_script

  assert_success
  run grep -c "^release edit" "${FAKE_DIR}/gh-calls"
  assert_output "1"
  run cat "${FAKE_DIR}/edited-notes"
  assert_line "alpha 9.9.9-fake@${FAKE_DIGEST_ALPHA}"
  assert_line "beta 9.9.9-fake@${FAKE_DIGEST_BETA}"
  assert_line "| fake-tool-alpha | 1.2.3 | fake-command |  |"
  assert_line "| fake-lib-beta | 4.5.6 |  | /fake/file |"
  refute_output --partial "{{"
}

@test "the script reads and edits the release with the given tag" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '## fake\n' > "${FAKE_DIR}/notes"

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_success
  run cat "${FAKE_DIR}/gh-calls"
  assert_line "release view 9.9.9-fake --json body -q .body"
  assert_line --regexp "^release edit 9.9.9-fake --notes "
  run cat "${FAKE_DIR}/docker-calls"
  assert_line --regexp "^buildx imagetools inspect fake-registry.invalid/fake-image-alpha:9.9.9-fake --format "
}

@test "the script applies the template before rendering" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '## [9.9.9-fake]\n\n### Features\n' > "${FAKE_DIR}/notes"
  printf 'image {{ image.fake-image-alpha.version }}\n' > "${FAKE_DIR}/template.md"

  IMAGES=fake-registry.invalid/fake-image-alpha TEMPLATE_FILE="${FAKE_DIR}/template.md" run_script

  assert_success
  run cat "${FAKE_DIR}/edited-notes"
  assert_output $'## [9.9.9-fake]\nimage 9.9.9-fake\n\n### Features'
}

@test "the script resolves the digest of a manifest list" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "unused" '{"tools": []}'
  printf '{"manifests": [{"digest": "%s"}]}' "${FAKE_DIGEST_BETA}" > "${FAKE_DIR}/digests/fake-registry.invalid_fake-image-alpha:9.9.9-fake"
  printf '{{ image.fake-image-alpha.digest }}\n' > "${FAKE_DIR}/notes"

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_success
  run cat "${FAKE_DIR}/edited-notes"
  assert_output "${FAKE_DIGEST_BETA}"
}

@test "the script does not edit the release when the digest cannot be resolved" {
  printf '{{ image.fake-image-alpha.digest }}\n' > "${FAKE_DIR}/notes"

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when an inventory is missing" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}"
  printf '{{ image.fake-image-alpha.digest }}\n' > "${FAKE_DIR}/notes"

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  assert_output --partial "tool inventory not found"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when a placeholder has no value" {
  add_image fake-registry.invalid/fake-image-alpha 9.9.9-fake "${FAKE_DIGEST_ALPHA}" '{"tools": []}'
  printf '{{ image.fake-image-gamma.digest }}\n' > "${FAKE_DIR}/notes"

  IMAGES=fake-registry.invalid/fake-image-alpha run_script

  assert_failure
  assert_output --partial "image.fake-image-gamma.digest"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script does not edit the release when the template is missing" {
  printf '## fake\n' > "${FAKE_DIR}/notes"

  IMAGES="" TEMPLATE_FILE="${FAKE_DIR}/fake-missing.md" run_script

  assert_failure
  assert_output --partial "template file not found"
  refute [ -e "${FAKE_DIR}/edited-notes" ]
}

@test "the script fails without a release tag" {
  run env -u RELEASE_TAG bash "${SCRIPT}"

  assert_failure
  assert_output --partial "release tag required"
}

@test "the script works without images when the notes have no placeholders" {
  printf '## fake\n\nfake notes\n' > "${FAKE_DIR}/notes"

  IMAGES="" run_script

  assert_success
  run cat "${FAKE_DIR}/edited-notes"
  assert_output $'## fake\n\nfake notes'
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
