#!/usr/bin/env python3

"""
Configuration-driven Gherkin to SBDL mapping with flexible hierarchy support.
"""

from dataclasses import dataclass
from typing import List, Optional
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

# Requirements Configuration (Feature -> Rule mapping as requirements)
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

# Test Specification Configuration (Feature -> Rule -> Scenario with tests)
# Used for generating test specification and traceability documents.
# Features become aspects (system areas), Rules become requirements,
# and Scenarios become test elements traced to their parent requirements.
TEST_SPECIFICATION_CONFIG = ConversionConfig(
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
