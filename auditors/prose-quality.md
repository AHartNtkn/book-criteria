# Prose Quality Auditor

You are evaluating a scene for prose quality. Read all context and the scene carefully, then evaluate each criterion.

## Premise

{premise}

## Novel Plan

{novel_plan}

## Chapter Plan

{chapter_plan}

## Scene Being Audited

{content}

## Evaluation Instructions

For each criterion: score 0-5 with specific evidence (quote the scene). For each sentinel: PASS or FAIL with evidence. Be rigorous. Quote specific passages.

## Criteria

### C1: Sensory Grounding
Does the scene ground the reader in the physical world through concrete sensory detail? Look for sight, sound, smell, touch, taste. Score 0 if the scene is abstract and ungrounded. Score 5 if the reader feels physically present.

### C2: Show Not Tell
Does the scene convey emotion, character, and atmosphere through action, detail, and dialogue rather than direct statement? "She felt angry" is telling. A slammed door is showing. Score based on the ratio and quality.

### C3: Sentence Variety
Does the scene vary sentence length and structure deliberately? Look for: mix of short and long, varied openings, rhythm changes matching content. Score 0 if monotonous. Score 5 if rhythm serves the story.

### C4: Specificity
Does the scene use specific nouns and active verbs rather than generic language? "The ship" vs. "the rust-scarred freighter." "She walked" vs. "She shouldered through." Score based on the density of specific, evocative choices.

### C5: Scene Structure
Does the scene have clear orientation (grounding), development (beats landing), and closure (sense of what shifted)? Score 0 if the scene just starts and stops. Score 5 if structure is clean and deliberate.

### C6: Pacing
Does the scene give weight proportional to dramatic importance? Action passages tight and fast? Reflective passages allowed to breathe? Score 0 if pacing is flat. Score 5 if pacing serves the content.

### C7: Dialogue Exposition
Does dialogue avoid characters explaining things they both already know for the reader's benefit? Score 0 if dialogue is an exposition vehicle. Score 5 if all information delivery feels natural.

## Sentinels

### S1: LLM Stock Phrases
Does the scene contain phrases statistically associated with LLM output? Examples: "a testament to," "the weight of," "echoed through the corridors," "couldn't help but," "a sense of," "little did they know," "the silence was deafening," "sent shivers down," "it was as if." Check for any of these or similar formulaic constructions. If found: FAIL with quotes.

### S2: Excessive Nodding
Do characters nod more than twice in the scene? Nodding is a default LLM gesture when it can't think of specific body language. If more than 2 nods: FAIL with count.

### S3: Purple Prose
Are there passages where the writing draws attention to itself at the expense of the story? Overwrought metaphors, excessive adjective stacking, flowery descriptions that slow the narrative. If found: FAIL with quotes.

### S4: Emotional Tell After Show
Does the scene show an emotion effectively through action/detail, then immediately undercut it by also telling the emotion directly? (e.g., "She slammed the door. She was furious.") If found: FAIL with quotes.

## Output

Write your analysis with specific quotes from the scene. Then output scores:

```json
{
    "criteria": {
        "sensory-grounding": {"score": N, "evidence": "..."},
        "show-not-tell": {"score": N, "evidence": "..."},
        "sentence-variety": {"score": N, "evidence": "..."},
        "specificity": {"score": N, "evidence": "..."},
        "scene-structure": {"score": N, "evidence": "..."},
        "pacing": {"score": N, "evidence": "..."},
        "dialogue-exposition": {"score": N, "evidence": "..."}
    },
    "sentinels": {
        "llm-stock-phrases": {"status": "PASS|FAIL", "evidence": "..."},
        "excessive-nodding": {"status": "PASS|FAIL", "evidence": "..."},
        "purple-prose": {"status": "PASS|FAIL", "evidence": "..."},
        "emotional-tell-after-show": {"status": "PASS|FAIL", "evidence": "..."}
    }
}
```
