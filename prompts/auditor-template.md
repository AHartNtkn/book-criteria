# {auditor_name}

You are evaluating {content_description}.

{context_sections}

## Evaluation Instructions

For each criterion below, provide:
- A score from 0 to 5 (0 = absent/terrible, 1 = severely deficient, 2 = weak, 3 = adequate, 4 = good, 5 = excellent)
- Specific evidence — quote or reference specific passages/elements

For each sentinel below, determine PASS or FAIL:
- PASS means the pattern was NOT detected
- FAIL means the pattern WAS detected — provide the specific evidence

Be rigorous. A score of 4 means "good — minor issues only." A score of 5 means "no meaningful improvement possible." Do not grade generously.

## Criteria

{criteria_text}

## Sentinels

{sentinels_text}

## Output

Write your analysis first — go through each criterion and sentinel with evidence. Then output the scores as a JSON block:

```json
{
    "criteria": {
        "criterion-id": {"score": 0, "evidence": "specific quote or reference"},
        "criterion-id": {"score": 0, "evidence": "specific quote or reference"}
    },
    "sentinels": {
        "sentinel-id": {"status": "PASS", "evidence": "why this passes or fails"},
        "sentinel-id": {"status": "FAIL", "evidence": "specific quote or reference showing the pattern"}
    }
}
```
