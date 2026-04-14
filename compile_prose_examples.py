#!/usr/bin/env python3
"""Compile prose examples from active criteria definitions.

Usage: python3 compile_prose_examples.py [--settings FILE] [--config FILE] [--defs FILE]

Reads auditor-config.yaml to find scene-level criteria, filters by
criteria-settings.yaml, and outputs all examples found in their definitions.
"""

import os
import sys
import yaml

DEFINITIONS_FILE = "criteria-definitions.yaml"
SETTINGS_FILE = "criteria-settings.yaml"
CONFIG_FILE = "auditor-config.yaml"


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


def main():
    defs_file = DEFINITIONS_FILE
    settings_file = SETTINGS_FILE
    config_file = CONFIG_FILE

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--settings" and i + 1 < len(args):
            settings_file = args[i + 1]
            i += 2
        elif args[i] == "--config" and i + 1 < len(args):
            config_file = args[i + 1]
            i += 2
        elif args[i] == "--defs" and i + 1 < len(args):
            defs_file = args[i + 1]
            i += 2
        else:
            i += 1

    defs = load_yaml(defs_file)
    settings = load_yaml(settings_file)
    config = load_yaml(config_file)

    # Collect scene-level criteria IDs (deduplicated)
    seen = set()
    criteria_ids = []
    for auditor in config.get("auditors", []):
        if auditor.get("level") != "scene":
            continue
        for cid in auditor.get("criteria", []):
            if cid not in seen:
                seen.add(cid)
                criteria_ids.append(cid)

    # Collect examples from active criteria that have them
    lines = []
    for cid in criteria_ids:
        if is_disabled(cid, settings):
            continue
        defn = defs.get("criteria", {}).get(cid)
        if not defn or "examples" not in defn:
            continue
        lines.append(f"### {defn['name']}")
        lines.append("")
        for ex in defn["examples"]:
            lines.append(f"**{ex['author']}**, *{ex['work']}*:")
            lines.append(f"> {ex['passage']}")
            lines.append("")

    if lines:
        print("\n".join(lines))
    else:
        print("(No prose examples available for active criteria.)")


if __name__ == "__main__":
    main()
