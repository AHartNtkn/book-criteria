# Fiction Creation Pipeline — Design Spec

## Goal

Build a pipeline that produces novel-length fiction fit for human consumption using iterative LLM refinement. Quality comes from the refinement loop, not from the initial creation prompt.

## Core Lessons Informing This Design

- **lean_worlds (success)**: Iterative refinement works. Plan at a high level, author one unit at a time with full attention, review with specialized auditors, refine until quality gates pass. One unit at a time. No shortcuts.
- **gamePrompting (failure)**: Autoresearch on the creation prompt is insufficient. The criteria/sentinel evaluation framework was good; the approach of optimizing the prompt instead of refining the output was the problem.

## Pipeline Architecture

The pipeline has hierarchical levels of brainstorming, planning, and authoring, each with its own mechanisms, plus backtracking after completion of each unit.

### Phase 0: Premise Brainstorming

- **Input**: `premise.md` (user's initial concept/constraints/goals)
- **Process**: Random-injection parallel ideation
  1. Launch 10 parallel agents, each generating 10 concept ideas
  2. Each agent receives: the premise file + ideation-level criteria/sentinels as guidance + 5 random dictionary words as inspiration seeds
  3. The random words are selected fresh for each agent at runtime, forcing each agent off the default attractor basin and into different regions of idea space
  4. Output: 100 candidate concept ideas across `output/brainstorm/premise/`
  5. A synthesis agent reads all 100, identifies the strongest elements, evaluates compatibility and complementarity, rejects combinations that create convolution, and produces a single synthesized concept
- **Output**: `output/synthesized-premise.md` — the refined premise that feeds into novel planning
- **Note**: Some criteria/sentinels apply here as ideation guidance (what to aim for, what to avoid) rather than as scoring criteria. These are given to the ideation agents, not to auditors.

### Phase 1: Novel Planning

- **Input**: `output/synthesized-premise.md`
- **Prompt**: `plan-novel.md`
- **Output**: `output/novel-plan.md` — chapter-level plan (arc structure, chapter purposes, ordering)
- **Loop**: Novel-plan auditors score it → `fix-novel-plan.md` refines → repeat until 4+ on all criteria, all sentinels pass, or iteration cap hit

### Phase 2: Chapter Brainstorming + Planning (per chapter, sequential)

- **Brainstorming** (per chapter, before scene planning):
  1. Launch 5 parallel agents, each generating 5 ideas for how this chapter could play out
  2. Each agent receives: synthesized premise + novel plan + chapter's high-level description from the novel plan + completed chapters summary + 5 random dictionary words
  3. Output: 25 candidate chapter concepts across `output/brainstorm/chapters/NN/`
  4. A synthesis agent reads all 25, produces the best chapter concept
  5. Output: `output/chapters/NN/chapter-concept.md`
- **Planning**:
  - **Input**: synthesized premise + novel plan + chapter concept + any completed chapters
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

Criteria and sentinels operate at four levels:

1. **Ideation level** — given to brainstorming agents as generation guidance ("aim for this", "avoid that"). Not scored by auditors. Used during premise brainstorming and chapter concept brainstorming.
2. **Novel plan level** — scored by auditors evaluating the chapter-level plan.
3. **Chapter plan level** — scored by auditors evaluating the scene-level plan.
4. **Scene level** — scored by auditors evaluating prose.

Some criteria may exist at multiple levels (e.g., "concept originality" matters during ideation AND when auditing the novel plan). The way they're used differs: ideation uses them as generation guidance, refinement uses them as scoring criteria. Auditors are grouped by evidentiary overlap within a level.

### Criteria vs. Sentinels

**Criteria** are quality dimensions. "Tell-not-show" is a criterion — it's a measurable quality axis that applies to all writing. Scored 0–5 with evidence requirements.

**Sentinels** are canary indicators that the LLM is in autocomplete mode rather than constructing the story intentionally. Example: using "the dark lord" as a villain archetype isn't inherently bad fiction, but when an LLM reaches for that specific token sequence, everything around it is overwhelmingly likely to be default-sampled rather than intentionally designed.

The actual criteria and sentinel catalogs require dedicated research. The starting genre set is space opera, detective/mystery, and high fantasy.

## Style Questionnaire & Criteria Toggles

Quality evaluation is configured through a two-layer system:

### Layer 1: Style Questionnaire

A set of questions about the user's priorities and the kind of fiction being produced. Each answer maps to toggling specific criteria and sentinels on or off. This resolves contradictions — an auditor can contain criteria that contradict each other (e.g., "tight commercial pacing" vs "literary deliberate slowness") because the questionnaire ensures only the applicable ones are active for a given project.

Questions cover meta-priorities like:
- Commercial vs literary fiction standards
- Genre-specific conventions (which genre contract to honor)
- Prose style preferences (transparent vs opaque, minimalist vs maximalist)
- Structural preferences (tight three-act vs experimental/non-linear)
- Thematic approach (emergent vs didactic vs absent)

The questionnaire lives in `questionnaire.yaml`. Genre presets are pre-filled answer sets.

```yaml
# questionnaire.yaml
questions:
  - id: fiction_tradition
    text: "What fiction tradition are you targeting?"
    options:
      - id: commercial
        label: "Commercial/genre fiction (prioritize reader compulsion, genre satisfaction)"
        enables: [hook-effectiveness, stakes-escalation, chapter-hooks, page-turn-compulsion]
        disables: [deliberate-pacing-disruption, productive-discomfort]
      - id: literary
        label: "Literary fiction (prioritize artistic ambition, thematic depth)"
        enables: [thematic-depth, prose-as-content, deliberate-pacing-disruption]
        disables: [every-scene-must-advance-plot]
      - id: hybrid
        label: "Literary genre fiction (genre structure with literary ambition)"
        enables: [hook-effectiveness, thematic-depth, genre-contract]
        disables: []

  - id: prose_style
    text: "What prose tradition?"
    options:
      - id: transparent
        label: "Transparent (Orwell's windowpane — style doesn't draw attention)"
        enables: [filter-word-control, sentence-clarity, economy-of-language]
        disables: []
      - id: opaque
        label: "Opaque/stylized (Joyce, Nabokov — style IS the content)"
        enables: [prose-density, defamiliarization, verbal-personality]
        disables: [filter-word-control]
  # ... more questions

# Answers are stored in:
answers:
  fiction_tradition: commercial
  prose_style: transparent
  # ...
```

### Layer 2: Criteria Settings (Generated from Questionnaire)

The questionnaire answers produce `criteria-settings.yaml`, which has per-criterion and per-sentinel toggles:

```yaml
# criteria-settings.yaml (generated from questionnaire answers)
iteration_cap: 5

criteria:
  hook-effectiveness: true
  stakes-escalation: true
  thematic-depth: false
  deliberate-pacing-disruption: false
  # ... every criterion listed with true/false

sentinels:
  flat-escalation: true
  slow-opening: true
  llm-stock-phrases: true
  # ... every sentinel listed with true/false
```

Users can also edit `criteria-settings.yaml` directly for fine-grained control after the questionnaire generates the initial version.

### Genre Presets

Genre presets are pre-filled questionnaire answer sets:

```
genre-presets/
├── space-opera.yaml        # Questionnaire answers for space opera
├── detective-mystery.yaml  # Questionnaire answers for detective/mystery
└── high-fantasy.yaml       # Questionnaire answers for high fantasy
```

To use a genre: copy the preset to `questionnaire.yaml`'s answers section, then run the questionnaire processor to generate `criteria-settings.yaml`.

### Auditor Grouping

Auditors are grouped by **evidentiary overlap** — criteria and sentinels that share the same evidence (what the auditor needs to read to evaluate them) belong in the same auditor. An auditor's criteria list is NOT fixed — it receives only the criteria/sentinels that are currently toggled ON from `criteria-settings.yaml`. This means the same auditor template can evaluate different criteria for different projects.

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
| `ideate-premise.md` | premise + ideation criteria/sentinels + 5 random words |
| `synthesize-premise.md` | premise + all 100 candidate ideas |
| `ideate-chapter.md` | synthesized premise + novel plan + chapter description + completed chapters summary + 5 random words |
| `synthesize-chapter.md` | all 25 candidate chapter concepts |
| `plan-novel.md` | synthesized premise |
| `plan-chapter.md` | synthesized premise + novel plan + chapter concept |
| `author-scene.md` | synthesized premise + novel plan + chapter plan + relevant context file + preceding scenes within current chapter |
| `fix-novel-plan.md` | synthesized premise + novel plan + all auditor feedback for this round |
| `fix-chapter-plan.md` | synthesized premise + novel plan + chapter plan + completed scenes + all auditor feedback |
| `fix-scene.md` | synthesized premise + novel plan + chapter plan + relevant context file + preceding scenes + scene + all auditor feedback |
| `backtrack-chapter.md` | synthesized premise + novel plan + chapter plan + all completed scenes in chapter |
| `backtrack-novel.md` | synthesized premise + novel plan + all completed chapters |
| Auditors (any level) | synthesized premise + full context stack for that level + the content being audited |

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
