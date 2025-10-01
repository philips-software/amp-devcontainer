#!/usr/bin/env python3

import argparse
import os
import sys

from gherkin_mapping_config import FEATURE_RULE_CONFIG, FEATURE_RULE_SCENARIO_CONFIG
from gherkin_sbdl_converter import GherkinConverter

def main():
    configs = {
        'feature-rule': FEATURE_RULE_CONFIG,
        'feature-rule-scenario': FEATURE_RULE_SCENARIO_CONFIG
    }

    parser = argparse.ArgumentParser(description='Configurable Gherkin to SBDL converter')
    parser.add_argument('feature_files', nargs='+', help='Paths to feature files')
    parser.add_argument('--output', '-o', default='output.sbdl', help='Output SBDL file')
    parser.add_argument('--config', choices=configs.keys(), 
                        default='feature-rule', help='Conversion configuration preset')

    args = parser.parse_args()
    config = configs[args.config]
    converter = GherkinConverter(config)
    gherkin_elements = []

    for feature_path in args.feature_files:
        if os.path.isfile(feature_path):
            print(f"Processing {feature_path}")
            elements = converter.extract_from_feature_file(feature_path)
            gherkin_elements.extend(elements)
        else:
            print(f"File not found: {feature_path}", file=sys.stderr)

    converter.write_sbdl_output(gherkin_elements, args.output)
    print(f"Extracted {len(gherkin_elements)} elements to {args.output}")

if __name__ == '__main__':
    main()
