#!/usr/bin/env python3
"""Make the text of a generated release summary safe to publish.

Usage: sanitize.py [--max-chars N] < generated.md > summary.md

The summary is generated from text that contributors write, so it is not trusted.
The sanitized text is markdown, without HTML or comments (which could contain the markers
of the release notes), images, links to other places than GitHub, and at-mentions.
It is shortened at a line boundary when it is longer than the maximum.
Fails when nothing is left.
"""

import argparse
import re
import sys

MARKER = "render-release-notes:"

# A fence is at least three backticks or tildes, the info string of a backtick fence has no backticks.
FENCE = re.compile(r"^[ \t]*(`{3,}|~{3,})(.*)$")


def close_open_fence(text: str) -> str:
    """Close the code block that the text ends in, with a fence like the one that opened it."""
    opening = None
    for line in text.split("\n"):
        match = FENCE.match(line)
        if not match:
            continue
        run, rest = match.groups()
        if opening is None:
            if run[0] != "`" or "`" not in rest:
                opening = run
        elif run[0] == opening[0] and len(run) >= len(opening) and not rest.strip():
            opening = None
    return text if opening is None else f"{text}\n{opening}"


def sanitize(text: str, max_chars: int) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = "".join(c for c in text if c in "\n\t" or not (ord(c) < 32 or 0x7F <= ord(c) < 0xA0))

    text = re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)
    # Tags can span lines, and so can the alt text and the destination of images and links
    text = re.sub(r"<(?:/?[A-Za-z]|[!?])[^>]*>", "", text)
    # Reference definitions can point anywhere, which is why the images and links that use them are
    # left without a destination
    text = re.sub(r"^[ \t]*\[[^\]\n]+\]:[ \t]*\S.*$", "", text, flags=re.MULTILINE)
    text = re.sub(r"!\[[^\]]*\](?:\([^)]*\)|\[[^\]]*\])?", "", text)
    text = re.sub(r"\[([^\]]*)\]\((?!https://github\.com/)[^)]*\)", r"\1", text)
    text = re.sub(r"https?://(?!github\.com/)[^\s)\]>]*[^\s)\]>.,;:!?]", "", text)
    text = re.sub(r"(?<![\w`])@(?=[A-Za-z0-9_-])", "[at]", text)

    lines = [line.rstrip() for line in text.split("\n") if MARKER not in line]
    text = re.sub(r"\n{3,}", "\n\n", "\n".join(lines)).strip()

    if len(text) > max_chars:
        cut = text[:max_chars]
        text = cut[: cut.rfind("\n")] if "\n" in cut else cut
        text = text.rstrip()

    return close_open_fence(text)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--max-chars", type=int, default=1500)
    arguments = parser.parse_args()

    text = sanitize(sys.stdin.read(), arguments.max_chars)
    if not text:
        print("error: nothing is left of the summary after sanitizing it", file=sys.stderr)
        return 1

    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
