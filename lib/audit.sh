#!/bin/bash
# Audit/refine loop for the fiction pipeline.
# Requires: claude CLI, assemble_auditor.py, fill_template.py,
#           lib/config.sh, lib/state.sh, lib/scoring.sh,
#           lib/logging.sh, lib/progress.sh
#
# PROJECT_DIR must be set before sourcing.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Maximum parallel auditor calls per batch
AUDITOR_BATCH_SIZE=5

# Get list of auditor names for a given pipeline level from auditor-config.yaml
get_auditors_for_level() {
    local level="$1"
    yq -r ".auditors[] | select(.level == \"$level\") | .name" \
        "$PROJECT_DIR/auditor-config.yaml"
}

# Generate a round-specific settings file that disables criteria/sentinels
# that already passed in previous rounds.
generate_round_settings() {
    local output_path="$1"
    local passed_items_file="$STATE_DIR/passed-items.json"
    local base_settings="$PROJECT_DIR/criteria-settings.yaml"

    python3 -c "
import json, yaml, sys, os

output_path = sys.argv[1]
passed_file = sys.argv[2]
base_file = sys.argv[3]

base = {}
if os.path.isfile(base_file):
    with open(base_file) as f:
        base = yaml.safe_load(f) or {}

passed = set()
if os.path.isfile(passed_file):
    with open(passed_file) as f:
        passed = set(json.load(f))

criteria = dict(base.get('criteria', {}))
sentinels = dict(base.get('sentinels', {}))

for item_id in passed:
    if item_id.startswith('SS-') or item_id.startswith('CS-') or \
       item_id.startswith('NS-') or item_id.startswith('IS-'):
        sentinels[item_id] = False
    else:
        criteria[item_id] = False

result = {
    'iteration_cap': base.get('iteration_cap', 5),
    'iteration_caps': base.get('iteration_caps', {}),
    'criteria': criteria,
    'sentinels': sentinels,
}

with open(output_path, 'w') as f:
    yaml.dump(result, f, default_flow_style=False)
" "$output_path" "$passed_items_file" "$base_settings"
}

# Record passing criteria/sentinels from an auditor's scores
record_passing_items() {
    local scores_json="$1"
    local passed_items_file="$STATE_DIR/passed-items.json"

    python3 -c "
import json, sys, os

scores = json.loads(sys.stdin.read())
passed_file = sys.argv[1]

existing = set()
if os.path.isfile(passed_file):
    with open(passed_file) as f:
        existing = set(json.load(f))

for name, data in scores.get('criteria', {}).items():
    if data.get('score', 0) >= 4:
        existing.add(name)

for name, data in scores.get('sentinels', {}).items():
    if data.get('status', 'FAIL') == 'PASS':
        existing.add(name)

with open(passed_file, 'w') as f:
    json.dump(sorted(existing), f)
" "$passed_items_file" <<< "$scores_json"
}

# Set by audit_refine_loop before calling run_auditors
CURRENT_AUDIT_ROUND=0
CURRENT_AUDIT_PREFIX=""

