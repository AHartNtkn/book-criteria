#!/usr/bin/env python3
"""Generate ideation guidance text from criteria definitions.

Usage: python3 generate_ideation_guidance.py [premise|chapter] [--settings FILE] [--defs FILE]

Reads criteria definitions and current settings. Outputs guidance text
suitable for injection into brainstorming prompts.
"""

import os
import sys
import yaml

DEFINITIONS_FILE = "criteria-definitions.yaml"
SETTINGS_FILE = "criteria-settings.yaml"

# IDs that apply at ideation level. These come from the structured catalog's
# ideation sections and multi-level items marked for ideation.
# Premise ideation items:
PREMISE_IDEATION_CRITERIA = [
    "IC-001", "IC-002", "IC-004",  # Direct ideation criteria
    "ML-003", "ML-005", "ML-006", "ML-014", "ML-025", "ML-028",
    "ML-041", "ML-048", "ML-050", "ML-061",  # Multi-level at ideation
    # Character concept items relevant at ideation
    "ML-068", "ML-069", "ML-072", "ML-073", "ML-076", "ML-078",
    "ML-080", "ML-084", "ML-085", "ML-087", "ML-090",
    # Thematic items at ideation
    "ML-112", "ML-113", "ML-115", "ML-117", "ML-119", "ML-120",
    # Genre/structural at ideation
    "ML-062", "ML-094", "ML-098", "ML-102",
]

PREMISE_IDEATION_SENTINELS = [
    "IS-001", "IS-004",  # Direct ideation sentinels
    "ML-001", "ML-002", "ML-010", "ML-015",
    "ML-021", "ML-030", "ML-031", "ML-033", "ML-034",
    "ML-037", "ML-038", "ML-044",  # Multi-level sentinels at ideation
    "ML-097", "ML-101", "ML-102",
]

# Chapter ideation items (more constrained — about chapter-level choices):
CHAPTER_IDEATION_CRITERIA = [
    "IC-002",  # Cognitive load
    "ML-061",  # Moral complexity
    "ML-068", "ML-072", "ML-078", "ML-084", "ML-085",  # Character items
    "ML-062", "ML-080", "ML-094",  # Structural items
]

CHAPTER_IDEATION_SENTINELS = [
    "ML-001", "ML-002", "ML-010", "ML-031",
]


def load_yaml(path):
    if not os.path.isfile(path):
        return {}
    with open(path) as f:
        return yaml.safe_load(f) or {}


def is_disabled(item_id, settings):
    for section in ("criteria", "sentinels"):
        if item_id in settings.get(section, {}):
            if not settings[section][item_id]:
                return True
    return False


def format_guidance(defs, settings, criteria_ids, sentinel_ids):
    lines = []

    lines.append("### What to aim for:\n")
    for cid in criteria_ids:
        if is_disabled(cid, settings):
            continue
        defn = defs.get("criteria", {}).get(cid)
        if defn:
            lines.append(f"- **{defn['name']}**: {defn['measures']}")

    lines.append("\n### What to avoid:\n")
    for sid in sentinel_ids:
        if is_disabled(sid, settings):
            continue
        defn = defs.get("sentinels", {}).get(sid)
        if defn:
            lines.append(f"- **{defn['name']}**: {defn['detection']}")
        else:
            # Check criteria section (some ML items classified as criteria)
            defn = defs.get("criteria", {}).get(sid)
            if defn:
                lines.append(f"- **{defn['name']}**: {defn['measures']}")

    return "\n".join(lines)


def main():
    level = sys.argv[1] if len(sys.argv) > 1 else "premise"

    defs_file = DEFINITIONS_FILE
    settings_file = SETTINGS_FILE

    args = sys.argv[2:]
    i = 0
    while i < len(args):
        if args[i] == "--settings" and i + 1 < len(args):
            settings_file = args[i + 1]
            i += 2
        elif args[i] == "--defs" and i + 1 < len(args):
            defs_file = args[i + 1]
            i += 2
        else:
            i += 1

    defs = load_yaml(defs_file)
    settings = load_yaml(settings_file)

    if level == "premise":
        print(format_guidance(defs, settings,
                              PREMISE_IDEATION_CRITERIA, PREMISE_IDEATION_SENTINELS))
    elif level == "chapter":
        print(format_guidance(defs, settings,
                              CHAPTER_IDEATION_CRITERIA, CHAPTER_IDEATION_SENTINELS))
    else:
        print(f"FATAL: Unknown level: {level}. Use 'premise' or 'chapter'.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
