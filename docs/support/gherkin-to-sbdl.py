#!/usr/bin/env python3
"""
Generalized Gherkin to SBDL converter with configurable hierarchy mapping.
"""

import argparse
import os
import sys
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional
from gherkin.parser import Parser
from gherkin.token_scanner import TokenScanner
import sbdl

from gherkin_mapping_config import (
    GherkinElementType,
    SBDLElementType,
    HierarchyMapping,
    ConversionConfig,
    FEATURE_RULE_CONFIG,
    FEATURE_RULE_SCENARIO_CONFIG
)

@dataclass
class SBDLElement:
    """A generalized SBDL element that can represent any type."""
    identifier: str
    element_type: SBDLElementType
    description: str
    parent: Optional[str] = None
    metadata: Dict = None

    def __post_init__(self):
        self.identifier = self._make_sbdl_identifier(self.identifier)
        self.description = self._unindent_description_text(self.description)

        if self.metadata is None:
            self.metadata = {}

    def _make_sbdl_identifier(self, name: str) -> str:
        identifier = name.replace(" ", "_").replace("-", "_")
        identifier = sbdl.SBDL_Parser.sanitize_identifier(identifier)
        identifier = identifier.strip("_")

        return identifier

    def _unindent_description_text(self, text: str) -> str:
        if not text:
            return text

        lines = text.split('\n')
        non_empty_lines = [line for line in lines if line.strip()]
        if not non_empty_lines:
            return text.strip()

        min_indent = min(len(line) - len(line.lstrip()) for line in non_empty_lines)

        cleaned_lines = []
        for line in lines:
            if line.strip():
                cleaned_lines.append(line[min_indent:] if len(line) >= min_indent else line)
            else:
                cleaned_lines.append('')

        return '\n'.join(cleaned_lines).strip()

class GherkinConverter:
    """Converts Gherkin files to SBDL using configurable hierarchy mappings."""

    def __init__(self, config: ConversionConfig):
        self.config = config

    def extract_gherkin_element(self, element_data: Dict, element_type: GherkinElementType, 
                               parent_id: Optional[str] = None) -> Optional[SBDLElement]:
        """Extract a single Gherkin element and convert it to SBDL."""
        mapping = self.config.get_mapping_for_type(element_type)

        if not mapping:
            return None

        name = element_data.get('name', '').strip()
        if not name:
            return None

        return SBDLElement(
            identifier=name,
            element_type=mapping.sbdl_type,
            description=element_data.get('description', ''),
            parent=parent_id,
            metadata={
                'gherkin_type': element_type.value,
                'original_name': name,
                'line': element_data.get('location', {}).get('line')
            }
        )

    def extract_from_feature_file(self, file_path: str) -> List[SBDLElement]:
        """Extract all configured elements from a Gherkin feature file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            parser = Parser()
            feature_document = parser.parse(TokenScanner(content))
            elements = []

            if 'feature' not in feature_document:
                return elements

            feature_data = feature_document['feature']

            # Extract feature
            feature_element = self.extract_gherkin_element(
                feature_data, GherkinElementType.FEATURE
            )
            if feature_element:
                elements.append(feature_element)
                print(f"Extracted Feature: {feature_element.identifier}")

            # Extract children (rules, scenarios, etc.)
            if 'children' in feature_data:
                for child in feature_data['children']:
                    child_elements = self._extract_child_elements(
                        child, feature_element.identifier if feature_element else None
                    )
                    elements.extend(child_elements)

            return elements

        except Exception as e:
            print(f"Error parsing {file_path}: {e}", file=sys.stderr)
            return []

    def _extract_child_elements(self, child_data: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        """Recursively extract child elements from Gherkin data."""
        elements = []

        # Check for rule
        if 'rule' in child_data:
            rule_element = self.extract_gherkin_element(
                child_data['rule'], GherkinElementType.RULE, parent_id
            )
            if rule_element:
                elements.append(rule_element)
                print(f"  Extracted Rule: {rule_element.identifier}")
                
                # Extract scenarios under rule
                if 'children' in child_data['rule']:
                    for rule_child in child_data['rule']['children']:
                        scenario_elements = self._extract_child_elements(
                            rule_child, rule_element.identifier
                        )
                        elements.extend(scenario_elements)

        # Check for scenario
        elif 'scenario' in child_data:
            scenario_element = self.extract_gherkin_element(
                child_data['scenario'], GherkinElementType.SCENARIO, parent_id
            )
            if scenario_element:
                elements.append(scenario_element)
                print(f"    Extracted Scenario: {scenario_element.identifier}")

        # Check for scenario outline
        elif 'scenarioOutline' in child_data:
            outline_element = self.extract_gherkin_element(
                child_data['scenarioOutline'], GherkinElementType.SCENARIO_OUTLINE, parent_id
            )
            if outline_element:
                elements.append(outline_element)
                print(f"    Extracted Scenario Outline: {outline_element.identifier}")

        return elements

    def write_sbdl_output(self, elements: List[SBDLElement], output_file: str):
        """Write elements to SBDL format."""
        # Get SBDL syntax tokens and types
        tokens = sbdl.SBDL_Parser.Tokens
        types = sbdl.SBDL_Parser.Types
        attrs = sbdl.SBDL_Parser.Attributes

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("#!sbdl\n")

            for element in elements:
                escaped_desc = sbdl.SBDL_Parser.sanitize(element.description)
                sbdl_type = element.element_type.value

                # Write element declaration
                f.write(f"{element.identifier} {tokens.declaration} {sbdl_type} ")
                f.write(f"{tokens.declaration_group_delimeters[0]} ")
                f.write(f"{attrs.description}{tokens.declaration_attribute_assign}")
                f.write(f"{tokens.declaration_attribute_delimeter}{escaped_desc}{tokens.declaration_attribute_delimeter} ")

                # Add parent relationship if exists
                if element.parent:
                    f.write(f"{attrs.parent}{tokens.declaration_attribute_assign}{element.parent} ")

                f.write(f"{tokens.declaration_group_delimeters[1]}\n")

def main():
    configs = {
        'feature-rule': FEATURE_RULE_CONFIG,
        'feature-rule-scenario': FEATURE_RULE_SCENARIO_CONFIG
    }

    parser = argparse.ArgumentParser(description='Configurable Gherkin to SBDL converter')
    parser.add_argument('feature_files', nargs='+', help='Paths to feature files')
    parser.add_argument('--output', '-o', default='output.sbdl', help='Output SBDL file')
    parser.add_argument('--config', choices=configs.keys(), 
                        default=list(configs.keys())[0], help='Conversion configuration preset')

    args = parser.parse_args()
    config = configs[args.config]
    converter = GherkinConverter(config)

    # Process all feature files
    all_elements = []
    for feature_path in args.feature_files:
        if os.path.isfile(feature_path):
            print(f"Processing {feature_path}")
            elements = converter.extract_from_feature_file(feature_path)
            all_elements.extend(elements)
        else:
            print(f"File not found: {feature_path}", file=sys.stderr)

    # Write SBDL output
    converter.write_sbdl_output(all_elements, args.output)
    print(f"Extracted {len(all_elements)} elements to {args.output}")
    
if __name__ == '__main__':
    main()
