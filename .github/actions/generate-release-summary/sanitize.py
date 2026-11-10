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


def sanitize(text: str, max_chars: int) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = "".join(c for c in text if c in "\n\t" or not (ord(c) < 32 or 0x7F <= ord(c) < 0xA0))

    text = re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL)
    text = re.sub(r"<(?:/?[A-Za-z][^>\n]*|[!?][^>\n]*)>", "", text)
    text = re.sub(r"!\[[^\]\n]*\]\([^)\n]*\)", "", text)
    text = re.sub(r"\[([^\]\n]*)\]\((?!https://github\.com/)[^)\n]*\)", r"\1", text)
    text = re.sub(r"https?://(?!github\.com/)[^\s)\]>]*[^\s)\]>.,;:!?]", "", text)
    text = re.sub(r"(?<![\w`])@(?=[A-Za-z0-9_-])", "[at]", text)

    lines = [line.rstrip() for line in text.split("\n") if MARKER not in line]
    text = re.sub(r"\n{3,}", "\n\n", "\n".join(lines)).strip()

    if len(text) > max_chars:
        cut = text[:max_chars]
        text = cut[: cut.rfind("\n")] if "\n" in cut else cut
        text = text.rstrip()
        if sum(1 for line in text.split("\n") if line.lstrip().startswith("```")) % 2:
            text += "\n```"

    return text


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
