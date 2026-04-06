#!/bin/bash
# Audit/refine loop for the fiction pipeline.
# Requires: claude CLI, lib/config.sh, lib/state.sh, lib/scoring.sh
#
# PROJECT_DIR must be set before sourcing.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

# Run all active auditors for a level.
# Sets: COMBINED_FEEDBACK (file path), COMBINED_SCORES (JSON string)
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        remaining args = KEY=FILE pairs for context assembly
run_auditors() {
    local level="$1"
    local content_file="$2"
    shift 2
    local context_args=("$@" "content=$content_file")

    local auditors
    auditors=$(get_active_auditors "$level")

    COMBINED_FEEDBACK="$STATE_DIR/current-feedback.txt"
    COMBINED_SCORES='{"criteria":{},"sentinels":{}}'
    > "$COMBINED_FEEDBACK"

    while IFS= read -r auditor; do
        [[ -z "$auditor" ]] && continue
        local auditor_file="$PROJECT_DIR/auditors/${auditor}.md"

        if [[ ! -f "$auditor_file" ]]; then
            echo "FATAL: Auditor prompt not found: $auditor_file" >&2
            exit 1
        fi

        echo "  Auditing: $auditor" >&2

        # Assemble prompt with context
        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$auditor_file" "${context_args[@]}")

        # Call claude
        local output
        output=$(echo "$assembled" | claude -p - --output-format text)

        # Append to combined feedback
        printf '\n\n--- Auditor: %s ---\n%s' "$auditor" "$output" >> "$COMBINED_FEEDBACK"

        # Extract and merge scores
        local scores
        scores=$(echo "$output" | extract_scores) || {
            echo "WARNING: Could not extract scores from auditor $auditor" >&2
            continue
        }
        COMBINED_SCORES=$(merge_scores "$COMBINED_SCORES" "$scores")

    done <<< "$auditors"
}

# The main audit/refine loop.
# Returns: 0 = passed, 1 = iteration cap reached, 2 = fixer recommended deletion
#
# Args: $1 = level (novel_plan|chapter_plan|scene)
#        $2 = content file being refined
#        $3 = fixer prompt file
#        $4 = log prefix for audit logs
#        remaining args = KEY=FILE pairs for context assembly
audit_refine_loop() {
    local level="$1"
    local content_file="$2"
    local fixer_prompt="$3"
    local log_prefix="$4"
    shift 4
    local context_args=("$@")

    local iteration_cap
    iteration_cap=$(get_iteration_cap)
    local round=1

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

        # Run fixer
        echo "Fixing (round $round)..." >&2
        update_state "status" '"fixing"'

        local assembled
        assembled=$(python3 "$PROJECT_DIR/fill_template.py" "$fixer_prompt" \
            "${context_args[@]}" \
            "audit_feedback=$COMBINED_FEEDBACK")

        local fixed_output
        fixed_output=$(echo "$assembled" | claude -p - --output-format text)

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
