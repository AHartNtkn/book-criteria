#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TESTDIR=$(mktemp -d)
trap "rm -rf $TESTDIR" EXIT

cd "$PROJECT_DIR"

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
    local label="$1" needle="$2" file="$3"
    if grep -qF "$needle" "$file"; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  Expected file to contain: $needle"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local label="$1" needle="$2" file="$3"
    if ! grep -qF "$needle" "$file"; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  Expected file NOT to contain: $needle"
        FAIL=$((FAIL + 1))
    fi
}

# Backup and restore criteria-settings.yaml
BACKUP=""
if [[ -f criteria-settings.yaml ]]; then
    BACKUP="$TESTDIR/backup.yaml"
    cp criteria-settings.yaml "$BACKUP"
fi
restore_settings() {
    if [[ -n "$BACKUP" ]]; then
        cp "$BACKUP" criteria-settings.yaml
    else
        rm -f criteria-settings.yaml
    fi
}
trap "restore_settings; rm -rf $TESTDIR" EXIT

# ── Test 1: Defaults mode ──────────────────────────────────────

echo "--- Test 1: Defaults mode ---"
python3 process_questionnaire.py --defaults > "$TESTDIR/output1.txt" 2>&1
assert_eq "exits 0" "0" "$?"
assert_contains "file generated" "Generated criteria-settings.yaml" "$TESTDIR/output1.txt"

# With defaults (hybrid, no genre), genre items should be OFF
assert_contains "genre item CC-029 off" "CC-029: false" criteria-settings.yaml
assert_contains "genre item CC-044 off" "CC-044: false" criteria-settings.yaml
# No items should be explicitly true (hybrid disables nothing, no genre enables nothing)
EXPLICIT_TRUE=$(grep -c ": true" criteria-settings.yaml 2>/dev/null; true)
assert_eq "no explicit true with defaults" "0" "$EXPLICIT_TRUE"

# ── Test 2: Answers file mode ─────────────────────────────────

echo "--- Test 2: Answers file mode ---"

# Commercial + detective mystery
cat > "$TESTDIR/answers.yaml" << 'EOF'
fiction_tradition: commercial
genre: detective_mystery
prose_style: balanced
structural_approach: hybrid
thematic_ambition: central
pov_approach: mixed
tonal_register: mixed
character_arc_model: transformative
EOF

python3 process_questionnaire.py --answers "$TESTDIR/answers.yaml" > "$TESTDIR/output2.txt" 2>&1
assert_eq "exits 0" "0" "$?"

# Detective mystery items should be ON
assert_contains "mystery item CC-029 on" "CC-029: true" criteria-settings.yaml
assert_contains "mystery item CC-044 on" "CC-044: true" criteria-settings.yaml

# Commercial disables literary items
assert_contains "literary SC-054 off" "SC-054: false" criteria-settings.yaml
assert_contains "literary SC-247 off" "SC-247: false" criteria-settings.yaml

# Non-detective genre items should still be OFF
assert_contains "space opera CC-001 off" "CC-001: false" criteria-settings.yaml

# ── Test 3: Literary + no genre ───────────────────────────────

echo "--- Test 3: Literary + no genre ---"

cat > "$TESTDIR/answers2.yaml" << 'EOF'
fiction_tradition: literary
genre: none
prose_style: opaque
structural_approach: experimental
thematic_ambition: central
pov_approach: omniscient
tonal_register: serious
character_arc_model: anti_arc
EOF

python3 process_questionnaire.py --answers "$TESTDIR/answers2.yaml" > "$TESTDIR/output3.txt" 2>&1
assert_eq "exits 0" "0" "$?"

# Literary disables commercial structural items
assert_contains "commercial NC-028 off" "NC-028: false" criteria-settings.yaml
assert_contains "commercial CC-121 off" "CC-121: false" criteria-settings.yaml

# Literary should NOT disable literary items
assert_not_contains "SC-054 should not be off" "SC-054: false" criteria-settings.yaml

# Opaque prose disables ornament-policing items (check a few)
# Experimental disables rigid structural items
# These would need specific ID checks — the point is it runs without error

# ── Test 4: Missing answers file ──────────────────────────────

echo "--- Test 4: Missing answers file ---"
if python3 process_questionnaire.py --answers /nonexistent/path.yaml > /dev/null 2>&1; then
    echo "FAIL: should have exited nonzero"
    FAIL=$((FAIL + 1))
else
    echo "PASS: rejects missing answers file"
    PASS=$((PASS + 1))
fi

# ── Test 5: Config parser integration ─────────────────────────

echo "--- Test 5: Config parser reads generated settings ---"

# Generate settings with known answers
python3 process_questionnaire.py --answers "$TESTDIR/answers.yaml" > /dev/null 2>&1

# Source config parser and verify it reads the generated file
source lib/config.sh
load_criteria_settings criteria-settings.yaml

# CC-029 should be enabled (detective mystery)
RESULT=$(is_criterion_enabled "CC-029")
assert_eq "CC-029 enabled via detective_mystery" "true" "$RESULT"

# SC-054 should be disabled (commercial disables literary items)
RESULT=$(is_criterion_enabled "SC-054")
assert_eq "SC-054 disabled via commercial" "false" "$RESULT"

# Unlisted item should default to true
RESULT=$(is_criterion_enabled "SC-001")
assert_eq "unlisted SC-001 defaults to true" "true" "$RESULT"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
