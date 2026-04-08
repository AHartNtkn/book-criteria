#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TESTDIR=$(mktemp -d)
trap "rm -rf $TESTDIR" EXIT
STATE_DIR="$TESTDIR/state"
mkdir -p "$STATE_DIR/audit-logs"

source "$PROJECT_DIR/lib/scoring.sh"

PASS_COUNT=0
FAIL_COUNT=0

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $label"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $label"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

SAMPLE="$SCRIPT_DIR/fixtures/sample-audit-output.txt"

# Test 1: extract_scores pulls JSON from audit output
echo "--- Test 1: extract_scores ---"
SCORES=$(extract_scores < "$SAMPLE")
# Check it's valid JSON (jq empty returns 0 on valid JSON, outputs nothing)
if echo "$SCORES" | jq empty 2>/dev/null; then
    echo "PASS: extracted valid JSON"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "FAIL: extracted invalid JSON"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
assert_eq "sensory-grounding score" "5" "$(echo "$SCORES" | jq '.criteria["sensory-grounding"].score')"
assert_eq "show-not-tell score" "3" "$(echo "$SCORES" | jq '.criteria["show-not-tell"].score')"

# Test 2: check_criteria_passing with threshold 4
echo "--- Test 2: check_criteria_passing ---"
RESULT=$(check_criteria_passing "$SCORES" 4 2>/dev/null)
assert_eq "fails when show-not-tell is 3" "FAIL" "$RESULT"

# Test 3: check_criteria_passing with threshold 3
echo "--- Test 3: check_criteria_passing threshold 3 ---"
RESULT=$(check_criteria_passing "$SCORES" 3 2>/dev/null)
assert_eq "passes when threshold is 3" "PASS" "$RESULT"

# Test 4: check_sentinels_passing
echo "--- Test 4: check_sentinels_passing ---"
RESULT=$(check_sentinels_passing "$SCORES" 2>/dev/null)
assert_eq "fails when excessive-nodding is FAIL" "FAIL" "$RESULT"

# Test 5: check_sentinels_passing with all-pass input
echo "--- Test 5: sentinels all pass ---"
ALL_PASS='{"criteria":{},"sentinels":{"s1":{"status":"PASS","evidence":"ok"}}}'
RESULT=$(check_sentinels_passing "$ALL_PASS" 2>/dev/null)
assert_eq "passes when all sentinels pass" "PASS" "$RESULT"

# Test 6: log_scores writes file
echo "--- Test 6: log_scores ---"
log_scores "test-level" "1" "$SCORES"
assert_eq "log file created" "true" \
    "$(test -f "$STATE_DIR/audit-logs/test-level-round-1.json" && echo true || echo false)"

# Test 7: merge_scores combines two auditor outputs
echo "--- Test 7: merge_scores ---"
SCORES_A='{"criteria":{"a":{"score":4,"evidence":"ok"}},"sentinels":{"s1":{"status":"PASS","evidence":"ok"}}}'
SCORES_B='{"criteria":{"b":{"score":5,"evidence":"great"}},"sentinels":{"s2":{"status":"FAIL","evidence":"bad"}}}'
MERGED=$(merge_scores "$SCORES_A" "$SCORES_B")
assert_eq "merged has criterion a" "4" "$(echo "$MERGED" | jq '.criteria.a.score')"
assert_eq "merged has criterion b" "5" "$(echo "$MERGED" | jq '.criteria.b.score')"
assert_eq "merged has sentinel s1" "PASS" "$(echo "$MERGED" | jq -r '.sentinels.s1.status')"
assert_eq "merged has sentinel s2" "FAIL" "$(echo "$MERGED" | jq -r '.sentinels.s2.status')"

echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"
[[ "$FAIL_COUNT" -eq 0 ]] || exit 1
