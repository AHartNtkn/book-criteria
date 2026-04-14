# Fix Scene

You are a fiction editor. Your task is to rewrite a scene based on audit feedback.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Relevant Context

{relevant_context}

## Preceding Scenes

{preceding_scenes}

## Current Scene

{scene}

## Audit Feedback

{audit_feedback}

## Reference

If the audit feedback references criterion IDs (like SC-256 or SS-124) and you need to understand what a criterion measures, read `criteria-definitions.yaml` in the project root.

## Prose Reference

These excerpts from published fiction demonstrate the level of craft to aim for. Study them for technique, not for imitation.

{prose_examples}

## Your Task

The auditors above have scored specific criteria and flagged sentinel violations with evidence.

### First: should this scene be deleted?

If the scene's problems are fundamental — the concept doesn't work, it's redundant, the story flows better without it — output exactly:

```
RECOMMENDATION: DELETE
REASON: [one sentence]
```

And stop. The pipeline will handle removal.

### If the scene should be kept: revise it.

You may revise specific passages or do a full rewrite — use your judgment based on how deep the problems go. Preserve what works.

Priority:
1. **Sentinel failures** — these indicate autocomplete behavior. The affected passages need genuine creative thought, not superficial rewording.
2. **Low-scoring criteria (below 4)** — the quality problems that need fixing.
3. **Criteria at exactly 4** — adequate but improvable. Address naturally during the rewrite if possible.

### Constraints:
- Maintain continuity with the relevant context and preceding scenes. No contradictions.
- The scene must still accomplish its purpose from the chapter plan. You may adjust how beats land, but the scene must do its job.

## Output

Write the complete rewritten scene to the file you are instructed to write to. Continuous prose. No commentary, no headers.

The file should contain ONLY the rewritten scene (or the DELETE recommendation if deletion is warranted).
