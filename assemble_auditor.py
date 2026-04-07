#!/usr/bin/env python3
"""Assemble a filled auditor prompt for a specific auditor.

Usage: python3 assemble_auditor.py AUDITOR_NAME [--settings FILE] [--config FILE] [--defs FILE]

Reads the auditor config, criteria definitions, and current settings.
Outputs the filled prompt to stdout.

The pipeline calls this for each auditor, pipes the output to claude -p.
"""

import os
import sys
import yaml

TEMPLATE_FILE = "prompts/auditor-template.md"
CONFIG_FILE = "auditor-config.yaml"
DEFINITIONS_FILE = "criteria-definitions.yaml"
SETTINGS_FILE = "criteria-settings.yaml"

CONTENT_DESCRIPTIONS = {
    "scene": "a prose scene for specific quality criteria and failure patterns",
    "chapter_plan": "a chapter's scene-level plan for structural quality and design patterns",
    "novel_plan": "a novel's chapter-level plan for narrative architecture and design quality",
}

CONTEXT_LABELS = {
    "premise": "Story Premise",
    "novel_plan": "Novel Plan",
    "chapter_plan": "Chapter Plan",
    "relevant_context": "Relevant Context From Prior Chapters",
    "preceding_scenes": "Preceding Scenes In This Chapter",
    "scene": "Scene Being Evaluated",
    "completed_chapters_summary": "Completed Chapters Summary",
    "content": "Content Being Evaluated",
}


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)


def load_template(path):
    with open(path) as f:
        return f.read()


def get_enabled_ids(settings):
    """Return set of IDs that are enabled (explicitly true or not listed)."""
    disabled = set()
    for item_id, enabled in settings.get("criteria", {}).items():
        if not enabled:
            disabled.add(item_id)
    for item_id, enabled in settings.get("sentinels", {}).items():
        if not enabled:
            disabled.add(item_id)
    return disabled


def format_criterion(item_id, defn):
    """Format a criterion definition for injection into the template."""
    lines = [f"### {item_id}: {defn['name']}"]
    lines.append(f"**What it measures**: {defn['measures']}")
    lines.append(f"**Score 0**: {defn['score_0']}")
    lines.append(f"**Score 5**: {defn['score_5']}")
    return "\n".join(lines)


def format_sentinel(item_id, defn):
    """Format a sentinel definition for injection into the template."""
    lines = [f"### {item_id}: {defn['name']}"]
    lines.append(f"**Detection**: {defn['detection']}")
    lines.append(f"**Why it indicates autocomplete**: {defn['why_autocomplete']}")
    return "\n".join(lines)


def build_context_sections(context_keys):
    """Build context placeholder sections for the template."""
    sections = []
    for key in context_keys:
        label = CONTEXT_LABELS.get(key, key)
        sections.append(f"## {label}\n\n{{{key}}}")
    return "\n\n".join(sections)


def assemble(auditor_name, config, definitions, settings, template):
    """Assemble the filled prompt for one auditor."""
    # Find auditor in config
    auditor = None
    for a in config["auditors"]:
        if a["name"] == auditor_name:
            auditor = a
            break

    if auditor is None:
        print(f"FATAL: Auditor '{auditor_name}' not found in config", file=sys.stderr)
        sys.exit(1)

    level = auditor["level"]
    context_keys = auditor["context"]
    criteria_ids = auditor.get("criteria", [])
    sentinel_ids = auditor.get("sentinels", [])

    # Filter by enabled settings
    disabled = get_enabled_ids(settings)
    active_criteria = [cid for cid in criteria_ids if cid not in disabled]
    active_sentinels = [sid for sid in sentinel_ids if sid not in disabled]

    # Build criteria text
    criteria_parts = []
    for cid in active_criteria:
        defn = definitions.get("criteria", {}).get(cid)
        if defn is None:
            print(f"WARNING: No definition for criterion {cid}", file=sys.stderr)
            continue
        criteria_parts.append(format_criterion(cid, defn))

    # Build sentinel text
    # Some ML items may be classified as criteria in the definitions file
    # but listed as sentinels in the auditor config. Check both sections.
    sentinel_parts = []
    for sid in active_sentinels:
        defn = definitions.get("sentinels", {}).get(sid)
        if defn is None:
            # Check criteria section for ML items
            defn = definitions.get("criteria", {}).get(sid)
            if defn is not None:
                # Adapt criteria format to sentinel format
                defn = {
                    "name": defn["name"],
                    "detection": defn.get("measures", ""),
                    "why_autocomplete": f"Score 0: {defn.get('score_0', '')}",
                }
        if defn is None:
            print(f"WARNING: No definition for sentinel {sid}", file=sys.stderr)
            continue
        sentinel_parts.append(format_sentinel(sid, defn))

    criteria_text = "\n\n".join(criteria_parts) if criteria_parts else "(No active criteria for this auditor with current settings.)"
    sentinels_text = "\n\n".join(sentinel_parts) if sentinel_parts else "(No active sentinels for this auditor with current settings.)"

    content_desc = CONTENT_DESCRIPTIONS.get(level, f"content at the {level} level")
    context_sections = build_context_sections(context_keys)

    # Fill template
    filled = template
    filled = filled.replace("{auditor_name}", auditor_name)
    filled = filled.replace("{content_description}", content_desc)
    filled = filled.replace("{context_sections}", context_sections)
    filled = filled.replace("{criteria_text}", criteria_text)
    filled = filled.replace("{sentinels_text}", sentinels_text)

    return filled


def main():
    if len(sys.argv) < 2:
        print("Usage: assemble_auditor.py AUDITOR_NAME [--settings FILE] [--config FILE] [--defs FILE]",
              file=sys.stderr)
        sys.exit(1)

    auditor_name = sys.argv[1]

    # Parse optional file overrides
    settings_file = SETTINGS_FILE
    config_file = CONFIG_FILE
    defs_file = DEFINITIONS_FILE

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
            print(f"Unknown argument: {args[i]}", file=sys.stderr)
            sys.exit(1)

    # Load files
    for path, name in [(config_file, "config"), (defs_file, "definitions"),
                        (TEMPLATE_FILE, "template")]:
        if not os.path.isfile(path):
            print(f"FATAL: {name} file not found: {path}", file=sys.stderr)
            sys.exit(1)

    config = load_yaml(config_file)
    definitions = load_yaml(defs_file)
    settings = load_yaml(settings_file) if os.path.isfile(settings_file) else {}
    template = load_template(TEMPLATE_FILE)

    result = assemble(auditor_name, config, definitions, settings, template)
    print(result)


if __name__ == "__main__":
    main()
