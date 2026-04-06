#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

source lib/config.sh
source lib/state.sh
source lib/scoring.sh
source lib/audit.sh

# ── Prerequisites ──────────────────────────────────────────────

for cmd in claude yq jq python3; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "FATAL: Required command not found: $cmd" >&2
        exit 1
    fi
done

if [[ ! -f "premise.md" ]]; then
    echo "FATAL: premise.md not found. Create it with your story premise." >&2
    exit 1
fi

if [[ ! -f "auditor-settings.yaml" ]]; then
    echo "FATAL: auditor-settings.yaml not found. Copy a genre template or create one." >&2
    exit 1
fi

load_config "auditor-settings.yaml"
init_state
mkdir -p output

# ── Helpers ────────────────────────────────────────────────────

# Count chapters in the novel plan by counting ## Chapter N headers
count_chapters() {
    grep -c '^## Chapter [0-9]' output/novel-plan.md
}

# Count scenes in a chapter plan by counting ## Scene N headers
count_scenes() {
    local plan_file="$1"
    grep -c '^## Scene [0-9]' "$plan_file"
}

# Extract one scene's plan section from the chapter plan
extract_scene_plan() {
    local plan_file="$1"
    local scene_num="$2"
    python3 -c "
import re, sys
text = open(sys.argv[1]).read()
pattern = r'(## Scene ' + sys.argv[2] + r':.*?)(?=## Scene \d+:|$)'
match = re.search(pattern, text, re.DOTALL)
if match:
    print(match.group(1).strip())
else:
    print(f'FATAL: Scene {sys.argv[2]} not found in {sys.argv[1]}', file=sys.stderr)
    sys.exit(1)
" "$plan_file" "$scene_num"
}

# Build a summary of completed chapters for context
build_completed_summary() {
    local up_to_ch="$1"
    for ((c=1; c<=up_to_ch; c++)); do
        local dir
        dir=$(printf "output/chapters/%02d" "$c")
        if [[ -d "$dir" && -f "$dir/chapter-plan.md" ]]; then
            printf '\n## Chapter %d (COMPLETED)\n' "$c"
            cat "$dir/chapter-plan.md"
        fi
    done
}

# Build the concatenated preceding scenes for the current chapter
build_preceding_scenes() {
    local ch_dir="$1"
    local up_to_scene="$2"
    for ((s=1; s<up_to_scene; s++)); do
        local sf="$ch_dir/scene-$(printf '%02d' "$s").md"
        if [[ -f "$sf" ]]; then
            printf '\n\n--- Scene %d ---\n' "$s"
            cat "$sf"
        fi
    done
}

# Build all completed prose for context collection
build_all_completed_prose() {
    local up_to_ch="$1"
    for ((c=1; c<up_to_ch; c++)); do
        local dir
        dir=$(printf "output/chapters/%02d" "$c")
        for sf in "$dir"/scene-*.md; do
            [[ -f "$sf" ]] && cat "$sf" && echo ""
        done
    done
}

# Run a prompt through claude. Args: assembled prompt text
run_claude() {
    echo "$1" | claude -p - --output-format text
}

# ── Phase 1: Novel Planning ───────────────────────────────────

phase_novel_planning() {
    echo "=== Phase 1: Novel Planning ===" >&2
    update_state "phase" '"novel_planning"'

    if [[ ! -f "output/novel-plan.md" ]]; then
        echo "Creating novel plan..." >&2
        local assembled
        assembled=$(python3 fill_template.py prompts/plan-novel.md \
            "premise=premise.md")
        run_claude "$assembled" > output/novel-plan.md
    fi

    echo "Auditing novel plan..." >&2
    audit_refine_loop "novel_plan" "output/novel-plan.md" \
        "prompts/fix-novel-plan.md" "novel-plan" \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md"

    echo "Novel plan complete." >&2
}

# ── Phase 2: Chapter Planning + Scene Authoring ────────────────

