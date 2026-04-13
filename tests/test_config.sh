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

# === Criteria settings ===

# Test 1: load_criteria_settings
echo "--- Test 1: load_criteria_settings ---"
load_criteria_settings "$SCRIPT_DIR/fixtures/sample-criteria-settings.yaml"
assert_eq "CRITERIA_FILE set" "$SCRIPT_DIR/fixtures/sample-criteria-settings.yaml" "$CRITERIA_FILE"

# Test 2: get_iteration_cap from criteria settings
echo "--- Test 2: get_iteration_cap ---"
CAP=$(get_iteration_cap)
assert_eq "iteration cap is 3 from criteria file" "3" "$CAP"

# Test 3: is_criterion_enabled — enabled criterion
echo "--- Test 3: is_criterion_enabled (enabled) ---"
RESULT=$(is_criterion_enabled "hook-effectiveness")
assert_eq "hook-effectiveness is enabled" "true" "$RESULT"

# Test 4: is_criterion_enabled — disabled criterion
echo "--- Test 4: is_criterion_enabled (disabled) ---"
RESULT=$(is_criterion_enabled "thematic-depth")
assert_eq "thematic-depth is disabled" "false" "$RESULT"

# Test 5: is_criterion_enabled — unlisted criterion defaults to true
echo "--- Test 5: is_criterion_enabled (unlisted) ---"
RESULT=$(is_criterion_enabled "nonexistent-criterion")
assert_eq "unlisted criterion defaults to true" "true" "$RESULT"

# Test 6: is_sentinel_enabled — enabled sentinel
echo "--- Test 6: is_sentinel_enabled (enabled) ---"
RESULT=$(is_sentinel_enabled "flat-escalation")
assert_eq "flat-escalation is enabled" "true" "$RESULT"

# Test 7: is_sentinel_enabled — disabled sentinel
echo "--- Test 7: is_sentinel_enabled (disabled) ---"
RESULT=$(is_sentinel_enabled "slow-opening")
assert_eq "slow-opening is disabled" "false" "$RESULT"

# Test 8: get_enabled_criteria
echo "--- Test 8: get_enabled_criteria ---"
ENABLED=$(get_enabled_criteria)
EXPECTED=$(printf "hook-effectiveness\nstakes-escalation\nprose-density")
assert_eq "three criteria enabled" "$EXPECTED" "$ENABLED"

# Test 9: get_enabled_sentinels
echo "--- Test 9: get_enabled_sentinels ---"
ENABLED=$(get_enabled_sentinels)
EXPECTED=$(printf "flat-escalation\nllm-stock-phrases")
assert_eq "two sentinels enabled" "$EXPECTED" "$ENABLED"

# Test 10: load_criteria_settings fails on missing file
echo "--- Test 10: load_criteria_settings fails on missing ---"
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
