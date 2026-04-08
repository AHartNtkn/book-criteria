#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TESTDIR=$(mktemp -d)
trap "rm -rf $TESTDIR" EXIT

PASS=0
FAIL=0

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local label="$1" needle="$2" haystack="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local label="$1" needle="$2" haystack="$3"
    if ! echo "$haystack" | grep -qF "$needle"; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  Expected NOT to contain: $needle"
        FAIL=$((FAIL + 1))
    fi
}

# Setup: create test context files
echo "A story about a detective on Mars." > "$TESTDIR/premise.md"
printf "Chapter 1: Arrival\nChapter 2: Investigation\n" > "$TESTDIR/novel-plan.md"

# Test 1: File placeholder replacement
echo "--- Test 1: File placeholder replacement ---"
OUTPUT=$(python3 "$PROJECT_DIR/fill_template.py" \
    "$PROJECT_DIR/tests/fixtures/sample-template.md" \
    "premise=$TESTDIR/premise.md" \
    "novel_plan=$TESTDIR/novel-plan.md" \
    "chapter_number=3")

assert_contains "premise replaced with tagged content" \
    "<premise>" "$OUTPUT"
assert_contains "premise file content present" \
    "A story about a detective on Mars." "$OUTPUT"
assert_contains "novel_plan replaced" \
    "Chapter 1: Arrival" "$OUTPUT"
assert_not_contains "no remaining premise placeholder" \
    "{premise}" "$OUTPUT"
assert_not_contains "no remaining novel_plan placeholder" \
    "{novel_plan}" "$OUTPUT"

# Test 2: Literal value replacement
echo "--- Test 2: Literal value replacement ---"
assert_contains "literal chapter number" \
    "Literal value: 3" "$OUTPUT"
assert_not_contains "no remaining chapter_number placeholder" \
    "{chapter_number}" "$OUTPUT"

# Test 3: Missing file handled gracefully
echo "--- Test 3: Missing file warns on stderr ---"
STDERR_OUTPUT=$(python3 "$PROJECT_DIR/fill_template.py" \
    "$PROJECT_DIR/tests/fixtures/sample-template.md" \
    "premise=$TESTDIR/nonexistent.md" \
    "novel_plan=$TESTDIR/novel-plan.md" \
    "chapter_number=1" 2>&1 >/dev/null)
assert_contains "warning for missing file" \
    "WARNING" "$STDERR_OUTPUT"

# Test 4: Unreferenced placeholders remain (no silent corruption)
echo "--- Test 4: Unreferenced placeholders remain ---"
PARTIAL=$(python3 "$PROJECT_DIR/fill_template.py" \
    "$PROJECT_DIR/tests/fixtures/sample-template.md" \
    "premise=$TESTDIR/premise.md" \
    "chapter_number=1")
assert_contains "unreplaced placeholder remains" \
    "{novel_plan}" "$PARTIAL"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
