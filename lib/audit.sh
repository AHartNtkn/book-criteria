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
# Args: $1 = output path for the round settings file
generate_round_settings() {
    local output_path="$1"
    local passed_items_file="$STATE_DIR/passed-items.json"
    local base_settings="$PROJECT_DIR/criteria-settings.yaml"

    python3 -c "
import json, yaml, sys, os

output_path = sys.argv[1]
passed_file = sys.argv[2]
base_file = sys.argv[3]

# Load base settings
base = {}
if os.path.isfile(base_file):
    with open(base_file) as f:
        base = yaml.safe_load(f) or {}

# Load passed items
passed = set()
if os.path.isfile(passed_file):
    with open(passed_file) as f:
        passed = set(json.load(f))

# Merge: start with base, then additionally disable passed items
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
# Args: $1 = scores JSON string
record_passing_items() {
    local scores_json="$1"
    local passed_items_file="$STATE_DIR/passed-items.json"

    python3 -c "
import json, sys, os

scores = json.loads(sys.stdin.read())
passed_file = sys.argv[1]

# Load existing passed items
existing = set()
if os.path.isfile(passed_file):
    with open(passed_file) as f:
        existing = set(json.load(f))

# Add newly passing items
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

# Run all auditors for a level in parallel using dynamic prompt assembly.
# Uses round-specific settings that disable previously-passing criteria/sentinels.
# Sets: COMBINED_FEEDBACK (file path), COMBINED_SCORES (JSON string)
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

    COMBINED_FEEDBACK="$STATE_DIR/current-feedback.txt"
    COMBINED_SCORES='{"criteria":{},"sentinels":{}}'
    > "$COMBINED_FEEDBACK"

    # Generate round-specific settings (base settings + disable passed items)
    local round_settings="$STATE_DIR/round-settings.yaml"
    generate_round_settings "$round_settings"

    # Create per-auditor output directory for this round
    local auditor_out_dir="$STATE_DIR/auditor-results"
    rm -rf "$auditor_out_dir"
    mkdir -p "$auditor_out_dir"

    # Phase 1: Assemble prompts and identify active auditors (sequential, fast)
    local active_auditors=()
    local skipped=0
    while IFS= read -r auditor_name; do
        [[ -z "$auditor_name" ]] && continue

        local safe_name
        safe_name=$(echo "$auditor_name" | tr ' /:' '---' | tr -cd 'a-zA-Z0-9-')
        local prompt_file="$auditor_out_dir/${safe_name}.prompt.md"

        # Assemble using round-specific settings (which disable passed items)
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
    if [[ "$skipped" -gt 0 ]]; then
        echo "  Running $total auditors ($skipped skipped — all criteria passed)..." >&2
    else
        echo "  Running $total auditors in parallel (batches of $AUDITOR_BATCH_SIZE)..." >&2
    fi

    if [[ "$total" -eq 0 ]]; then
        echo "  All criteria/sentinels passed in previous rounds." >&2
        return
    fi

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

    # Phase 3: Merge results and record passing items
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

            # Record individual passing criteria/sentinels
            record_passing_items "$scores"
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

        # Run auditors (with per-item pass filtering)
        run_auditors "$level" "$content_file" "${context_args[@]}"
        log_scores "$log_prefix" "$round" "$COMBINED_SCORES"

        # Check pass conditions — if no scores were produced this round
        # (all items passed previously), that's a full pass
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
