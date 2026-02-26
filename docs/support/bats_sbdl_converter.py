#!/usr/bin/env python3
"""BATS test file to SBDL converter.

Parses BATS test files and extracts @test definitions along with their
optional `# bats test_tags=` annotations, producing SBDL `test` elements
with traceability to requirements via tag-based mapping.
"""

import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional

try:
    import sbdl

    def sanitize_identifier(name: str) -> str:
        """Convert a name to a hyphenated slug identifier."""
        slug = re.sub(r'[^a-z0-9]+', '-', name.lower())
        return slug.strip('-')

    def sanitize_description(text: str) -> str:
        return sbdl.SBDL_Parser.sanitize(text)

except ImportError:
    def sanitize_identifier(name: str) -> str:
        """Convert a name to a hyphenated slug identifier."""
        slug = re.sub(r'[^a-z0-9]+', '-', name.lower())
        return slug.strip('-')

    def sanitize_description(text: str) -> str:
        return text.replace('"', '\\"')


@dataclass
class BatsTest:
    """Represents a single BATS test case."""

    name: str
    identifier: str
    tags: List[str] = field(default_factory=list)
    file_path: str = ""
    line_number: int = 0

    def __post_init__(self):
        if not self.identifier:
            self.identifier = sanitize_identifier(self.name)


class BatsConverter:
    """Converts BATS test files to SBDL test elements."""

    # Regex patterns for BATS file parsing
    _TAG_PATTERN = re.compile(r"^#\s*bats\s+test_tags\s*=\s*(.+)$", re.IGNORECASE)
    _TEST_PATTERN = re.compile(r'^@test\s+"(.+?)"\s*\{', re.MULTILINE)

    def __init__(self, requirement_tag_map: Optional[Dict[str, str]] = None):
        """Initialize the converter.

        Args:
            requirement_tag_map: Optional mapping from tag names to requirement
                identifiers (SBDL element IDs). When provided, tests with
                matching tags will get a `requirement` relation in SBDL output.
        """
        self.requirement_tag_map = requirement_tag_map or {}

    @staticmethod
    def _extract_flavor(file_path: str) -> str:
        """Extract the flavor prefix from a BATS file path.

        Derives a prefix from the parent directory name of the BATS file,
        e.g. 'test/cpp/integration-tests.bats' -> 'cpp'.

        Args:
            file_path: Path to the BATS file.

        Returns:
            Flavor string derived from the parent directory.
        """
        import os
        parent = os.path.basename(os.path.dirname(os.path.abspath(file_path)))
        return sanitize_identifier(parent) if parent else ""

    def extract_from_bats_file(self, file_path: str) -> List[BatsTest]:
        """Extract all test definitions from a BATS file.

        Parses `@test "..."` blocks and any preceding `# bats test_tags=...`
        comment lines.

        Args:
            file_path: Path to the .bats file.

        Returns:
            List of BatsTest objects.
        """
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except (IOError, OSError) as e:
            print(f"Error reading {file_path}: {e}")
            return []

        tests: List[BatsTest] = []
        pending_tags: List[str] = []

        for line_number, line in enumerate(lines, start=1):
            stripped = line.strip()

            # Check for tag annotation
            tag_match = self._TAG_PATTERN.match(stripped)
            if tag_match:
                tags_str = tag_match.group(1)
                pending_tags = [t.strip() for t in tags_str.split(",") if t.strip()]
                continue

            # Check for test definition
            test_match = self._TEST_PATTERN.match(stripped)
            if test_match:
                test_name = test_match.group(1)
                flavor = self._extract_flavor(file_path)
                base_id = sanitize_identifier(test_name)
                identifier = f"{flavor}-{base_id}" if flavor else base_id
                test = BatsTest(
                    name=test_name,
                    identifier=identifier,
                    tags=list(pending_tags),
                    file_path=file_path,
                    line_number=line_number,
                )
                tests.append(test)
                pending_tags = []
                print(f"  Extracted BATS test: {test.identifier}")
                continue

            # Reset pending tags if we hit a non-comment, non-empty line
            # that isn't a test (so tags don't bleed across unrelated lines)
            if stripped and not stripped.startswith("#"):
                pending_tags = []

        return tests

    def write_sbdl_output(self, tests: List[BatsTest], output_file: str):
        """Write extracted BATS tests as SBDL test elements.

        Args:
            tests: List of BatsTest objects.
            output_file: Path to write the SBDL output.
        """
        with open(output_file, "w", encoding="utf-8") as f:
            f.write("#!sbdl\n")

            for test in tests:
                escaped_desc = sanitize_description(test.name)
                identifier = test.identifier

                f.write(f'{identifier} is test {{ description is "{escaped_desc}" custom:title is "{escaped_desc}"')

                # Add tag property if tags exist
                if test.tags:
                    tag_str = ",".join(test.tags)
                    f.write(f" tag is {tag_str}")

                # Add requirement relation via tag mapping
                req_ids = self._resolve_requirement_relations(test)
                if req_ids:
                    f.write(f" requirement is {','.join(req_ids)}")

                f.write(" }\n")

    def _resolve_requirement_relations(self, test: BatsTest) -> List[str]:
        """Resolve requirement identifiers from test tags using the tag map.

        Args:
            test: A BatsTest with tags.

        Returns:
            List of requirement SBDL identifiers.
        """
        req_ids = []
        for tag in test.tags:
            tag_lower = tag.lower()
            if tag_lower in self.requirement_tag_map:
                entry = self.requirement_tag_map[tag_lower]
                # Support both plain string and (identifier, type) tuple entries
                req_id = entry[0] if isinstance(entry, tuple) else entry
                if req_id not in req_ids:
                    req_ids.append(req_id)
        return req_ids

    def _resolve_typed_relations(self, test: BatsTest) -> Dict[str, List[str]]:
        """Resolve typed relations from test tags using the tag map.

        Groups resolved identifiers by their SBDL element type, so the
        correct relation keyword (e.g. 'aspect', 'requirement') is used
        in the SBDL output.

        Args:
            test: A BatsTest with tags.

        Returns:
            Dict mapping SBDL type names to lists of identifiers.
        """
        relations: Dict[str, List[str]] = {}
        for tag in test.tags:
            tag_lower = tag.lower()
            if tag_lower in self.requirement_tag_map:
                entry = self.requirement_tag_map[tag_lower]
                if isinstance(entry, tuple):
                    identifier, elem_type = entry
                else:
                    identifier, elem_type = entry, "requirement"
                if elem_type not in relations:
                    relations[elem_type] = []
                if identifier not in relations[elem_type]:
                    relations[elem_type].append(identifier)
        return relations
