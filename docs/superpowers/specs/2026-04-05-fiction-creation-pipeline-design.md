# Fiction Creation Pipeline — Design Spec

## Goal

Build a pipeline that produces novel-length fiction fit for human consumption using iterative LLM refinement. Quality comes from the refinement loop, not from the initial creation prompt.

## Core Lessons Informing This Design

- **lean_worlds (success)**: Iterative refinement works. Plan at a high level, author one unit at a time with full attention, review with specialized auditors, refine until quality gates pass. One unit at a time. No shortcuts.
- **gamePrompting (failure)**: Autoresearch on the creation prompt is insufficient. The criteria/sentinel evaluation framework was good; the approach of optimizing the prompt instead of refining the output was the problem.

## Pipeline Architecture

The pipeline has three hierarchical levels of planning/authoring, each with its own audit/refine loop, plus backtracking after completion of each unit.

### Phase 1: Novel Planning

- **Input**: `premise.md`
- **Prompt**: `plan-novel.md`
- **Output**: `output/novel-plan.md` — chapter-level plan (arc structure, chapter purposes, ordering)
- **Loop**: Novel-plan auditors score it → `fix-novel-plan.md` refines → repeat until 4+ on all criteria, all sentinels pass, or iteration cap hit

### Phase 2: Chapter Planning (per chapter, sequential)

- **Input**: premise + novel plan + any completed chapters
- **Prompt**: `plan-chapter.md`
- **Output**: `output/chapters/NN/chapter-plan.md` — scene-level plan (scene purposes, beat annotations, character arcs within chapter)
- **Loop**: Chapter-plan auditors score it → `fix-chapter-plan.md` refines → repeat until passing

### Phase 3: Scene Authoring (per scene, sequential within chapter)

- **Input**: premise + novel plan + chapter plan + relevant context file + preceding scenes within current chapter
- **Prompt**: `author-scene.md`
- **Output**: `output/chapters/NN/scene-NN.md` — complete prose scene
- **Pre-step**: `collect-context.md` agent reads all completed chapters and extracts details relevant to the current scene's purpose, producing a `relevant-context.md` file. This replaces passing the full history into the scene author's context.
- **Loop**: Scene auditors score it → `fix-scene.md` refines → repeat until passing

### Phase 4: Backtracking

After each scene completes:
- `backtrack-chapter.md` receives: premise + novel plan + chapter plan + all completed scenes in this chapter
- Evaluates whether the remaining chapter plan is still the best path given what was actually produced
- Can add, remove, or reorder upcoming scenes
- If it produces a revised plan, that plan enters the normal chapter-plan audit/refine loop before the pipeline proceeds
- If no change needed, pipeline continues

After each chapter completes:
- `backtrack-novel.md` receives: premise + novel plan + all completed chapters
- Same logic: can adjust remaining chapters, revised plan gets audited
- Completed work is final — backtracking only adjusts the forward plan

## Audit/Refine Loop

This loop runs at every level (novel plan, chapter plan, scene):

1. Run all active auditors for this level
2. Check results:
   - All criteria 4+ and all sentinels pass → **ADVANCE** to next step
   - Iteration cap reached → **MOVE ON** (log final scores)
   - Otherwise → pass all audit feedback to the level-specific fixer
3. Fixer receives all auditor output and makes holistic decisions
   - First question the fixer asks: "Should this part be deleted rather than fixed?"
   - Produces revised content
4. Loop back to step 1

## Auditors

Each auditor is a separate prompt focused on one category of quality. Each auditor contains:

- **Criteria** (scored 0–5): Measurable quality dimensions with evidence requirements. These are the quality standards — prose quality, dialogue, pacing, tension, etc.
- **Sentinels** (present/not-present + evidence): Binary checks that detect LLM autocomplete behavior. Not inherently bad, but statistically correlated with failure modes. Banning them sacrifices a small slice of design space to head off degraded output.

Auditors are grouped by pipeline level. Some auditors only apply to novel plans, some only to chapter plans, some only to scenes. The settings file makes this explicit.

