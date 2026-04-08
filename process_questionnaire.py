#!/usr/bin/env python3
"""Process the style questionnaire and generate criteria-settings.yaml.

Usage:
    python3 process_questionnaire.py                    # Interactive mode
    python3 process_questionnaire.py --answers FILE     # From answers file
    python3 process_questionnaire.py --defaults         # Use defaults

Reads questionnaire.yaml, prompts for answers (or reads them from a file),
then generates criteria-settings.yaml with per-criterion/sentinel toggles.

Default state: everything ON except genre-specific items (which are OFF
until a genre is selected).
"""

import sys
import yaml
import os

QUESTIONNAIRE_FILE = "questionnaire.yaml"
OUTPUT_FILE = "criteria-settings.yaml"


def load_questionnaire(path):
    with open(path) as f:
        data = yaml.safe_load(f)
    return data["questions"], data.get("defaults", {})


def collect_all_ids(questions):
    """Collect every criterion/sentinel ID referenced in the questionnaire."""
    genre_ids = set()
    disable_ids = set()

    for q in questions:
        for opt in q["options"]:
            for item_id in opt.get("enables", []):
                genre_ids.add(item_id)
            for item_id in opt.get("disables", []):
                disable_ids.add(item_id)

    return genre_ids, disable_ids


def prompt_interactive(questions):
    """Ask questions interactively, return answers dict."""
    answers = {}
    print("\n=== Fiction Style Questionnaire ===\n")

    for q in questions:
        is_multi = q.get("multi", False)
        print(f"\n{q['text']}\n")
        for i, opt in enumerate(q["options"]):
            print(f"  {i + 1}. {opt['label']}")
        print()

        if is_multi:
            while True:
                choice = input(f"Select one or more (comma-separated, e.g. 1,3): ").strip()
                try:
                    indices = [int(x.strip()) - 1 for x in choice.split(",")]
                    if all(0 <= idx < len(q["options"]) for idx in indices):
                        selected = [q["options"][idx]["id"] for idx in indices]
                        answers[q["id"]] = selected
                        print(f"  → {', '.join(selected)}")
                        break
                except ValueError:
                    pass
                print(f"  Invalid. Enter comma-separated numbers (1-{len(q['options'])}).")
        else:
            while True:
                choice = input(f"Select (1-{len(q['options'])}): ").strip()
                try:
                    idx = int(choice) - 1
                    if 0 <= idx < len(q["options"]):
                        answers[q["id"]] = q["options"][idx]["id"]
                        print(f"  → {q['options'][idx]['id']}")
                        break
                except ValueError:
                    pass
                print(f"  Invalid choice. Enter 1-{len(q['options'])}.")

    return answers


def load_answers_file(path):
    """Load answers from a YAML file."""
    with open(path) as f:
        data = yaml.safe_load(f)
    return data


def apply_answers(questions, answers, genre_ids):
    """Apply questionnaire answers to produce enabled/disabled sets.

    Returns (disabled_ids, enabled_genre_ids).
    """
    disabled = set()
    enabled_genre = set()

    for q in questions:
        answer_val = answers.get(q["id"])
        if answer_val is None:
            continue

        # Multi-select: answer can be a list of IDs
        is_multi = q.get("multi", False)
        if is_multi:
            answer_ids = answer_val if isinstance(answer_val, list) else [answer_val]
        else:
            answer_ids = [answer_val]

        for answer_id in answer_ids:
            chosen = None
            for opt in q["options"]:
                if opt["id"] == answer_id:
                    chosen = opt
                    break

            if chosen is None:
                print(f"WARNING: Unknown answer '{answer_id}' for question '{q['id']}'",
                      file=sys.stderr)
                continue

            for item_id in chosen.get("disables", []):
                disabled.add(item_id)
            for item_id in chosen.get("enables", []):
                enabled_genre.add(item_id)

    return disabled, enabled_genre


def generate_settings(disabled, enabled_genre, genre_ids, iteration_cap=5):
    """Generate the criteria-settings structure.

    All IDs default to ON except genre-specific IDs (which default to OFF
    unless explicitly enabled).
    """
    # Collect all known IDs from the questionnaire
    all_ids = disabled | enabled_genre | genre_ids

    criteria = {}
    sentinels = {}

    for item_id in sorted(all_ids):
        is_genre = item_id in genre_ids
        is_disabled = item_id in disabled
        is_enabled_genre = item_id in enabled_genre

        if is_genre:
            enabled = is_enabled_genre
        else:
            enabled = not is_disabled

        # Classify by ID prefix
        if item_id.startswith("SS-") or item_id.startswith("CS-") or \
           item_id.startswith("NS-") or item_id.startswith("IS-"):
            sentinels[item_id] = enabled
        else:
            criteria[item_id] = enabled

    return {
        "iteration_cap": iteration_cap,
        "criteria": criteria,
        "sentinels": sentinels,
    }


def write_settings(settings, path):
    """Write criteria-settings.yaml."""
    with open(path, "w") as f:
        f.write("# Generated by process_questionnaire.py\n")
        f.write("# Edit manually for fine-grained control.\n\n")
        f.write(f"iteration_cap: {settings['iteration_cap']}\n\n")

        f.write("criteria:\n")
        for item_id, enabled in sorted(settings["criteria"].items()):
            f.write(f"  {item_id}: {str(enabled).lower()}\n")

        f.write("\nsentinels:\n")
        for item_id, enabled in sorted(settings["sentinels"].items()):
            f.write(f"  {item_id}: {str(enabled).lower()}\n")


def main():
    if not os.path.isfile(QUESTIONNAIRE_FILE):
        print(f"FATAL: {QUESTIONNAIRE_FILE} not found", file=sys.stderr)
        sys.exit(1)

    questions, defaults = load_questionnaire(QUESTIONNAIRE_FILE)
    genre_ids, _ = collect_all_ids(questions)

    # Determine mode
    if "--defaults" in sys.argv:
        answers = defaults
        print("Using default answers.")
    elif "--answers" in sys.argv:
        idx = sys.argv.index("--answers")
        if idx + 1 >= len(sys.argv):
            print("FATAL: --answers requires a file path", file=sys.stderr)
            sys.exit(1)
        answers_path = sys.argv[idx + 1]
        if not os.path.isfile(answers_path):
            print(f"FATAL: Answers file not found: {answers_path}", file=sys.stderr)
            sys.exit(1)
        answers = load_answers_file(answers_path)
        print(f"Loaded answers from {answers_path}.")
    else:
        answers = prompt_interactive(questions)

    # Apply answers
    disabled, enabled_genre = apply_answers(questions, answers, genre_ids)

    # Generate and write settings
    settings = generate_settings(disabled, enabled_genre, genre_ids)
    write_settings(settings, OUTPUT_FILE)

    # Summary
    criteria_on = sum(1 for v in settings["criteria"].values() if v)
    criteria_off = sum(1 for v in settings["criteria"].values() if not v)
    sentinels_on = sum(1 for v in settings["sentinels"].values() if v)
    sentinels_off = sum(1 for v in settings["sentinels"].values() if not v)

    print(f"\nGenerated {OUTPUT_FILE}:")
    print(f"  Criteria:  {criteria_on} explicitly on, {criteria_off} explicitly off")
    print(f"  Sentinels: {sentinels_on} explicitly on, {sentinels_off} explicitly off")
    print(f"  (All criteria/sentinels not listed in the file default to ON)")


if __name__ == "__main__":
    main()
