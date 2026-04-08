# Consolidate Audit Feedback

You are consolidating raw output from multiple auditors who evaluated the same content. Your job is to read each auditor's feedback file and produce one unified feedback document that the fixer will use.

## Auditor Feedback Files

The following files contain raw auditor output. Read each one using the Read tool:

{feedback_file_list}

## Your Task

Read each feedback file. Multiple auditors examined the same content from different angles. Their outputs overlap — the same problem is often identified by several auditors from different perspectives. Your job is to deduplicate and consolidate.

### What to keep:

1. **Flaw observations** — every auditor starts with a flaw-first analysis listing problems they observed. Many will point at the same problem. Consolidate these into a single list of unique problems. When multiple auditors describe the same issue, combine their evidence into one entry — use whichever description is most specific and actionable.

2. **Failing scores** — for criteria that scored below 4, keep the criterion name, score, and evidence. If the same criterion was scored by multiple auditors, keep the lowest score and best evidence.

3. **Failing sentinels** — for sentinels that FAILED, keep the sentinel name and evidence.

### What to drop:

- Criteria that scored 4 or 5 (the fixer doesn't need to know what's working)
- Sentinels that passed
- Adversarial counter-arguments for passing scores
- Redundant observations (same problem described by multiple auditors — keep one version)
- Reasoning about why something was scored the way it was (keep the score and evidence, drop the deliberation)

### Output format:

```
## Observed Flaws

[Deduplicated list of problems, each with specific evidence]

1. [Problem description] — [specific evidence: quotes, chapter references, structural references]
2. ...

## Failing Criteria

[Criterion ID]: [Name] — Score [N]
  Evidence: [specific reference]

[Criterion ID]: [Name] — Score [N]
  Evidence: [specific reference]

## Failing Sentinels

[Sentinel ID]: [Name] — FAIL
  Evidence: [specific reference]
```

Write the consolidated feedback to the file you are instructed to write to.
