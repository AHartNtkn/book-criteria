#!/bin/bash
# Show current pipeline status. Run anytime to see what's happening.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

STATE_DIR="state"
source lib/progress.sh

echo "=== Pipeline State ==="
if [[ -f "$STATE_DIR/progress.json" ]]; then
    cat "$STATE_DIR/progress.json"
else
    echo "(no progress.json)"
fi

echo ""
echo "=== Output Files ==="
if [[ -f "output/synthesized-premise.md" ]]; then
    echo "✓ Synthesized premise ($(wc -c < output/synthesized-premise.md) bytes)"
else
    echo "○ Synthesized premise (not yet)"
fi

if [[ -f "output/novel-plan.md" ]]; then
    echo "✓ Novel plan ($(wc -c < output/novel-plan.md) bytes)"
else
    echo "○ Novel plan (not yet)"
fi

for ch_dir in output/chapters/*/; do
    [[ -d "$ch_dir" ]] || continue
    ch=$(basename "$ch_dir")
    plan_status="○"
    [[ -f "$ch_dir/chapter-plan.md" ]] && plan_status="✓"
    scene_count=$(ls "$ch_dir"/scene-*.md 2>/dev/null | wc -l)
    echo "  Chapter $ch: plan=$plan_status scenes=$scene_count"
done

echo ""
echo "=== Brainstorming ==="
premise_ideas=$(ls output/brainstorm/premise/idea-*.md 2>/dev/null | wc -l)
echo "Premise ideas: $premise_ideas / 10"
for ch_dir in output/brainstorm/chapters/*/; do
    [[ -d "$ch_dir" ]] || continue
    ch=$(basename "$ch_dir")
    ch_ideas=$(ls "$ch_dir"/idea-*.md 2>/dev/null | wc -l)
    echo "Chapter $ch ideas: $ch_ideas / 5"
done

echo ""
echo "=== Step Status ==="
init_progress
show_progress

echo ""
echo "=== Processes ==="
if pgrep -f "bash run.sh" > /dev/null 2>&1; then
    echo "Pipeline is RUNNING (PIDs: $(pgrep -f 'bash run.sh' | tr '\n' ' '))"
    claude_count=$(pgrep -f "claude -p" 2>/dev/null | wc -l)
    echo "Active claude calls: $claude_count"
else
    echo "Pipeline is NOT RUNNING"
fi
