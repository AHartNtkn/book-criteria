#!/bin/bash
# Logging for the fiction pipeline.
# Saves prompts, responses, and intermediate state for every claude call.
#
# LOG_DIR is set by init_logging. All pipeline functions should use
# log_call() to wrap claude invocations.

LOG_DIR=""
CALL_COUNTER=0

init_logging() {
    LOG_DIR="$STATE_DIR/logs/$(date -u +%Y%m%d-%H%M%S)"
    mkdir -p "$LOG_DIR"
    echo "Logging to $LOG_DIR" >&2
}

# Log a claude call: saves the prompt, the response, and metadata.
# Usage: response=$(log_call "description" "prompt_text")
#
# Args: $1 = description (e.g., "auditor-prose-quality-round-2")
#        $2 = the assembled prompt text
# Outputs: the claude response (to stdout, for capture)
log_call() {
    local description="$1"
    local prompt_text="$2"

    CALL_COUNTER=$((CALL_COUNTER + 1))
    local call_id
    call_id=$(printf "%04d" "$CALL_COUNTER")
    local call_dir="$LOG_DIR/${call_id}-${description}"
    mkdir -p "$call_dir"

    # Save prompt
    echo "$prompt_text" > "$call_dir/prompt.md"

    # Save metadata
    cat > "$call_dir/metadata.json" << METAJSON
{
    "call_id": "$call_id",
    "description": "$description",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "phase": "$(read_state phase)",
    "chapter": $(read_state chapter),
    "scene": $(read_state scene),
    "round": $(read_state refinement_round)
}
METAJSON

    # Run claude and capture response
    local response
    local start_time
    start_time=$(date +%s)

    response=$(echo "$prompt_text" | claude -p - --output-format text)
    local exit_code=$?

    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))

    # Save response
    echo "$response" > "$call_dir/response.md"

    # Save timing
    echo "{\"duration_seconds\": $duration, \"exit_code\": $exit_code}" > "$call_dir/timing.json"

    # Log summary to stderr
    echo "    [log] $description (${duration}s)" >&2

    # Output response for capture
    echo "$response"
}

# Save a snapshot of a file before it gets overwritten (e.g., before fixer runs)
log_snapshot() {
    local description="$1"
    local file_path="$2"

    if [[ ! -f "$file_path" ]]; then
        return
    fi

    local snapshot_dir="$LOG_DIR/snapshots"
    mkdir -p "$snapshot_dir"

    local basename
    basename=$(basename "$file_path")
    local snapshot_name="${CALL_COUNTER}-${description}-${basename}"
    cp "$file_path" "$snapshot_dir/$snapshot_name"
}
