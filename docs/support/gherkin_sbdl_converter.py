#!/usr/bin/env python3
"""Gherkin to SBDL converter with configurable hierarchy mappings."""

from dataclasses import dataclass
from typing import List, Dict, Optional
from textwrap import dedent
import sys

from gherkin.parser import Parser
from gherkin.token_scanner import TokenScanner
import sbdl

from gherkin_mapping_config import (
    ConversionConfig,
    GherkinElementType,
    SBDLElementType,
)

@dataclass
class SBDLElement:
    """A generalized SBDL element that can represent any type."""

    identifier: str
    element_type: SBDLElementType
    description: str
    parent: Optional[str] = None
    metadata: Optional[Dict] = None

    def __post_init__(self):
        self.identifier = self._make_sbdl_identifier(self.identifier)
        self.description = dedent(self.description)

        if self.metadata is None:
            self.metadata = {}

    def _make_sbdl_identifier(self, name: str) -> str:
        return sbdl.SBDL_Parser.sanitize_identifier(
            name.replace(" ", "_").replace("-", "_")
        ).strip("_")

class GherkinConverter:
    """Converts Gherkin files to SBDL using configurable hierarchy mappings."""

    def __init__(self, config: ConversionConfig):
        self.config = config
        # Strategy map for element extraction: key in parsed Gherkin dict -> handler.
        self._strategies = {
            'feature': self._handle_feature,
            'rule': self._handle_rule,
            'scenario': self._handle_scenario,
            'scenarioOutline': self._handle_scenario_outline,
        }

    def extract_from_feature_file(self, file_path: str) -> List[SBDLElement]:
        """Extract all configured elements from a Gherkin feature file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()

            parser = Parser()
            feature_document = parser.parse(TokenScanner(content))

            if 'feature' not in feature_document:
                return []

            return self._dispatch(feature_document, None)
        except Exception as e:
            print(f"Error parsing {file_path}: {e}", file=sys.stderr)
            return []

    def write_sbdl_output(self, elements: List[SBDLElement], output_file: str):
        tokens = sbdl.SBDL_Parser.Tokens
        attrs = sbdl.SBDL_Parser.Attributes

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("#!sbdl\n")

            for element in elements:
                escaped_desc = sbdl.SBDL_Parser.sanitize(element.description)
                sbdl_type = element.element_type.value
                f.write(f"{element.identifier} {tokens.declaration} {sbdl_type} ")
                f.write(f"{tokens.declaration_group_delimeters[0]} ")
                f.write(f"{attrs.description}{tokens.declaration_attribute_assign}")
                f.write(
                    f"{tokens.declaration_attribute_delimeter}{escaped_desc}{tokens.declaration_attribute_delimeter} "
                )

                if element.parent:
                    f.write(f"{attrs.parent}{tokens.declaration_attribute_assign}{element.parent} ")

                f.write(f"{tokens.declaration_group_delimeters[1]}\n")

    def _extract_gherkin_element(self, element_data: Dict, element_type: GherkinElementType, parent_id: Optional[str]) -> Optional[SBDLElement]:
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
                'line': element_data.get('location', {}).get('line'),
            },
        )

    def _dispatch(self, node: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        for key, handler in self._strategies.items():
            if key in node:
                return handler(node[key], parent_id)
        return []

    def _handle_feature(self, feature_data: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        elements: List[SBDLElement] = []
        feature_element = self._extract_gherkin_element(feature_data, GherkinElementType.FEATURE, parent_id)
        feature_id = None
        if feature_element:
            elements.append(feature_element)
            feature_id = feature_element.identifier
            print(f"Extracted Feature: {feature_element.identifier}")
        for child in feature_data.get('children', []):
            elements.extend(self._dispatch(child, feature_id))
        return elements

    def _handle_rule(self, rule_data: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        elements: List[SBDLElement] = []
        rule_element = self._extract_gherkin_element(rule_data, GherkinElementType.RULE, parent_id)
        if not rule_element:
            return elements
        elements.append(rule_element)
        print(f"  Extracted Rule: {rule_element.identifier}")
        for rule_child in rule_data.get('children', []):
            elements.extend(self._dispatch(rule_child, rule_element.identifier))
        return elements

    def _handle_scenario(self, scenario_data: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        scenario_element = self._extract_gherkin_element(scenario_data, GherkinElementType.SCENARIO, parent_id)
        if not scenario_element:
            return []
        print(f"    Extracted Scenario: {scenario_element.identifier}")
        return [scenario_element]

    def _handle_scenario_outline(self, outline_data: Dict, parent_id: Optional[str]) -> List[SBDLElement]:
        outline_element = self._extract_gherkin_element(outline_data, GherkinElementType.SCENARIO_OUTLINE, parent_id)
        if not outline_element:
            return []
        print(f"    Extracted Scenario Outline: {outline_element.identifier}")
        return [outline_element]