# Run all auditors for a level in parallel using dynamic prompt assembly.
# Sets: COMBINED_FEEDBACK (file path), COMBINED_SCORES (JSON string)
# FATAL on any auditor failure.
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        $2 = content file being audited
#        remaining args = KEY=FILE pairs for context
run_auditors() {
    local level="$1"
    local content_file="$2"
    shift 2
    local context_args=("$@" "content=$content_file")

    local auditor_names
    auditor_names=$(get_auditors_for_level "$level")

    # Generate round-specific settings
    local round_settings="$STATE_DIR/round-settings.yaml"
    generate_round_settings "$round_settings"

    # Organized output: auditor-results/target/round-N/
    local auditor_out_dir="$STATE_DIR/auditor-results/${CURRENT_AUDIT_PREFIX}/round-${CURRENT_AUDIT_ROUND}"
    mkdir -p "$auditor_out_dir"

    COMBINED_FEEDBACK="$auditor_out_dir/combined-feedback.txt"
    COMBINED_SCORES='{"criteria":{},"sentinels":{}}'
    > "$COMBINED_FEEDBACK"

    # Phase 1: Assemble prompts and identify active auditors (sequential, fast)
    local active_auditors=()
    local resumed_auditors=()
    local skipped=0
    local resumed=0
    while IFS= read -r auditor_name; do
        [[ -z "$auditor_name" ]] && continue

        local safe_name
        safe_name=$(echo "$auditor_name" | tr ' /:' '---' | tr -cd 'a-zA-Z0-9-')

        # Skip auditors that already completed in this round (mid-round resume)
        local existing_status="$auditor_out_dir/${safe_name}.status"
        if [[ -f "$existing_status" && "$(cat "$existing_status")" == "OK" ]]; then
            echo "    Already done: $auditor_name (resuming)" >&2
            resumed=$((resumed + 1))
            # Still need to include in active_auditors for merge phase
            resumed_auditors+=("$safe_name|$auditor_name")
            continue
        fi

        local prompt_file="$auditor_out_dir/${safe_name}.prompt.md"

        if ! python3 "$PROJECT_DIR/assemble_auditor.py" "$auditor_name" \
                --settings "$round_settings" \
                > "$prompt_file" 2>/dev/null; then
            echo "WARNING: Could not assemble auditor '$auditor_name'" >&2
            continue
        fi

        # Skip auditors with no remaining active criteria/sentinels
        if grep -q "No active criteria" "$prompt_file" && \
           grep -q "No active sentinels" "$prompt_file"; then
            skipped=$((skipped + 1))
            continue
        fi

        # Fill context placeholders
        local filled_file="$auditor_out_dir/${safe_name}.filled.md"
        python3 "$PROJECT_DIR/fill_template.py" "$prompt_file" \
            "${context_args[@]}" > "$filled_file"

        active_auditors+=("$safe_name|$auditor_name")
    done <<< "$auditor_names"

    local total=${#active_auditors[@]}
    local status_parts=()
    [[ "$total" -gt 0 ]] && status_parts+=("$total to run")
    [[ "$resumed" -gt 0 ]] && status_parts+=("$resumed already done")
    [[ "$skipped" -gt 0 ]] && status_parts+=("$skipped skipped (all criteria passed)")
    echo "  Auditors: $(IFS=', '; echo "${status_parts[*]}")" >&2

    if [[ "$total" -eq 0 && "$resumed" -eq 0 ]]; then
        echo "  All criteria/sentinels passed in previous rounds." >&2
        return
    fi

    # Phase 2: Run all active auditors in parallel batches
    # Each subshell writes a .status file: "OK" on success, error message on failure
    local batch_count=0
    for entry in "${active_auditors[@]}"; do
        local safe_name="${entry%%|*}"
        local auditor_name="${entry#*|}"
        local filled_file="$auditor_out_dir/${safe_name}.filled.md"
        local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
        local scores_file="$auditor_out_dir/${safe_name}.scores.json"
        local status_file="$auditor_out_dir/${safe_name}.status"

        echo "    Launched: $auditor_name" >&2
        (
            # Write status on exit (success or failure)
            trap 'if [[ ! -f "$status_file" ]]; then echo "CRASHED: unexpected exit" > "$status_file"; fi' EXIT

            step_start "audit-${safe_name}" "Auditor: $auditor_name"

            # Auditor writes its analysis to the feedback file
            local write_prompt="$(cat "$filled_file")

---
IMPORTANT: Write your complete analysis and JSON scores block to the file: ${feedback_file}
Use the Write tool to create this file. Do not output your response as text — write it to the file.
Do not write any other files. Do not use any other tools."

            echo "$write_prompt" | claude -p - \
                --tools "Read,Write" \
                --dangerously-skip-permissions \
                --output-format text \
                > "$auditor_out_dir/${safe_name}.claude-stdout.txt" 2>&1

            if [[ ! -f "$feedback_file" || ! -s "$feedback_file" ]]; then
                echo "FAILED: output file not written" > "$status_file"
                echo "    FAILED: $auditor_name — no output" >&2
                step_failed "audit-${safe_name}" "output file not written"
                exit 1
            fi

            # Prepend auditor name to feedback
            local tmp_feedback
            tmp_feedback=$(mktemp)
            echo "--- Auditor: ${auditor_name} ---" > "$tmp_feedback"
            cat "$feedback_file" >> "$tmp_feedback"
            mv "$tmp_feedback" "$feedback_file"

            # Extract scores from the feedback
            local scores
            scores=$(extract_scores < "$feedback_file" 2>/dev/null) || {
                echo "FAILED: could not extract scores" > "$status_file"
                step_failed "audit-${safe_name}" "could not extract scores"
                exit 1
            }
            echo "$scores" > "$scores_file"

            echo "OK" > "$status_file"
            echo "    Done: $auditor_name" >&2
            step_done "audit-${safe_name}" "$(echo "$scores" | python3 -c "
import json,sys
d=json.load(sys.stdin)
nc=len(d.get('criteria',{}))
ns=len(d.get('sentinels',{}))
print(f'{nc} criteria, {ns} sentinels scored')
" 2>/dev/null)"
        ) &

        batch_count=$((batch_count + 1))
        if (( batch_count % AUDITOR_BATCH_SIZE == 0 )); then
            wait
        fi
    done
    wait

    # Phase 3: Check for failures, then merge results
    local failed=0
    for entry in "${active_auditors[@]}"; do
        local safe_name="${entry%%|*}"
        local auditor_name="${entry#*|}"
        local status_file="$auditor_out_dir/${safe_name}.status"

        if [[ ! -f "$status_file" ]]; then
            echo "FATAL: Auditor '$auditor_name' produced no status file — subshell may have crashed" >&2
            failed=$((failed + 1))
        elif [[ "$(cat "$status_file")" != "OK" ]]; then
            echo "FATAL: Auditor '$auditor_name' failed: $(cat "$status_file")" >&2
            failed=$((failed + 1))
        fi
    done

    if [[ "$failed" -gt 0 ]]; then
        echo "FATAL: $failed of $total auditors failed. Stopping pipeline." >&2
        exit 1
    fi

    # All auditors succeeded — merge results (both newly run and resumed)
    local all_completed=("${resumed_auditors[@]}" "${active_auditors[@]}")
    for entry in "${all_completed[@]}"; do
        local safe_name="${entry%%|*}"
        local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
        local scores_file="$auditor_out_dir/${safe_name}.scores.json"

        printf '\n\n' >> "$COMBINED_FEEDBACK"
        cat "$feedback_file" >> "$COMBINED_FEEDBACK"

        local scores
        scores=$(cat "$scores_file")
        COMBINED_SCORES=$(merge_scores "$COMBINED_SCORES" "$scores")
        record_passing_items "$scores"
    done

    echo "  All auditors complete ($total new + $resumed resumed)." >&2
}

# Run the enhancement agent for a level.
# Appends enhancement suggestions to $COMBINED_FEEDBACK.
run_enhancement() {
    local level="$1"
    shift
    local context_args=("$@")

    local enhance_prompt
    case "$level" in
        novel_plan)   enhance_prompt="$PROJECT_DIR/prompts/enhance-novel-plan.md" ;;
        chapter_plan) enhance_prompt="$PROJECT_DIR/prompts/enhance-chapter-plan.md" ;;
        scene)        enhance_prompt="$PROJECT_DIR/prompts/enhance-scene.md" ;;
        *)
            echo "WARNING: No enhancement prompt for level '$level'" >&2
            return
            ;;
    esac

    echo "  Brainstorming enhancements..." >&2

    local enhance_output="$STATE_DIR/current-enhancements.md"

    local filled
    filled=$(python3 "$PROJECT_DIR/fill_template.py" "$enhance_prompt" \
        "${context_args[@]}")

    run_claude_to_file "enhance-${level}" "$filled" "$enhance_output"

    if [[ -f "$enhance_output" && -s "$enhance_output" ]]; then
        printf '\n\n=== ENHANCEMENT OPPORTUNITIES ===\n' >> "$COMBINED_FEEDBACK"
        printf 'The following are not problems to fix, but opportunities to elevate the work.\n' >> "$COMBINED_FEEDBACK"
        printf 'Consider pursuing any that would significantly improve quality without destabilizing what works.\n\n' >> "$COMBINED_FEEDBACK"
        cat "$enhance_output" >> "$COMBINED_FEEDBACK"
    fi
}

