#!/usr/bin/env python3
"""Render a Jinja2 template with the data of a JSON file and print the result.

Usage: render.py TEMPLATE_FILE DATA_FILE

The data file must contain a JSON object, its keys are the variables of the
template. Referring to a variable that does not exist is an error.
"""

import json
import sys
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, StrictUndefined, TemplateError


def render(template_file: str, data_file: str) -> str:
    data = json.loads(Path(data_file).read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{data_file}: the data must be a JSON object")

    template_path = Path(template_file)
    environment = Environment(
        loader=FileSystemLoader(template_path.parent),
        undefined=StrictUndefined,
        autoescape=False,  # the output is markdown, not HTML
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )
    return environment.get_template(template_path.name).render(**data)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2

    try:
        sys.stdout.write(render(argv[1], argv[2]))
    except (OSError, ValueError, TemplateError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
