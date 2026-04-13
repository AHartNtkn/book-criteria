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

def try_parse(s):
    \"\"\"Try to parse JSON, with repair for common LLM errors.\"\"\"
    # First try direct parse
    try:
        return json.loads(s)
    except json.JSONDecodeError:
        pass

    # Repair: escape unescaped double quotes inside JSON string values.
    # Strategy: find each \"key\": \"value\" pair and escape inner quotes in value.
    def escape_inner_quotes(m):
        key_part = m.group(1)  # everything up to the value's opening quote
        value = m.group(2)     # the value content (between outer quotes)
        # Escape any unescaped double quotes inside the value
        fixed_value = value.replace('\"', '\\\\\"')
        return key_part + '\"' + fixed_value + '\"'

    try:
        # Match \"evidence\": \"...\" patterns where the value may contain unescaped quotes
        # This regex finds: \"key\": \" then captures everything until the pattern
        # looks like it's ending with \", followed by } or ,
        # Since this is tricky, use a different approach: parse line by line
        lines = s.split('\\n')
        fixed_lines = []
        for line in lines:
            # If line has \"evidence\": with potential inner quotes, fix them
            if '\"evidence\"' in line or '\"status\"' in line:
                # Find the value portion after the last \": \"
                parts = line.split('\": \"', 1)
                if len(parts) == 2:
                    prefix = parts[0] + '\": \"'
                    rest = parts[1]
                    # The value ends with \"} or \",
                    if rest.endswith('\"}') or rest.endswith('\"},'):
                        suffix = rest[-2:] if rest.endswith('\"},') else rest[-2:]
                        if rest.endswith('\"},'):
                            suffix = rest[-3:]
                            inner = rest[:-3]
                        else:
                            suffix = rest[-2:]
                            inner = rest[:-2]
                        # Escape any double quotes in the inner value
                        inner_fixed = inner.replace('\\\\\"', '\\x00').replace('\"', '\\\\\"').replace('\\x00', '\\\\\"')
                        fixed_lines.append(prefix + inner_fixed + suffix)
                        continue
            fixed_lines.append(line)
        fixed = '\\n'.join(fixed_lines)
        return json.loads(fixed)
    except (json.JSONDecodeError, Exception):
        pass

    # Last resort: extract just scores using regex, ignore evidence text
    try:
        result = {'criteria': {}, 'sentinels': {}}
        # Extract criterion scores: \"ID\": {\"score\": N
        for m in re.finditer(r'\"([A-Z]{2}-\\d+)\"\\s*:\\s*\\{\\s*\"score\"\\s*:\\s*(\\d+|\"N/A\")', s):
            cid = m.group(1)
            score_raw = m.group(2)
            score = score_raw.strip('\"') if score_raw.startswith('\"') else int(score_raw)
            result['criteria'][cid] = {'score': score, 'evidence': '(extracted from malformed JSON)'}
        # Extract sentinel statuses: \"ID\": {\"status\": \"PASS\"/\"FAIL\"
        for m in re.finditer(r'\"([A-Z]{2}-\\d+)\"\\s*:\\s*\\{\\s*\"status\"\\s*:\\s*\"(PASS|FAIL)\"', s):
            sid = m.group(1)
            status = m.group(2)
            result['sentinels'][sid] = {'status': status, 'evidence': '(extracted from malformed JSON)'}
        if result['criteria'] or result['sentinels']:
            return result
    except Exception:
        pass

    return None

# Try fenced JSON blocks first
blocks = re.findall(r'\x60\x60\x60json\s*\n(.*?)\n\s*\x60\x60\x60', text, re.DOTALL)
if blocks:
    parsed = try_parse(blocks[-1])
    if parsed and ('criteria' in parsed or 'sentinels' in parsed):
        # Re-serialize to guarantee valid JSON output
        print(json.dumps(parsed))
        sys.exit(0)

# Fallback: find bare JSON objects with criteria/sentinels keys
matches = re.findall(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', text, re.DOTALL)
for m in reversed(matches):
    parsed = try_parse(m)
    if parsed and ('criteria' in parsed or 'sentinels' in parsed):
        print(json.dumps(parsed))
        sys.exit(0)

# Fallback: extract scores from Markdown prose (e.g., **Score: 2** under ### ID: headings)
result = {'criteria': {}, 'sentinels': {}}

# Find criterion scores: ### XX-NNN: ... followed by **Score: N** or **Score: N/A**
for m in re.finditer(r'###\s+([A-Z]{2}-\d+):.*?(?:\*\*Score:\s*([\dN/A]+)\*\*|\*\*Score\*\*:\s*([\dN/A]+))', text, re.DOTALL):
    cid = m.group(1)
    score_raw = m.group(2) or m.group(3)
    if score_raw in ('N/A', 'n/a'):
        score = 'N/A'
    else:
        try:
            score = int(score_raw)
        except ValueError:
            continue
    result['criteria'][cid] = {'score': score, 'evidence': '(extracted from Markdown prose)'}

# Find sentinel statuses: ### XX-NNN: ... followed by **Status: PASS** or **FAIL**
for m in re.finditer(r'###\s+([A-Z]{2}-\d+):.*?(?:\*\*Status:\s*(PASS|FAIL)\*\*|\*\*Status\*\*:\s*(PASS|FAIL))', text, re.DOTALL):
    sid = m.group(1)
    status = m.group(2) or m.group(3)
    result['sentinels'][sid] = {'status': status, 'evidence': '(extracted from Markdown prose)'}

if result['criteria'] or result['sentinels']:
    print(json.dumps(result))
    sys.exit(0)

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
    # N/A scores are not failures — skip them
    if score == 'N/A' or score == 'n/a':
        continue
    if isinstance(score, str):
        try:
            score = int(score)
        except ValueError:
            continue
    if score < $threshold:
        print(f'BELOW THRESHOLD: {name} = {score} (need >= $threshold)', file=sys.stderr)
        all_pass = False

print('PASS' if all_pass else 'FAIL')
" <<< "$scores_json"
}

# Check if all sentinels pass. Prints PASS or FAIL.
# Always exits 0 — pass/fail communicated via stdout.
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
" <<< "$scores_json"
}

# Merge two scores JSON objects (combines criteria and sentinels).
# Args: $1 = first JSON, $2 = second JSON
merge_scores() {
    local a="$1"
    local b="$2"
    python3 -c "
import json, sys

lines = sys.stdin.read().split('\n---SPLIT---\n')
a = json.loads(lines[0])
b = json.loads(lines[1])

merged = {
    'criteria': {**a.get('criteria', {}), **b.get('criteria', {})},
    'sentinels': {**a.get('sentinels', {}), **b.get('sentinels', {})}
}
print(json.dumps(merged))
" <<< "${a}
---SPLIT---
${b}"
}

# Write scores to the audit log.
# Args: $1 = log prefix, $2 = round number, $3 = scores JSON
log_scores() {
    local prefix="$1"
    local round="$2"
    local scores_json="$3"
    echo "$scores_json" > "$STATE_DIR/audit-logs/${prefix}-round-${round}.json"
}
