#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TESTDIR=$(mktemp -d)
trap "rm -rf $TESTDIR" EXIT

# Override state directory for testing
STATE_DIR="$TESTDIR/state"

source "$PROJECT_DIR/lib/state.sh"

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

# Test 1: init_state creates files
echo "--- Test 1: init_state ---"
init_state
assert_eq "progress.json exists" "true" "$(test -f "$STATE_DIR/progress.json" && echo true || echo false)"
assert_eq "audit-logs dir exists" "true" "$(test -d "$STATE_DIR/audit-logs" && echo true || echo false)"

# Test 2: read_state returns initial values
echo "--- Test 2: read_state initial values ---"
assert_eq "initial phase" "novel_planning" "$(read_state phase)"
assert_eq "initial chapter" "0" "$(read_state chapter)"
assert_eq "initial scene" "0" "$(read_state scene)"
assert_eq "initial status" "starting" "$(read_state status)"

# Test 3: update_state changes values
echo "--- Test 3: update_state ---"
update_state "phase" '"chapter_planning"'
update_state "chapter" "3"
update_state "scene" "2"
assert_eq "updated phase" "chapter_planning" "$(read_state phase)"
assert_eq "updated chapter" "3" "$(read_state chapter)"
assert_eq "updated scene" "2" "$(read_state scene)"

# Test 4: init_state does not overwrite existing state
echo "--- Test 4: init_state preserves existing ---"
init_state
assert_eq "phase preserved" "chapter_planning" "$(read_state phase)"
assert_eq "chapter preserved" "3" "$(read_state chapter)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
