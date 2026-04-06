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
blocks = re.findall(r'\x60\x60\x60json\s*\n(.*?)\n\s*\x60\x60\x60', text, re.DOTALL)
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

scores = json.loads(sys.stdin.read())
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
" <<< "$scores_json"
}

# Check if all sentinels pass. Prints PASS or FAIL.
# Args: $1 = scores JSON string
check_sentinels_passing() {
    local scores_json="$1"
    python3 -c "
import json, sys

scores = json.loads(sys.stdin.read())
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
" <<< "$scores_json"
}

# Merge two scores JSON objects (combines criteria and sentinels).
# Args: $1 = first JSON, $2 = second JSON
merge_scores() {
    local a="$1"
    local b="$2"
    python3 -c "
import json, sys

a = json.loads(sys.argv[1])
b = json.loads(sys.argv[2])

merged = {
    'criteria': {**a.get('criteria', {}), **b.get('criteria', {})},
    'sentinels': {**a.get('sentinels', {}), **b.get('sentinels', {})}
}
print(json.dumps(merged))
" "$a" "$b"
}

# Write scores to the audit log.
# Args: $1 = log prefix, $2 = round number, $3 = scores JSON
log_scores() {
    local prefix="$1"
    local round="$2"
    local scores_json="$3"
    echo "$scores_json" > "$STATE_DIR/audit-logs/${prefix}-round-${round}.json"
}
