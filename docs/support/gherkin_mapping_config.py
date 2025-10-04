#!/usr/bin/env python3

"""
Configuration-driven Gherkin to SBDL mapping with flexible hierarchy support.
"""

from dataclasses import dataclass
from typing import Dict, List, Optional, Union
from enum import Enum

class GherkinElementType(Enum):
    """Supported Gherkin element types for conversion."""
    FEATURE = "feature"
    RULE = "rule"
    SCENARIO = "scenario"
    SCENARIO_OUTLINE = "scenario_outline"
    EXAMPLE = "example"
    BACKGROUND = "background"

class SBDLElementType(Enum):
    """Supported SBDL element types for mapping."""
    REQUIREMENT = "requirement"
    ASPECT = "aspect"
    USECASE = "usecase"
    DEFINITION = "definition"
    TEST = "test"

@dataclass
class HierarchyMapping:
    """Configuration for mapping Gherkin elements to SBDL with document hierarchy."""
    gherkin_type: GherkinElementType
    sbdl_type: SBDLElementType

@dataclass
class ConversionConfig:
    """Complete configuration for Gherkin to SBDL conversion."""
    hierarchy_mappings: List[HierarchyMapping]

    def get_mapping_for_type(self, gherkin_type: GherkinElementType) -> Optional[HierarchyMapping]:
        """Get the hierarchy mapping for a specific Gherkin element type."""
        for mapping in self.hierarchy_mappings:
            if mapping.gherkin_type == gherkin_type:
                return mapping
        return None

# Predefined configurations for different use cases

# Current Configuration (Feature -> Rule mapping)
FEATURE_RULE_CONFIG = ConversionConfig(
    hierarchy_mappings=[
        HierarchyMapping(
            gherkin_type=GherkinElementType.FEATURE,
            sbdl_type=SBDLElementType.REQUIREMENT
        ),
        HierarchyMapping(
            gherkin_type=GherkinElementType.RULE,
            sbdl_type=SBDLElementType.REQUIREMENT
        )
    ]
)

# Extended Configuration (Feature -> Rule -> Scenario mapping)
FEATURE_RULE_SCENARIO_CONFIG = ConversionConfig(
    hierarchy_mappings=[
        HierarchyMapping(
            gherkin_type=GherkinElementType.FEATURE,
            sbdl_type=SBDLElementType.ASPECT
        ),
        HierarchyMapping(
            gherkin_type=GherkinElementType.RULE,
            sbdl_type=SBDLElementType.REQUIREMENT
        ),
        HierarchyMapping(
            gherkin_type=GherkinElementType.SCENARIO,
            sbdl_type=SBDLElementType.TEST
        )
    ]
)

# Flat Configuration (All as requirements at same level)
FLAT_CONFIG = ConversionConfig(
    hierarchy_mappings=[
        HierarchyMapping(
            gherkin_type=GherkinElementType.FEATURE,
            sbdl_type=SBDLElementType.REQUIREMENT
        ),
        HierarchyMapping(
            gherkin_type=GherkinElementType.RULE,
            sbdl_type=SBDLElementType.REQUIREMENT
        )
    ]
)

# Use Case Focused Configuration
USECASE_CONFIG = ConversionConfig(
    hierarchy_mappings=[
        HierarchyMapping(
            gherkin_type=GherkinElementType.FEATURE,
            sbdl_type=SBDLElementType.USECASE
        ),
        HierarchyMapping(
            gherkin_type=GherkinElementType.SCENARIO,
            sbdl_type=SBDLElementType.USECASE
        )
    ]
)
