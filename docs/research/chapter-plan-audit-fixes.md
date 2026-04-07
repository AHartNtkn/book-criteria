# Chapter-Plan Level Auditor Fixes

## Summary

Reviewed all 30 chapter-plan level auditors in `auditor-config.yaml`, covering approximately 200 unique criteria and sentinel IDs. Each definition was read from `criteria-definitions.yaml` and evaluated for appropriateness at the chapter-plan level.

## Items Removed (9)

These criteria/sentinels fundamentally require reading actual written prose and cannot be evaluated from a chapter plan (scene descriptions, beat annotations, character assignments, pacing intent, etc.).

### From "Continuity and Consistency (Chapter-Plan)"

| ID | Name | Reason |
|----|------|--------|
| ML-006 | Concrete vs. Abstract Description | Measures whether "description operates in concrete, sensory terms." Requires reading actual descriptive prose -- abstract vs. concrete language is a sentence-level quality invisible in a plan. |
| ML-009 | Description-Action Integration | Measures whether "descriptive passages are woven into ongoing action." Requires reading prose paragraphs to detect static description blocks vs. integrated description. Not observable in scene plans. |
| ML-022 | Narrative Voice and Tonal Consistency | Measures whether "the narrative voice, register, and tone remain consistent." Voice, register, and prose style are line-level qualities that exist only in written text. A plan can specify intended tone but cannot exhibit narrative voice. |

### From "AI Structural Tells (Chapter-Plan Level)"

| ID | Name | Reason |
|----|------|--------|
| ML-025 | Originality of Execution | Measures "fresh, non-default ways to handle scenes, transitions, character introductions, dialogue, revelations." The criterion is about execution-level craft -- how scenes play out in prose, how dialogue is written, how transitions read. A plan describes what happens, not how it reads on the page. |

### From "Sycophantic and Sanitized Resolution Patterns"

| ID | Name | Reason |
|----|------|--------|
| ML-041 | Specificity and Concrete Detail | Measures whether "the prose traffics in specific, concrete, sensory details." Explicitly about prose-level diction: "Not 'a car' but 'a rust-spotted Corolla.'" Word-level specificity is invisible in a plan. |

### From "Scene Description and Planning Quality"

| ID | Name | Reason |
|----|------|--------|
| ML-032 | Prose Density (Layered Meaning) | Measures "whether each sentence and paragraph is doing multiple things simultaneously." Fundamentally about sentence-level craft. Sentences and paragraphs do not exist at the plan level. |
| ML-039 | Sensory Detail as Plot Device | Measures whether "sensory details serve plot functions (foreshadowing, revelation, misdirection)." Requires reading actual sensory descriptions to evaluate whether they perform dual duty. A plan can note "use smell to foreshadow" but the execution is prose-level. |
| ML-054 | Tonal Consistency in Description | Measures "whether the descriptive register, diction, and imagery maintain a consistent emotional tone." Diction, imagery, and descriptive register are prose artifacts. |

### From "Space Opera: Scale, Technology, and Spectacle" (genre auditor)

| ID | Name | Reason |
|----|------|--------|
| SS-184 | Purple Prose in Wonder Scenes | Detects "excessive metaphor stacking, grandiose abstract nouns ('tapestry,' 'symphony,' 'cascade'), and adjective overload." This is a sentence-level prose quality sentinel. Metaphor stacking, abstract noun choice, and adjective density exist only in written text. |

## Language Fixes (7)

These criteria are correctly assigned at chapter-plan level (the underlying structural concept is evaluable from a plan), but their definition text uses prose-level language that could mislead an evaluator. Added `At chapter_plan:` annotations to the `measures` field to clarify what to evaluate at plan level.

