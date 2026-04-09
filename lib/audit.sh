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
    local passed_items_file="$CURRENT_PASSED_ITEMS_FILE"
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
    local passed_items_file="$CURRENT_PASSED_ITEMS_FILE"

    python3 -c "
import json, sys, os

scores = json.loads(sys.stdin.read())
passed_file = sys.argv[1]

existing = set()
if os.path.isfile(passed_file):
    with open(passed_file) as f:
        existing = set(json.load(f))

for name, data in scores.get('criteria', {}).items():
    score = data.get('score', 0)
    # N/A counts as passed (not applicable = no action needed)
    if score == 'N/A' or score == 'n/a':
        existing.add(name)
    elif isinstance(score, (int, float)) and score >= 4:
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

    # Phase 2: Run auditors in parallel, maintaining AUDITOR_BATCH_SIZE concurrent.
    # Uses `wait -n` to wait for any one job to finish before launching next.
    # Fail-fast: if any auditor fails, kill remaining jobs and exit immediately.
    # Completed (OK) auditors survive in status files for resume on restart.
    local running=0
    for entry in "${active_auditors[@]}"; do
        if [[ "$running" -ge "$AUDITOR_BATCH_SIZE" ]]; then
            local wait_rc=0
            wait -n || wait_rc=$?
            running=$((running - 1))
            if [[ "$wait_rc" -ne 0 ]]; then
                echo "FATAL: An auditor failed. Killing remaining jobs." >&2
                kill $(jobs -p) 2>/dev/null
                wait 2>/dev/null
                # Report which auditor(s) failed
                for chk in "${active_auditors[@]}"; do
                    local chk_name="${chk%%|*}"
                    local chk_display="${chk#*|}"
                    local chk_status="$auditor_out_dir/${chk_name}.status"
                    if [[ -f "$chk_status" && "$(cat "$chk_status")" != "OK" ]]; then
                        echo "FATAL: Auditor '$chk_display' failed: $(cat "$chk_status")" >&2
                    fi
                done
                exit 1
            fi
        fi

        local safe_name="${entry%%|*}"
        local auditor_name="${entry#*|}"
        local filled_file="$auditor_out_dir/${safe_name}.filled.md"
        local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
        local scores_file="$auditor_out_dir/${safe_name}.scores.json"
        local status_file="$auditor_out_dir/${safe_name}.status"

        echo "    Launched: $auditor_name" >&2
        (
            # Write status on exit — but only if we weren't killed by a signal
            # (fail-fast kills siblings; they shouldn't write spurious status)
            _auditor_killed=0
            trap '_auditor_killed=1' TERM INT
            trap 'if [[ "$_auditor_killed" -eq 0 && ! -f "$status_file" ]]; then echo "CRASHED: unexpected exit" > "$status_file"; fi' EXIT

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
                $(get_model_flag auditor) \
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
        running=$((running + 1))
    done
    # Drain remaining jobs, fail-fast on any failure
    while [[ "$running" -gt 0 ]]; do
        local wait_rc=0
        wait -n || wait_rc=$?
        running=$((running - 1))
        if [[ "$wait_rc" -ne 0 ]]; then
            echo "FATAL: An auditor failed. Killing remaining jobs." >&2
            kill $(jobs -p) 2>/dev/null
            wait 2>/dev/null
            for chk in "${active_auditors[@]}"; do
                local chk_name="${chk%%|*}"
                local chk_display="${chk#*|}"
                local chk_status="$auditor_out_dir/${chk_name}.status"
                if [[ -f "$chk_status" && "$(cat "$chk_status")" != "OK" ]]; then
                    echo "FATAL: Auditor '$chk_display' failed: $(cat "$chk_status")" >&2
                fi
            done
            exit 1
        fi
    done

    # All auditors succeeded — merge results (both newly run and resumed)
    # Concatenate feedback files
    for fb in "$auditor_out_dir"/*.feedback.txt; do
        if [[ -f "$fb" && -s "$fb" ]]; then
            printf '\n\n' >> "$COMBINED_FEEDBACK"
            cat "$fb" >> "$COMBINED_FEEDBACK"
        fi
    done

    # Merge all score files in one Python call (avoids bash JSON corruption)
    COMBINED_SCORES=$(python3 -c "
import json, os, sys, glob

scores_dir = sys.argv[1]
merged = {'criteria': {}, 'sentinels': {}}
for f in sorted(glob.glob(os.path.join(scores_dir, '*.scores.json'))):
    with open(f) as fh:
        data = json.load(fh)
    merged['criteria'].update(data.get('criteria', {}))
    merged['sentinels'].update(data.get('sentinels', {}))
print(json.dumps(merged))
" "$auditor_out_dir")

    # Record passing items from the merged scores
    record_passing_items "$COMBINED_SCORES"

    echo "  All auditors complete ($total new + $resumed resumed)." >&2
}

# Run the enhancement agent for a level.
# Writes to $STATE_DIR/current-enhancements.md (not appended to audit feedback).
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

    run_claude_to_file "enhance-${level}" "$filled" "$enhance_output" "$(get_model_flag enhancement)"
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
    if [[ "${BACKTRACK_MODE:-0}" == "1" ]]; then
        iteration_cap=$(get_iteration_cap "backtrack")
        BACKTRACK_MODE=0  # Reset so nested calls don't inherit
    else
        iteration_cap=$(get_iteration_cap "$level")
    fi

    # Skip if this target already completed in a previous session.
    local logged_rounds
    logged_rounds=$(ls "$STATE_DIR/audit-logs/${log_prefix}-round-"*.json 2>/dev/null | wc -l)
    if [[ "$logged_rounds" -gt 0 ]]; then
        if [[ "$iteration_cap" -gt 0 && "$logged_rounds" -ge "$iteration_cap" ]]; then
            echo "Already completed $logged_rounds rounds (cap: $iteration_cap) for $log_prefix. Skipping." >&2
            return 0
        fi
        local last_log
        last_log=$(ls -t "$STATE_DIR/audit-logs/${log_prefix}-round-"*.json 2>/dev/null | head -1)
        local prev_criteria_ok prev_sentinel_ok
        prev_criteria_ok=$(check_criteria_passing "$(cat "$last_log")" 4 2>/dev/null)
        prev_sentinel_ok=$(check_sentinels_passing "$(cat "$last_log")" 2>/dev/null)
        if [[ "$prev_criteria_ok" == "PASS" && "$prev_sentinel_ok" == "PASS" ]]; then
            echo "Already passed for $log_prefix. Skipping." >&2
            return 0
        fi
    fi

    # Per-target passed-items file — each audit target has its own, nothing is ever cleared
    CURRENT_PASSED_ITEMS_FILE="$STATE_DIR/passed-items-${log_prefix}.json"

    # Resume from saved round if restarting mid-audit for the SAME content
    local round=1
    local saved_audit_target
    saved_audit_target=$(read_state "audit_target")
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
        # Check iteration cap at the start — if we've done enough rounds, stop
        if [[ "$iteration_cap" -gt 0 ]] && [[ "$round" -gt "$iteration_cap" ]]; then
            echo "Iteration cap ($iteration_cap) reached. Moving on." >&2
            update_state "status" '"cap_reached"'
            return 0
        fi

        echo "Audit round $round for $log_prefix" >&2
        update_state "refinement_round" "$round"
        update_state "status" '"auditing"'

        # Set context for run_auditors directory structure
        CURRENT_AUDIT_ROUND=$round
        CURRENT_AUDIT_PREFIX=$log_prefix

        # Run auditors — FATAL on any failure (exits the pipeline)
        run_auditors "$level" "$content_file" "${context_args[@]}"
        log_scores "$log_prefix" "$round" "$COMBINED_SCORES"

        # Consolidate audit feedback (deduplicate across auditors)
        echo "  Consolidating audit feedback..." >&2
        local auditor_out_dir="$STATE_DIR/auditor-results/${CURRENT_AUDIT_PREFIX}/round-${CURRENT_AUDIT_ROUND}"
        local consolidated_feedback="$auditor_out_dir/consolidated-feedback.md"

        # Build list of feedback file paths for the consolidator to read
        local feedback_list_file="$auditor_out_dir/feedback-file-list.txt"
        > "$feedback_list_file"
        for fb in "$auditor_out_dir"/*.feedback.txt; do
            if [[ -f "$fb" && -s "$fb" ]]; then
                echo "- $fb" >> "$feedback_list_file"
            fi
        done

        local consolidate_prompt
        consolidate_prompt=$(python3 "$PROJECT_DIR/fill_template.py" \
            "$PROJECT_DIR/prompts/consolidate-feedback.md" \
            "feedback_file_list=$feedback_list_file")

        # Append file-writing instruction
        consolidate_prompt="${consolidate_prompt}

---
IMPORTANT: Write your consolidated feedback to the file: ${consolidated_feedback}
Use the Write tool to create this file. Read each feedback file listed above using the Read tool."

        # Consolidator gets Read+Write tools to access feedback files and write output
        echo "$consolidate_prompt" | claude -p - \
            --tools "Read,Write" \
            --dangerously-skip-permissions \
            $(get_model_flag consolidation) \
            --output-format text \
            > "$auditor_out_dir/consolidate-stdout.txt" 2>&1

        # Also log it
        step_start "consolidate-feedback-round-${round}" "Consolidating audit feedback"
        if [[ -f "$consolidated_feedback" && -s "$consolidated_feedback" ]]; then
            step_done "consolidate-feedback-round-${round}" "$(wc -c < "$consolidated_feedback") bytes"
        else
            step_failed "consolidate-feedback-round-${round}" "no output"
        fi

        if [[ ! -f "$consolidated_feedback" || ! -s "$consolidated_feedback" ]]; then
            echo "FATAL: Consolidation failed — no output produced. Stopping pipeline." >&2
            exit 1
        fi

        # Check pass conditions
        local criteria_ok sentinel_ok
        criteria_ok=$(check_criteria_passing "$COMBINED_SCORES" 4 2>/dev/null)
        sentinel_ok=$(check_sentinels_passing "$COMBINED_SCORES" 2>/dev/null)

        if [[ "$criteria_ok" == "PASS" ]] && [[ "$sentinel_ok" == "PASS" ]]; then
            echo "PASS: All criteria >= 4, all sentinels pass (round $round)" >&2
            update_state "status" '"passed"'
            return 0
        fi

        # Run enhancement (separate from audit feedback)
        run_enhancement "$level" "${context_args[@]}"

        # Append enhancement suggestions to consolidated feedback for the fixer
        if [[ -f "$STATE_DIR/current-enhancements.md" && -s "$STATE_DIR/current-enhancements.md" ]]; then
            printf '\n\n=== ENHANCEMENT OPPORTUNITIES ===\n' >> "$consolidated_feedback"
            printf 'The following are not problems to fix, but opportunities to elevate the work.\n' >> "$consolidated_feedback"
            printf 'Consider pursuing any that would significantly improve quality without destabilizing what works.\n\n' >> "$consolidated_feedback"
            cat "$STATE_DIR/current-enhancements.md" >> "$consolidated_feedback"
        fi

        # Run fixer with consolidated audit feedback + enhancement suggestions
        echo "Fixing (round $round)..." >&2
        update_state "status" '"fixing"'

        log_snapshot "pre-fix-round-${round}" "$content_file"

        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
            "${context_args[@]}" \
            "audit_feedback=$consolidated_feedback")

        run_claude_to_file "fix-${level}-round-${round}" "$assembled" "$content_file" "$(get_model_flag fixing)"

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
