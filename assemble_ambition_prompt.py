#!/usr/bin/env python3
"""Assemble the ambition synthesis prompt for a given pipeline level.

Usage: python3 assemble_ambition_prompt.py LEVEL [--settings FILE] [--config FILE] [--defs FILE]

Collects all criteria and sentinels assigned to auditors at the given level,
filters by settings, formats their definitions, and fills the ambition prompt
template. Outputs the filled prompt to stdout for piping to claude -p.
"""

import os
import sys
import yaml

TEMPLATE_FILE = "prompts/synthesize-ambition.md"
CONFIG_FILE = "auditor-config.yaml"
DEFINITIONS_FILE = "criteria-definitions.yaml"
SETTINGS_FILE = "criteria-settings.yaml"

VALID_LEVELS = ("scene", "chapter_plan", "novel_plan")

LEVEL_LABELS = {
    "scene": "scene",
    "chapter_plan": "chapter plan",
    "novel_plan": "novel plan",
}


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


def collect_ids_for_level(config, level):
    criteria_ids = []
    sentinel_ids = []
    seen_criteria = set()
    seen_sentinels = set()

    for auditor in config.get("auditors", []):
        if auditor.get("level") != level:
            continue
        for cid in auditor.get("criteria", []):
            if cid not in seen_criteria:
                seen_criteria.add(cid)
                criteria_ids.append(cid)
        for sid in auditor.get("sentinels", []):
            if sid not in seen_sentinels:
                seen_sentinels.add(sid)
                sentinel_ids.append(sid)

    return criteria_ids, sentinel_ids


def format_criterion(item_id, defn):
    lines = [f"### {item_id}: {defn['name']}"]
    lines.append(f"**What it measures**: {defn['measures']}")
    lines.append(f"**Score 5**: {defn['score_5']}")
    return "\n".join(lines)


def format_sentinel(item_id, defn):
    lines = [f"### {item_id}: {defn['name']}"]
    lines.append(f"**Detection**: {defn['detection']}")
    return "\n".join(lines)


def main():
    level = sys.argv[1] if len(sys.argv) > 1 else None

    if not level or level.startswith("--"):
        print(f"FATAL: Level argument required. Use one of: {', '.join(VALID_LEVELS)}", file=sys.stderr)
        sys.exit(1)

    if level not in VALID_LEVELS:
        print(f"FATAL: Unknown level: {level}. Use one of: {', '.join(VALID_LEVELS)}", file=sys.stderr)
        sys.exit(1)

    defs_file = DEFINITIONS_FILE
    settings_file = SETTINGS_FILE
    config_file = CONFIG_FILE

    args = sys.argv[2:]
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

    if not os.path.isfile(TEMPLATE_FILE):
        print(f"FATAL: Template not found: {TEMPLATE_FILE}", file=sys.stderr)
        sys.exit(1)

    with open(TEMPLATE_FILE) as f:
        template = f.read()

    criteria_ids, sentinel_ids = collect_ids_for_level(config, level)

    criteria_parts = []
    for cid in criteria_ids:
        if is_disabled(cid, settings):
            continue
        defn = defs.get("criteria", {}).get(cid)
        if defn:
            criteria_parts.append(format_criterion(cid, defn))

    sentinel_parts = []
    for sid in sentinel_ids:
        if is_disabled(sid, settings):
            continue
        defn = defs.get("sentinels", {}).get(sid)
        if defn:
            sentinel_parts.append(format_sentinel(sid, defn))
        else:
            defn = defs.get("criteria", {}).get(sid)
            if defn:
                sentinel_parts.append(format_criterion(sid, defn))

    criteria_text = "\n\n".join(criteria_parts) if criteria_parts else "(No active criteria.)"
    sentinels_text = "\n\n".join(sentinel_parts) if sentinel_parts else "(No active sentinels.)"

    filled = template.replace("{level}", LEVEL_LABELS[level])
    filled = filled.replace("{criteria_text}", criteria_text)
    filled = filled.replace("{sentinels_text}", sentinels_text)

    print(filled)


if __name__ == "__main__":
    main()
