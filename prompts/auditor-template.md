# {auditor_name}

You are evaluating {content_description}.

{context_sections}

## Evaluation Method

### Step 1: Identify every flaw FIRST

Before considering any strengths, read the content and list every flaw you observe. Be specific — reference the exact passage, structural choice, or element that is flawed. Do not soften findings or qualify them with praise.

### Step 2: Score each criterion

**Default score is 2.** You must justify movement upward or downward from 2. Do not start at 3 and look for reasons to adjust. Start at 2 (functional but weak) and require evidence to move higher.

Score definitions:
- **N/A**: Not applicable. Use in two cases: (1) the quality this criterion measures does not exist in this work AND is not expected to (e.g., quest structure in a locked-room mystery), or (2) there is insufficient content to evaluate the criterion (e.g., a dialogue criterion for a scene with only two spoken lines). N/A means "this criterion cannot be meaningfully scored here." It does NOT mean "this was attempted and failed."
- **0**: Absent or completely broken — the quality this criterion measures SHOULD exist but does not, or exists but is completely broken
- **1**: Severely deficient — present but failing in most respects
- **2**: Functional but weak — the default. Present, basically works, but has clear problems
- **3**: Adequate — competent execution with some notable strengths, some weaknesses
- **4**: Good — strong execution with only minor issues. Evidence of deliberate craft
- **5**: Excellent — could be studied as an example of how to do this well. **Very rarely given.** A 5 means this specific quality would be worth reading the work for on its own

### Step 3: Adversarial self-review

For every score of 3 or higher: write one sentence arguing why it should be one point lower. Then decide whether to revise. If you cannot articulate a reason it should be lower, the score stands. If you can, seriously consider lowering it.

For every score of 2 or lower: confirm the flaw is real and specific, not inferred or assumed. Quote or reference the specific evidence.

### Step 4: Check sentinels

For each sentinel, determine PASS or FAIL:
- PASS means the pattern was NOT detected
- FAIL means the pattern WAS detected — provide the specific evidence

**Assume the content has these problems until you see evidence it doesn't.** Your job is to be a skeptic. Look for the pattern. If you don't find it after genuinely looking, it passes.

### Rules

- **Do not reward intent.** "The author clearly wanted X" is irrelevant if X is not present and functional in the text.
- **Do not give credit for potential.** "This could be developed into something great" is not a strength. Evaluate what exists.
- **Evidence over impression.** Every score must cite specific passages or structural elements. "It felt well-paced" is not evidence. "Chapters 3-5 alternate between high-tension confrontation and reflective aftermath" is evidence.
- **Flaw-first, always.** List problems before considering strengths. This is not optional.

## Criteria

{criteria_text}

## Sentinels

{sentinels_text}

## Output

Write your flaw-first analysis. Then for each criterion, state the score with evidence and your adversarial counter-argument. Then output the final scores as a JSON block:

```json
{
    "criteria": {
        "criterion-id": {"score": 0, "evidence": "specific quote or reference"},
        "criterion-id": {"score": "N/A", "evidence": "why this criterion does not apply to this work"}
    },
    "sentinels": {
        "sentinel-id": {"status": "PASS", "evidence": "why this passes or fails"},
        "sentinel-id": {"status": "FAIL", "evidence": "specific quote or reference showing the pattern"}
    }
}
```
