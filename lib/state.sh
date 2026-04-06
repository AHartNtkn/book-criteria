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
