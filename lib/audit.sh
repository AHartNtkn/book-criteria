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

# Set by audit_refine_loop before calling run_audit_fix_cycle
CURRENT_AUDIT_ROUND=0
CURRENT_AUDIT_PREFIX=""
CURRENT_PASSED_ITEMS_FILE=""

# Run a single auditor and return its scores.
# Args: $1 = auditor name, $2 = filled prompt file, $3 = output dir
# Sets: AUDITOR_SCORES (JSON string), AUDITOR_FEEDBACK (file path)
# Returns: 0 on success, 1 on failure
run_single_auditor() {
    local auditor_name="$1"
    local filled_file="$2"
    local auditor_out_dir="$3"

    local safe_name
    safe_name=$(echo "$auditor_name" | tr ' /:' '---' | tr -cd 'a-zA-Z0-9-')

    local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
    local scores_file="$auditor_out_dir/${safe_name}.scores.json"
    local status_file="$auditor_out_dir/${safe_name}.status"

    AUDITOR_FEEDBACK="$feedback_file"
    AUDITOR_SCORES=""

    step_start "audit-${safe_name}" "Auditor: $auditor_name"

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
        # Fallback: model wrote to stdout instead of using Write tool
        local stdout_file="$auditor_out_dir/${safe_name}.claude-stdout.txt"
        local stdout_size=0
        [[ -f "$stdout_file" ]] && stdout_size=$(wc -c < "$stdout_file")
        if [[ "$stdout_size" -gt 500 ]] && ! head -1 "$stdout_file" | grep -qi "prompt is too long\|error\|fatal"; then
            cp "$stdout_file" "$feedback_file"
            echo "    (stdout fallback): $auditor_name" >&2
        else
            echo "FAILED: output file not written" > "$status_file"
            echo "    FAILED: $auditor_name — no output (stdout: ${stdout_size} bytes)" >&2
            step_failed "audit-${safe_name}" "output file not written"
            return 1
        fi
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
        return 1
    }
    echo "$scores" > "$scores_file"

    AUDITOR_SCORES="$scores"
    echo "OK" > "$status_file"
    echo "    Done: $auditor_name" >&2
    step_done "audit-${safe_name}" "$(echo "$scores" | python3 -c "
import json,sys
d=json.load(sys.stdin)
nc=len(d.get('criteria',{}))
ns=len(d.get('sentinels',{}))
print(f'{nc} criteria, {ns} sentinels scored')
" 2>/dev/null)"
    return 0
}

# Check if an auditor's scores require a fix (any criteria < 4 or sentinels FAIL)
auditor_needs_fix() {
    local scores_json="$1"
    python3 -c "
import json, sys
scores = json.loads(sys.stdin.read())
needs_fix = False
for name, data in scores.get('criteria', {}).items():
    score = data.get('score', 0)
    if score == 'N/A' or score == 'n/a':
        continue
    if isinstance(score, str):
        try: score = int(score)
        except ValueError: continue
    if score < 4:
        needs_fix = True
        break
if not needs_fix:
    for name, data in scores.get('sentinels', {}).items():
        if data.get('status', 'FAIL') != 'PASS':
            needs_fix = True
            break
print('FIX' if needs_fix else 'PASS')
" <<< "$scores_json"
}

