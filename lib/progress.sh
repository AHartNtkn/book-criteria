#!/bin/bash
# Step-level progress tracking for the fiction pipeline.
#
# Uses individual files per step (not one shared JSON) to avoid
# concurrent write corruption from parallel subshells.
#
# Each step writes to: $STATE_DIR/steps/<step-id>.status
# Format: STATUS|TIMESTAMP|DESCRIPTION
#
# This is safe for parallel writes because each step writes to
# its own file — no shared state.

STEP_DIR=""

init_progress() {
    STEP_DIR="$STATE_DIR/steps"
    mkdir -p "$STEP_DIR"
}

step_start() {
    local step_id="$1"
    local description="${2:-}"
    echo "STARTED|$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${description}" > "$STEP_DIR/${step_id}.status"
}

step_heartbeat() {
    local step_id="$1"
    local file="$STEP_DIR/${step_id}.status"
    if [[ -f "$file" ]]; then
        local desc
        desc=$(cut -d'|' -f3- "$file")
        echo "RUNNING|$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${desc}" > "$file"
    fi
}

step_done() {
    local step_id="$1"
    local result="${2:-}"
    echo "DONE|$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${result}" > "$STEP_DIR/${step_id}.status"
}

step_failed() {
    local step_id="$1"
    local error="${2:-unknown}"
    echo "FAILED|$(date -u +"%Y-%m-%dT%H:%M:%SZ")|${error}" > "$STEP_DIR/${step_id}.status"
}

show_progress() {
    if [[ ! -d "$STEP_DIR" ]]; then
        echo "No steps recorded yet."
        return
    fi

    local count
    count=$(ls "$STEP_DIR"/*.status 2>/dev/null | wc -l)
    if [[ "$count" -eq 0 ]]; then
        echo "No steps recorded yet."
        return
    fi

    local now
    now=$(date +%s)

    echo "Pipeline Progress ($count steps):"
    echo ""

    for f in "$STEP_DIR"/*.status; do
        local step_id
        step_id=$(basename "$f" .status)
        local line
        line=$(cat "$f")
        local status
        status=$(echo "$line" | cut -d'|' -f1)
        local timestamp
        timestamp=$(echo "$line" | cut -d'|' -f2)
        local desc
        desc=$(echo "$line" | cut -d'|' -f3-)

        local stale_warning=""
        if [[ "$status" == "STARTED" || "$status" == "RUNNING" ]]; then
            local step_time
            step_time=$(date -d "$timestamp" +%s 2>/dev/null) || step_time=0
            if [[ "$step_time" -gt 0 ]]; then
                local age=$(( now - step_time ))
                if [[ "$age" -gt 300 ]]; then
                    stale_warning=" [STALE: no update in ${age}s]"
                elif [[ "$age" -gt 60 ]]; then
                    stale_warning=" [${age}s ago]"
                fi
            fi
        fi

        local icon
        case "$status" in
            DONE)    icon="✓" ;;
            FAILED)  icon="✗" ;;
            RUNNING) icon="►" ;;
            STARTED) icon="○" ;;
            *)       icon="?" ;;
        esac

        echo "  ${icon} ${step_id}: ${status}${stale_warning} — ${desc}"
    done
}