| ID | Name | Auditor | Fix |
|----|------|---------|-----|
| CC-010 | Backstory Distribution | Exposition and Information Architecture | Added: "At chapter_plan: whether the plan distributes backstory and exposition across scenes strategically rather than front-loading it, and whether scenes are designed so that background information arrives when dramatically relevant." |
| CC-011 | Backstory-Tension Balance | Exposition and Information Architecture | Added: "At chapter_plan: whether the plan positions flashbacks, exposition, and backstory reveals away from high-tension scenes, and whether scene descriptions avoid specifying exposition delivery during climactic or turning-point moments." |
| CC-044 | Convention Delivery -- Hardboiled/Noir | Mystery/Detective: Fair Play and Clue Architecture | Added: "At chapter_plan: whether the plan establishes systemic corruption, a morally tested detective with a personal code, consequence-laden violence, and noir-appropriate tone and atmosphere across scenes." |
| CC-095 | Incluing and Worldbuilding Integration | Exposition and Information Architecture | Added: "At chapter_plan: whether scene descriptions specify worldbuilding delivery through character action and discovery rather than through planned exposition blocks, and whether the plan avoids front-loading world mechanics." |
| CC-158 | Scene-Level Thematic Integration | Thematic Integration and Development | Added: "At chapter_plan: whether each scene's stated purpose, character choices, and dramatic beats connect to the thematic argument, and whether scene descriptions indicate how the theme will be tested or advanced." |
| CC-212 | Worldbuilding Delivery (Content vs. Exposition) | Worldbuilding Integration and Delivery | Added: "At chapter_plan: whether scenes are designed so that world information emerges through character action and plot events rather than through planned exposition blocks, and whether the plan avoids dedicating entire scenes or scene openings to worldbuilding lectures." |
| CC-213 | Worldbuilding Integration (Fantasy/SF) | General Genre: Convention and Trope Management | Added: "At chapter_plan: whether scene purposes integrate worldbuilding with dramatic action rather than dedicating scenes or scene segments to pure worldbuilding exposition." |
| ML-063 | Atmosphere and Mood Creation | Worldbuilding Through Absence and Speculation | Added: "At chapter_plan: whether scene descriptions specify coherent atmospheric intent, whether settings and environmental elements are chosen to support emotional tone, and whether the planned mood across scenes serves the chapter's dramatic arc." |

## Items Reviewed and Confirmed Correct

The remaining ~190 criteria and sentinels across all 30 chapter-plan auditors were confirmed as appropriate for chapter-plan level evaluation. Notable categories:

- **CC-xxx structural criteria** (plot causality, scene structure, conflict, stakes, pacing, character arcs, thematic architecture): All evaluable from scene descriptions, beat annotations, and structural plans.
- **ML-xxx multi-level criteria** with existing `At chapter_plan:` annotations (ML-001, ML-014): Already correctly scoped.
- **ML-xxx sentinels** (ML-090 through ML-136): Detect structural AI patterns (homogeneous structure, flat arcs, sycophantic resolution, episodic scenes) that are visible in planning documents.
- **CS-xxx sentinels**: Detect structural issues (abandoned subplots, abrupt resolution, missing midpoints, flat escalation, predictable structure) that are all observable in chapter plans.
- **Genre-specific criteria** (mystery fair play, space opera scale, high fantasy worldbuilding): Evaluate structural genre convention delivery, which is a planning-level concern.

## Borderline Items Retained

Several items contain incidental references to prose-level concepts within definitions that are primarily structural:

- **CC-085** (Genre-Specific Quality Markers -- Space Opera): score_5 mentions "Distinctive voice" but the criterion is primarily about scale, spectacle, and thematic depth -- all plan-level.
- **CC-143** (Satisfying vs. Derivative Balance): score_0 mentions "no unique voice" but the criterion is about structural originality vs. derivativeness.
- **CC-191** (Thematic Subtlety): References "dialogue, internal monologue, narration" but the criterion is about whether theme emerges from character action vs. being stated -- a structural design question visible in scene purpose descriptions.

These were retained because the prose-level references are incidental to the primary structural evaluation, and an evaluator reading a chapter plan would naturally interpret them at the appropriate level.
