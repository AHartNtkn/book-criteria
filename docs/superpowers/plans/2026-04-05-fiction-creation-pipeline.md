# Fiction Creation Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a pipeline that produces novel-length fiction through iterative LLM refinement with focused auditors and holistic fixers.

**Architecture:** A bash orchestrator (`run.sh`) calls `claude -p` with focused prompts in sequence. Hierarchical planning (novel → chapter → scene) with audit/refine loops at each level. A Python utility handles template expansion. Auditor settings control which quality checks are active.

**Tech Stack:** Bash, Python 3 (template utility + JSON parsing), `claude` CLI, `yq` (YAML), `jq` (JSON)

**Spec:** `docs/superpowers/specs/2026-04-05-fiction-creation-pipeline-design.md`

---

## File Map

```
book-criteria/
├── run.sh                              # Pipeline orchestrator
├── fill_template.py                    # Template expansion utility
├── premise.md                          # Story premise (user-provided)
├── auditor-settings.yaml               # Active auditors + iteration cap
├── genre-templates/
│   ├── space-opera.yaml
│   ├── detective-mystery.yaml
│   └── high-fantasy.yaml
├── lib/
│   ├── config.sh                       # Config parsing functions
│   ├── state.sh                        # State management functions
│   ├── scoring.sh                      # Auditor output parsing
│   └── audit.sh                        # Audit/refine loop
├── prompts/
│   ├── plan-novel.md                   # Novel plan creator
│   ├── plan-chapter.md                 # Chapter plan creator
│   ├── author-scene.md                 # Scene author
│   ├── collect-context.md              # Context collector
│   ├── fix-novel-plan.md               # Novel plan fixer
│   ├── fix-chapter-plan.md             # Chapter plan fixer
│   ├── fix-scene.md                    # Scene fixer
│   ├── backtrack-chapter.md            # Chapter plan re-evaluator
│   └── backtrack-novel.md              # Novel plan re-evaluator
├── auditors/                           # One .md per auditor category
│   ├── narrative-arc.md                # Novel plan auditor
│   ├── scene-design.md                 # Chapter plan auditor
│   ├── prose-quality.md                # Scene auditor
│   └── character-voice.md              # Scene auditor
├── output/                             # Generated content (created at runtime)
├── state/                              # Pipeline state (created at runtime)
└── tests/
    ├── test_fill_template.sh
    ├── test_config.sh
    ├── test_state.sh
    ├── test_scoring.sh
    └── fixtures/
        ├── sample-settings.yaml
        ├── sample-audit-output.txt
        └── sample-template.md
```

---

## Phase A: Infrastructure

### Task 1: Directory structure, dependencies, and template utility

**Files:**
- Create: `fill_template.py`
- Create: `tests/test_fill_template.sh`
- Create: `tests/fixtures/sample-template.md`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p lib prompts auditors genre-templates output state/audit-logs tests/fixtures
```

- [ ] **Step 2: Verify dependencies**

```bash
for cmd in claude yq jq python3; do
    command -v "$cmd" || echo "MISSING: $cmd"
done
```

All four must be present. Install any that are missing before proceeding:
- `yq`: https://github.com/mikefarah/yq — `sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq`
- `jq`: `sudo apt install jq`
- `python3`: should already be present
- `claude`: Anthropic CLI — must be installed and authenticated

- [ ] **Step 3: Write the test for fill_template.py**

Create `tests/fixtures/sample-template.md`:
```markdown
# Test Template

Here is the premise:

{premise}

Here is the plan:

{novel_plan}

Literal value: {chapter_number}
```

Create `tests/test_fill_template.sh`:
```bash
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
    "chapter_number=1" 2>&1 >/dev/null) || true
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
```

- [ ] **Step 4: Run test to verify it fails**

```bash
bash tests/test_fill_template.sh
```

Expected: FAIL — `fill_template.py` does not exist yet.

- [ ] **Step 5: Write fill_template.py**

Create `fill_template.py`:
```python
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
```

- [ ] **Step 6: Run test to verify it passes**

```bash
bash tests/test_fill_template.sh
```

Expected: All PASS.

- [ ] **Step 7: Commit**

```bash
git add fill_template.py tests/test_fill_template.sh tests/fixtures/sample-template.md
git commit -m "feat: add template expansion utility with tests"
```

---

### Task 2: Config parsing library

**Files:**
- Create: `lib/config.sh`
- Create: `tests/test_config.sh`
- Create: `tests/fixtures/sample-settings.yaml`

- [ ] **Step 1: Write the test fixture**

Create `tests/fixtures/sample-settings.yaml`:
```yaml
iteration_cap: 5

novel_plan:
  - auditor: narrative-arc
    enabled: true
  - auditor: premise-alignment
    enabled: false

chapter_plan:
  - auditor: scene-design
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: character-voice
    enabled: true
  - auditor: dialogue-subtext
    enabled: false
```

- [ ] **Step 2: Write the test**

Create `tests/test_config.sh`:
```bash
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
```

- [ ] **Step 3: Run test to verify it fails**

```bash
bash tests/test_config.sh
```

Expected: FAIL — `lib/config.sh` does not exist yet.

- [ ] **Step 4: Write lib/config.sh**

Create `lib/config.sh`:
```bash
#!/bin/bash
# Config parsing for the fiction pipeline.
# Requires: yq

CONFIG_FILE=""

load_config() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        echo "FATAL: Config file not found: $config_file" >&2
        return 1
    fi
    CONFIG_FILE="$config_file"
}

get_iteration_cap() {
    yq '.iteration_cap' "$CONFIG_FILE"
}

