#!/usr/bin/env python3

import argparse
import os
import sys
from dataclasses import dataclass
from typing import List, Dict
from gherkin.parser import Parser
from gherkin.token_scanner import TokenScanner

@dataclass
class SBDLRequirement:
    """A class representing an SBDL requirement."""
    identifier: str
    description: str
    parent: str = ""

def make_sbdl_identifier(name: str) -> str:
    """Convert a name to a valid SBDL identifier."""
    # Replace spaces and special characters with underscores
    identifier = name.replace(" ", "_").replace("-", "_").replace("®", "_")
    # Remove or replace other special characters
    identifier = "".join(c if c.isalnum() or c == "_" else "_" for c in identifier)
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
            print(f"Extracted Feature: {feature_name}")
            print(f"Feature ID: {feature_id}")
            print(f"Description: {feature_description}\n")
            
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
                        print(f"  Extracted Rule: {rule_name}")
                        print(f"  Rule ID: {rule_id}")
                        print(f"  Description: {rule_description}\n")
                        
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
    """Write SBDL format output."""
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("#!sbdl\n")
        
        for feature_id, feature_data in all_features.items():
            feature_req = feature_data['feature']
            rules = feature_data['rules']
            
            # Write feature requirement
            f.write(f"{feature_req.identifier} is requirement {{ ")
            f.write(f'description is "{feature_req.description.replace(chr(10), "\\n")}" ')
            f.write("}\n")
            
            # Write child rule requirements
            for rule in rules:
                f.write(f"{rule.identifier} is requirement {{ ")
                f.write(f'description is "{rule.description.replace(chr(10), "\\n")}" ')
                f.write(f'parent is {rule.parent} ')
                f.write("}\n")

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
