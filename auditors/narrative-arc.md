# Narrative Arc Auditor

You are evaluating a novel plan for narrative arc quality. Read the premise and plan carefully, then evaluate each criterion below.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Evaluation Instructions

For each criterion, provide:
- A score from 0 to 5 (0 = absent, 1 = severely deficient, 2 = weak, 3 = adequate, 4 = good, 5 = excellent)
- Specific evidence from the plan supporting your score — quote or reference specific chapters

For each sentinel, determine PASS or FAIL with evidence.

Be rigorous. A score of 4 means "good — minor issues only." A score of 5 means "no meaningful improvement possible." Do not grade generously.

## Criteria

### C1: Premise Delivery
Does the plan deliver on the premise? Every major element of the premise should be addressed by at least one chapter. Score 0 if the plan ignores key premise elements. Score 5 if every premise element has a clear home in the plan.

### C2: Central Conflict Escalation
Does the central conflict escalate across the novel? Look for: initial stakes, complications that raise stakes, a clear climax, resolution. Score 0 if tension is flat. Score 5 if escalation is deliberate, varied, and compelling.

### C3: Character Arc Traceability
For each major character: can you trace their arc through the plan? Point to the chapter where each stage of change occurs. Score 0 if arcs are invisible. Score 5 if every major character has a clear, traceable arc with turning points identified.

### C4: Chapter Purpose Clarity
Does every chapter have a clear, stated purpose? Score 0 if purposes are vague or missing. Score 5 if every chapter has a specific, non-redundant purpose that advances the story.

### C5: Structural Connectivity
Are chapters connected through the "Connections" fields? Do setups have payoffs? Do payoffs have setups? Score 0 if chapters float independently. Score 5 if the plan forms a tight causal web.

### C6: Pacing Variation
Does the plan alternate between high and low tension? Are there deliberate peaks and valleys? Score 0 if pacing is monotonous. Score 5 if pacing is deliberately varied with appropriate recovery beats.

### C7: Exposition Distribution
Is world-building and background information distributed across chapters rather than front-loaded? Score 0 if the first few chapters are all setup. Score 5 if information arrives when it's relevant.

## Sentinels

### S1: Orphan Chapter
Is there any chapter with no connections to other chapters — no setups it pays off, no payoffs for prior setups, no character arc progression? If yes: FAIL.

### S2: Identical Register Streak
Are there 3+ consecutive chapters at the same tension level (all high or all low) with no variation? If yes: FAIL.

### S3: Missing Resolution
Does the final chapter fail to address the central conflict? If the plan ends without resolving what it set up: FAIL.

## Output

Write your analysis for each criterion and sentinel. Then output the scores as a JSON block:

```json
{
    "criteria": {
        "premise-delivery": {"score": N, "evidence": "..."},
        "conflict-escalation": {"score": N, "evidence": "..."},
        "arc-traceability": {"score": N, "evidence": "..."},
        "chapter-purpose": {"score": N, "evidence": "..."},
        "structural-connectivity": {"score": N, "evidence": "..."},
        "pacing-variation": {"score": N, "evidence": "..."},
        "exposition-distribution": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "orphan-chapter": {"status": "PASS|FAIL", "evidence": "..."},
        "identical-register-streak": {"status": "PASS|FAIL", "evidence": "..."},
        "missing-resolution": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