# Run the enhancement agent for a level.
# Args: $1 = level, $2 = output file path, remaining = context key=value pairs
run_enhancement() {
    local level="$1"
    local enhance_output="$2"
    shift 2
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

    local dares_file="$PROJECT_DIR/state/ambition-dares-${level}.txt"

    local filled
    filled=$(python3 "$PROJECT_DIR/fill_template.py" "$enhance_prompt" \
        "${context_args[@]}" \
        "ambition_dares=$dares_file")

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
        local candidate_round="$saved_round"
        if [[ "$saved_status" == "fixed" || "$saved_status" == "passed" || "$saved_status" == "cap_reached" ]]; then
            candidate_round=$((saved_round + 1))
        fi

        # Verify the round directory exists — if state says round N but the
        # directory was deleted, start from round 1 instead of trusting stale state
        local candidate_dir="$STATE_DIR/auditor-results/${log_prefix}/round-${candidate_round}"
        local prev_dir="$STATE_DIR/auditor-results/${log_prefix}/round-${saved_round}"
        if [[ -d "$candidate_dir" || -d "$prev_dir" ]]; then
            round=$candidate_round
            if [[ "$saved_status" == "fixed" || "$saved_status" == "passed" || "$saved_status" == "cap_reached" ]]; then
                echo "Resuming audit from round $round (previous fix completed)" >&2
            else
                echo "Resuming audit from round $round (re-running interrupted round)" >&2
            fi
        else
            echo "Saved state says round $saved_round but no round directories found — starting from round 1" >&2
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

        CURRENT_AUDIT_ROUND=$round
        CURRENT_AUDIT_PREFIX=$log_prefix

        local auditor_out_dir="$STATE_DIR/auditor-results/${log_prefix}/round-${round}"
        mkdir -p "$auditor_out_dir"

        # Use base settings (all active criteria evaluated every round)
        local round_settings="$PROJECT_DIR/criteria-settings.yaml"

        local auditor_names
        auditor_names=$(get_auditors_for_level "$level")

        # Build set of Phase 2 (prose refinement) auditor names from config
        # Everything after "Phase 2: Prose Refinement" comment is prose phase
        local prose_auditors
        prose_auditors=$(python3 -c "
import sys
in_phase2 = False
with open(sys.argv[1]) as f:
    for line in f:
        if 'Phase 2: Prose Refinement' in line:
            in_phase2 = True
            continue
        if in_phase2 and ('Chapter-Plan' in line or 'Novel-Plan' in line or 'chapter_plan' in line or 'novel_plan' in line):
            break
        if in_phase2:
            stripped = line.strip()
            if stripped.startswith('- name:'):
                name = stripped.split('\"')[1] if '\"' in stripped else ''
                if name:
                    print(name)
" "$PROJECT_DIR/auditor-config.yaml" 2>/dev/null)

        local any_fix_applied=0
        local all_passed=1
        local enhancement_applied=0

        # Sequential: for each auditor, audit then fix if needed
        while IFS= read -r auditor_name; do
            [[ -z "$auditor_name" ]] && continue

            local safe_name
            safe_name=$(echo "$auditor_name" | tr ' /:' '---' | tr -cd 'a-zA-Z0-9-')

            # When transitioning from content to prose phase, run enhancement
            local is_prose_auditor=0
            if echo "$prose_auditors" | grep -qF "$auditor_name"; then
                is_prose_auditor=1
            fi
            if [[ "$is_prose_auditor" -eq 1 && "$enhancement_applied" -eq 0 ]]; then
                local auditor_out_dir_for_enhance="$STATE_DIR/auditor-results/${log_prefix}/round-${round}"
                local enhancement_file="$auditor_out_dir_for_enhance/enhancements.md"
                if [[ ! -f "$enhancement_file" || ! -s "$enhancement_file" ]]; then
                    run_enhancement "$level" "$enhancement_file" "${context_args[@]}"
                fi
                if [[ -f "$enhancement_file" && -s "$enhancement_file" ]]; then
                    echo "  Applying enhancements (between content and prose phases)..." >&2
                    log_snapshot "pre-enhance-round-${round}" "$content_file"
                    local enhance_assembled
                    enhance_assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
                        "${context_args[@]}" \
                        "audit_feedback=$enhancement_file")
                    run_claude_to_file "enhance-fix-round-${round}" "$enhance_assembled" "$content_file" "$(get_model_flag fixing)"
                    if grep -qE '^#{1,3} |REVISED|REFINEMENT|^## Scene' "$content_file"; then
                        echo "    Cleaning enhancement output (headers/metadata detected)..." >&2
                        local clean_prompt
                        clean_prompt=$(python3 "$PROJECT_DIR/fill_template.py" \
                            "$PROJECT_DIR/prompts/clean-scene.md" \
                            "raw_scene=$content_file" \
                            "scene_number=$(read_state scene)" \
                            "chapter_number=$(read_state chapter)")
                        run_claude_to_file "clean-enhance-round-${round}" "$clean_prompt" "$content_file" "$(get_model_flag fixing)"
                    fi
                fi
                enhancement_applied=1
            fi

            # Skip if already done in this round (resume)
            local existing_status="$auditor_out_dir/${safe_name}.status"
            if [[ -f "$existing_status" && "$(cat "$existing_status")" == "OK" ]]; then
                echo "    Already done: $auditor_name (resuming)" >&2
                # Still check if it needed a fix (load scores)
                local prev_scores_file="$auditor_out_dir/${safe_name}.scores.json"
                if [[ -f "$prev_scores_file" ]]; then
                    local prev_result
                    prev_result=$(auditor_needs_fix "$(cat "$prev_scores_file")")
                    if [[ "$prev_result" == "FIX" ]]; then
                        all_passed=0
                    fi
                fi
                continue
            fi

            # Assemble auditor prompt
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
                continue
            fi

            # Fill context placeholders (content_file may have been updated by previous fix)
            local filled_file="$auditor_out_dir/${safe_name}.filled.md"
            python3 "$PROJECT_DIR/fill_template.py" "$prompt_file" \
                "${context_args[@]}" "content=$content_file" > "$filled_file"

            # Run the auditor
            echo "  Auditing: $auditor_name" >&2
            if ! run_single_auditor "$auditor_name" "$filled_file" "$auditor_out_dir"; then
                echo "FATAL: Auditor '$auditor_name' failed." >&2
                exit 1
            fi


            # Check if this auditor's scores require a fix
            local fix_needed
            fix_needed=$(auditor_needs_fix "$AUDITOR_SCORES")

            if [[ "$fix_needed" == "FIX" ]]; then
                all_passed=0

                # Select fix prompt based on phase
                local active_fixer="$fixer_prompt"
                if echo "$prose_auditors" | grep -qF "$auditor_name"; then
                    local prose_fixer="${fixer_prompt%.md}-prose.md"
                    if [[ -f "$prose_fixer" ]]; then
                        active_fixer="$prose_fixer"
                        echo "    Fixing (prose): $auditor_name" >&2
                    else
                        echo "    Fixing for: $auditor_name" >&2
                    fi
                else
                    echo "    Fixing for: $auditor_name" >&2
                fi

                log_snapshot "pre-fix-${safe_name}-round-${round}" "$content_file"

                local assembled
                assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$active_fixer" \
                    "${context_args[@]}" \
                    "audit_feedback=$AUDITOR_FEEDBACK")

                run_claude_to_file "fix-${safe_name}-round-${round}" "$assembled" "$content_file" "$(get_model_flag fixing)"

                # Check for deletion recommendation
                if [[ -f "$content_file" ]] && head -5 "$content_file" | grep -q "^RECOMMENDATION: DELETE"; then
                    echo "FIXER RECOMMENDS DELETION" >&2
                    cp "$content_file" "$STATE_DIR/delete-recommendation.txt"
                    return 2
                fi

                # Verify fixer produced output
                if [[ ! -f "$content_file" || ! -s "$content_file" ]]; then
                    echo "FATAL: Fixer produced no output. Stopping pipeline." >&2
                    local snapshot_dir="$LOG_DIR/snapshots"
                    local latest_snapshot
                    latest_snapshot=$(ls -t "$snapshot_dir"/*"$(basename "$content_file")" 2>/dev/null | head -1)
                    if [[ -n "$latest_snapshot" ]]; then
                        cp "$latest_snapshot" "$content_file"
                        echo "  Restored from snapshot: $latest_snapshot" >&2
                    fi
                    exit 1
                fi

                # Clean fix output if it contains headers, metadata, or extra scenes
                if grep -qE '^#{1,3} |REVISED|REFINEMENT|^## Scene' "$content_file"; then
                    echo "    Cleaning fixer output (headers/metadata detected)..." >&2
                    local clean_prompt
                    clean_prompt=$(python3 "$PROJECT_DIR/fill_template.py" \
                        "$PROJECT_DIR/prompts/clean-scene.md" \
                        "raw_scene=$content_file" \
                        "scene_number=$(read_state scene)" \
                        "chapter_number=$(read_state chapter)")
                    run_claude_to_file "clean-${safe_name}-round-${round}" "$clean_prompt" "$content_file" "$(get_model_flag fixing)"
                fi

                any_fix_applied=1

            fi
        done <<< "$auditor_names"

        if [[ "$all_passed" -eq 1 ]]; then
            echo "PASS: All criteria >= 4, all sentinels pass (round $round)" >&2
            update_state "status" '"passed"'
            return 0
        fi

        # If enhancement wasn't applied during the loop (e.g., level has no prose phase),
        # run it now at the end of the round
        if [[ "$enhancement_applied" -eq 0 ]]; then
            local end_enhancement_file="$auditor_out_dir/enhancements.md"
            if [[ ! -f "$end_enhancement_file" || ! -s "$end_enhancement_file" ]]; then
                run_enhancement "$level" "$end_enhancement_file" "${context_args[@]}"
            fi
            if [[ -f "$end_enhancement_file" && -s "$end_enhancement_file" ]]; then
                echo "  Applying enhancements (end of round)..." >&2
                log_snapshot "pre-enhance-round-${round}" "$content_file"
                local enhance_assembled
                enhance_assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
                    "${context_args[@]}" \
                    "audit_feedback=$end_enhancement_file")
                run_claude_to_file "enhance-fix-round-${round}" "$enhance_assembled" "$content_file" "$(get_model_flag fixing)"
            fi
        fi

        update_state "status" '"fixed"'
        round=$((round + 1))
    done
}
