# Scene Design Auditor

You are evaluating a chapter plan for scene design quality. Read all context, then evaluate each criterion.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Content Being Audited

{content}

## Evaluation Instructions

For each criterion: score 0-5 with specific evidence. For each sentinel: PASS or FAIL with evidence. Be rigorous.

## Criteria

### C1: Scene Purpose Specificity
Does every scene have a clear, specific purpose stated in terms of story function? "Establish trust between X and Y" is specific. "Things happen" is not. Score based on the weakest scene.

### C2: Beat Quality
Do scenes have meaningful beats — shifts in emotional state, power dynamics, or understanding? Score 0 if beats are absent or trivial. Score 5 if every scene has well-defined shifts that create movement.

### C3: Chapter Goal Delivery
Does the collection of scenes deliver on the chapter's goal as stated in the novel plan? Score 0 if scenes don't add up to the chapter's purpose. Score 5 if the scenes clearly accomplish it.

### C4: Scene Flow and Transitions
Do scenes connect logically? Does emotional state carry between scenes? Are transitions (hard cuts vs. continuous) chosen deliberately? Score 0 if scenes feel disconnected. Score 5 if flow is natural and intentional.

### C5: Pacing Within Chapter
Is there variation in scene intensity and implied length? Score 0 if all scenes are the same weight. Score 5 if pacing is deliberately varied.

### C6: Character Knowledge Tracking
Do scenes respect what characters know and don't know? Does information revealed in one scene affect possibilities in later scenes? Score 0 if characters seem omniscient. Score 5 if knowledge is carefully tracked.

## Sentinels

### S1: Purposeless Scene
Is there any scene whose purpose is vague, empty, or duplicates another scene's purpose? If yes: FAIL.

### S2: Beatless Scene
Is there any scene with fewer than 2 beats — where characters end in the same state they started? If yes: FAIL.

### S3: Novel Plan Contradiction
Does any scene contradict the chapter's role as defined in the novel plan? If yes: FAIL.

## Output

Write your analysis, then output scores:

```json
{
    "criteria": {
        "scene-purpose": {"score": N, "evidence": "..."},
        "beat-quality": {"score": N, "evidence": "..."},
        "chapter-goal-delivery": {"score": N, "evidence": "..."},
        "scene-flow": {"score": N, "evidence": "..."},
        "pacing-within-chapter": {"score": N, "evidence": "..."},
        "character-knowledge": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "purposeless-scene": {"status": "PASS|FAIL", "evidence": "..."},
        "beatless-scene": {"status": "PASS|FAIL", "evidence": "..."},
        "novel-plan-contradiction": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
