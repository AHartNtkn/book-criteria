#!/bin/bash
# Step-level progress tracking for the fiction pipeline.
#
# Every pipeline step writes explicit status markers:
#   STARTED  → step has begun
#   RUNNING  → actively processing (with heartbeat timestamp)
#   DONE     → step completed successfully
#   FAILED   → step failed with error
#
# Progress file: state/step-status.json
# Each step is keyed by a unique ID (e.g., "ideate-premise-03", "audit-scene-ch01-sc02-round-1")
#
# The status file is human-readable and machine-parseable.
# Checking progress = reading this file. No ambiguity.

STEP_STATUS_FILE=""

init_progress() {
    STEP_STATUS_FILE="$STATE_DIR/step-status.json"
    if [[ ! -f "$STEP_STATUS_FILE" ]]; then
        echo '{}' > "$STEP_STATUS_FILE"
    fi
}

# Mark a step as started
step_start() {
    local step_id="$1"
    local description="${2:-}"
    python3 -c "
import json, sys
from datetime import datetime, timezone
f = sys.argv[1]
step_id = sys.argv[2]
desc = sys.argv[3] if len(sys.argv) > 3 else ''
with open(f) as fh:
    data = json.load(fh)
data[step_id] = {
    'status': 'STARTED',
    'description': desc,
    'started_at': datetime.now(timezone.utc).isoformat(),
    'updated_at': datetime.now(timezone.utc).isoformat(),
}
with open(f, 'w') as fh:
    json.dump(data, fh, indent=2)
" "$STEP_STATUS_FILE" "$step_id" "$description"
}

# Update heartbeat (call periodically during long steps)
step_heartbeat() {
    local step_id="$1"
    python3 -c "
import json, sys
from datetime import datetime, timezone
f = sys.argv[1]
step_id = sys.argv[2]
with open(f) as fh:
    data = json.load(fh)
if step_id in data:
    data[step_id]['status'] = 'RUNNING'
    data[step_id]['updated_at'] = datetime.now(timezone.utc).isoformat()
with open(f, 'w') as fh:
    json.dump(data, fh, indent=2)
" "$STEP_STATUS_FILE" "$step_id"
}

# Mark a step as done
step_done() {
    local step_id="$1"
    local result="${2:-}"
    python3 -c "
import json, sys
from datetime import datetime, timezone
f = sys.argv[1]
step_id = sys.argv[2]
result = sys.argv[3] if len(sys.argv) > 3 else ''
with open(f) as fh:
    data = json.load(fh)
if step_id in data:
    data[step_id]['status'] = 'DONE'
    data[step_id]['updated_at'] = datetime.now(timezone.utc).isoformat()
    data[step_id]['result'] = result
with open(f, 'w') as fh:
    json.dump(data, fh, indent=2)
" "$STEP_STATUS_FILE" "$step_id" "$result"
}

# Mark a step as failed
step_failed() {
    local step_id="$1"
    local error="${2:-unknown}"
    python3 -c "
import json, sys
from datetime import datetime, timezone
f = sys.argv[1]
step_id = sys.argv[2]
error = sys.argv[3] if len(sys.argv) > 3 else 'unknown'
with open(f) as fh:
    data = json.load(fh)
if step_id in data:
    data[step_id]['status'] = 'FAILED'
    data[step_id]['updated_at'] = datetime.now(timezone.utc).isoformat()
    data[step_id]['error'] = error
with open(f, 'w') as fh:
    json.dump(data, fh, indent=2)
" "$STEP_STATUS_FILE" "$step_id" "$error"
}

# Print a human-readable summary of current progress
show_progress() {
    python3 -c "
import json, sys
from datetime import datetime, timezone

f = sys.argv[1]
with open(f) as fh:
    data = json.load(fh)

if not data:
    print('No steps recorded yet.')
    sys.exit(0)

now = datetime.now(timezone.utc)
print(f'Pipeline Progress ({len(data)} steps):')
print()

for step_id, info in data.items():
    status = info.get('status', '?')
    desc = info.get('description', '')
    updated = info.get('updated_at', '')

    # Calculate staleness for RUNNING/STARTED steps
    stale_warning = ''
    if status in ('STARTED', 'RUNNING') and updated:
        try:
            updated_dt = datetime.fromisoformat(updated)
            age_seconds = (now - updated_dt).total_seconds()
            if age_seconds > 300:
                stale_warning = f' [STALE: no update in {int(age_seconds)}s]'
            elif age_seconds > 60:
                stale_warning = f' [{int(age_seconds)}s ago]'
        except (ValueError, TypeError):
            pass

    icon = {'DONE': '✓', 'FAILED': '✗', 'RUNNING': '►', 'STARTED': '○'}.get(status, '?')
    line = f'  {icon} {step_id}: {status}{stale_warning}'
    if desc:
        line += f' — {desc}'
    if status == 'FAILED':
        line += f' — ERROR: {info.get(\"error\", \"?\")}'
    print(line)
" "$STEP_STATUS_FILE"
}