process_chapters() {
    local chapter_count
    chapter_count=$(count_chapters)

    local start_ch
    start_ch=$(read_state "chapter")
    [[ "$start_ch" == "0" || "$start_ch" == "null" ]] && start_ch=1

    for ((ch=start_ch; ch<=chapter_count; ch++)); do
        echo "=== Chapter $ch of $chapter_count ===" >&2
        update_state "chapter" "$ch"

        local ch_dir
        ch_dir=$(printf "output/chapters/%02d" "$ch")
        mkdir -p "$ch_dir"

        # Plan chapter
        plan_one_chapter "$ch" "$ch_dir"

        # Author scenes
        author_chapter_scenes "$ch" "$ch_dir"

        # Backtrack: re-evaluate novel plan after chapter completion
        run_backtrack_novel "$ch"

        # Re-count chapters in case backtracking added/removed some
        chapter_count=$(count_chapters)

        # Reset scene counter for next chapter
        update_state "scene" "0"
    done
}

plan_one_chapter() {
    local ch="$1"
    local ch_dir="$2"
    local plan_file="$ch_dir/chapter-plan.md"

    update_state "phase" '"chapter_planning"'
    update_state "scene" "0"

    if [[ ! -f "$plan_file" ]]; then
        echo "Planning chapter $ch..." >&2

        # Build completed chapters summary if not the first chapter
        local summary_file="$STATE_DIR/completed-summary.txt"
        if [[ "$ch" -gt 1 ]]; then
            build_completed_summary "$((ch - 1))" > "$summary_file"
        else
            echo "(No prior chapters)" > "$summary_file"
        fi

        local assembled
        assembled=$(python3 fill_template.py prompts/plan-chapter.md \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_number=$ch" \
            "completed_chapters_summary=$summary_file")
        run_claude "$assembled" > "$plan_file"
    fi

    echo "Auditing chapter $ch plan..." >&2
    audit_refine_loop "chapter_plan" "$plan_file" \
        "prompts/fix-chapter-plan.md" "ch$(printf '%02d' "$ch")-plan" \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$plan_file"
}

author_chapter_scenes() {
    local ch="$1"
    local ch_dir="$2"
    local plan_file="$ch_dir/chapter-plan.md"

    update_state "phase" '"scene_authoring"'

    local scene_count
    scene_count=$(count_scenes "$plan_file")

    local start_sc
    start_sc=$(read_state "scene")
    [[ "$start_sc" == "0" || "$start_sc" == "null" ]] && start_sc=1

    for ((sc=start_sc; sc<=scene_count; sc++)); do
        echo "  Scene $sc of $scene_count" >&2
        update_state "scene" "$sc"

        local scene_file="$ch_dir/scene-$(printf '%02d' "$sc").md"
        local context_file="$ch_dir/scene-$(printf '%02d' "$sc")-context.md"

        # Collect context from prior chapters
        if [[ ! -f "$context_file" ]]; then
            collect_scene_context "$ch" "$sc" "$ch_dir" "$context_file" "$plan_file"
        fi

        # Build preceding scenes within this chapter
        local preceding_file="$STATE_DIR/preceding-scenes.txt"
        build_preceding_scenes "$ch_dir" "$sc" > "$preceding_file"

        # Extract this scene's plan
        local scene_plan_file="$STATE_DIR/scene-plan.txt"
        extract_scene_plan "$plan_file" "$sc" > "$scene_plan_file"

        # Author scene
        if [[ ! -f "$scene_file" ]]; then
            echo "  Writing scene $sc..." >&2
            local assembled
            assembled=$(python3 fill_template.py prompts/author-scene.md \
                "premise=premise.md" \
                "novel_plan=output/novel-plan.md" \
                "chapter_plan=$plan_file" \
                "relevant_context=$context_file" \
                "preceding_scenes=$preceding_file" \
                "scene_plan=$scene_plan_file" \
                "chapter_number=$ch" \
                "scene_number=$sc")
            run_claude "$assembled" > "$scene_file"
        fi

        # Audit/refine scene
        echo "  Auditing scene $sc..." >&2
        local audit_result=0
        audit_refine_loop "scene" "$scene_file" \
            "prompts/fix-scene.md" "ch$(printf '%02d' "$ch")-scene-$(printf '%02d' "$sc")" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_plan=$plan_file" \
            "relevant_context=$context_file" \
            "preceding_scenes=$preceding_file" \
            "scene=$scene_file" || audit_result=$?

        if [[ "$audit_result" -eq 2 ]]; then
            echo "  Scene $sc: fixer recommended deletion" >&2
            rm -f "$scene_file" "$context_file"
            # Backtrack chapter plan to adjust remaining scenes
            run_backtrack_chapter "$ch" "$ch_dir"
            scene_count=$(count_scenes "$plan_file")
            continue
        fi

        # Backtrack: re-evaluate chapter plan after each scene
        run_backtrack_chapter "$ch" "$ch_dir"

        # Scene count may have changed
        scene_count=$(count_scenes "$plan_file")
    done
}

collect_scene_context() {
    local ch="$1"
    local sc="$2"
    local ch_dir="$3"
    local output_file="$4"
    local plan_file="$5"

    if [[ "$ch" -le 1 ]]; then
        echo "# No prior chapters — this is Chapter 1" > "$output_file"
        return
    fi

    echo "  Collecting context for scene $sc..." >&2

    local prose_file="$STATE_DIR/all-completed-prose.txt"
    build_all_completed_prose "$ch" > "$prose_file"

    local scene_plan_file="$STATE_DIR/upcoming-scene-plan.txt"
    extract_scene_plan "$plan_file" "$sc" > "$scene_plan_file"

    local assembled
    assembled=$(python3 fill_template.py prompts/collect-context.md \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$plan_file" \
        "upcoming_scene_plan=$scene_plan_file" \
        "completed_content=$prose_file")
    run_claude "$assembled" > "$output_file"
}

run_backtrack_chapter() {
    local ch="$1"
    local ch_dir="$2"

    echo "  Backtracking: evaluating chapter plan..." >&2

    local scenes_file="$STATE_DIR/completed-scenes-bt.txt"
    local has_scenes=false
    > "$scenes_file"
    for sf in "$ch_dir"/scene-*.md; do
        [[ -f "$sf" ]] && cat "$sf" >> "$scenes_file" && echo "" >> "$scenes_file" && has_scenes=true
    done

    if [[ "$has_scenes" == "false" ]]; then
        return  # No scenes yet, nothing to backtrack on
    fi

    local assembled
    assembled=$(python3 fill_template.py prompts/backtrack-chapter.md \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "chapter_plan=$ch_dir/chapter-plan.md" \
        "completed_scenes=$scenes_file")

    local result
    result=$(run_claude "$assembled")

    if ! echo "$result" | head -1 | grep -q "^NO_CHANGE"; then
        echo "  Chapter plan revised by backtracking" >&2
        echo "$result" > "$ch_dir/chapter-plan.md"

        # Audit the revised plan
        audit_refine_loop "chapter_plan" "$ch_dir/chapter-plan.md" \
            "prompts/fix-chapter-plan.md" "ch$(printf '%02d' "$ch")-plan-bt" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md" \
            "chapter_plan=$ch_dir/chapter-plan.md"
    fi
}

run_backtrack_novel() {
    local ch="$1"

    echo "Backtracking: evaluating novel plan..." >&2

    local summary_file="$STATE_DIR/completed-summary-bt.txt"
    build_completed_summary "$ch" > "$summary_file"

    local assembled
    assembled=$(python3 fill_template.py prompts/backtrack-novel.md \
        "premise=premise.md" \
        "novel_plan=output/novel-plan.md" \
        "completed_chapters_summary=$summary_file")

    local result
    result=$(run_claude "$assembled")

    if ! echo "$result" | head -1 | grep -q "^NO_CHANGE"; then
        echo "Novel plan revised by backtracking" >&2
        echo "$result" > output/novel-plan.md

        # Audit the revised plan
        audit_refine_loop "novel_plan" "output/novel-plan.md" \
            "prompts/fix-novel-plan.md" "novel-plan-bt-ch$(printf '%02d' "$ch")" \
            "premise=premise.md" \
            "novel_plan=output/novel-plan.md"
    fi
}

# ── Main ───────────────────────────────────────────────────────

main() {
    echo "Fiction Pipeline starting at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >&2

    local current_phase
    current_phase=$(read_state "phase")

    case "$current_phase" in
        novel_planning|starting|null)
            phase_novel_planning
            process_chapters
            ;;
        chapter_planning|scene_authoring)
            # Resume from where we left off
            process_chapters
            ;;
        *)
            echo "FATAL: Unknown phase: $current_phase" >&2
            exit 1
            ;;
    esac

    echo "=== Pipeline complete at $(date -u +"%Y-%m-%dT%H:%M:%SZ") ===" >&2
}

main "$@"
