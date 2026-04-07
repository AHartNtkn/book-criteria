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

# Run all auditors for a level using dynamic prompt assembly.
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

    local auditor_prompt_file="$STATE_DIR/current-auditor-prompt.md"

    while IFS= read -r auditor_name; do
        [[ -z "$auditor_name" ]] && continue

        # Assemble the auditor prompt dynamically
        # assemble_auditor.py reads auditor-config.yaml + criteria-definitions.yaml + criteria-settings.yaml
        # and outputs a prompt with context placeholders ({scene}, {chapter_plan}, etc.)
        if ! python3 "$PROJECT_DIR/assemble_auditor.py" "$auditor_name" \
                > "$auditor_prompt_file" 2>/dev/null; then
            echo "WARNING: Could not assemble auditor '$auditor_name'" >&2
            continue
        fi

        # Check if auditor has any active criteria/sentinels
        if grep -q "No active criteria" "$auditor_prompt_file" && \
           grep -q "No active sentinels" "$auditor_prompt_file"; then
            continue  # Skip empty auditors (all criteria toggled off)
        fi

        echo "  Auditing: $auditor_name" >&2

        # Fill context placeholders with actual content
        local filled
        filled=$(python3 "$PROJECT_DIR/fill_template.py" "$auditor_prompt_file" \
            "${context_args[@]}")

        # Call claude
        local output
        output=$(echo "$filled" | claude -p - --output-format text)

        # Append to combined feedback
        printf '\n\n--- Auditor: %s ---\n%s' "$auditor_name" "$output" >> "$COMBINED_FEEDBACK"

        # Extract and merge scores
        local scores
        scores=$(echo "$output" | extract_scores) || {
            echo "WARNING: Could not extract scores from auditor '$auditor_name'" >&2
            continue
        }
        COMBINED_SCORES=$(merge_scores "$COMBINED_SCORES" "$scores")

    done <<< "$auditor_names"
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
    enhancements=$(echo "$filled" | claude -p - --output-format text)

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

        # Run enhancement brainstorming (appends to COMBINED_FEEDBACK)
        run_enhancement "$level" "${context_args[@]}"

        # Run fixer with audit feedback + enhancement suggestions
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
