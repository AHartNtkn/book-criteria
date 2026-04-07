#!/usr/bin/env python3
"""Generate random dictionary words for brainstorming injection.

Usage: python3 random_words.py [COUNT]

Selects COUNT (default 5) random words from the system dictionary.
Outputs one word per line.
"""

import random
import sys

DICT_PATHS = [
    "/usr/share/dict/words",
    "/usr/share/dict/american-english",
    "/usr/share/dict/british-english",
]


def load_words():
    for path in DICT_PATHS:
        try:
            with open(path) as f:
                words = [
                    line.strip()
                    for line in f
                    if line.strip()
                    and not line.strip()[0].isupper()  # skip proper nouns
                    and len(line.strip()) > 2  # skip very short words
                    and "'" not in line  # skip contractions
                ]
                if words:
                    return words
        except FileNotFoundError:
            continue

    print("FATAL: No system dictionary found. Tried:", file=sys.stderr)
    for p in DICT_PATHS:
        print(f"  {p}", file=sys.stderr)
    sys.exit(1)


def main():
    count = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    words = load_words()
    selected = random.sample(words, min(count, len(words)))
    for word in selected:
        print(word)


if __name__ == "__main__":
    main()
