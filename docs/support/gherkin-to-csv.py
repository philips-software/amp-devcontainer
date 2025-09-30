#!/usr/bin/env python3

import argparse
import csv
import os
import sys
from dataclasses import dataclass, asdict, fields
from typing import List
from gherkin.parser import Parser
from gherkin.token_scanner import TokenScanner

@dataclass
class Rule:
    """A class representing a rule extracted from a Gherkin feature file."""
    identifier: str
    description: str

    @classmethod
    def field_names(cls) -> List[str]:
        return [f.name for f in fields(cls)]

def extract_rules_from_feature(file_path):
    """Parse a Gherkin feature file and extract the rules."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()

        parser = Parser()
        feature_document = parser.parse(TokenScanner(content))
        rules = []

        if 'feature' in feature_document:
            feature = feature_document['feature']

            if 'children' in feature:
                for child in feature['children']:
                    if 'rule' in child:
                        rule = child['rule']
                        rule_id = rule.get('name', '').strip()
                        description = rule.get('description', '').strip()
                        rules.append(Rule(
                            identifier=rule_id,
                            description=description
                        ))

        return rules
    except Exception as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        return []

def main():
    parser = argparse.ArgumentParser(description='Extract rules from Gherkin feature files and save to CSV')
    parser.add_argument('feature_files', nargs='+', help='Paths to feature files')
    parser.add_argument('--output', '-o', default='rules.csv', help='Output CSV file path')

    args = parser.parse_args()
    all_rules = []

    for feature_path in args.feature_files:
        if os.path.isfile(feature_path):
            print(f"Processing {feature_path}")
            rules = extract_rules_from_feature(feature_path)
            all_rules.extend(rules)
        else:
            print(f"File not found: {feature_path}", file=sys.stderr)

    with open(args.output, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=Rule.field_names())
        writer.writeheader()
        writer.writerows([asdict(rule) for rule in all_rules])

    print(f"Extracted {len(all_rules)} rules to {args.output}")

if __name__ == '__main__':
    main()
