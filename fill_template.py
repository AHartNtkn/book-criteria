#!/usr/bin/env python3
"""Template expansion utility for the fiction pipeline.

Usage: python3 fill_template.py TEMPLATE_FILE [KEY=SOURCE ...]

For each KEY=SOURCE pair:
  - If SOURCE is a readable file: replaces {KEY} with <KEY>\n...content...\n</KEY>
  - Otherwise: replaces {KEY} with the literal SOURCE value

Unreferenced placeholders are left as-is (they won't silently vanish).
Warns on stderr if a SOURCE looks like a file path but doesn't exist.
"""

import os
import sys


def main():
    if len(sys.argv) < 2:
        print("Usage: fill_template.py TEMPLATE_FILE [KEY=SOURCE ...]", file=sys.stderr)
        sys.exit(1)

    template_path = sys.argv[1]
    if not os.path.isfile(template_path):
        print(f"FATAL: Template file not found: {template_path}", file=sys.stderr)
        sys.exit(1)

    with open(template_path) as f:
        content = f.read()

    for arg in sys.argv[2:]:
        if "=" not in arg:
            print(f"FATAL: Invalid argument (expected KEY=SOURCE): {arg}", file=sys.stderr)
            sys.exit(1)

        key, source = arg.split("=", 1)

        if os.path.isfile(source):
            with open(source) as f:
                file_content = f.read()
            replacement = f"<{key}>\n{file_content}\n</{key}>"
            content = content.replace("{" + key + "}", replacement)
        elif "/" in source or source.endswith(".md") or source.endswith(".yaml"):
            # Looks like a file path but doesn't exist — warn
            print(f"WARNING: File not found for {key}: {source}", file=sys.stderr)
        else:
            # Literal value
            content = content.replace("{" + key + "}", source)

    print(content)


if __name__ == "__main__":
    main()
