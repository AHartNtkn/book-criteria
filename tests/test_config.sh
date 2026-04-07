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

# === Auditor settings (existing) ===

# Test 1: load_config succeeds with valid file
echo "--- Test 1: load_config ---"
load_config "$SCRIPT_DIR/fixtures/sample-settings.yaml"
assert_eq "CONFIG_FILE set" "$SCRIPT_DIR/fixtures/sample-settings.yaml" "$CONFIG_FILE"

# Test 2: get_iteration_cap from auditor settings
echo "--- Test 2: get_iteration_cap (auditor settings) ---"
CAP=$(get_iteration_cap)
assert_eq "iteration cap is 5" "5" "$CAP"

# Test 3: get_active_auditors for novel_plan
echo "--- Test 3: get_active_auditors novel_plan ---"
AUDITORS=$(get_active_auditors "novel_plan")
EXPECTED=$(printf "narrative-arc\npremise-alignment")
assert_eq "all novel_plan auditors listed" "$EXPECTED" "$AUDITORS"

# Test 4: get_active_auditors for scene
echo "--- Test 4: get_active_auditors scene ---"
AUDITORS=$(get_active_auditors "scene")
EXPECTED=$(printf "prose-quality\ncharacter-voice\ndialogue-subtext")
assert_eq "all scene auditors listed" "$EXPECTED" "$AUDITORS"

# Test 5: get_active_auditors for chapter_plan
echo "--- Test 5: get_active_auditors chapter_plan ---"
AUDITORS=$(get_active_auditors "chapter_plan")
assert_eq "scene-design listed" "scene-design" "$AUDITORS"

# Test 6: load_config fails on missing file
echo "--- Test 6: load_config fails on missing ---"
if load_config "/nonexistent/file.yaml" 2>/dev/null; then
    echo "FAIL: should have exited nonzero"
    FAIL=$((FAIL + 1))
else
    echo "PASS: load_config rejects missing file"
    PASS=$((PASS + 1))
fi

# === Criteria settings (new) ===

# Test 7: load_criteria_settings
echo "--- Test 7: load_criteria_settings ---"
load_criteria_settings "$SCRIPT_DIR/fixtures/sample-criteria-settings.yaml"
assert_eq "CRITERIA_FILE set" "$SCRIPT_DIR/fixtures/sample-criteria-settings.yaml" "$CRITERIA_FILE"

# Test 8: get_iteration_cap from criteria settings (overrides auditor settings)
echo "--- Test 8: get_iteration_cap (criteria settings) ---"
CAP=$(get_iteration_cap)
assert_eq "iteration cap is 3 from criteria file" "3" "$CAP"

# Test 9: is_criterion_enabled — enabled criterion
echo "--- Test 9: is_criterion_enabled (enabled) ---"
RESULT=$(is_criterion_enabled "hook-effectiveness")
assert_eq "hook-effectiveness is enabled" "true" "$RESULT"

# Test 10: is_criterion_enabled — disabled criterion
echo "--- Test 10: is_criterion_enabled (disabled) ---"
RESULT=$(is_criterion_enabled "thematic-depth")
assert_eq "thematic-depth is disabled" "false" "$RESULT"

# Test 11: is_criterion_enabled — unlisted criterion defaults to true
echo "--- Test 11: is_criterion_enabled (unlisted) ---"
RESULT=$(is_criterion_enabled "nonexistent-criterion")
assert_eq "unlisted criterion defaults to true" "true" "$RESULT"

# Test 12: is_sentinel_enabled — enabled sentinel
echo "--- Test 12: is_sentinel_enabled (enabled) ---"
RESULT=$(is_sentinel_enabled "flat-escalation")
assert_eq "flat-escalation is enabled" "true" "$RESULT"

# Test 13: is_sentinel_enabled — disabled sentinel
echo "--- Test 13: is_sentinel_enabled (disabled) ---"
RESULT=$(is_sentinel_enabled "slow-opening")
assert_eq "slow-opening is disabled" "false" "$RESULT"

# Test 14: get_enabled_criteria
echo "--- Test 14: get_enabled_criteria ---"
ENABLED=$(get_enabled_criteria)
EXPECTED=$(printf "hook-effectiveness\nstakes-escalation\nprose-density")
assert_eq "three criteria enabled" "$EXPECTED" "$ENABLED"

# Test 15: get_enabled_sentinels
echo "--- Test 15: get_enabled_sentinels ---"
ENABLED=$(get_enabled_sentinels)
EXPECTED=$(printf "flat-escalation\nllm-stock-phrases")
assert_eq "two sentinels enabled" "$EXPECTED" "$ENABLED"

# Test 16: load_criteria_settings fails on missing file
echo "--- Test 16: load_criteria_settings fails on missing ---"
if load_criteria_settings "/nonexistent/file.yaml" 2>/dev/null; then
    echo "FAIL: should have exited nonzero"
    FAIL=$((FAIL + 1))
else
    echo "PASS: load_criteria_settings rejects missing file"
    PASS=$((PASS + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