### Criteria vs. Sentinels

**Criteria** are quality dimensions. "Tell-not-show" is a criterion — it's a measurable quality axis that applies to all writing. Scored 0–5 with evidence requirements.

**Sentinels** are canary indicators that the LLM is in autocomplete mode rather than constructing the story intentionally. Example: using "the dark lord" as a villain archetype isn't inherently bad fiction, but when an LLM reaches for that specific token sequence, everything around it is overwhelmingly likely to be default-sampled rather than intentionally designed.

The actual criteria and sentinel catalogs require dedicated research. The starting genre set is space opera, detective/mystery, and high fantasy.

## Auditor Settings & Genre Templates

### Settings File

`auditor-settings.yaml` lists every auditor with an on/off toggle, grouped by pipeline level:

```yaml
iteration_cap: 0            # 0 = no limit, N = move on after N rounds

novel_plan:
  - auditor: arc-structure
    enabled: true
  - auditor: premise-alignment
    enabled: true

chapter_plan:
  - auditor: scene-coherence
    enabled: true
  - auditor: tension-progression
    enabled: true

scene:
  - auditor: prose-quality
    enabled: true
  - auditor: dialogue
    enabled: true
  - auditor: pacing
    enabled: true
```

### Genre Templates

Genre templates are complete copies of the settings file with genre-appropriate presets:

```
genre-templates/
├── space-opera.yaml
├── detective-mystery.yaml
└── high-fantasy.yaml
```

To use a genre: copy the template contents into `auditor-settings.yaml` and adjust if desired. Some auditors are universal (generic writing standards, always on); others are genre-specific (e.g., "clue-planting" for detective/mystery, "magic-system-consistency" for high fantasy).

## Fixers

Three level-specific fixers, each holistic within its level:

- `fix-novel-plan.md` — restructures chapter-level plan
- `fix-chapter-plan.md` — restructures scene-level plan
- `fix-scene.md` — rewrites prose

Each receives all audit feedback for its level and makes holistic decisions. Deletion is a first-class option at every level — the fixer always considers whether the right fix is removing the problematic part rather than patching it.

Fixing is holistic by design. Not everything gets fixed each round, but the iterative cycle means unaddressed problems surface in later rounds and eventually get attention.

## Context Stack

Each prompt receives the full context above it in the hierarchy:

| Prompt | Receives |
|---|---|
| `plan-novel.md` | premise |
| `plan-chapter.md` | premise + novel plan |
| `author-scene.md` | premise + novel plan + chapter plan + relevant context file + preceding scenes within current chapter |
| `fix-novel-plan.md` | premise + novel plan + all auditor feedback for this round |
| `fix-chapter-plan.md` | premise + novel plan + chapter plan + completed scenes + all auditor feedback |
| `fix-scene.md` | premise + novel plan + chapter plan + relevant context file + preceding scenes + scene + all auditor feedback |
| `backtrack-chapter.md` | premise + novel plan + chapter plan + all completed scenes in chapter |
| `backtrack-novel.md` | premise + novel plan + all completed chapters |
| Auditors (any level) | premise + full context stack for that level + the content being audited |

### Goal-Directed Context Collection

As a novel progresses, passing all completed chapters into every prompt exceeds context limits. Instead, a dedicated context-collector agent (`collect-context.md`) reads all prior completed content with a specific lens: "what from the existing story is relevant to this scene's purpose?" It produces a focused `relevant-context.md` file.

This is better than truncation or windowing because the filtering is goal-directed — it pulls different details depending on what the current scene needs. A scene introducing a recurring character pulls that character's prior appearances. A scene resolving a subplot pulls the setup beats.

Preceding scenes within the current chapter are still included in full as immediate local context.

The context collector runs once before each scene's author/audit/refine cycle begins.

## Creation Prompts

Creation prompts are focused, not simple. They provide:
- Clear specification of what to produce (format, structure, expected output)
- Full context stack for the current level
- Structural guidance and constraints

