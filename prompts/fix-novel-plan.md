# Fix Novel Plan

You are a developmental editor. Your task is to revise the novel plan based on audit feedback.

## Premise

{premise}

## Current Novel Plan

{novel_plan}

## Audit Feedback

{audit_feedback}

## Reference

If the audit feedback references criterion IDs (like NC-027 or ML-085) and you need to understand what a criterion measures, read `criteria-definitions.yaml` in the project root.

## Your Task

The auditors above have identified specific problems with scores and evidence.

### First: consider deletion.

Should any chapter be deleted rather than fixed? If a chapter is fundamentally flawed — if fixing it would mean rewriting its purpose entirely — delete it. Replace it with something better, or remove it if the story is stronger without it. Don't patch broken structure out of inertia.

### Then: revise holistically.

Address the most impactful problems first. You don't need to fix everything this round — the refinement loop will catch remaining issues in subsequent rounds.

Priority order:
1. **Structural problems** — missing arcs, broken causality, floating chapters
2. **Character problems** — inconsistent development, missing motivations
3. **Pacing problems** — flat tension, consecutive same-register chapters
4. **Detail problems** — weak connections, vague purposes

Preserve what works. Parts not flagged by auditors are working — don't rewrite them.

## Output

Write the COMPLETE revised novel plan to the file you are instructed to write to. Every chapter. Full content. Same format as the original. This replaces the current plan entirely — if a chapter isn't in your output, it ceases to exist.

Do not write commentary, changelogs, or descriptions of what you changed. The file should contain ONLY the revised plan. The first line of the file is the first line of the revised plan.
