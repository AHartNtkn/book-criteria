# Fiction Creation Pipeline

A pipeline that produces novel-length fiction through iterative LLM refinement. Quality comes from the refinement loop, not from the initial creation prompt.

## Prerequisites

- `claude` CLI (installed and authenticated)
- `python3`
- `jq`
- `yq` (https://github.com/mikefarah/yq)

## Quick Start

```bash
# 1. Write your story premise
cat > premise.md << 'EOF'
Your story idea here. Can be as short or detailed as you want.
Include genre, tone, length, and any constraints.
EOF

# 2. Answer the style questionnaire (generates criteria-settings.yaml)
python3 process_questionnaire.py

# 3. Run the pipeline
bash run.sh
```

## Setup

### Style Questionnaire

The questionnaire asks 8 questions about your fiction priorities (commercial vs literary, genre, prose style, structure, etc.) and generates `criteria-settings.yaml` — a file that toggles individual quality criteria and failure-detection sentinels on or off.

```bash
# Interactive mode
python3 process_questionnaire.py

# From a preset answers file
python3 process_questionnaire.py --answers my-answers.yaml

# Use defaults (everything on, no genre)
python3 process_questionnaire.py --defaults
```

Answers file format:
```yaml
fiction_tradition: hybrid        # commercial | literary | hybrid
genre: detective_mystery         # detective_mystery | space_opera | high_fantasy | none
prose_style: balanced            # transparent | opaque | balanced
structural_approach: traditional # traditional | experimental | hybrid
thematic_ambition: central       # central | secondary | minimal
pov_approach: strict_limited     # strict_limited | omniscient | mixed
tonal_register: serious          # serious | light | mixed
character_arc_model: transformative  # transformative | flat_arc | anti_arc
```

After generation, you can edit `criteria-settings.yaml` directly for fine-grained control. The `iteration_caps` section controls how many refinement rounds each level gets:

```yaml
iteration_caps:
  novel_plan: 5
  chapter_plan: 5
  scene: 3
```

### Premise File

Write `premise.md` with your story concept. Can range from a sentence to a detailed outline. This file is used throughout the pipeline as the success criteria. Include:

- Core concept / hook
- Genre and tone
- Target length (e.g., "5-7 chapters", "short novel")
- Any specific constraints or requirements

## Pipeline Phases

```
premise.md
    |
    v
Phase 0: Premise Brainstorming
    10 agents x 10 ideas + random dictionary words --> 100 ideas
    Synthesis agent --> output/synthesized-premise.md
    |
    v
Phase 1: Novel Planning
    Plan --> output/novel-plan.md
    Audit/enhance/fix loop (up to iteration cap)
    |
    v
For each chapter:
    |
    v
    Phase 2a: Chapter Brainstorming
        5 agents x 5 ideas + random words --> 25 ideas
        Synthesis --> output/chapters/NN/chapter-concept.md
        |
        v
    Phase 2b: Chapter Planning
        Plan --> output/chapters/NN/chapter-plan.md
        Audit/enhance/fix loop
        |
        v
    Phase 3: Scene Authoring (per scene)
        Context collection --> scene-NN-context.md
        Author --> output/chapters/NN/scene-NN.md
        Audit/enhance/fix loop
        |
        v
    Backtrack: re-evaluate chapter plan
    |
    v
Backtrack: re-evaluate novel plan
```

### The Audit/Enhance/Fix Loop

Each refinement round:
1. **Audit**: All active auditors for the current level run in parallel (batches of 5). Each scores criteria 0-5 and checks sentinels pass/fail.
2. **Check**: If all criteria >= 4 and all sentinels pass, advance. If iteration cap reached, move on.
3. **Enhance**: An enhancement agent brainstorms ambitious improvements (not fixes, but opportunities for brilliance).
4. **Fix**: A holistic fixer receives all audit feedback + enhancement suggestions and rewrites. Can recommend deletion if the content is fundamentally broken.
5. Loop back to audit.

## Monitoring

### Live output
```bash
tail -f state/pipeline-stdout.log
```

### Status dashboard
```bash
bash status.sh
```

Shows: current phase, output files produced, brainstorming progress, step-by-step status with staleness detection, and active process counts.

### Step status

Every pipeline step writes explicit status markers (STARTED/RUNNING/DONE/FAILED) with timestamps to `state/step-status.json`. Steps with no heartbeat for >5 minutes are flagged as STALE.

## Resuming After Interruption

The pipeline resumes from where it left off. Every output file is checked individually before regenerating:

- Existing brainstorming ideas are skipped (only missing ones are generated)
- Existing plans, scenes, and context files are skipped
- The audit loop resumes from the correct round
- Empty files (0 bytes) are treated as incomplete and regenerated

To restart cleanly from scratch:
```bash
rm -rf output/ state/
bash run.sh
```

## File Structure

```
book-criteria/
|-- run.sh                          Pipeline orchestrator
|-- status.sh                       Status dashboard
|-- premise.md                      Your story premise (you write this)
|-- questionnaire.yaml              Style questions + criteria mappings
|-- criteria-settings.yaml          Generated: per-criterion on/off toggles
|-- auditor-config.yaml             Auditor definitions (level, context, criteria IDs)
|-- criteria-definitions.yaml       Full text of all criteria and sentinels
|
|-- fill_template.py                Template expansion (placeholders --> content)
|-- assemble_auditor.py             Dynamic auditor prompt assembly
|-- process_questionnaire.py        Questionnaire --> criteria-settings.yaml
|-- generate_ideation_guidance.py   Extract ideation guidance from definitions
|-- random_words.py                 Random dictionary words for brainstorming
|
|-- lib/
|   |-- audit.sh                    Audit/refine loop (parallel auditors)
|   |-- config.sh                   Config + criteria settings parsing
|   |-- logging.sh                  Per-call logging (prompt, response, timing)
|   |-- progress.sh                 Step-level progress tracking
|   |-- scoring.sh                  Auditor output parsing + score checking
|   |-- state.sh                    Pipeline state management (progress.json)
|
|-- prompts/
|   |-- auditor-template.md         Universal auditor prompt template
|   |-- ideate-premise.md           Premise brainstorming (10 agents)
|   |-- synthesize-premise.md       Premise synthesis (best of 100)
|   |-- ideate-chapter.md           Chapter brainstorming (5 agents)
|   |-- synthesize-chapter.md       Chapter synthesis (best of 25)
|   |-- plan-novel.md               Novel plan creator
|   |-- plan-chapter.md             Chapter plan creator
|   |-- author-scene.md             Scene author
|   |-- collect-context.md          Context collector from prior chapters
|   |-- enhance-novel-plan.md       Novel plan enhancement brainstorming
|   |-- enhance-chapter-plan.md     Chapter plan enhancement brainstorming
|   |-- enhance-scene.md            Scene enhancement brainstorming
|   |-- fix-novel-plan.md           Novel plan fixer
|   |-- fix-chapter-plan.md         Chapter plan fixer
|   |-- fix-scene.md                Scene fixer
|   |-- backtrack-chapter.md        Chapter plan re-evaluation
|   |-- backtrack-novel.md          Novel plan re-evaluation
|
|-- output/                         Generated content (created at runtime)
|   |-- synthesized-premise.md
|   |-- novel-plan.md
|   |-- brainstorm/
|   |   |-- premise/idea-01..10.md
|   |   |-- chapters/NN/idea-01..05.md
|   |-- chapters/
|       |-- 01/
|       |   |-- chapter-concept.md
|       |   |-- chapter-plan.md
|       |   |-- scene-01.md
|       |   |-- scene-01-context.md
|       |   |-- scene-02.md
|       |   |-- ...
|       |-- 02/
|       |-- ...
|
|-- state/                          Pipeline state (created at runtime)
|   |-- progress.json               Current phase/chapter/scene/round
|   |-- step-status.json            Per-step STARTED/RUNNING/DONE/FAILED
|   |-- audit-logs/                 JSON scores per audit round
|   |-- logs/TIMESTAMP/             Per-call logs (prompt + response + timing)
|   |-- pipeline-stdout.log         Pipeline stderr/stdout capture
|
|-- tests/                          Test suites (67 tests)
|-- docs/
    |-- research/                   Criteria research (raw files + structured catalog)
    |-- superpowers/specs/          Design spec
```

## Quality System

### Criteria vs Sentinels

**Criteria** are scored quality dimensions (0-5). "Does dialogue carry subtext?" is a criterion. They measure how good something is along a specific axis.

**Sentinels** are binary (pass/fail) pattern detectors that catch LLM autocomplete behavior. "Does the prose use 'a testament to'?" is a sentinel. They don't mean the writing is objectively bad -- they indicate the LLM is defaulting rather than constructing intentionally.

### Auditor Design

Auditors are grouped by **evidentiary overlap** -- criteria that require reading the same evidence belong in the same auditor. Each auditor receives only the context it needs (many scene-level auditors need only the scene text, not the full novel plan).

Auditor prompts are assembled dynamically at runtime from:
- `auditor-config.yaml` (which auditor has which criteria)
- `criteria-definitions.yaml` (full text of each criterion/sentinel)
- `criteria-settings.yaml` (which are currently toggled on)

### Enhancement

Each refinement round includes an enhancement step that brainstorms ambitious improvements -- not fixes for problems, but opportunities to elevate the work toward greatness. The fixer receives both audit feedback and enhancement suggestions.

## Research

The criteria catalog was built through deep per-category web research across 20 categories of fiction criticism. Raw research files are in `docs/research/raw/`. The structured, deduplicated, level-classified catalog is in `docs/research/structured-catalog.md`. The auditor clustering is in `docs/research/auditor-clusters.md`.

The research prompt template for adding new categories is at `docs/research/research-prompt-template.md`.

## Running Tests

```bash
# All tests
for t in tests/test_*.sh; do bash "$t"; done

# Individual suite
bash tests/test_config.sh
bash tests/test_fill_template.sh
bash tests/test_questionnaire.sh
bash tests/test_scoring.sh
bash tests/test_state.sh
```
