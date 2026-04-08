#!/bin/bash
# Logging for the fiction pipeline.
# Saves prompts, responses, and intermediate state for every claude call.
#
# LOG_DIR is set by init_logging. All pipeline functions should use
# run_claude_to_file() for calls that write output to a specific file,
# or log_call() for calls where the response is captured.

LOG_DIR=""
CALL_COUNTER=0

# Tools given to claude for file-writing calls
CLAUDE_TOOLS="Read,Write"
CLAUDE_FLAGS="--dangerously-skip-permissions"

init_logging() {
    LOG_DIR="$STATE_DIR/logs/$(date -u +%Y%m%d-%H%M%S)"
    mkdir -p "$LOG_DIR"
    echo "Logging to $LOG_DIR" >&2
}

# Run claude with file-writing tools. The LLM writes output to the specified file.
# This is the primary invocation method — avoids stdout capture entirely.
#
# Args: $1 = description (for logging)
#        $2 = prompt text (instructions + context)
#        $3 = output file path (the LLM is told to write here)
#        $4 = model flag (optional, e.g., "--model sonnet")
# Returns: 0 if output file exists and is non-empty after the call
run_claude_to_file() {
    local description="$1"
    local prompt_text="$2"
    local output_file="$3"
    local model_flag="${4:-}"

    CALL_COUNTER=$((CALL_COUNTER + 1))
    local call_id
    call_id=$(printf "%04d" "$CALL_COUNTER")
    local call_dir="$LOG_DIR/${call_id}-${description}"
    mkdir -p "$call_dir"

    # Append file-writing instruction to the prompt
    local full_prompt="${prompt_text}

---
IMPORTANT: Write your complete output to the file: ${output_file}
Use the Write tool to create this file. Do not output your response as text — write it to the file.
Do not write any other files. Do not use any other tools."

    # Save prompt
    echo "$full_prompt" > "$call_dir/prompt.md"

    # Save metadata
    cat > "$call_dir/metadata.json" << METAJSON
{
    "call_id": "$call_id",
    "description": "$description",
    "output_file": "$output_file",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "phase": "$(read_state phase)",
    "chapter": $(read_state chapter),
    "scene": $(read_state scene),
    "round": $(read_state refinement_round)
}
METAJSON

    # Track step progress
    step_start "$description" "claude call $call_id → $output_file"

    local start_time
    start_time=$(date +%s)

    # Run claude with file tools
    echo "$full_prompt" | claude -p - \
        --tools "$CLAUDE_TOOLS" \
        $CLAUDE_FLAGS \
        $model_flag \
        --output-format text \
        > "$call_dir/claude-stdout.txt" 2>&1
    local exit_code=$?

    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))

    # Save timing
    echo "{\"duration_seconds\": $duration, \"exit_code\": $exit_code}" > "$call_dir/timing.json"

    # Check if the output file was written
    if [[ -f "$output_file" && -s "$output_file" ]]; then
        cp "$output_file" "$call_dir/response.md"
        step_done "$description" "${duration}s, $(wc -c < "$output_file") bytes"
        echo "    [log] $description (${duration}s, $(wc -c < "$output_file") bytes)" >&2
        return 0
    else
        step_failed "$description" "output file not written after ${duration}s"
        echo "    [log] $description FAILED — no output file (${duration}s)" >&2
        return 1
    fi
}

# Legacy: capture response via stdout. Still used for auditor calls where
# we need the response text in a variable for score extraction.
#
# Args: $1 = description
#        $2 = prompt text
#        $3 = model flag (optional)
# Outputs: the claude response to stdout
log_call() {
    local description="$1"
    local prompt_text="$2"
    local model_flag="${3:-}"

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

    # Track step progress
    step_start "$description" "claude call $call_id"

    local response
    local start_time
    start_time=$(date +%s)

    response=$(echo "$prompt_text" | claude -p - $model_flag --output-format text)
    local exit_code=$?

    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))

    # Save response
    echo "$response" > "$call_dir/response.md"

    # Save timing
    echo "{\"duration_seconds\": $duration, \"exit_code\": $exit_code}" > "$call_dir/timing.json"

    if [[ "$exit_code" -eq 0 ]]; then
        step_done "$description" "${duration}s, $(echo "$response" | wc -c) bytes"
    else
        step_failed "$description" "exit code $exit_code after ${duration}s"
    fi

    echo "    [log] $description (${duration}s)" >&2

    echo "$response"
}

# Save a snapshot of a file before it gets overwritten
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
