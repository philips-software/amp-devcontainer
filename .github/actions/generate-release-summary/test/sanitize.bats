#!/usr/bin/env bats

bats_require_minimum_version 1.6.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  SANITIZE="${BATS_TEST_DIRNAME}/../sanitize.py"
}

sanitize() {
  run python3 "${SANITIZE}" "$@"
}

@test "markdown that is fine is kept as it is" {
  sanitize <<< $'Fake summary of the release.\n\n* a fake item with `code`\n* another fake item\n\n> [!NOTE]\n> Fake users have to act.\n\n```sh\nfake --command\n```'

  assert_success
  assert_output $'Fake summary of the release.\n\n* a fake item with `code`\n* another fake item\n\n> [!NOTE]\n> Fake users have to act.\n\n```sh\nfake --command\n```'
}

@test "HTML tags and comments are removed, with the markers of the release notes" {
  sanitize <<< $'Fake <b>bold</b> text<script>fake()</script>.\n<!-- render-release-notes:end -->\n<!--\nmulti-line\ncomment -->\nAfter.'

  assert_success
  assert_output $'Fake bold textfake().\n\nAfter.'
}

@test "lines with the markers of the release notes are dropped, however they are written" {
  sanitize <<< $'Before.\nrender-release-notes:start\nAfter.'

  assert_success
  assert_output $'Before.\nAfter.'
}

@test "images are removed" {
  sanitize <<< 'Fake ![tracking pixel](https://example.invalid/pixel.png) text.'

  assert_success
  assert_output "Fake  text."
}

@test "images that use a reference are removed, with the definitions of the references" {
  sanitize <<< $'Fake ![pixel][p] and ![collapsed][] and ![shortcut] text.\n\n[p]: //example.invalid/pixel.png\n[collapsed]: https://github.com/fake-owner/fake-repo/pixel.png\n  [shortcut]: <https://example.invalid/pixel.png> "title"'

  assert_success
  assert_output "Fake  and  and  text."
}

@test "images with the alt text or destination on more than one line are removed" {
  sanitize <<< $'Fake ![multi\nline](https://example.invalid/pixel.png\n"title") text.'

  assert_success
  assert_output "Fake  text."
}

@test "links that use a reference lose their destination" {
  sanitize <<< $'See [the fake page][p].\n\n[p]: https://example.invalid/page'

  assert_success
  assert_output "See [the fake page][p]."
}

@test "HTML tags that span lines are removed" {
  sanitize <<< $'Fake <img\n  src="https://github.com/fake-owner/fake-repo/pixel.png"\n  alt="pixel"> text <a\nhref="https://example.invalid">link</a>.'

  assert_success
  assert_output "Fake  text link."
}

@test "links to other places than GitHub are reduced to their text" {
  sanitize <<< 'See [the fake page](https://example.invalid/page) and [a fake commit](https://github.com/fake-owner/fake-repo/commit/0000000).'

  assert_success
  assert_output 'See the fake page and [a fake commit](https://github.com/fake-owner/fake-repo/commit/0000000).'
}

@test "bare URLs to other places than GitHub are removed" {
  sanitize <<< 'Fake https://example.invalid/page text, http://example.invalid/other, and https://github.com/fake-owner/fake-repo.'

  assert_success
  assert_output 'Fake  text, , and https://github.com/fake-owner/fake-repo.'
}

@test "at-mentions are defused" {
  sanitize <<< $'@fake-user fixed it, thanks (@fake-other) and fake@example.invalid and `@fake/package`.'

  assert_success
  assert_output '[at]fake-user fixed it, thanks ([at]fake-other) and fake@example.invalid and `@fake/package`.'
}

@test "control characters are removed and line endings are normalized" {
  sanitize <<< $'First\r\nSecond\x1b[31m red\x07 text'

  assert_success
  assert_output $'First\nSecond[31m red text'
}

@test "empty lines are collapsed, and the space around the text is removed" {
  sanitize <<< $'\n\n  First  \n\n\n\n\nSecond\n\n\n'

  assert_success
  assert_output $'First\n\nSecond'
}

@test "text that is too long is shortened to a whole line" {
  sanitize --max-chars 30 <<< $'First fake line.\nSecond fake line.\nThird fake line.'

  assert_success
  assert_output "First fake line."
}

@test "a single line that is too long is cut" {
  sanitize --max-chars 10 <<< 'A fake line that is much too long'

  assert_success
  assert_output "A fake lin"
}

@test "a code block that is cut short is closed" {
  sanitize --max-chars 30 <<< $'Fake intro.\n```sh\nfake --one\nfake --two\n```'

  assert_success
  assert_output $'Fake intro.\n```sh\nfake --one\n```'
}

@test "a code block with tildes that is cut short is closed with tildes" {
  sanitize --max-chars 29 <<< $'Fake intro.\n~~~sh\nfake --one\nfake --two\n~~~'

  assert_success
  assert_output $'Fake intro.\n~~~sh\nfake --one\n~~~'
}

@test "a code block with a longer fence is closed with a fence that is as long" {
  sanitize --max-chars 41 <<< $'Fake intro.\n````md\n```\nfake --one\nfake --two\n````'

  assert_success
  assert_output $'Fake intro.\n````md\n```\nfake --one\n````'
}

@test "a code block that is not closed in the text is closed" {
  sanitize <<< $'Fake intro.\n```sh\nfake --one'

  assert_success
  assert_output $'Fake intro.\n```sh\nfake --one\n```'
}

@test "code blocks that are complete are not closed again" {
  sanitize <<< $'```\nfake ``` inside\n```\n\n~~~\nfake\n~~~ \n\nFake `inline` and ```inline``` code.'

  assert_success
  assert_output $'```\nfake ``` inside\n```\n\n~~~\nfake\n~~~\n\nFake `inline` and ```inline``` code.'
}

@test "the default maximum is 1500 characters" {
  local line="A fake line of text that is sixty characters long, in total."
  local text
  text=$(for _ in $(seq 40); do printf '%s\n' "${line}"; done)

  sanitize <<< "${text}"

  assert_success
  assert [ "${#output}" -le 1500 ]
  assert [ "${#output}" -gt 1400 ]
}

@test "the script fails when nothing is left" {
  sanitize <<< $'<!-- only a comment -->\n\n   \n'

  assert_failure
  assert_output --partial "nothing is left of the summary"
}

@test "the script fails on empty input" {
  sanitize < /dev/null

  assert_failure
}
