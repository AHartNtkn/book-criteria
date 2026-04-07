# Scene-Level Auditor Fixes

## Summary

Reviewed all 37 scene-level auditors in `auditor-config.yaml`. Removed 33 criteria/sentinel IDs that require cross-scene, cross-chapter, or full-novel perspective and cannot be meaningfully evaluated by reading a single scene (even with chapter_plan, preceding_scenes, or relevant_context).

## Removals by Auditor

### Prose Density and Layered Meaning
- **ML-028** (Premise Clarity): Evaluates whether the core story concept can be articulated in a single sentence. Novel-level.
- **ML-030** (Premise Inexpressible in One Sentence): Same — novel premise evaluation.

### Cliche Detection and Originality in Prose
- **ML-003** (Cliche Avoidance at Story Level): Explicitly labeled "at Story Level." Evaluates exhausted premises, character types, and plot patterns across the full work.

### Reader Engagement and Immersion
- **ML-075** (Emotional Resonance and Memorability): "Whether the story creates lasting emotional impact that lingers in the reader's mind after finishing." Requires full-story experience.

### Pacing — Macro-Rhythm and Tempo Control
- **SC-026** (Chapter/Scene Length Variation): Requires seeing multiple chapters to evaluate variation.
- **SC-120** (Hook Placement and Density): "Hook types vary across chapters... hook density increases in the second half." Cross-chapter.
- **SC-168** (POV Switch Pacing as Hook): Evaluates the switching pattern across many scene/chapter breaks.
- **SC-205** (Rhythm Pattern Variety): "The story alternates between short and long scenes." Requires multi-scene view.
- **SC-294** (Weight Distribution): Word count proportional to narrative importance — requires full-story perspective.
- **ML-020** (Macro Pacing Variation): "Whether the story's pacing varies across its length." Novel-level.
- **ML-043** (Subplot Pacing as Counterpoint): Requires seeing subplot interplay across the full narrative.

### Scene Polarity, Turns, and Value Shifts
- **SC-285** (Turn Variety Across Scenes): Explicitly says "across scenes."
- **ML-016** (Impossible Choice Presence): "Whether the story includes at least one choice where..." — novel-level assessment.
- **ML-060** (Promise-Progress-Payoff Integrity): Full story arc (promises established in opening, progressed through middle, paid off at end).
- **ML-026** (Passive Protagonist sentinel): "The protagonist initiates fewer than ~30% of major plot transitions." Requires full-story statistics.

### Scene-Level Subtext, Theme, and Irony
- **ML-049** (Thematic Subplots and Mirroring): Requires seeing subplots across the full story.
- **ML-061** (Moral and Thematic Complexity): Full thematic square evaluation ("McKee's thematic square is fully populated") requires novel-level view.
- **ML-114** (Motif Development and Evolution): "Recurring elements accumulate meaning through repetition and variation" — requires seeing repetitions across the narrative.

### Scene-Level Plot Mechanics
- **ML-017** (Inciting Incident Timing): "Within the first 10-15%" — novel structure positioning.
- **ML-064** (Audience Expectation Alignment): "The story's pacing delivers what its genre and opening promise." Full story.
- **ML-002** (Circling Conflicts sentinel): "The same argument recurs multiple times without meaningful change." Requires seeing multiple scenes.
- **ML-014** (Genre-Flavored Non-Genre Story sentinel): Whether the story delivers the genre's core emotional experience. Novel-level.
- **ML-051** (Three-Chapter Degradation sentinel): Explicitly multi-chapter.
- **ML-052** (Tidy Single-Track Plots sentinel): Full narrative structure.
- **ML-057** (Unfired Chekhov's Guns sentinel): Requires full narrative to determine if elements fire.
- **ML-058** (Uniform Chapter/Scene Lengths sentinel): Requires seeing multiple chapters/scenes.
- **ML-091** (Backstory Info-Dump in Opening sentinel): About the novel's opening specifically.
- **ML-092** (Conflict Resolved Through Communication sentinel): About how the central conflict resolves. Novel-level.

### Scene-Level Character Dynamics
- **ML-078** (Flat vs Round Character Deployment): Evaluating which characters are round vs flat requires seeing their behavior across the full narrative.
- **ML-050** (Thematic Unity Across Story Elements): "Whether all major story elements work in concert to express the theme." Novel-level.

### Character Interiority and Psychological Depth
- **ML-067** (Character Consistency Under Change): "Whether characters remain recognizably themselves even as they grow." Requires seeing character across full arc.
- **ML-070** (Character-as-Theme): "Whether the character's journey, psychology, and transformation embody and investigate the story's thematic questions." Requires full arc.

### AI Structural Tells (Pattern Repetition)
- **ML-081** (Novelistic Discovery): "Whether the fiction reveals something about human experience that the reader did not already know." Requires full-work assessment.
- **ML-033** (Repetitive Scene Beat Pattern sentinel): "Same sequence of beats across 5+ scenes." Requires seeing 5+ scenes.

### Reader Emotion and Engagement Mechanics
- **ML-087** (Symbolism and Image System Effectiveness): "Image system that repeats with variation from beginning to end." Requires full-work view.

### Continuity — Factual Details and Physical Logic
- **ML-062** (Aggregate Consistency Across Length): Explicitly about consistency "across the full span of a novel-length work."

### Scene Transition and Backstory Integration
- **ML-010** (Exposition Front-Loading sentinel): "The first 10-20% consists primarily of exposition." Novel structure.

### AI Structural Tells (Scene-Level)
- **ML-005** (Conceptual Originality / Premise Freshness): Story-premise evaluation.

### Scene-Level Worldbuilding in Prose
- **ML-031** (Premise Stated But Never Explored sentinel): Requires full-story view.
- **ML-096** (Homogeneous Narrative Structure sentinel): "The story follows a single predictable pattern." Full story.
- **ML-101** (Sycophantic Resolution sentinel): "Every conflict thread is resolved... the ending produces complete closure." Requires seeing the ending.

## Items Retained (Borderline Cases)

These items have language that references broader patterns but CAN be meaningfully evaluated within a single scene given the auditor's context:

- **ML-004** (Coincidence Management) in Scene-Level Plot Mechanics: Can detect if THIS scene uses coincidence to solve a problem.
- **ML-018** (Internal Consistency of World Rules) in Atmosphere auditor: With chapter_plan context, can flag violations visible in this scene.
- **ML-023** (No Thematic Counter-Argument) in Subtext auditor: Can observe if this scene presents only one thematic side.
- **ML-045** (Surface-Level Thematic Details) in Subtext auditor: Can observe if thematic details are integrated into this scene's action.
- **ML-084** (Relationship Dynamics) in Character Dynamics: Can evaluate whether relationships show distinct dynamics within this scene.
- **ML-094** (Episodic Scene Sequence) in Character Dynamics: With relevant_context, can flag if this scene lacks causal connection to previous.
- **ML-098** (Missing Character Wound) in Character Interiority: Sentinel can flag if no wound is visible in this scene's characterization.
- **ML-074** (Emotional Continuity) in Continuity auditor: With preceding_scenes, can check if this scene's opening state matches previous events.

## Auditors That Lost All Criteria

**Scene Polarity, Turns, and Value Shifts** was reduced to a single criterion (ML-083). This auditor may need additional scene-appropriate criteria added, or could be merged into "Scene Structure and Dramatic Shape."
