# Novel-Plan Auditor Criteria/Sentinel Audit

Date: 2026-04-05

## Summary

Audited all 13 novel-plan-level auditors in `auditor-config.yaml`, evaluating every criterion and sentinel against what is actually observable at the novel-plan level (chapter descriptions, arc structure, character roster, thematic territory, pacing intent -- NOT scenes, prose, dialogue, or sentence-level craft).

## Changes Made

### Criteria Removed from Novel-Plan Auditors (Misassigned)

| ID | Name | Removed From Auditor | Reason |
|---|---|---|---|
| NC-029 | Scene Entrance and Exit Craft | Pacing, Momentum, and Structural Rhythm (Novel-Plan) | Fundamentally about prose-level scene entry/exit ("Scenes begin mid-action, mid-thought, or mid-argument"). Requires reading actual written scenes. Cannot be evaluated from chapter descriptions. |
| ML-041 | Specificity and Concrete Detail | Engagement and Reader Experience (Novel-Plan) | Fundamentally about prose quality ("Not 'a car' but 'a rust-spotted Corolla'"). Measures sentence-level sensory detail. No prose exists at novel-plan level. |
| ML-032 | Prose Density (Layered Meaning) | Novel-Plan Genre Contract and Structure | Measures "whether each sentence and paragraph is doing multiple things simultaneously." This is purely sentence-level prose craft. No sentences or paragraphs exist at novel-plan level. |
| ML-077 | Flashback Integration Without Momentum Loss | Pacing, Momentum, and Structural Rhythm (Novel-Plan) | Measures flashback execution in prose: "brief (a few lines when possible)", "re-entry to the present timeline is disorienting." This is scene-level prose craft. Novel-plan level can only assess whether flashback chapters exist at appropriate structural positions, which is already covered by ML-042 (Structural Beat Placement). |

### Criteria/Sentinels Updated with Novel-Plan Language

These items are correctly assigned to novel-plan auditors but their definition text referenced scene-level artifacts (scenes, dialogue voice, etc.). Added `At novel_plan:` annotations following the existing pattern (see ML-001, ML-014).

| ID | Type | Change |
|---|---|---|
| NC-027 | Criterion | Replaced "scenes" with "chapters" in score_0 and score_5 text. Changed "Every scene has a unique five-word purpose statement" to "Every chapter has a unique purpose statement". |
| NC-006 | Criterion | Changed "Scenes convey contradictory meanings" to "Chapters convey contradictory meanings" and "Every scene's climactic value change" to "Every chapter's value change" in score descriptions. |
| ML-074 | Criterion | Added: "At novel_plan: whether chapter descriptions account for emotional carry-over from preceding chapters rather than treating each chapter's emotional state as independent." |
| ML-094 | Sentinel | Added: "At novel_plan: consecutive chapters are connected only by featuring the same characters; no chapter's outcome drives the next chapter's situation; chapters could be reordered without creating logical problems." |
| ML-090 | Sentinel | Added: "At novel_plan: every chapter description ends with its conflicts resolved and no threads carrying forward to the next chapter." |
| ML-025 | Criterion | Added: "At novel_plan: whether the planned chapter structure, revelation sequencing, and narrative arc take non-default paths rather than following the most predictable template for the genre." |
| ML-080 | Criterion | Added: "At novel_plan: whether the planned chapter structure, POV assignments, arc shape, and resolution strategy show non-default choices rather than following the most predictable genre template." |
| ML-109 | Criterion | Added: "At novel_plan: whether the character roster contains distinct roles, goals, and thematic perspectives with no redundant characters." |
| ML-084 | Criterion | Added: "At novel_plan: whether the planned character pairings are distinct, with different dynamics and planned evolution across the chapter arc." |
| ML-095 | Sentinel | Added: "At novel_plan: check whether the character roster defines distinct goals, perspectives, and thematic roles for each character, or whether multiple characters serve interchangeable functions." |
| NS-004 | Sentinel | Added: "At novel_plan: the first chapter's described purpose or content has no connection to the story's central conflict or thematic concerns." |

### Items Reviewed and Confirmed Correct (No Change Needed)

The following items were reviewed and determined to be appropriately assigned and appropriately worded for novel-plan evaluation:

**NC-prefixed criteria (all novel-plan native):** NC-001, NC-002, NC-004, NC-005, NC-007, NC-008, NC-009, NC-010, NC-012, NC-013, NC-014, NC-015, NC-016, NC-018, NC-019, NC-025, NC-026, NC-028, NC-030, NC-031, NC-033, NC-034, NC-035

**ML-prefixed criteria (multi-level, text appropriate):** ML-003, ML-005, ML-007, ML-011, ML-012, ML-013, ML-020, ML-024, ML-028, ML-042, ML-046, ML-048, ML-050, ML-060, ML-061, ML-062, ML-064, ML-065, ML-066, ML-067, ML-068, ML-069, ML-070, ML-071, ML-072, ML-073, ML-075, ML-078, ML-079, ML-081, ML-082, ML-085, ML-086, ML-087, ML-088, ML-089, ML-103, ML-104, ML-105, ML-106, ML-107, ML-108, ML-110, ML-111, ML-112, ML-113, ML-114, ML-115, ML-116, ML-126, ML-127, ML-128, ML-129, ML-132, ML-133, ML-134

**Sentinels (appropriately worded):** NS-001, NS-002, NS-003, NS-006, NS-007, NS-010, NS-011, NS-012, NS-013, NS-014, NS-015, NS-016, NS-017, NS-018, NS-019, NS-020, NS-021, ML-001, ML-014, ML-044, ML-052, ML-056, ML-092, ML-093, ML-096, ML-097, ML-100, ML-101, ML-117, ML-118, ML-119, ML-120, ML-121, ML-122, ML-123, ML-124, ML-125, ML-130, ML-131

## Borderline Decisions (Kept, with Reasoning)

| ID | Name | Decision | Reasoning |
|---|---|---|---|
| NC-015 | Interestingness/Engagement | Kept | Mentions "enjoyable, entertaining, and engaging to read." While there's no prose to read, the novel plan's structural choices CAN be evaluated for engagement potential (compelling arc shape, interesting character dynamics, effective pacing design). |
| ML-068 | Character Self-Revelation | Kept | Mentions "enacted" moments and "sudden for maximum dramatic force." At novel-plan level, can evaluate whether the arc plans include a self-revelation beat at an appropriate structural position. |
| ML-079 | Meaningful vs Cosmetic Flaws | Kept | Mentions "demonstrated in action." At novel-plan level, can check whether planned character flaws are designed to create consequences in the chapter arc. |
| ML-073 | Dramatic Irony | Kept | At novel-plan level, can evaluate whether the information architecture across chapters creates planned knowledge asymmetries between reader and characters. |
| ML-133 | Cognitive Load Management | Kept | Mentions "unfamiliar names, concepts, and world elements." At novel-plan level, can evaluate whether the plan front-loads too many new elements in early chapters. |

## Files Modified

- `/home/ahart/Documents/book-criteria/auditor-config.yaml` -- removed 4 misassigned criteria
- `/home/ahart/Documents/book-criteria/criteria-definitions.yaml` -- updated 11 criterion/sentinel definitions with novel-plan-level language
