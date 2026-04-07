#!/bin/bash
# Audit/refine loop for the fiction pipeline.
# Requires: claude CLI, assemble_auditor.py, fill_template.py,
#           lib/config.sh, lib/state.sh, lib/scoring.sh
#
# PROJECT_DIR must be set before sourcing.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Get list of auditor names for a given pipeline level from auditor-config.yaml
get_auditors_for_level() {
    local level="$1"
    yq -r ".auditors[] | select(.level == \"$level\") | .name" \
        "$PROJECT_DIR/auditor-config.yaml"
}

# Maximum parallel auditor calls per batch
AUDITOR_BATCH_SIZE=5

# Run all auditors for a level in parallel using dynamic prompt assembly.
# Sets: COMBINED_FEEDBACK (file path), COMBINED_SCORES (JSON string)
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        $2 = content file being audited
#        remaining args = KEY=FILE pairs for context (all available context for this level)
run_auditors() {
    local level="$1"
    local content_file="$2"
    shift 2
    local context_args=("$@" "content=$content_file")

    local auditor_names
    auditor_names=$(get_auditors_for_level "$level")

    COMBINED_FEEDBACK="$STATE_DIR/current-feedback.txt"
    COMBINED_SCORES='{"criteria":{},"sentinels":{}}'
    > "$COMBINED_FEEDBACK"

    # Create per-auditor output directory for this round
    local auditor_out_dir="$STATE_DIR/auditor-results"
    rm -rf "$auditor_out_dir"
    mkdir -p "$auditor_out_dir"

    # Phase 1: Assemble prompts and identify active auditors (sequential, fast)
    local active_auditors=()
    while IFS= read -r auditor_name; do
        [[ -z "$auditor_name" ]] && continue

        local safe_name
        safe_name=$(echo "$auditor_name" | tr ' /:' '---' | tr -cd 'a-zA-Z0-9-')
        local prompt_file="$auditor_out_dir/${safe_name}.prompt.md"

        if ! python3 "$PROJECT_DIR/assemble_auditor.py" "$auditor_name" \
                > "$prompt_file" 2>/dev/null; then
            echo "WARNING: Could not assemble auditor '$auditor_name'" >&2
            continue
        fi

        # Skip empty auditors
        if grep -q "No active criteria" "$prompt_file" && \
           grep -q "No active sentinels" "$prompt_file"; then
            continue
        fi

        # Fill context placeholders
        local filled_file="$auditor_out_dir/${safe_name}.filled.md"
        python3 "$PROJECT_DIR/fill_template.py" "$prompt_file" \
            "${context_args[@]}" > "$filled_file"

        active_auditors+=("$safe_name|$auditor_name")
    done <<< "$auditor_names"

    local total=${#active_auditors[@]}
    echo "  Running $total auditors in parallel (batches of $AUDITOR_BATCH_SIZE)..." >&2

    # Phase 2: Run all active auditors in parallel batches
    local batch_count=0
    for entry in "${active_auditors[@]}"; do
        local safe_name="${entry%%|*}"
        local auditor_name="${entry#*|}"
        local filled_file="$auditor_out_dir/${safe_name}.filled.md"
        local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
        local scores_file="$auditor_out_dir/${safe_name}.scores.json"

        (
            step_start "audit-${safe_name}" "Auditor: $auditor_name"

            local output
            output=$(log_call "audit-${safe_name}" "$(cat "$filled_file")")

            # Save feedback
            printf '--- Auditor: %s ---\n%s' "$auditor_name" "$output" > "$feedback_file"

            # Extract scores
            local scores
            scores=$(echo "$output" | extract_scores 2>/dev/null) || {
                echo '{"criteria":{},"sentinels":{}}' > "$scores_file"
                step_failed "audit-${safe_name}" "could not extract scores"
                exit 0
            }
            echo "$scores" > "$scores_file"

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

    # Phase 3: Merge all results (sequential, fast)
    for entry in "${active_auditors[@]}"; do
        local safe_name="${entry%%|*}"
        local feedback_file="$auditor_out_dir/${safe_name}.feedback.txt"
        local scores_file="$auditor_out_dir/${safe_name}.scores.json"

        if [[ -f "$feedback_file" && -s "$feedback_file" ]]; then
            printf '\n\n' >> "$COMBINED_FEEDBACK"
            cat "$feedback_file" >> "$COMBINED_FEEDBACK"
        fi

        if [[ -f "$scores_file" && -s "$scores_file" ]]; then
            local scores
            scores=$(cat "$scores_file")
            COMBINED_SCORES=$(merge_scores "$COMBINED_SCORES" "$scores")
        fi
    done

    echo "  All $total auditors complete." >&2
}

# Run the enhancement agent for a level.
# Appends enhancement suggestions to $COMBINED_FEEDBACK.
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        remaining args = KEY=FILE pairs for context
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

    local filled
    filled=$(python3 "$PROJECT_DIR/fill_template.py" "$enhance_prompt" \
        "${context_args[@]}")

    local enhancements
    enhancements=$(log_call "enhance-${level}" "$filled")

    # Append to combined feedback with clear header
    printf '\n\n=== ENHANCEMENT OPPORTUNITIES ===\n' >> "$COMBINED_FEEDBACK"
    printf 'The following are not problems to fix, but opportunities to elevate the work.\n' >> "$COMBINED_FEEDBACK"
    printf 'Consider pursuing any that would significantly improve quality without destabilizing what works.\n\n' >> "$COMBINED_FEEDBACK"
    printf '%s' "$enhancements" >> "$COMBINED_FEEDBACK"
}

# The main audit/refine loop.
# Returns: 0 = passed, 1 = iteration cap reached, 2 = fixer recommended deletion
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        $2 = content file being refined
#        $3 = fixer prompt file
#        $4 = log prefix for audit logs
#        remaining args = KEY=FILE pairs for context
audit_refine_loop() {
    local level="$1"
    local content_file="$2"
    local fixer_prompt="$3"
    local log_prefix="$4"
    shift 4
    local context_args=("$@")

    local iteration_cap
    iteration_cap=$(get_iteration_cap "$level")

    # Resume from saved round if restarting mid-audit for the SAME content
    local round=1
    local saved_round
    saved_round=$(read_state "refinement_round")
    local saved_status
    saved_status=$(read_state "status")
    local saved_audit_target
    saved_audit_target=$(read_state "audit_target")

    if [[ "$saved_audit_target" == "$log_prefix" && "$saved_round" != "0" && "$saved_round" != "null" ]]; then
        if [[ "$saved_status" == "fixing" || "$saved_status" == "passed" || "$saved_status" == "cap_reached" ]]; then
            # Crashed after fixing — content file has the fixed version, next round
            round=$((saved_round + 1))
            echo "Resuming audit from round $round (previous fix completed)" >&2
        elif [[ "$saved_status" == "auditing" ]]; then
            # Crashed during auditing — re-run this round
            round=$saved_round
            echo "Resuming audit from round $round (re-running interrupted audit)" >&2
        fi
    fi

    update_state "audit_target" "\"$log_prefix\""

    while true; do
        echo "Audit round $round for $log_prefix" >&2
        update_state "refinement_round" "$round"
        update_state "status" '"auditing"'

        # Run all auditors
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

        # Run enhancement brainstorming (appends to COMBINED_FEEDBACK)
        run_enhancement "$level" "${context_args[@]}"

        # Run fixer with audit feedback + enhancement suggestions
        echo "Fixing (round $round)..." >&2
        update_state "status" '"fixing"'

        # Snapshot the content before fixer overwrites it
        log_snapshot "pre-fix-round-${round}" "$content_file"

        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
            "${context_args[@]}" \
            "audit_feedback=$COMBINED_FEEDBACK")

        local fixed_output
        fixed_output=$(log_call "fix-${level}-round-${round}" "$assembled")

        # Check for deletion recommendation
        if echo "$fixed_output" | head -5 | grep -q "^RECOMMENDATION: DELETE"; then
            echo "FIXER RECOMMENDS DELETION" >&2
            echo "$fixed_output" > "$STATE_DIR/delete-recommendation.txt"
            return 2
        fi

        # Write fixed content
        echo "$fixed_output" > "$content_file"
        round=$((round + 1))
    done
}