get_active_auditors() {
    local level="$1"
    yq -r ".${level}[] | select(.enabled == true) | .auditor" "$CONFIG_FILE"
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
bash tests/test_config.sh
```

Expected: All PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/config.sh tests/test_config.sh tests/fixtures/sample-settings.yaml
git commit -m "feat: add config parsing library with tests"
```

---

### Task 3: State management library

**Files:**
- Create: `lib/state.sh`
- Create: `tests/test_state.sh`

- [ ] **Step 1: Write the test**

Create `tests/test_state.sh`:
```bash
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
bash tests/test_state.sh
```

Expected: FAIL.

- [ ] **Step 3: Write lib/state.sh**

Create `lib/state.sh`:
```bash
#!/bin/bash
# State management for the fiction pipeline.
# Requires: jq
#
# STATE_DIR can be overridden before sourcing (for testing).

STATE_DIR="${STATE_DIR:-state}"

init_state() {
    mkdir -p "$STATE_DIR/audit-logs"
    if [[ ! -f "$STATE_DIR/progress.json" ]]; then
        cat > "$STATE_DIR/progress.json" << 'INIT_JSON'
{
    "phase": "novel_planning",
    "chapter": 0,
    "scene": 0,
    "refinement_round": 0,
    "status": "starting"
}
INIT_JSON
    fi
}

read_state() {
    local key="$1"
    jq -r ".$key" "$STATE_DIR/progress.json"
}

update_state() {
    local key="$1"
    local value="$2"
    local tmp
    tmp=$(mktemp)
    jq ".$key = $value" "$STATE_DIR/progress.json" > "$tmp"
    mv "$tmp" "$STATE_DIR/progress.json"
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
bash tests/test_state.sh
```

Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/state.sh tests/test_state.sh
git commit -m "feat: add state management library with tests"
```

---

### Task 4: Score parsing library

**Files:**
- Create: `lib/scoring.sh`
- Create: `tests/test_scoring.sh`
- Create: `tests/fixtures/sample-audit-output.txt`

- [ ] **Step 1: Write the test fixture**

Create `tests/fixtures/sample-audit-output.txt`:
````
This scene demonstrates strong prose quality in several areas. The opening
paragraph grounds the reader effectively with concrete sensory detail.

However, the dialogue in the middle section is weak — characters sound
interchangeable and several exchanges serve only to dump exposition.

The pacing falters in the final third where two consecutive paragraphs
describe the same emotional state without advancement.

```json
{
    "criteria": {
        "sensory-grounding": {"score": 5, "evidence": "Opening paragraph uses smell, sound, and texture to establish the market setting"},
        "sentence-variety": {"score": 4, "evidence": "Mix of short and long sentences throughout, though the middle section gets monotonous"},
        "show-not-tell": {"score": 3, "evidence": "The line 'She felt betrayed' tells directly; contrast with the stronger 'She pushed the ring across the table'"}
    },
    "sentinels": {
        "llm-stock-phrases": {"status": "PASS", "evidence": "No instances of 'a testament to', 'echoed through', or similar"},
        "excessive-nodding": {"status": "FAIL", "evidence": "Characters nod 4 times in 800 words — twice in consecutive paragraphs"}
    }
}
```
````

- [ ] **Step 2: Write the test**

Create `tests/test_scoring.sh`:
```bash
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
assert_eq "extracted JSON is valid" "0" "$(echo "$SCORES" | jq empty 2>&1 | wc -c)"
assert_eq "sensory-grounding score" "5" "$(echo "$SCORES" | jq '.criteria["sensory-grounding"].score')"
assert_eq "show-not-tell score" "3" "$(echo "$SCORES" | jq '.criteria["show-not-tell"].score')"

# Test 2: check_criteria_passing with threshold 4
echo "--- Test 2: check_criteria_passing ---"
RESULT=$(check_criteria_passing "$SCORES" 4 2>/dev/null) || true
assert_eq "fails when show-not-tell is 3" "FAIL" "$RESULT"

# Test 3: check_criteria_passing with threshold 3
echo "--- Test 3: check_criteria_passing threshold 3 ---"
RESULT=$(check_criteria_passing "$SCORES" 3 2>/dev/null) || true
assert_eq "passes when threshold is 3" "PASS" "$RESULT"

# Test 4: check_sentinels_passing
echo "--- Test 4: check_sentinels_passing ---"
RESULT=$(check_sentinels_passing "$SCORES" 2>/dev/null) || true
assert_eq "fails when excessive-nodding is FAIL" "FAIL" "$RESULT"

# Test 5: check_sentinels_passing with all-pass input
echo "--- Test 5: sentinels all pass ---"
ALL_PASS='{"criteria":{},"sentinels":{"s1":{"status":"PASS","evidence":"ok"}}}'
RESULT=$(check_sentinels_passing "$ALL_PASS" 2>/dev/null) || true
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
```

- [ ] **Step 3: Run test to verify it fails**

```bash
bash tests/test_scoring.sh
```

Expected: FAIL.

- [ ] **Step 4: Write lib/scoring.sh**

Create `lib/scoring.sh`:
```bash
#!/bin/bash
# Auditor output parsing for the fiction pipeline.
# Requires: python3, jq
#
# STATE_DIR must be set before sourcing.

STATE_DIR="${STATE_DIR:-state}"

# Extract the JSON scores block from auditor output (stdin).
# Auditors produce free-text analysis followed by a ```json block.
extract_scores() {
    python3 -c "
import json, re, sys

text = sys.stdin.read()

# Try fenced JSON blocks first
blocks = re.findall(r'\`\`\`json\s*\n(.*?)\n\s*\`\`\`', text, re.DOTALL)
if blocks:
    # Use the last JSON block (auditors put scores at the end)
    print(blocks[-1])
    sys.exit(0)

# Fallback: find bare JSON objects with criteria/sentinels keys
matches = re.findall(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', text, re.DOTALL)
for m in reversed(matches):
    try:
        parsed = json.loads(m)
        if 'criteria' in parsed or 'sentinels' in parsed:
            print(m)
            sys.exit(0)
    except json.JSONDecodeError:
        continue

print('FATAL: No valid scores JSON found in auditor output', file=sys.stderr)
sys.exit(1)
"
}

# Check if all criteria meet the threshold. Prints PASS or FAIL.
# Args: $1 = scores JSON string, $2 = threshold (default 4)
check_criteria_passing() {
    local scores_json="$1"
    local threshold="${2:-4}"
    python3 -c "
import json, sys

scores = json.loads('''$scores_json''')
criteria = scores.get('criteria', {})
if not criteria:
    print('PASS')
    sys.exit(0)

all_pass = True
for name, data in criteria.items():
    score = data.get('score', 0)
    if score < $threshold:
        print(f'BELOW THRESHOLD: {name} = {score} (need >= $threshold)', file=sys.stderr)
        all_pass = False

print('PASS' if all_pass else 'FAIL')
sys.exit(0 if all_pass else 1)
" 2>&2
}

# Check if all sentinels pass. Prints PASS or FAIL.
# Args: $1 = scores JSON string
check_sentinels_passing() {
    local scores_json="$1"
    python3 -c "
import json, sys

scores = json.loads('''$scores_json''')
sentinels = scores.get('sentinels', {})
if not sentinels:
    print('PASS')
    sys.exit(0)

all_pass = True
for name, data in sentinels.items():
    status = data.get('status', 'FAIL')
    if status != 'PASS':
        evidence = data.get('evidence', 'no evidence')
        print(f'SENTINEL FAIL: {name} — {evidence}', file=sys.stderr)
        all_pass = False

print('PASS' if all_pass else 'FAIL')
sys.exit(0 if all_pass else 1)
" 2>&2
}

# Merge two scores JSON objects (combines criteria and sentinels).
# Args: $1 = first JSON, $2 = second JSON
merge_scores() {
    local a="$1"
    local b="$2"
    python3 -c "
import json, sys

a = json.loads('''$a''')
b = json.loads('''$b''')

merged = {
    'criteria': {**a.get('criteria', {}), **b.get('criteria', {})},
    'sentinels': {**a.get('sentinels', {}), **b.get('sentinels', {})}
}
print(json.dumps(merged))
"
}

# Write scores to the audit log.
# Args: $1 = log prefix (e.g. "ch01-scene-02"), $2 = round number, $3 = scores JSON
log_scores() {
    local prefix="$1"
    local round="$2"
    local scores_json="$3"
    echo "$scores_json" > "$STATE_DIR/audit-logs/${prefix}-round-${round}.json"
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
bash tests/test_scoring.sh
```

Expected: All PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/scoring.sh tests/test_scoring.sh tests/fixtures/sample-audit-output.txt
git commit -m "feat: add score parsing library with tests"
```

---

### Task 5: Audit loop library

**Files:**
- Create: `lib/audit.sh`

This library ties together config, state, scoring, and context assembly to implement the audit/refine loop. It calls `claude -p` and therefore cannot be unit tested without real API calls. The logic is straightforward orchestration — correctness depends on the libraries it composes, which are tested above.

- [ ] **Step 1: Write lib/audit.sh**

Create `lib/audit.sh`:
```bash
#!/bin/bash
# Audit/refine loop for the fiction pipeline.
# Requires: claude CLI, lib/config.sh, lib/state.sh, lib/scoring.sh
#
# PROJECT_DIR must be set before sourcing.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Run all active auditors for a level.
# Sets: COMBINED_FEEDBACK (file path), COMBINED_SCORES (JSON string)
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        remaining args = KEY=FILE pairs for context assembly
run_auditors() {
    local level="$1"
    local content_file="$2"
    shift 2
    local context_args=("$@" "content=$content_file")

    local auditors
    auditors=$(get_active_auditors "$level")

    COMBINED_FEEDBACK="$STATE_DIR/current-feedback.txt"
    COMBINED_SCORES='{"criteria":{},"sentinels":{}}'
    > "$COMBINED_FEEDBACK"

    while IFS= read -r auditor; do
        [[ -z "$auditor" ]] && continue
        local auditor_file="$PROJECT_DIR/auditors/${auditor}.md"

        if [[ ! -f "$auditor_file" ]]; then
            echo "FATAL: Auditor prompt not found: $auditor_file" >&2
            exit 1
        fi

        echo "  Auditing: $auditor" >&2

        # Assemble prompt with context
        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$auditor_file" "${context_args[@]}")

        # Call claude
        local output
        output=$(echo "$assembled" | claude -p - --output-format text)

        # Append to combined feedback
        printf '\n\n--- Auditor: %s ---\n%s' "$auditor" "$output" >> "$COMBINED_FEEDBACK"

        # Extract and merge scores
        local scores
        scores=$(echo "$output" | extract_scores) || {
            echo "WARNING: Could not extract scores from auditor $auditor" >&2
            continue
        }
        COMBINED_SCORES=$(merge_scores "$COMBINED_SCORES" "$scores")

    done <<< "$auditors"
}

# The main audit/refine loop.
# Returns: 0 = passed, 1 = iteration cap reached, 2 = fixer recommended deletion
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        $2 = content file being refined
#        $3 = fixer prompt file
#        $4 = log prefix for audit logs
#        remaining args = KEY=FILE pairs for context assembly
audit_refine_loop() {
    local level="$1"
    local content_file="$2"
    local fixer_prompt="$3"
    local log_prefix="$4"
    shift 4
    local context_args=("$@")

    local iteration_cap
    iteration_cap=$(get_iteration_cap)
    local round=1

    while true; do
        echo "Audit round $round for $log_prefix" >&2
        update_state "refinement_round" "$round"
        update_state "status" '"auditing"'

        # Run all auditors
        run_auditors "$level" "$content_file" "${context_args[@]}"
        log_scores "$log_prefix" "$round" "$COMBINED_SCORES"

        # Check pass conditions
        local criteria_ok sentinel_ok
        criteria_ok=$(check_criteria_passing "$COMBINED_SCORES" 4 2>/dev/null) || true
        sentinel_ok=$(check_sentinels_passing "$COMBINED_SCORES" 2>/dev/null) || true

        if [[ "$criteria_ok" == "PASS" ]] && [[ "$sentinel_ok" == "PASS" ]]; then
            echo "PASS: All criteria >= 4, all sentinels pass (round $round)" >&2
            update_state "status" '"passed"'
            return 0
        fi

        # Check iteration cap
        if [[ "$iteration_cap" -gt 0 ]] && [[ "$round" -ge "$iteration_cap" ]]; then
            echo "WARNING: Iteration cap ($iteration_cap) reached at round $round" >&2
            echo "Final scores: $COMBINED_SCORES" >&2
            update_state "status" '"cap_reached"'
            return 1
        fi

        # Run fixer
        echo "Fixing (round $round)..." >&2
        update_state "status" '"fixing"'

        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
            "${context_args[@]}" \
            "audit_feedback=$COMBINED_FEEDBACK")

        local fixed_output
        fixed_output=$(echo "$assembled" | claude -p - --output-format text)

        # Check for deletion recommendation
        if echo "$fixed_output" | head -5 | grep -q "^RECOMMENDATION: DELETE"; then
            echo "FIXER RECOMMENDS DELETION" >&2
            echo "$fixed_output" > "$STATE_DIR/delete-recommendation.txt"
            return 2
        fi

        # Write fixed content
        echo "$fixed_output" > "$content_file"
        round=$((round + 1))
    done
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/audit.sh
git commit -m "feat: add audit/refine loop library"
```

---

### Task 6: Pipeline orchestrator (run.sh)

**Files:**
- Create: `run.sh`

- [ ] **Step 1: Write run.sh**

Create `run.sh`:
```bash
#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

source lib/config.sh
source lib/state.sh
source lib/scoring.sh
source lib/audit.sh

# ── Prerequisites ──────────────────────────────────────────────

for cmd in claude yq jq python3; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "FATAL: Required command not found: $cmd" >&2
        exit 1
    fi
done

if [[ ! -f "premise.md" ]]; then
    echo "FATAL: premise.md not found. Create it with your story premise." >&2
    exit 1
fi

if [[ ! -f "auditor-settings.yaml" ]]; then
    echo "FATAL: auditor-settings.yaml not found. Copy a genre template or create one." >&2
    exit 1
fi

load_config "auditor-settings.yaml"
init_state
mkdir -p output

# ── Helpers ────────────────────────────────────────────────────

# Count chapters in the novel plan by counting ## Chapter N headers
count_chapters() {
    grep -c '^## Chapter [0-9]' output/novel-plan.md
}

# Count scenes in a chapter plan by counting ## Scene N headers
count_scenes() {
    local plan_file="$1"
    grep -c '^## Scene [0-9]' "$plan_file"
}

# Extract one scene's plan section from the chapter plan
extract_scene_plan() {
    local plan_file="$1"
    local scene_num="$2"
    python3 -c "
import re, sys
text = open(sys.argv[1]).read()
pattern = r'(## Scene ' + sys.argv[2] + r':.*?)(?=## Scene \d+:|$)'
match = re.search(pattern, text, re.DOTALL)
if match:
    print(match.group(1).strip())
else:
    print(f'FATAL: Scene {sys.argv[2]} not found in {sys.argv[1]}', file=sys.stderr)
    sys.exit(1)
" "$plan_file" "$scene_num"
}

# Build a summary of completed chapters for context
build_completed_summary() {
    local up_to_ch="$1"
    for ((c=1; c<=up_to_ch; c++)); do
        local dir
        dir=$(printf "output/chapters/%02d" "$c")
        if [[ -d "$dir" && -f "$dir/chapter-plan.md" ]]; then
            printf '\n## Chapter %d (COMPLETED)\n' "$c"
            cat "$dir/chapter-plan.md"
        fi
    done
}

# Build the concatenated preceding scenes for the current chapter
build_preceding_scenes() {
    local ch_dir="$1"
    local up_to_scene="$2"
    for ((s=1; s<up_to_scene; s++)); do
        local sf="$ch_dir/scene-$(printf '%02d' "$s").md"
        if [[ -f "$sf" ]]; then
            printf '\n\n--- Scene %d ---\n' "$s"
            cat "$sf"
        fi
    done
}

# Build all completed prose for context collection
build_all_completed_prose() {
    local up_to_ch="$1"
    for ((c=1; c<up_to_ch; c++)); do
        local dir
        dir=$(printf "output/chapters/%02d" "$c")
        for sf in "$dir"/scene-*.md; do
            [[ -f "$sf" ]] && cat "$sf" && echo ""
        done
    done
}

# Run a prompt through claude. Args: assembled prompt text
run_claude() {
    echo "$1" | claude -p - --output-format text
}

# ── Phase 1: Novel Planning ───────────────────────────────────

phase_novel_planning() {
    echo "=== Phase 1: Novel Planning ===" >&2
    update_state "phase" '"novel_planning"'

    if [[ ! -f "output/novel-plan.md" ]]; then
        echo "Creating novel plan..." >&2
        local assembled
        assembled=$(python3 fill_template.py prompts/plan-novel.md \
            "premise=premise.md")
        run_claude "$assembled" > output/novel-plan.md
    fi

    echo "Auditing novel plan..." >&2
    audit_refine_loop "novel_plan" "output/novel-plan.md" \
        "prompts/fix-novel-plan.md" "novel-plan" \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md"

    echo "Novel plan complete." >&2
}

# ── Phase 2: Chapter Planning + Scene Authoring ────────────────

process_chapters() {
    local chapter_count
    chapter_count=$(count_chapters)

    local start_ch
    start_ch=$(read_state "chapter")
    [[ "$start_ch" == "0" || "$start_ch" == "null" ]] && start_ch=1

    for ((ch=start_ch; ch<=chapter_count; ch++)); do
        echo "=== Chapter $ch of $chapter_count ===" >&2
        update_state "chapter" "$ch"

        local ch_dir
        ch_dir=$(printf "output/chapters/%02d" "$ch")
        mkdir -p "$ch_dir"

        # Plan chapter
        plan_one_chapter "$ch" "$ch_dir"

        # Author scenes
        author_chapter_scenes "$ch" "$ch_dir"

        # Backtrack: re-evaluate novel plan after chapter completion
        run_backtrack_novel "$ch"

        # Re-count chapters in case backtracking added/removed some
        chapter_count=$(count_chapters)

        # Reset scene counter for next chapter
        update_state "scene" "0"
    done
}

plan_one_chapter() {
    local ch="$1"
    local ch_dir="$2"
    local plan_file="$ch_dir/chapter-plan.md"

    update_state "phase" '"chapter_planning"'
    update_state "scene" "0"

    if [[ ! -f "$plan_file" ]]; then
        echo "Planning chapter $ch..." >&2

        # Build completed chapters summary if not the first chapter
        local summary_file="$STATE_DIR/completed-summary.txt"
        if [[ "$ch" -gt 1 ]]; then
            build_completed_summary "$((ch - 1))" > "$summary_file"
        else
            echo "(No prior chapters)" > "$summary_file"
        fi

        local assembled
        assembled=$(python3 fill_template.py prompts/plan-chapter.md \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_number=$ch" \
            "completed_chapters_summary=$summary_file")
        run_claude "$assembled" > "$plan_file"
    fi

    echo "Auditing chapter $ch plan..." >&2
    audit_refine_loop "chapter_plan" "$plan_file" \
        "prompts/fix-chapter-plan.md" "ch$(printf '%02d' "$ch")-plan" \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$plan_file"
}

author_chapter_scenes() {
    local ch="$1"
    local ch_dir="$2"
    local plan_file="$ch_dir/chapter-plan.md"

    update_state "phase" '"scene_authoring"'

    local scene_count
    scene_count=$(count_scenes "$plan_file")

    local start_sc
    start_sc=$(read_state "scene")
    [[ "$start_sc" == "0" || "$start_sc" == "null" ]] && start_sc=1

    for ((sc=start_sc; sc<=scene_count; sc++)); do
        echo "  Scene $sc of $scene_count" >&2
        update_state "scene" "$sc"

        local scene_file="$ch_dir/scene-$(printf '%02d' "$sc").md"
        local context_file="$ch_dir/scene-$(printf '%02d' "$sc")-context.md"

        # Collect context from prior chapters
        if [[ ! -f "$context_file" ]]; then
            collect_scene_context "$ch" "$sc" "$ch_dir" "$context_file" "$plan_file"
        fi

        # Build preceding scenes within this chapter
        local preceding_file="$STATE_DIR/preceding-scenes.txt"
        build_preceding_scenes "$ch_dir" "$sc" > "$preceding_file"

        # Extract this scene's plan
        local scene_plan_file="$STATE_DIR/scene-plan.txt"
        extract_scene_plan "$plan_file" "$sc" > "$scene_plan_file"

        # Author scene
        if [[ ! -f "$scene_file" ]]; then
            echo "  Writing scene $sc..." >&2
            local assembled
            assembled=$(python3 fill_template.py prompts/author-scene.md \
                "premise=premise.md" \
                "novel_plan=output/novel-plan.md" \
                "chapter_plan=$plan_file" \
                "relevant_context=$context_file" \
                "preceding_scenes=$preceding_file" \
                "scene_plan=$scene_plan_file" \
                "chapter_number=$ch" \
                "scene_number=$sc")
            run_claude "$assembled" > "$scene_file"
        fi

        # Audit/refine scene
        echo "  Auditing scene $sc..." >&2
        local audit_result=0
        audit_refine_loop "scene" "$scene_file" \
            "prompts/fix-scene.md" "ch$(printf '%02d' "$ch")-scene-$(printf '%02d' "$sc")" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_plan=$plan_file" \
            "relevant_context=$context_file" \
            "preceding_scenes=$preceding_file" \
            "scene=$scene_file" || audit_result=$?

        if [[ "$audit_result" -eq 2 ]]; then
            echo "  Scene $sc: fixer recommended deletion" >&2
            rm -f "$scene_file" "$context_file"
            # Backtrack chapter plan to adjust remaining scenes
            run_backtrack_chapter "$ch" "$ch_dir"
            scene_count=$(count_scenes "$plan_file")
            continue
        fi

        # Backtrack: re-evaluate chapter plan after each scene
        run_backtrack_chapter "$ch" "$ch_dir"

        # Scene count may have changed
        scene_count=$(count_scenes "$plan_file")
    done
}

collect_scene_context() {
    local ch="$1"
    local sc="$2"
    local ch_dir="$3"
    local output_file="$4"
    local plan_file="$5"

    if [[ "$ch" -le 1 ]]; then
        echo "# No prior chapters — this is Chapter 1" > "$output_file"
        return
    fi

    echo "  Collecting context for scene $sc..." >&2

    local prose_file="$STATE_DIR/all-completed-prose.txt"
    build_all_completed_prose "$ch" > "$prose_file"

    local scene_plan_file="$STATE_DIR/upcoming-scene-plan.txt"
    extract_scene_plan "$plan_file" "$sc" > "$scene_plan_file"

    local assembled
    assembled=$(python3 fill_template.py prompts/collect-context.md \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$plan_file" \
        "upcoming_scene_plan=$scene_plan_file" \
        "completed_content=$prose_file")
    run_claude "$assembled" > "$output_file"
}

run_backtrack_chapter() {
    local ch="$1"
    local ch_dir="$2"

    echo "  Backtracking: evaluating chapter plan..." >&2

    local scenes_file="$STATE_DIR/completed-scenes-bt.txt"
    local has_scenes=false
    > "$scenes_file"
    for sf in "$ch_dir"/scene-*.md; do
        [[ -f "$sf" ]] && cat "$sf" >> "$scenes_file" && echo "" >> "$scenes_file" && has_scenes=true
    done

    if [[ "$has_scenes" == "false" ]]; then
        return  # No scenes yet, nothing to backtrack on
    fi

    local assembled
    assembled=$(python3 fill_template.py prompts/backtrack-chapter.md \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$ch_dir/chapter-plan.md" \
        "completed_scenes=$scenes_file")

    local result
    result=$(run_claude "$assembled")

    if ! echo "$result" | head -1 | grep -q "^NO_CHANGE"; then
        echo "  Chapter plan revised by backtracking" >&2
        echo "$result" > "$ch_dir/chapter-plan.md"

        # Audit the revised plan
        audit_refine_loop "chapter_plan" "$ch_dir/chapter-plan.md" \
            "prompts/fix-chapter-plan.md" "ch$(printf '%02d' "$ch")-plan-bt" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_plan=$ch_dir/chapter-plan.md"
    fi
}

run_backtrack_novel() {
    local ch="$1"

    echo "Backtracking: evaluating novel plan..." >&2

    local summary_file="$STATE_DIR/completed-summary-bt.txt"
    build_completed_summary "$ch" > "$summary_file"

    local assembled
    assembled=$(python3 fill_template.py prompts/backtrack-novel.md \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "completed_chapters_summary=$summary_file")

    local result
    result=$(run_claude "$assembled")

    if ! echo "$result" | head -1 | grep -q "^NO_CHANGE"; then
        echo "Novel plan revised by backtracking" >&2
        echo "$result" > output/novel-plan.md

        # Audit the revised plan
        audit_refine_loop "novel_plan" "output/novel-plan.md" \
            "prompts/fix-novel-plan.md" "novel-plan-bt-ch$(printf '%02d' "$ch")" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md"
    fi
}

# ── Main ───────────────────────────────────────────────────────

main() {
    echo "Fiction Pipeline starting at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >&2

    local current_phase
    current_phase=$(read_state "phase")

    case "$current_phase" in
        novel_planning|starting|null)
            phase_novel_planning
            process_chapters
            ;;
        chapter_planning|scene_authoring)
            # Resume from where we left off
            process_chapters
            ;;
        *)
            echo "FATAL: Unknown phase: $current_phase" >&2
            exit 1
            ;;
    esac

    echo "=== Pipeline complete at $(date -u +"%Y-%m-%dT%H:%M:%SZ") ===" >&2
}

main "$@"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x run.sh
```

- [ ] **Step 3: Commit**

```bash
git add run.sh lib/audit.sh
git commit -m "feat: add pipeline orchestrator and audit loop"
```

---

## Phase B: Prompts

### Task 7: Novel plan creator

**Files:**
- Create: `prompts/plan-novel.md`

- [ ] **Step 1: Write plan-novel.md**

Create `prompts/plan-novel.md`:
```markdown
# Plan Novel

You are a novel architect. Your task is to create a chapter-by-chapter plan for a novel based on the premise below.

## Premise

{premise}

Read the premise carefully. This is your success criteria — the finished novel must deliver on this premise.

## Your Task

Create a chapter-by-chapter plan that realizes this premise as a compelling novel.

## Output Format

Use this exact format. Chapter headers must follow the pattern `## Chapter N: Title`.

# Novel Plan

## Overview
[2-3 sentences: what this novel is, what it's about, what makes it worth reading]

## Central Conflict
[One sentence: the core tension that drives the entire story]

## Character Roster
[For each major character:]
- **Name**: role, central want, central flaw, arc trajectory

## Chapter 1: [Title]
**Purpose**: [What this chapter accomplishes — why it exists in the novel]
**Key Events**:
- [Event 1]
- [Event 2]
**Character Development**: [Who changes, how, why]
**Connections**: [What prior threads this pays off / what future threads this sets up]
**Tone**: [Tension level, emotional register]

## Chapter 2: [Title]
...

[Continue for all chapters.]

## Guidelines

### Story Structure
- The first chapter must establish the premise's core hook within its first scene. Don't bury the lead.
- The final chapter must resolve the central conflict. Loose secondary threads are acceptable; abandoned main threads are not.
- Every chapter must advance plot, develop character, or both. Chapters that only "set the mood" or "provide background" are filler — cut them.

### Arc Design
- Character arcs must be traceable through the plan. For any character who changes, you should be able to point to the chapter where each stage of that change occurs.
- The central conflict should escalate across the novel. Design deliberate peaks and valleys — flat tension is boring, endlessly rising tension is exhausting.
- Antagonists need coherent motivations. "Evil" is not a motivation.

### Pacing
- Vary chapter weight. Some chapters are load-bearing (revelations, confrontations, turning points). Others are transitional (aftermath, setup, recovery). Both are necessary — design them as such.
- Alternate between high-tension and low-tension. Multiple consecutive chapters at the same tension level is a pacing problem.
- Don't front-load exposition. Distribute world-building, revealing information when it becomes relevant to current events.

### Practical
- Plan for the number of chapters the story actually needs. Don't pad to hit a count. Don't compress to save space.
- Each chapter's "Connections" field is how you verify structural integrity. A chapter with no connections to other chapters is floating free and probably unnecessary.
- Supporting characters exist to create pressure on protagonist arcs, not as decoration.

## Constraint

Output ONLY the novel plan in the format above. Do not write prose, sample scenes, or commentary.
```

- [ ] **Step 2: Verify template placeholders**

```bash
python3 fill_template.py prompts/plan-novel.md "premise=premise.md" > /dev/null 2>&1
echo "Exit code: $?"
```

Expected: exit 0 (or warning about missing premise.md, which is expected).

- [ ] **Step 3: Commit**

```bash
git add prompts/plan-novel.md
git commit -m "feat: add novel plan creator prompt"
```

---

### Task 8: Chapter plan creator

**Files:**
- Create: `prompts/plan-chapter.md`

- [ ] **Step 1: Write plan-chapter.md**

Create `prompts/plan-chapter.md`:
```markdown
# Plan Chapter

You are a chapter architect. Your task is to break a single chapter into a scene-by-scene plan.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Completed Chapters

{completed_chapters_summary}

## Your Task

You are planning **Chapter {chapter_number}**. Create a scene-by-scene plan that delivers on this chapter's purpose as defined in the novel plan.

## Output Format

Use this exact format. Scene headers must follow the pattern `## Scene N: Title`.

# Chapter {chapter_number} Plan: [Title from novel plan]

## Chapter Goal
[One sentence: what this chapter must accomplish]

## Scene 1: [Title]
**Purpose**: [What this scene accomplishes — stated in terms of story function]
**Setting**: [Where and when]
**POV**: [Whose perspective]
**Characters Present**: [Who is in this scene]
**Beats**:
- [Opening state — where characters are emotionally/physically at scene start]
- [Shift 1 — what changes and why]
- [Shift 2 — what changes next]
- [Closing state — where characters are at scene end]
**Connects To**: [What this sets up or pays off]

## Scene 2: [Title]
...

[Continue for all scenes.]

## Guidelines

### Scene Design
- Every scene must have at least one meaningful shift — characters must be in a different emotional or situational state at the end than the beginning. A scene without movement is dead weight.
- Beats are planning annotations that capture where the dramatic shifts happen. 2-4 beats per scene is typical. Fewer than 2 suggests the scene lacks movement. More than 6 suggests it's doing too much — consider splitting.
- State "Purpose" in terms of story function, not plot mechanics. "Establish that Maria doesn't trust the crew" is better than "Maria argues with someone."

### Transitions
- Consider how each scene ends and the next begins. Hard cuts (jumping time/place/character) create pace. Soft transitions (continuous flow) create immersion. Choose deliberately.
- Leaving a scene mid-tension and returning later creates narrative drive.

### Pacing Within Chapter
- Vary scene length and intensity. All short punchy scenes is breathless. All long contemplative scenes is slow. Mix them.
- If the chapter's role in the novel plan is high-tension, most scenes should escalate. If transitional, scenes can breathe more — but they still need purpose.

### Character Continuity
- Characters carry emotional state between scenes. If Scene 2 ends with fury, Scene 3 must acknowledge it.
- Track what characters know. Information revealed in one scene affects what's possible in later scenes.

### Connection to Novel Plan
- This chapter plan must deliver on the "Purpose," "Key Events," and "Character Development" defined in the novel plan for this chapter.
- If delivering on the novel plan requires more or fewer scenes than expected, use the right number.

## Constraint

Output ONLY the chapter plan in the format above. Do not write prose or commentary.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/plan-chapter.md
git commit -m "feat: add chapter plan creator prompt"
```

---

### Task 9: Scene author

**Files:**
- Create: `prompts/author-scene.md`

- [ ] **Step 1: Write author-scene.md**

Create `prompts/author-scene.md`:
```markdown
# Author Scene

You are a fiction author. Your task is to write one complete scene as prose.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Relevant Context From Prior Chapters

{relevant_context}

## Preceding Scenes In This Chapter

{preceding_scenes}

## Scene Plan

{scene_plan}

## Your Task

Write **Scene {scene_number}** of **Chapter {chapter_number}** as complete prose. The scene plan gives you the structural skeleton — purpose, beats, characters. The prose is yours to craft.

## Guidelines

### Prose Craft
- Ground the reader in the physical world. Concrete sensory detail — what characters see, hear, smell, feel physically — creates presence. Abstract description creates distance.
- Use specific nouns and active verbs. "She crossed the market" is weaker than "She shouldered through the fish stalls." Specificity does the work that adjectives try to do.
- Vary sentence length deliberately. Short sentences create urgency. Longer sentences create flow and contemplation. Monotonous length at any size is flat.
- Don't narrate emotions directly. Show them through action, body language, speech pattern, and choice. A character who "felt angry" is told. A character who grips the table edge until her knuckles whiten is shown.

### Dialogue
- Every character must sound distinct. Vocabulary, sentence structure, directness, verbal habits — these differentiate voices. If you can swap names on dialogue lines without noticing, the voices are too similar.
- Dialogue should serve multiple purposes simultaneously: convey information, reveal character, advance conflict, establish relationships. Dialogue that only does one of these is underperforming.
- Subtext matters. What characters don't say, or say indirectly, is often more powerful than what they say directly.
- Characters don't explain things they both already know for the reader's benefit. Find natural contexts for information delivery.

### Scene Structure
- Open with orientation: where, who, what's happening. The reader must be grounded before the action begins.
- Follow the beats from the plan. Each beat represents a shift — make these shifts land.
- End with a sense of where things stand. This doesn't mean resolving tension — it means the reader knows what shifted and why it matters.

### Continuity
- Respect the relevant context. Characters' established behaviors, relationships, knowledge, and emotional states must be consistent with prior scenes.
- The preceding scenes in this chapter are your immediate context. This scene continues that flow.
- If something happened off-screen between scenes, acknowledge it naturally.

### Pacing
- Not every beat needs equal page time. Give weight proportional to dramatic importance.
- Action scenes: shorter paragraphs, more white space, less interiority. Reflective scenes: longer paragraphs, deeper internal access.

## Output

Write the complete scene as continuous prose. No commentary, no scene headers, no meta-text. Just the scene.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/author-scene.md
git commit -m "feat: add scene author prompt"
```

---

### Task 10: Context collector

**Files:**
- Create: `prompts/collect-context.md`

- [ ] **Step 1: Write collect-context.md**

Create `prompts/collect-context.md`:
```markdown
# Collect Relevant Context

You are a story continuity analyst. Your task is to extract details from completed content that are relevant to an upcoming scene.

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Upcoming Scene

{upcoming_scene_plan}

## Completed Content

{completed_content}

## Your Task

Read the upcoming scene plan. Identify what details from the completed content are relevant to writing this scene. Extract and organize them.

## What to Extract

### Characters Appearing in This Scene
For each character present in the upcoming scene:
- Last known emotional state and circumstances
- Key established traits, speech patterns, verbal habits
- Relevant relationship dynamics with other characters in the scene
- Unresolved tensions or commitments
- What this character knows and doesn't know

### Active Plot Threads
- Unresolved situations this scene might reference, continue, or resolve
- Setups or foreshadowing this scene might pay off
- Information asymmetries (what the reader knows vs. what characters know)

### Established World Details
- Setting details if the scene uses a previously visited location
- Rules, norms, or constraints that apply
- Technology, magic, or systems relevant to this scene

### Tone and Voice
- The narrative voice's established characteristics
- Tonal trajectory leading into this scene

## Output Format

# Relevant Context for Chapter [N], Scene [N]

## Characters
### [Name]
- **Last seen**: [when, where, doing what]
- **Emotional state**: [specific description]
- **Key traits/voice**: [established patterns]
- **Relationships**: [dynamics relevant to this scene]
- **Knowledge**: [what they know / don't know]
- **Unresolved**: [tensions, commitments, promises]

## Active Plot Threads
- [Thread name]: [current state, how it relates to this scene]

## World Details
- [Detail]: [what was established, where]

## Tone Notes
- [Relevant observations]

## Guidelines

- Extract only what's RELEVANT to this specific scene. Not everything — just what matters.
- Be specific. "Maria is angry" is less useful than "Maria discovered in Ch2 Sc4 that her partner lied about the funding source and hasn't confronted him yet."
- Preserve exact details: names, places, dates, specific facts.
- When in doubt, include it. Better to slightly over-extract than to miss something.

## Constraint

Output ONLY the context document. No commentary or suggestions.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/collect-context.md
git commit -m "feat: add context collector prompt"
```

---

### Task 11: Novel plan fixer

**Files:**
- Create: `prompts/fix-novel-plan.md`

- [ ] **Step 1: Write fix-novel-plan.md**

Create `prompts/fix-novel-plan.md`:
```markdown
# Fix Novel Plan

You are a developmental editor. Your task is to revise the novel plan based on audit feedback.

## Premise

{premise}

## Current Novel Plan

{novel_plan}

## Audit Feedback

{audit_feedback}

## Your Task

The auditors above have identified specific problems with scores and evidence.

### First: consider deletion.

Should any chapter be deleted rather than fixed? If a chapter is fundamentally flawed — if fixing it would mean rewriting its purpose entirely — delete it. Replace it with something better, or remove it if the story is stronger without it. Don't patch broken structure out of inertia.

### Then: revise holistically.

Address the most impactful problems first. You don't need to fix everything this round — the refinement loop will catch remaining issues in subsequent rounds.

Priority order:
1. **Structural problems** — missing arcs, broken causality, floating chapters
2. **Character problems** — inconsistent development, missing motivations
3. **Pacing problems** — flat tension, consecutive same-register chapters
4. **Detail problems** — weak connections, vague purposes

Preserve what works. Parts not flagged by auditors are working — don't rewrite them.

## Output

Produce the complete revised novel plan in the same format as the original. All chapters. Full content. Not a diff or changelog.

Output ONLY the revised plan.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/fix-novel-plan.md
git commit -m "feat: add novel plan fixer prompt"
```

---

### Task 12: Chapter plan fixer

**Files:**
- Create: `prompts/fix-chapter-plan.md`

- [ ] **Step 1: Write fix-chapter-plan.md**

Create `prompts/fix-chapter-plan.md`:
```markdown
# Fix Chapter Plan

You are a developmental editor. Your task is to revise a chapter's scene plan based on audit feedback.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Current Chapter Plan

{chapter_plan}

## Audit Feedback

{audit_feedback}

## Your Task

The auditors above have identified specific problems with scores and evidence.

### First: consider deletion.

Should any scene be deleted rather than fixed? If a scene's problems are fundamental — if fixing it would mean changing its purpose entirely — delete it. Replace it with something that serves the chapter better, or remove it entirely.

### Then: revise holistically.

Priority order:
1. **Scene purpose problems** — scenes that don't advance the chapter's goals
2. **Flow problems** — broken transitions, missing emotional continuity between scenes
3. **Beat problems** — scenes without meaningful shifts, too many or too few beats
4. **Detail problems** — vague settings, unclear POV choices

### Constraints:
- The chapter must still deliver on its purpose as defined in the novel plan.
- Preserve what works. Don't rewrite scenes that weren't flagged.

## Output

Produce the complete revised chapter plan in the same format as the original. All scenes. Full content.

Output ONLY the revised chapter plan.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/fix-chapter-plan.md
git commit -m "feat: add chapter plan fixer prompt"
```

---

### Task 13: Scene fixer

**Files:**
- Create: `prompts/fix-scene.md`

- [ ] **Step 1: Write fix-scene.md**

Create `prompts/fix-scene.md`:
```markdown
# Fix Scene

You are a fiction editor. Your task is to rewrite a scene based on audit feedback.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Relevant Context

{relevant_context}

## Preceding Scenes

{preceding_scenes}

## Current Scene

{scene}

## Audit Feedback

{audit_feedback}

## Your Task

The auditors above have scored specific criteria and flagged sentinel violations with evidence.

### First: should this scene be deleted?

If the scene's problems are fundamental — the concept doesn't work, it's redundant, the story flows better without it — output exactly:

```
RECOMMENDATION: DELETE
REASON: [one sentence]
```

And stop. The pipeline will handle removal.

### If the scene should be kept: rewrite it.

This is a full rewrite, not a patch job. Produce a new version that addresses the problems while preserving what works.

Priority:
1. **Sentinel failures** — these indicate autocomplete behavior. The affected passages need genuine creative thought, not superficial rewording.
2. **Low-scoring criteria (below 4)** — the quality problems that need fixing.
3. **Criteria at exactly 4** — adequate but improvable. Address naturally during the rewrite if possible.

### Constraints:
- Maintain continuity with the relevant context and preceding scenes. No contradictions.
- The scene must still accomplish its purpose from the chapter plan. You may adjust how beats land, but the scene must do its job.

## Output

Write the complete rewritten scene as continuous prose. No commentary, no headers.

Output ONLY the rewritten scene (or the DELETE recommendation).
```

- [ ] **Step 2: Commit**

```bash
git add prompts/fix-scene.md
git commit -m "feat: add scene fixer prompt"
```

---

### Task 14: Chapter backtracker

**Files:**
- Create: `prompts/backtrack-chapter.md`

- [ ] **Step 1: Write backtrack-chapter.md**

Create `prompts/backtrack-chapter.md`:
```markdown
# Re-evaluate Chapter Plan

You are a story analyst. After each scene is completed, you evaluate whether the remaining chapter plan should be revised.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Current Chapter Plan

{chapter_plan}

## Completed Scenes

{completed_scenes}

## Your Task

The completed scenes above are final — they will not be rewritten. But the remaining chapter plan (scenes not yet written) can be adjusted.

Consider:

1. **Divergence**: Did any completed scene diverge from the plan? If so, do the remaining scenes still make sense?
2. **Emergence**: Did something unexpected emerge — a character dynamic, a plot thread, a tonal shift? Should the remaining plan capitalize on it?
3. **Purpose**: Given what's been written, is the chapter still on track to achieve its purpose from the novel plan? Does the plan need adjustment to deliver?
4. **Optimization**: Should any remaining scene be added, removed, or reordered now that you've seen the actual execution?

## Output

If no changes needed:

```
NO_CHANGE
The remaining chapter plan is consistent with the completed scenes and still serves the chapter's purpose.
```

If changes needed: produce the complete revised chapter plan in the same format as the original. Mark completed scenes with `[COMPLETED]` after their title. Revise only the remaining scenes.

Output ONLY the result. No commentary.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/backtrack-chapter.md
git commit -m "feat: add chapter backtracker prompt"
```

---

### Task 15: Novel backtracker

**Files:**
- Create: `prompts/backtrack-novel.md`

- [ ] **Step 1: Write backtrack-novel.md**

Create `prompts/backtrack-novel.md`:
```markdown
# Re-evaluate Novel Plan

You are a story analyst. After each chapter is completed, you evaluate whether the remaining novel plan should be revised.

## Premise

{premise}

## Current Novel Plan

{novel_plan}

## Completed Chapters

{completed_chapters_summary}

## Your Task

The completed chapters above are final — they will not be rewritten. But the remaining novel plan (chapters not yet written) can be adjusted.

Consider:

1. **Divergence**: Did any completed chapter diverge from the plan? Do remaining chapters still make sense?
2. **Emergence**: Did the story develop in unexpected directions — character arcs, themes, plot threads? Should the remaining plan lean into these?
3. **Resolution**: Is the central conflict still on track for resolution with the remaining chapters?
4. **Optimization**: Should any remaining chapter be added, removed, or reordered?
5. **Dropped threads**: Are there things set up in completed chapters that the remaining plan doesn't address?

## Output

If no changes needed:

```
NO_CHANGE
The remaining novel plan is consistent with completed chapters and still serves the central conflict.
```

If changes needed: produce the complete revised novel plan in the same format as the original. Mark completed chapters with `[COMPLETED]` after their title. Revise only the remaining chapters.

Output ONLY the result. No commentary.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/backtrack-novel.md
git commit -m "feat: add novel backtracker prompt"
```

---

## Phase C: Initial Auditors

### Task 16: Define auditor output format and write initial auditors

Each auditor prompt produces free-text analysis followed by a structured JSON block. This task creates the initial set of universal auditors — enough to test the full pipeline.

**Files:**
- Create: `auditors/narrative-arc.md` (novel_plan level)
- Create: `auditors/scene-design.md` (chapter_plan level)
- Create: `auditors/prose-quality.md` (scene level)
- Create: `auditors/character-voice.md` (scene level)

- [ ] **Step 1: Write narrative-arc.md (novel plan auditor)**

Create `auditors/narrative-arc.md`:
```markdown
# Narrative Arc Auditor

You are evaluating a novel plan for narrative arc quality. Read the premise and plan carefully, then evaluate each criterion below.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Evaluation Instructions

For each criterion, provide:
- A score from 0 to 5 (0 = absent, 1 = severely deficient, 2 = weak, 3 = adequate, 4 = good, 5 = excellent)
- Specific evidence from the plan supporting your score — quote or reference specific chapters

For each sentinel, determine PASS or FAIL with evidence.

Be rigorous. A score of 4 means "good — minor issues only." A score of 5 means "no meaningful improvement possible." Do not grade generously.

## Criteria

### C1: Premise Delivery
Does the plan deliver on the premise? Every major element of the premise should be addressed by at least one chapter. Score 0 if the plan ignores key premise elements. Score 5 if every premise element has a clear home in the plan.

### C2: Central Conflict Escalation
Does the central conflict escalate across the novel? Look for: initial stakes, complications that raise stakes, a clear climax, resolution. Score 0 if tension is flat. Score 5 if escalation is deliberate, varied, and compelling.

### C3: Character Arc Traceability
For each major character: can you trace their arc through the plan? Point to the chapter where each stage of change occurs. Score 0 if arcs are invisible. Score 5 if every major character has a clear, traceable arc with turning points identified.

### C4: Chapter Purpose Clarity
Does every chapter have a clear, stated purpose? Score 0 if purposes are vague or missing. Score 5 if every chapter has a specific, non-redundant purpose that advances the story.

### C5: Structural Connectivity
Are chapters connected through the "Connections" fields? Do setups have payoffs? Do payoffs have setups? Score 0 if chapters float independently. Score 5 if the plan forms a tight causal web.

### C6: Pacing Variation
Does the plan alternate between high and low tension? Are there deliberate peaks and valleys? Score 0 if pacing is monotonous. Score 5 if pacing is deliberately varied with appropriate recovery beats.

### C7: Exposition Distribution
Is world-building and background information distributed across chapters rather than front-loaded? Score 0 if the first few chapters are all setup. Score 5 if information arrives when it's relevant.

## Sentinels

### S1: Orphan Chapter
Is there any chapter with no connections to other chapters — no setups it pays off, no payoffs for prior setups, no character arc progression? If yes: FAIL.

### S2: Identical Register Streak
Are there 3+ consecutive chapters at the same tension level (all high or all low) with no variation? If yes: FAIL.

### S3: Missing Resolution
Does the final chapter fail to address the central conflict? If the plan ends without resolving what it set up: FAIL.

## Output

Write your analysis for each criterion and sentinel. Then output the scores as a JSON block:

```json
{
    "criteria": {
        "premise-delivery": {"score": N, "evidence": "..."},
        "conflict-escalation": {"score": N, "evidence": "..."},
        "arc-traceability": {"score": N, "evidence": "..."},
        "chapter-purpose": {"score": N, "evidence": "..."},
        "structural-connectivity": {"score": N, "evidence": "..."},
        "pacing-variation": {"score": N, "evidence": "..."},
        "exposition-distribution": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "orphan-chapter": {"status": "PASS|FAIL", "evidence": "..."},
        "identical-register-streak": {"status": "PASS|FAIL", "evidence": "..."},
        "missing-resolution": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
```

- [ ] **Step 2: Write scene-design.md (chapter plan auditor)**

Create `auditors/scene-design.md`:
```markdown
# Scene Design Auditor

You are evaluating a chapter plan for scene design quality. Read all context, then evaluate each criterion.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Content Being Audited

{content}

## Evaluation Instructions

For each criterion: score 0-5 with specific evidence. For each sentinel: PASS or FAIL with evidence. Be rigorous.

## Criteria

### C1: Scene Purpose Specificity
Does every scene have a clear, specific purpose stated in terms of story function? "Establish trust between X and Y" is specific. "Things happen" is not. Score based on the weakest scene.

### C2: Beat Quality
Do scenes have meaningful beats — shifts in emotional state, power dynamics, or understanding? Score 0 if beats are absent or trivial. Score 5 if every scene has well-defined shifts that create movement.

### C3: Chapter Goal Delivery
Does the collection of scenes deliver on the chapter's goal as stated in the novel plan? Score 0 if scenes don't add up to the chapter's purpose. Score 5 if the scenes clearly accomplish it.

### C4: Scene Flow and Transitions
Do scenes connect logically? Does emotional state carry between scenes? Are transitions (hard cuts vs. continuous) chosen deliberately? Score 0 if scenes feel disconnected. Score 5 if flow is natural and intentional.

### C5: Pacing Within Chapter
Is there variation in scene intensity and implied length? Score 0 if all scenes are the same weight. Score 5 if pacing is deliberately varied.

### C6: Character Knowledge Tracking
Do scenes respect what characters know and don't know? Does information revealed in one scene affect possibilities in later scenes? Score 0 if characters seem omniscient. Score 5 if knowledge is carefully tracked.

## Sentinels

### S1: Purposeless Scene
Is there any scene whose purpose is vague, empty, or duplicates another scene's purpose? If yes: FAIL.

### S2: Beatless Scene
Is there any scene with fewer than 2 beats — where characters end in the same state they started? If yes: FAIL.

### S3: Novel Plan Contradiction
Does any scene contradict the chapter's role as defined in the novel plan? If yes: FAIL.

## Output

Write your analysis, then output scores:

```json
{
    "criteria": {
        "scene-purpose": {"score": N, "evidence": "..."},
        "beat-quality": {"score": N, "evidence": "..."},
        "chapter-goal-delivery": {"score": N, "evidence": "..."},
        "scene-flow": {"score": N, "evidence": "..."},
        "pacing-within-chapter": {"score": N, "evidence": "..."},
        "character-knowledge": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "purposeless-scene": {"status": "PASS|FAIL", "evidence": "..."},
        "beatless-scene": {"status": "PASS|FAIL", "evidence": "..."},
        "novel-plan-contradiction": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
```

- [ ] **Step 3: Write prose-quality.md (scene auditor)**

Create `auditors/prose-quality.md`:
```markdown
# Prose Quality Auditor

You are evaluating a scene for prose quality. Read all context and the scene carefully, then evaluate each criterion.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Scene Being Audited

{content}

## Evaluation Instructions

For each criterion: score 0-5 with specific evidence (quote the scene). For each sentinel: PASS or FAIL with evidence. Be rigorous. Quote specific passages.

## Criteria

### C1: Sensory Grounding
Does the scene ground the reader in the physical world through concrete sensory detail? Look for sight, sound, smell, touch, taste. Score 0 if the scene is abstract and ungrounded. Score 5 if the reader feels physically present.

### C2: Show Not Tell
Does the scene convey emotion, character, and atmosphere through action, detail, and dialogue rather than direct statement? "She felt angry" is telling. A slammed door is showing. Score based on the ratio and quality.

### C3: Sentence Variety
Does the scene vary sentence length and structure deliberately? Look for: mix of short and long, varied openings, rhythm changes matching content. Score 0 if monotonous. Score 5 if rhythm serves the story.

### C4: Specificity
Does the scene use specific nouns and active verbs rather than generic language? "The ship" vs. "the rust-scarred freighter." "She walked" vs. "She shouldered through." Score based on the density of specific, evocative choices.

### C5: Scene Structure
Does the scene have clear orientation (grounding), development (beats landing), and closure (sense of what shifted)? Score 0 if the scene just starts and stops. Score 5 if structure is clean and deliberate.

### C6: Pacing
Does the scene give weight proportional to dramatic importance? Action passages tight and fast? Reflective passages allowed to breathe? Score 0 if pacing is flat. Score 5 if pacing serves the content.

### C7: Dialogue Exposition
Does dialogue avoid characters explaining things they both already know for the reader's benefit? Score 0 if dialogue is an exposition vehicle. Score 5 if all information delivery feels natural.

## Sentinels

### S1: LLM Stock Phrases
Does the scene contain phrases statistically associated with LLM output? Examples: "a testament to," "the weight of," "echoed through the corridors," "couldn't help but," "a sense of," "little did they know," "the silence was deafening," "sent shivers down," "it was as if." Check for any of these or similar formulaic constructions. If found: FAIL with quotes.

### S2: Excessive Nodding
Do characters nod more than twice in the scene? Nodding is a default LLM gesture when it can't think of specific body language. If more than 2 nods: FAIL with count.

### S3: Purple Prose
Are there passages where the writing draws attention to itself at the expense of the story? Overwrought metaphors, excessive adjective stacking, flowery descriptions that slow the narrative. If found: FAIL with quotes.

### S4: Emotional Tell After Show
Does the scene show an emotion effectively through action/detail, then immediately undercut it by also telling the emotion directly? (e.g., "She slammed the door. She was furious.") If found: FAIL with quotes.

## Output

Write your analysis with specific quotes from the scene. Then output scores:

```json
{
    "criteria": {
        "sensory-grounding": {"score": N, "evidence": "..."},
        "show-not-tell": {"score": N, "evidence": "..."},
        "sentence-variety": {"score": N, "evidence": "..."},
        "specificity": {"score": N, "evidence": "..."},
        "scene-structure": {"score": N, "evidence": "..."},
        "pacing": {"score": N, "evidence": "..."},
        "dialogue-exposition": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "llm-stock-phrases": {"status": "PASS|FAIL", "evidence": "..."},
        "excessive-nodding": {"status": "PASS|FAIL", "evidence": "..."},
        "purple-prose": {"status": "PASS|FAIL", "evidence": "..."},
        "emotional-tell-after-show": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
```

- [ ] **Step 4: Write character-voice.md (scene auditor)**

Create `auditors/character-voice.md`:
```markdown
# Character Voice Auditor

You are evaluating a scene for character voice quality. Read all context and the scene, then evaluate.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Relevant Context

{relevant_context}

## Scene Being Audited

{content}

## Evaluation Instructions

For each criterion: score 0-5 with specific evidence (quote dialogue and narration). For each sentinel: PASS or FAIL with evidence. Be rigorous.

## Criteria

### C1: Voice Distinction
Can you identify which character is speaking without dialogue tags? Each character should have distinctive vocabulary, sentence structure, rhythm, directness, and verbal habits. Score 0 if all characters sound identical. Score 5 if every character has a recognizable voice.

### C2: Subtext Quality
Does dialogue carry meaning beyond the literal words? Do characters speak around things, imply without stating, or say one thing while meaning another? Score 0 if all dialogue is on-the-nose. Score 5 if subtext is rich and layered.

### C3: Character Consistency
Are characters consistent with their established traits from prior scenes and the novel plan? Does their behavior match their motivations, knowledge state, and emotional arc? Score 0 if characters act out of character without justification. Score 5 if consistency is airtight.

### C4: Emotional Authenticity
Do characters' emotional reactions feel proportionate and genuine? Do they react to events in ways that reflect their specific personality rather than generic "appropriate" reactions? Score 0 if emotions feel performed. Score 5 if they feel lived-in.

### C5: Relationship Dynamics
Do interactions between characters reflect their specific relationship — history, power dynamics, unresolved tensions, affection, rivalry? Score 0 if characters interact generically. Score 5 if every interaction is colored by relationship context.

## Sentinels

### S1: Voice Collapse
Can you swap the names on any two characters' dialogue lines in any exchange without it feeling wrong? If yes for any pair: FAIL, identifying which characters.

### S2: Generic Reactions
Does any character react to a major event with a generic, proportionate, "appropriate" response rather than a response specific to who they are? (e.g., everyone gasps at the reveal, everyone cries at the death.) If found: FAIL with example.

### S3: Exposition Mouthpiece
Is any character used primarily as a vehicle for delivering information to the reader rather than acting as a person with their own goals in the scene? If yes: FAIL, identifying which character.

## Output

Write your analysis with specific dialogue quotes. Then output scores:

```json
{
    "criteria": {
        "voice-distinction": {"score": N, "evidence": "..."},
        "subtext-quality": {"score": N, "evidence": "..."},
        "character-consistency": {"score": N, "evidence": "..."},
        "emotional-authenticity": {"score": N, "evidence": "..."},
        "relationship-dynamics": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "voice-collapse": {"status": "PASS|FAIL", "evidence": "..."},
        "generic-reactions": {"status": "PASS|FAIL", "evidence": "..."},
        "exposition-mouthpiece": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
```

- [ ] **Step 5: Commit**

```bash
git add auditors/narrative-arc.md auditors/scene-design.md auditors/prose-quality.md auditors/character-voice.md
git commit -m "feat: add initial universal auditors (narrative-arc, scene-design, prose-quality, character-voice)"
```

---

### Task 17: Auditor settings and genre templates

**Files:**
- Create: `auditor-settings.yaml`
- Create: `genre-templates/space-opera.yaml`
- Create: `genre-templates/detective-mystery.yaml`
- Create: `genre-templates/high-fantasy.yaml`

- [ ] **Step 1: Write auditor-settings.yaml (default universal config)**

Create `auditor-settings.yaml`:
```yaml
# Fiction Pipeline — Auditor Settings
# Copy a genre template here for genre-specific presets, then adjust.
# This default enables only universal auditors.

iteration_cap: 5

novel_plan:
  - auditor: narrative-arc
    enabled: true

chapter_plan:
  - auditor: scene-design
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: character-voice
    enabled: true
```

- [ ] **Step 2: Write genre template stubs**

These templates start as copies of the default. They will be expanded with genre-specific auditors after the research phase (Phase D). For now, they enable the universal auditors and include commented placeholders indicating where genre-specific auditors will be added.

Create `genre-templates/space-opera.yaml`:
```yaml
# Space Opera — Auditor Settings
# Genre-specific auditors will be added after criteria research.

iteration_cap: 5

novel_plan:
  - auditor: narrative-arc
    enabled: true

chapter_plan:
  - auditor: scene-design
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: character-voice
    enabled: true
```

Create `genre-templates/detective-mystery.yaml`:
```yaml
# Detective/Mystery — Auditor Settings
# Genre-specific auditors will be added after criteria research.

iteration_cap: 5

novel_plan:
  - auditor: narrative-arc
    enabled: true

chapter_plan:
  - auditor: scene-design
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: character-voice
    enabled: true
```

Create `genre-templates/high-fantasy.yaml`:
```yaml
# High Fantasy — Auditor Settings
# Genre-specific auditors will be added after criteria research.

iteration_cap: 5

novel_plan:
  - auditor: narrative-arc
    enabled: true

chapter_plan:
  - auditor: scene-design
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: character-voice
    enabled: true
```

- [ ] **Step 3: Commit**

```bash
git add auditor-settings.yaml genre-templates/
git commit -m "feat: add auditor settings and genre template stubs"
```

---

## Phase D: Criteria and Sentinel Research

### Task 18: Research universal writing criteria

This is a research task. The goal is to identify quality dimensions for fiction writing that apply across all genres, drawing from established literary criticism and creative writing pedagogy.

**Files:**
- Create: `docs/research/universal-criteria.md`

- [ ] **Step 1: Research sources**

Search for and read:
- Established creative writing craft books' evaluation criteria (e.g., what writing programs teach)
- Published fiction evaluation rubrics used in MFA programs, writing contests, and literary magazines
- Professional editorial checklists (developmental editing, line editing)
- Published analysis of what makes fiction effective (narrative theory, reader response)

Focus on criteria that are:
- Observable and scoreable (not vague like "good writing")
- Applicable to all prose fiction regardless of genre
- Distinguishable from each other (no overlapping criteria)

- [ ] **Step 2: Compile findings into catalog**

Create `docs/research/universal-criteria.md` with this format per criterion:

```markdown
## [Category Name]

### [Criterion Name]
**What it measures**: [One sentence]
**Score 0**: [What absence looks like]
**Score 5**: [What excellence looks like]
**Source**: [Where this criterion comes from — which framework, author, or standard]
**Applicable levels**: [novel_plan | chapter_plan | scene — which pipeline levels this applies to]
```

Target: 20-30 universal criteria across categories like prose craft, narrative structure, character, dialogue, pacing, tension, theme, and continuity. These will be distributed across existing and new auditor prompts.

- [ ] **Step 3: Commit**

```bash
git add docs/research/universal-criteria.md
git commit -m "research: universal fiction writing criteria catalog"
```

---

### Task 19: Research genre-specific criteria

**Files:**
- Create: `docs/research/genre-criteria-space-opera.md`
- Create: `docs/research/genre-criteria-detective-mystery.md`
- Create: `docs/research/genre-criteria-high-fantasy.md`

- [ ] **Step 1: Research genre conventions and expectations**

For each genre, search for:
- Reader expectations specific to the genre (what fans consider essential)
- Published genre-specific writing guides and craft advice
- Common criticisms of bad examples in the genre
- Genre-specific structural patterns (e.g., mystery: clue planting/fair play, space opera: scale/wonder)

- [ ] **Step 2: Compile genre-specific criteria**

Same format as universal criteria. Target: 5-10 genre-specific criteria per genre that are NOT covered by universal criteria.

Examples of what to look for:
- **Space opera**: sense of scale/wonder, technology consistency, political complexity, space-as-character
- **Detective/mystery**: fair play (reader has access to clues), red herrings, logical deduction chain, revelation pacing
- **High fantasy**: magic system consistency, world-building integration, quest/journey structure, power scaling

- [ ] **Step 3: Commit**

```bash
git add docs/research/genre-criteria-*.md
git commit -m "research: genre-specific fiction criteria catalogs"
```

---

### Task 20: Research LLM fiction sentinel events

**Files:**
- Create: `docs/research/sentinel-catalog.md`

- [ ] **Step 1: Research LLM fiction failure modes**

Search for:
- Forum discussions of AI-generated fiction problems (Reddit r/writing, r/artificial, writing forums)
- Published analysis of LLM creative writing weaknesses
- Reviews/criticism of AI-generated stories
- Your own systematic analysis: what patterns indicate the LLM is in autocomplete mode rather than constructing intentionally?

Remember: sentinels are NOT quality criteria. They are canary indicators of autocomplete behavior. A sentinel being present doesn't mean the writing is bad — it means it's statistically likely that the LLM was defaulting rather than thinking.

- [ ] **Step 2: Compile sentinel catalog**

Create `docs/research/sentinel-catalog.md` with this format:

```markdown
## [Sentinel Name]
**Detection**: [What to look for — specific, concrete, binary checkable]
**Why it indicates autocomplete**: [What failure mode this correlates with]
**Design space cost**: [What legitimate fiction you're excluding by banning this]
**Applicable levels**: [novel_plan | chapter_plan | scene]
**Category**: [Which auditor this sentinel belongs in]
```

Target: 30-50 sentinels. Group them by which auditor they belong in (prose-quality, character-voice, narrative-arc, scene-design, or new genre-specific auditors).

- [ ] **Step 3: Commit**

```bash
git add docs/research/sentinel-catalog.md
git commit -m "research: LLM fiction sentinel event catalog"
```

---

### Task 21: Expand auditors with research findings

Based on the research from Tasks 18-20, update existing auditors and create new ones.

**Files:**
- Modify: `auditors/narrative-arc.md`
- Modify: `auditors/scene-design.md`
- Modify: `auditors/prose-quality.md`
- Modify: `auditors/character-voice.md`
- Create: new auditor files as needed (e.g., `auditors/tension-dynamics.md`, `auditors/world-consistency.md`)
- Create: genre-specific auditor files (e.g., `auditors/mystery-fair-play.md`, `auditors/space-opera-scale.md`)

- [ ] **Step 1: Map research criteria to auditors**

For each criterion from the research:
1. Determine which auditor it belongs in (existing or new)
2. Determine which pipeline level it applies to
3. Group related criteria into focused auditors (one concern per auditor)

Rule: each auditor should have 5-10 criteria and 3-8 sentinels. If a category has more, split into sub-auditors.

- [ ] **Step 2: Update existing auditors**

Add new criteria and sentinels from the research to the four existing auditor prompts. Follow the same format: criterion definition with score 0 and score 5 descriptions, sentinel definition with detection rule.

- [ ] **Step 3: Create new auditors**

For any criteria/sentinels that don't fit existing auditors, create new auditor files following the same template as Task 16.

- [ ] **Step 4: Create genre-specific auditors**

For genre-specific criteria, create new auditor files. These will only be enabled in the corresponding genre template.

- [ ] **Step 5: Update genre templates**

Update `genre-templates/space-opera.yaml`, `genre-templates/detective-mystery.yaml`, and `genre-templates/high-fantasy.yaml` to include the new genre-specific auditors (enabled) alongside the universal ones.

- [ ] **Step 6: Update default auditor-settings.yaml**

Add new universal auditors (enabled by default). Add genre-specific auditors (disabled by default).

- [ ] **Step 7: Commit**

```bash
git add auditors/ genre-templates/ auditor-settings.yaml
git commit -m "feat: expand auditors with researched criteria and sentinels"
```

---

## Phase E: Validation

### Task 22: End-to-end pipeline test

**Files:**
- Create: `tests/test-premise.md`

- [ ] **Step 1: Write a short test premise**

Create `tests/test-premise.md`:
```markdown
A burned-out detective on a Mars colony investigates a murder in the
hydroponics district. The victim was a botanist who discovered that the
colony's food supply has been quietly contaminated — not by accident,
but by design. The detective must navigate corporate cover-ups, a
distrustful colonial population, and her own failing health (she's
been eating the same contaminated food) to expose who is poisoning
the colony and why, before the damage becomes irreversible.

This is a 3-chapter novella. Keep it tight.
```

- [ ] **Step 2: Set up and run the pipeline**

```bash
# Copy test premise
cp tests/test-premise.md premise.md

# Use default settings (iteration cap 5, universal auditors)
# auditor-settings.yaml is already configured

# Run the pipeline
bash run.sh 2>&1 | tee state/pipeline.log
```

This will take significant time and API calls. Monitor the output for:
- Does the novel plan get created and audited?
- Do chapter plans get created and audited?
- Do scenes get written and audited?
- Does the fixer improve scores across rounds?
- Does backtracking evaluate correctly?
- Does the pipeline resume correctly if interrupted (kill and restart)?

- [ ] **Step 3: Inspect output quality**

Read the generated content in `output/`. Evaluate:
- Is the novel plan coherent and well-structured?
- Do chapter plans break down into meaningful scenes?
- Is the prose readable and engaging?
- Did auditor scores improve across refinement rounds? (Check `state/audit-logs/`)
- Did backtracking make reasonable decisions?

- [ ] **Step 4: Fix issues found during testing**

Any bugs in the pipeline, prompts that produce poor output, or auditors that score incorrectly should be fixed. This is expected — first runs always reveal issues.

- [ ] **Step 5: Commit fixes**

```bash
git add -A
git commit -m "fix: address issues found during end-to-end testing"
```

---

## Post-Implementation Notes

### What this plan produces
A fully functional fiction creation pipeline with:
- Shell orchestrator with state management and restart capability
- 9 focused prompts (3 creators, 3 fixers, 2 backtrackers, 1 context collector)
- 4 initial universal auditors with criteria and sentinels
- Configurable auditor settings with genre template support
- Research catalogs for criteria and sentinels

### What requires ongoing work
- **Expanding the auditor catalog**: The initial 4 auditors are a starting set. The research phase will likely identify 8-15 total auditor categories.
- **Tuning prompts**: First-run output will reveal where prompts need refinement. This is expected and normal.
- **Genre template refinement**: Genre templates need testing with actual genre-specific premises to verify the right auditors are enabled.
- **Sentinel expansion**: The sentinel catalog will grow as more LLM fiction failure modes are identified through use.
