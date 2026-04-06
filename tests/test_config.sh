#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/lib/config.sh"

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

# Test 1: load_config succeeds with valid file
echo "--- Test 1: load_config ---"
load_config "$SCRIPT_DIR/fixtures/sample-settings.yaml"
assert_eq "CONFIG_FILE set" "$SCRIPT_DIR/fixtures/sample-settings.yaml" "$CONFIG_FILE"

# Test 2: get_iteration_cap
echo "--- Test 2: get_iteration_cap ---"
CAP=$(get_iteration_cap)
assert_eq "iteration cap is 5" "5" "$CAP"

# Test 3: get_active_auditors for novel_plan (only enabled ones)
echo "--- Test 3: get_active_auditors novel_plan ---"
AUDITORS=$(get_active_auditors "novel_plan")
assert_eq "only narrative-arc enabled" "narrative-arc" "$AUDITORS"

# Test 4: get_active_auditors for scene (multiple enabled)
echo "--- Test 4: get_active_auditors scene ---"
AUDITORS=$(get_active_auditors "scene")
EXPECTED=$(printf "prose-quality\ncharacter-voice")
assert_eq "prose-quality and character-voice enabled" "$EXPECTED" "$AUDITORS"

# Test 5: get_active_auditors for chapter_plan
echo "--- Test 5: get_active_auditors chapter_plan ---"
AUDITORS=$(get_active_auditors "chapter_plan")
assert_eq "scene-design enabled" "scene-design" "$AUDITORS"

# Test 6: load_config fails on missing file
echo "--- Test 6: load_config fails on missing ---"
if load_config "/nonexistent/file.yaml" 2>/dev/null; then
    echo "FAIL: should have exited nonzero"
    FAIL=$((FAIL + 1))
else
    echo "PASS: load_config rejects missing file"
    PASS=$((PASS + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
