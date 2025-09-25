#!/usr/bin/env python3

import argparse
import os
import sys
from dataclasses import dataclass
from typing import List, Dict
from gherkin.parser import Parser
from gherkin.token_scanner import TokenScanner
import sbdl

@dataclass
class SBDLRequirement:
    """A class representing an SBDL requirement."""
    identifier: str
    description: str
    parent: str = ""

def make_sbdl_identifier(name: str) -> str:
    """Convert a name to a valid SBDL identifier using SBDL's built-in functions."""
    # Replace spaces and dashes with underscores first, then use SBDL's sanitization
    identifier = name.replace(" ", "_").replace("-", "_")
    
    # Use SBDL's built-in identifier sanitization
    identifier = sbdl.SBDL_Parser.sanitize_identifier(identifier)
    
    # Additional cleanup for readability
    # Remove multiple consecutive underscores
    while "__" in identifier:
        identifier = identifier.replace("__", "_")
    
    # Remove leading/trailing underscores
    identifier = identifier.strip("_")
    
    return identifier

def clean_description_text(text: str) -> str:
    """Clean up description text by removing excessive indentation and normalizing whitespace."""
    if not text:
        return text
    
    lines = text.split('\n')
    
    # Find the minimum indentation (excluding empty lines)
    non_empty_lines = [line for line in lines if line.strip()]
    if not non_empty_lines:
        return text.strip()
    
    min_indent = min(len(line) - len(line.lstrip()) for line in non_empty_lines)
    
    # Remove the common indentation from all lines
    cleaned_lines = []
    for line in lines:
        if line.strip():  # Non-empty line
            cleaned_lines.append(line[min_indent:] if len(line) >= min_indent else line)
        else:  # Empty line
            cleaned_lines.append('')
    
    # Join lines and clean up excessive whitespace
    return '\n'.join(cleaned_lines).strip()

def extract_requirements_from_feature(file_path: str) -> Dict[str, List[SBDLRequirement]]:
    """Parse a Gherkin feature file and extract requirements in SBDL format."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()

        parser = Parser()
        feature_document = parser.parse(TokenScanner(content))
        features = {}

        if 'feature' in feature_document:
            feature = feature_document['feature']
            
            # Extract feature information
            feature_name = feature.get('name', '').strip()
            feature_description = clean_description_text(feature.get('description', ''))
            
            if not feature_name:
                print(f"Warning: Feature in {file_path} has no name", file=sys.stderr)
                return features
            
            feature_id = make_sbdl_identifier(feature_name)
            # Create feature requirement
            feature_requirement = SBDLRequirement(
                identifier=feature_id,
                description=feature_description
            )
            
            rules = []
            
            # Extract rules under this feature
            if 'children' in feature:
                for child in feature['children']:
                    if 'rule' in child:
                        rule = child['rule']
                        rule_name = rule.get('name', '').strip()
                        rule_description = clean_description_text(rule.get('description', ''))
                        
                        if not rule_name:
                            continue
                            
                        rule_id = make_sbdl_identifier(rule_name)
                        rule_requirement = SBDLRequirement(
                            identifier=rule_id,
                            description=rule_description,
                            parent=feature_id
                        )
                        rules.append(rule_requirement)
            
            features[feature_id] = {
                'feature': feature_requirement,
                'rules': rules
            }

        return features
    except Exception as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        return {}

def write_sbdl_output(all_features: Dict[str, Dict], output_file: str):
    """Write SBDL format output using SBDL Python interface."""
    # Get SBDL syntax tokens and types
    tokens = sbdl.SBDL_Parser.Tokens
    types = sbdl.SBDL_Parser.Types
    attrs = sbdl.SBDL_Parser.Attributes
    
    # Open output file using SBDL's file handler
    with sbdl.open_output_file(output_file) as f:
        # Write SBDL file header
        f.write("#!sbdl\n")
        
        for feature_id, feature_data in all_features.items():
            feature_req = feature_data['feature']
            rules = feature_data['rules']
            
            # Write feature requirement using proper SBDL syntax
            escaped_desc = sbdl.SBDL_Parser.sanitize(feature_req.description)
            f.write(f"{feature_req.identifier} {tokens.declaration} {types.requirement} ")
            f.write(f"{tokens.declaration_group_delimeters[0]} ")
            f.write(f"{attrs.description}{tokens.declaration_attribute_assign}")
            f.write(f"{tokens.declaration_attribute_delimeter}{escaped_desc}{tokens.declaration_attribute_delimeter} ")
            f.write(f"{tokens.declaration_group_delimeters[1]}\n")
            
            # Write child rule requirements
            for rule in rules:
                escaped_desc = sbdl.SBDL_Parser.sanitize(rule.description)
                f.write(f"{rule.identifier} {tokens.declaration} {types.requirement} ")
                f.write(f"{tokens.declaration_group_delimeters[0]} ")
                f.write(f"{attrs.description}{tokens.declaration_attribute_assign}")
                f.write(f"{tokens.declaration_attribute_delimeter}{escaped_desc}{tokens.declaration_attribute_delimeter} ")
                f.write(f"{attrs.parent}{tokens.declaration_attribute_assign}{rule.parent} ")
                f.write(f"{tokens.declaration_group_delimeters[1]}\n")

def main():
    parser = argparse.ArgumentParser(description='Extract requirements from Gherkin feature files and generate SBDL')
    parser.add_argument('feature_files', nargs='+', help='Paths to feature files')
    parser.add_argument('--output', '-o', default='output.sbdl', help='Output SBDL file path')

    args = parser.parse_args()
    all_features = {}
    total_requirements = 0

    for feature_path in args.feature_files:
        if os.path.isfile(feature_path):
            print(f"Processing {feature_path}")
            features = extract_requirements_from_feature(feature_path)
            all_features.update(features)
            
            # Count requirements
            for feature_data in features.values():
                total_requirements += 1  # Feature requirement
                total_requirements += len(feature_data['rules'])  # Rule requirements
        else:
            print(f"File not found: {feature_path}", file=sys.stderr)

    write_sbdl_output(all_features, args.output)
    print(f"Extracted {total_requirements} requirements to {args.output}")

if __name__ == '__main__':
    main()