They do NOT encode quality criteria — that's the auditors' job. Comparable in scope to lean_worlds' `phase2-world-author.md` (~200 lines of clear structural guidance).

## File Structure

```
book-criteria/
├── run.sh                          # Pipeline orchestrator
├── premise.md                      # Story premise / success criteria
├── auditor-settings.yaml           # Active auditors (on/off toggles)
├── genre-templates/                # Preset auditor configurations
│   ├── space-opera.yaml
│   ├── detective-mystery.yaml
│   └── high-fantasy.yaml
├── prompts/
│   ├── plan-novel.md               # Novel plan creator
│   ├── plan-chapter.md             # Chapter plan creator
│   ├── author-scene.md             # Scene author
│   ├── collect-context.md          # Context collector agent
│   ├── fix-novel-plan.md           # Novel plan fixer
│   ├── fix-chapter-plan.md         # Chapter plan fixer
│   ├── fix-scene.md                # Scene fixer
│   ├── backtrack-chapter.md        # Re-evaluate chapter plan
│   └── backtrack-novel.md          # Re-evaluate novel plan
├── auditors/                       # One .md per category (criteria + sentinels)
│   ├── (categories TBD through research)
│   └── ...
├── output/                         # Generated content
│   ├── novel-plan.md
│   └── chapters/
│       ├── 01/
│       │   ├── chapter-plan.md
│       │   ├── scene-01.md
│       │   ├── scene-01-context.md
│       │   ├── scene-02.md
│       │   ├── scene-02-context.md
│       │   └── ...
│       ├── 02/
│       └── ...
└── state/                          # Pipeline state for restarts
    ├── progress.json               # Current phase, chapter, scene, round
    └── audit-logs/                 # Score history per round
```

## State Management & Restarts

`progress.json` tracks pipeline position:

```json
{
  "phase": "scene_authoring",
  "chapter": 3,
  "scene": 2,
  "refinement_round": 4,
  "status": "auditing"
}
```

On restart, `run.sh` reads `progress.json` and resumes from where it left off. Output files are written to disk at each step, so nothing is lost.

Audit logs (`state/audit-logs/`) record scores per round for two purposes:
1. Resumability — the pipeline knows which round it's on
2. Inspection — after a run, score progression shows whether refinement is converging or spinning

## Run Script Orchestration

`run.sh` is pure orchestration — it makes no creative decisions. All intelligence lives in the prompts.

Responsibilities:
- Read `auditor-settings.yaml` for active auditors and iteration cap
- Read `progress.json` to resume from last position
- For each pipeline step: assemble context files, call `claude -p` with the appropriate prompt, write output to disk, update `progress.json`
- Run the audit/refine loop: call each active auditor, check scores, call fixer if needed, repeat
- Trigger context collection before each scene cycle
- Trigger backtracking after scene/chapter completion
- Log all audit scores to `audit-logs/`

Placeholder resolution (assembled by the script before each call):
- `{premise}` → contents of `premise.md`
- `{novel_plan}` → contents of `output/novel-plan.md`
- `{chapter_plan}` → contents of current chapter's `chapter-plan.md`
- `{relevant_context}` → contents of current scene's relevant-context.md
- `{scene}` → contents of current scene file
- `{audit_feedback}` → concatenated auditor outputs for current round

## Open Items

1. **Criteria catalog**: Requires dedicated research. Must identify quality dimensions for fiction writing, both universal and genre-specific. Should draw from established literary criticism, creative writing pedagogy, and genre-specific standards.
2. **Sentinel catalog**: Requires dedicated research into LLM fiction failure modes. Sources: forum discussions of AI-generated fiction problems, systematic testing of LLM writing outputs, published analysis of LLM creative writing weaknesses.
3. **Genre template content**: Once criteria and sentinels exist, preset combinations need to be defined for space opera, detective/mystery, and high fantasy.
4. **Prompt content**: The actual text of all creation, fixer, auditor, backtracking, and context-collection prompts.