# The main audit/refine loop.
# Returns: 0 = passed, 1 = iteration cap reached, 2 = fixer recommended deletion
audit_refine_loop() {
    local level="$1"
    local content_file="$2"
    local fixer_prompt="$3"
    local log_prefix="$4"
    shift 4
    local context_args=("$@")

    local iteration_cap
    iteration_cap=$(get_iteration_cap "$level")

    # Clear per-item pass tracking when starting a new audit target
    local passed_items_file="$STATE_DIR/passed-items.json"
    local saved_audit_target
    saved_audit_target=$(read_state "audit_target")
    if [[ "$saved_audit_target" != "$log_prefix" ]]; then
        rm -f "$passed_items_file"
    fi

    # Resume from saved round if restarting mid-audit for the SAME content
    local round=1
    local saved_round
    saved_round=$(read_state "refinement_round")
    local saved_status
    saved_status=$(read_state "status")

    if [[ "$saved_audit_target" == "$log_prefix" && "$saved_round" != "0" && "$saved_round" != "null" ]]; then
        if [[ "$saved_status" == "fixing" || "$saved_status" == "passed" || "$saved_status" == "cap_reached" ]]; then
            round=$((saved_round + 1))
            echo "Resuming audit from round $round (previous fix completed)" >&2
        elif [[ "$saved_status" == "auditing" ]]; then
            round=$saved_round
            echo "Resuming audit from round $round (re-running interrupted audit)" >&2
        fi
    fi

    update_state "audit_target" "\"$log_prefix\""

    while true; do
        echo "Audit round $round for $log_prefix" >&2
        update_state "refinement_round" "$round"
        update_state "status" '"auditing"'

        # Set context for run_auditors directory structure
        CURRENT_AUDIT_ROUND=$round
        CURRENT_AUDIT_PREFIX=$log_prefix

        # Run auditors — FATAL on any failure (exits the pipeline)
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

        # Run enhancement
        run_enhancement "$level" "${context_args[@]}"

        # Run fixer
        echo "Fixing (round $round)..." >&2
        update_state "status" '"fixing"'

        log_snapshot "pre-fix-round-${round}" "$content_file"

        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
            "${context_args[@]}" \
            "audit_feedback=$COMBINED_FEEDBACK")

        run_claude_to_file "fix-${level}-round-${round}" "$assembled" "$content_file"

        # Check for deletion recommendation
        if [[ -f "$content_file" ]] && head -5 "$content_file" | grep -q "^RECOMMENDATION: DELETE"; then
            echo "FIXER RECOMMENDS DELETION" >&2
            cp "$content_file" "$STATE_DIR/delete-recommendation.txt"
            return 2
        fi

        # Verify fixer produced output
        if [[ ! -f "$content_file" || ! -s "$content_file" ]]; then
            echo "FATAL: Fixer produced no output for round $round. Stopping pipeline." >&2
            local snapshot_dir="$LOG_DIR/snapshots"
            local latest_snapshot
            latest_snapshot=$(ls -t "$snapshot_dir"/*"$(basename "$content_file")" 2>/dev/null | head -1)
            if [[ -n "$latest_snapshot" ]]; then
                cp "$latest_snapshot" "$content_file"
                echo "  Restored from snapshot: $latest_snapshot" >&2
            fi
            exit 1
        fi

        round=$((round + 1))
    done
}
