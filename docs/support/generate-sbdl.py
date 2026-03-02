#!/usr/bin/env python3
"""Unified converter for generating SBDL from Gherkin feature files and BATS test files.

Supports multiple output configurations:
  - requirements: Feature/Rule hierarchy as requirements (for SRS)
  - test-specification: Feature→aspect, Rule→requirement, Scenario→test + BATS→test (for test spec & traceability)

Usage examples:
  # Generate requirements SBDL (existing behavior)
  python generate-sbdl.py --config requirements --gherkin test/cpp/features/*.feature

  # Generate test specification SBDL with both Gherkin scenarios and BATS tests
  python generate-sbdl.py --config test-specification \\
      --gherkin test/cpp/features/*.feature \\
      --bats test/cpp/integration-tests.bats test/base/integration-tests.bats
"""

import argparse
import os
import sys

from gherkin_mapping_config import FEATURE_RULE_CONFIG, TEST_SPECIFICATION_CONFIG
from gherkin_sbdl_converter import GherkinConverter, to_slug, write_gherkin_sbdl_elements
from bats_sbdl_converter import BatsConverter


def main():
    configs = {
        "requirements": FEATURE_RULE_CONFIG,
        "test-specification": TEST_SPECIFICATION_CONFIG,
    }

    parser = argparse.ArgumentParser(
        description="Unified Gherkin + BATS to SBDL converter"
    )
    parser.add_argument(
        "--gherkin",
        nargs="*",
        default=[],
        help="Paths to Gherkin feature files",
    )
    parser.add_argument(
        "--bats",
        nargs="*",
        default=[],
        help="Paths to BATS test files",
    )
    parser.add_argument(
        "--output",
        "-o",
        default="output.sbdl",
        help="Output SBDL file",
    )
    parser.add_argument(
        "--config",
        choices=configs.keys(),
        default="requirements",
        help="Conversion configuration preset",
    )
    parser.add_argument(
        "--flavor",
        default="",
        help="Container flavor name for per-flavor document generation",
    )

    args = parser.parse_args()

    if not args.gherkin and not args.bats:
        parser.error("At least one --gherkin or --bats file must be specified")

    config = configs[args.config]
    gherkin_converter = GherkinConverter(config)
    gherkin_elements = []

    # Process Gherkin feature files
    for feature_path in args.gherkin:
        if os.path.isfile(feature_path):
            print(f"Processing Gherkin: {feature_path}")
            elements = gherkin_converter.extract_from_feature_file(feature_path)
            gherkin_elements.extend(elements)
        else:
            print(f"File not found: {feature_path}", file=sys.stderr)

    # Build requirement tag map from Gherkin elements for BATS traceability.
    # Maps lowercased sanitized identifiers and feature names to (identifier, element_type)
    # tuples, enabling BATS tests tagged with e.g. "Compatibility" to trace to the
    # corresponding Gherkin element with the correct SBDL relation type.
    requirement_tag_map = {}
    for elem in gherkin_elements:
        if elem.metadata and elem.metadata.get("gherkin_type") in ("feature", "rule"):
            entry = (elem.identifier, elem.element_type.value)
            original = elem.metadata.get("original_name", "")
            # Map the original feature/rule name (lowercased) to the SBDL identifier + type
            if original:
                requirement_tag_map[original.lower()] = entry
                # Also map the slugified version for BATS tag matching
                slug_original = to_slug(original)
                if slug_original:
                    requirement_tag_map[slug_original] = entry
            # Also map the SBDL identifier itself
            requirement_tag_map[elem.identifier.lower()] = entry

    # Process BATS test files
    bats_converter = BatsConverter(requirement_tag_map=requirement_tag_map)
    bats_tests = []

    for bats_path in args.bats:
        if os.path.isfile(bats_path):
            print(f"Processing BATS: {bats_path}")
            flavor_prefix = to_slug(os.path.basename(os.path.dirname(os.path.abspath(bats_path))))
            tests = bats_converter.extract_from_bats_file(bats_path, flavor=flavor_prefix)
            bats_tests.extend(tests)
        else:
            print(f"File not found: {bats_path}", file=sys.stderr)

    # Write combined SBDL output
    _write_combined_sbdl(gherkin_elements, bats_converter, bats_tests, args.output, args.flavor)

    total = len(gherkin_elements) + len(bats_tests)
    print(f"Extracted {total} elements ({len(gherkin_elements)} from Gherkin, {len(bats_tests)} from BATS) to {args.output}")


def _write_combined_sbdl(gherkin_elements, bats_converter, bats_tests, output_file, flavor=""):
    """Write a single combined SBDL file from both Gherkin and BATS sources."""
    import sbdl as sbdl_lib

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("#!sbdl\n\n")

        # Write flavor marker element for per-flavor document generation
        if flavor:
            escaped_flavor = sbdl_lib.SBDL_Parser.sanitize(flavor)
            f.write(f'document-flavor is definition {{ description is "{escaped_flavor}" custom:title is "{escaped_flavor}" }}\n\n')

        f.write("# Elements extracted from Gherkin feature files\n")
        write_gherkin_sbdl_elements(f, gherkin_elements)

        if bats_tests:
            f.write("\n# Elements extracted from BATS integration test files\n")

            for test in bats_tests:
                escaped_desc = sbdl_lib.SBDL_Parser.sanitize(test.name)
                identifier = test.identifier

                f.write(f'{identifier} is test {{ description is "{escaped_desc}" custom:title is "{escaped_desc}"')

                if test.tags:
                    tag_str = ",".join(test.tags)
                    f.write(f" tag is {tag_str}")

                resolved = bats_converter._resolve_typed_relations(test)
                for rel_type, rel_ids in resolved.items():
                    f.write(f" {rel_type} is {','.join(rel_ids)}")

                f.write(" }\n")


if __name__ == "__main__":
    main()
