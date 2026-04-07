# Proposed Auditor Clusters

## Scene-Level Auditors

### Auditor: Grammar and Mechanical Correctness
**Evidence required**: Individual sentences and words examined for grammatical rules, spelling, and basic mechanical accuracy.
**Context needed**: scene
**Item count**: 10 criteria + 5 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| SC-005 | Apostrophe Correctness | criterion |
| SC-042 | Comma Splice and Run-On Management | criterion |
| SC-117 | Grammar Correctness | criterion |
| SC-173 | Participial Phrase Accuracy (Simultaneous Action) | criterion |
| SC-189 | Punctuation Accuracy | criterion |
| SC-230 | Sentence Clarity | criterion |
| SC-250 | Spelling and Typo Freedom | criterion |
| SC-255 | Subject-Verb Agreement | criterion |
| SC-271 | Tense Consistency | criterion |
| SC-053 | Dangling and Misplaced Modifiers | criterion |
| SS-048 | Bold-First Bullets / Markdown Formatting Artifacts | sentinel |
| SS-059 | Content Duplication (Repeated Passages) | sentinel |
| SS-133 | Lack of Contractions in Dialogue | sentinel |
| SS-195 | Repetitive Sentence Openings (Anaphora Without Purpose) | sentinel |
| SS-268 | S77: Bold-First Bullet Points / Markdown Formatting in Prose | sentinel |

---

### Auditor: Punctuation and Formatting Consistency
**Evidence required**: Manuscript-wide formatting patterns — dash usage, comma conventions, quotation marks, ellipses, capitalization, number formatting, italics, scene breaks.
**Context needed**: scene, preceding_scenes
**Item count**: 12 criteria + 6 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-025 | Capitalization Consistency | criterion |
| SC-046 | Consistency of Style Choices | criterion |
| SC-062 | Dialogue Punctuation and Formatting | criterion |
| SC-078 | Ellipsis Formatting Consistency | criterion |
| SC-079 | Em Dash, En Dash, and Hyphen Distinction | criterion |
| SC-121 | Hyphenation Consistency | criterion |
| SC-133 | Italics Usage Consistency | criterion |
| SC-157 | Number Formatting Consistency | criterion |
| SC-192 | Quotation Mark Consistency and Correctness | criterion |
| SC-209 | Scene Break and Chapter Break Formatting | criterion |
| SC-296 | Widows and Orphans Control | criterion |
| ML-008 | Cross-Reference and Internal Consistency (scene formulation) | criterion |
| SS-077 | Em Dash Overuse | sentinel |
| SS-078 | Em Dash Overuse Sentinel | sentinel |
| SS-081 | Emdash and Semicolon Overuse | sentinel |
| SS-169 | Oxford Comma Consistency as Mechanical Tell | sentinel |
| SS-241 | S4: Excessive Em Dash Usage | sentinel |
| SS-317 | Uniform Paragraph Length (formatting aspect) | sentinel |

---

### Auditor: Line-Level Prose Craft (Clarity, Concision, Polish)
**Evidence required**: Individual sentences and short passages examined for clarity of expression, unnecessary words, redundancy, and editing quality.
**Context needed**: scene
**Item count**: 10 criteria + 6 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| SC-002 | Adverb Control | criterion |
| SC-044 | Concision and Filler Word Control | criterion |
| SC-134 | Line Editing Hierarchy: Clarity, Flow, Polish | criterion |
| SC-174 | Passive Voice Control | criterion |
| SC-195 | Readability of Complex Sentences | criterion |
| SC-231 | Sentence Fragment Control | criterion |
| SC-253 | Strong Nouns Over Adjective Padding | criterion |
| SC-289 | Verb Strength and Dynamic Action | criterion |
| SC-298 | Word Choice Precision | criterion |
| ML-015 | Grandiose Stakes Inflation (scene formulation) | sentinel |
| SS-008 | "Despite Its Challenges" / Formulaic Optimism | sentinel |
| SS-135 | Listicle Structure in Prose | sentinel |
| SS-161 | Nominalization Overuse | sentinel |
| SS-178 | Present Participial Clause Overuse | sentinel |
| SS-215 | S25: Present Participle ("-ing") Phrase Stacking | sentinel |
| SS-320 | Vague Attribution ("Experts say," "It is often thought") | sentinel |

---

### Auditor: AI Vocabulary and Diction Tells
**Evidence required**: Word-frequency analysis across the text — detecting clusters of specific AI-associated words, stock phrases, and formulaic constructions.
**Context needed**: scene
**Item count**: 3 criteria + 15 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-017 | C1: Lexical Diversity and Vocabulary Breadth | criterion |
| SC-019 | C3: Entropy and Predictability | criterion |
| SC-020 | C4: Semantic Specificity vs Semantic Ablation | criterion |
| SS-014 | "Newfound" / "Palpable" / "Interplay" — AI Signature Word Clustering | sentinel |
| SS-021 | "Quietly" / "Deeply" / "Fundamentally" — Magic Adverb Clustering | sentinel |
| SS-025 | AI Vocabulary Clustering | sentinel |
| SS-026 | AI Vocabulary Density Sentinel | sentinel |
| SS-027 | AI Vocabulary Overuse ("Delve," "Tapestry," "Testament," "Vibrant," "Palpable") | sentinel |
| SS-201 | S10: "Crucial" / "Pivotal" / "Vital" Significance Inflation | sentinel |
| SS-208 | S17: "Quietly" and Other Atmosphere-Manufacturing Adverbs | sentinel |
| SS-211 | S1: "Delve" and "Delve Into" | sentinel |
| SS-216 | S26: "Bustling" as Default City Descriptor | sentinel |
| SS-217 | S27: "Meticulous" / "Meticulously" as Default Care Descriptor | sentinel |
| SS-224 | S34: "Unwavering" / "Indelible" / "Profound" Intensity Inflation | sentinel |
| SS-225 | S35: "Interplay" / "Intricacies" / "Multifaceted" Complexity Signaling | sentinel |
| SS-239 | S48: Cluster Co-occurrence of AI Vocabulary | sentinel |
| SS-262 | S70: "Robust" / "Compelling" / "Daunting" Generic Modifiers | sentinel |
| SS-273 | S9: "Vibrant" as Default Descriptor | sentinel |

---

### Auditor: AI Stock Phrases and Formulaic Constructions
**Evidence required**: Sentence-level patterns — detecting recurring AI-characteristic syntactic constructions, stock metaphor vehicles, formulaic transitions, and mechanical tics.
**Context needed**: scene
**Item count**: 1 criterion + 19 sentinels = 20 total

| ID | Name | Type |
|---|---|---|
| ML-019 | Invented Concept Labels ("The X Paradox," "The Y Trap") (scene formulation) | sentinel |
| SS-001 | "A Sense of [Abstract Noun]" Construction | sentinel |
| SS-002 | "A Tapestry of" / "A Testament to" / "A Dance of" Construction | sentinel |
| SS-004 | "Additionally/Furthermore" Sentence-Opening Sentinel | sentinel |
| SS-011 | "Here's the Kicker" / "Here's the Thing" Transition Pattern | sentinel |
| SS-012 | "It's Worth Noting" / Transitional Throat-Clearing | sentinel |
| SS-013 | "Let's Break This Down" / Pedagogical Voice | sentinel |
| SS-022 | "Serves As" / "Stands As" / Copula Avoidance | sentinel |
| SS-024 | "The Weight of [Abstract Noun]" / "The Air Was Thick With [Abstract Noun]" | sentinel |
| SS-202 | S11: "Serves As" / "Stands As" / "Marks" Copula Avoidance | sentinel |
| SS-220 | S2: "A Testament To" | sentinel |
| SS-226 | S36: "Navigate" / "Navigating" as Life Metaphor | sentinel |
| SS-227 | S37: "Embark on a Journey" / Journey Metaphor | sentinel |
| SS-228 | S38: "Resonates" / "Reverberate" for Emotional Impact | sentinel |
| SS-229 | S39: "Shed Light On" / "Shed Light" | sentinel |
| SS-230 | S3: "Tapestry" as Metaphor | sentinel |
| SS-231 | S40: "Unlock" / "Unlock the Power of" / "Unlock the Potential" | sentinel |
| SS-232 | S41: "Unveil" / "Uncover" Discovery Language | sentinel |
| SS-203 | S12: "Unspoken" as Emotional Modifier | sentinel |
| SS-221 | S30: "Moreover" / "Furthermore" / "Additionally" as Paragraph Openers | sentinel |

---

### Auditor: AI Formulaic Patterns (Structural Tics)
**Evidence required**: Paragraph-level and cross-paragraph patterns — detecting repeated syntactic templates, rhetorical constructions, and structural formulas characteristic of AI generation.
**Context needed**: scene
**Item count**: 0 criteria + 18 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SS-015 | "Not X; Y" Construction Overuse | sentinel |
| SS-016 | "Not X; Y" Construction Pattern | sentinel |
| SS-017 | "Not X; Y" Descriptive Construction | sentinel |
| SS-018 | "Not X; Y" Negation-Assertion Sentinel | sentinel |
| SS-019 | "Not X; Y" Rhetorical Tic | sentinel |
| SS-020 | "Not X; Y" Sentence Pattern | sentinel |
| SS-065 | Copulative Avoidance / "Stands As" Sentinel | sentinel |
| SS-108 | Fractal Summaries (Redundant Intro/Conclusion) | sentinel |
| SS-154 | Negative Parallelism Default ("Not Just X, But Also Y") | sentinel |
| SS-155 | Negative Parallelism Pattern ("Not X — It's Y") | sentinel |
| SS-212 | S20: "The Result? [One-word answer]." Self-Posed Rhetorical Questions | sentinel |
| SS-213 | S21: "Here's the Thing" / "Here's the Kicker" False Suspense | sentinel |
| SS-214 | S23: "Despite Its Challenges..." Formulaic Acknowledgment-Dismissal | sentinel |
| SS-233 | S42: "In Today's [Fast-Paced/Digital/Modern] World" Opening | sentinel |
| SS-234 | S43: "Let's Dive In" / "Let's Break It Down" / "Let's Unpack This" | sentinel |
| SS-235 | S44: "Imagine a World Where..." Futurism Opening | sentinel |
| SS-250 | S59: "It's Worth Noting" / "It's Important to Note" / "Notably" | sentinel |
| SS-251 | S5: "Not X, It's Y" / Negative Parallelism Pattern | sentinel |

---

### Auditor: AI Generation Tells (Broader Patterns)
**Evidence required**: Whole-text statistical patterns — burstiness, sentence length uniformity, register uniformity, syntactic template matching, and tonal flatness across the full text.
**Context needed**: scene
**Item count**: 2 criteria + 17 sentinels = 19 total

| ID | Name | Type |
|---|---|---|
| SC-018 | C2: Burstiness and Sentence-Length Variation | criterion |
| SC-024 | C9: Temporal Complexity | criterion |
| SS-028 | Absence of Contractions in Prose | sentinel |
| SS-138 | Low Burstiness (Uniform Sentence Length) | sentinel |
| SS-139 | Low Burstiness Sentinel | sentinel |
| SS-140 | Low Entropy / High Predictability Prose | sentinel |
| SS-141 | Low Epistemic Marker Density Sentinel | sentinel |
| SS-144 | Metronomic Sentence Length | sentinel |
| SS-196 | Repetitive Syntactic Patterns | sentinel |
| SS-205 | S14: Uniform Sentence Length (Low Burstiness) | sentinel |
| SS-252 | S60: 76%+ Syntactic Templates Match Pre-Training Data | sentinel |
| SS-254 | S62: Near-Uniform Earnestness (Absence of Irony) | sentinel |
| SS-255 | S63: High Register as Universal Default | sentinel |
| SS-256 | S64: "Fractal Summary" Structure (Tell-Do-Retell) | sentinel |
| SS-257 | S65: "Treasure Trove" / "Game Changer" / "Cutting-Edge" Hype Language | sentinel |
| SS-269 | S79: Absence of Hedging / Epistemic Markers | sentinel |
| SS-277 | Self-Answering Rhetorical Questions ("The X? A Y.") | sentinel |
| SS-316 | Uniform Narrative Stance (Earnest, Single-POV, Past Tense, Reliable, High Register) | sentinel |
| SS-236 | S45: Absence of Continuity Errors of the Right Kind | sentinel |

---

### Auditor: Sentence Rhythm and Prose Cadence
**Evidence required**: Paragraph-level prose flow — sentence length variation, syntactic pattern variety, stress patterns, rhythm, and the sonic texture of consecutive sentences.
**Context needed**: scene
**Item count**: 12 criteria + 6 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-087 | Emotional Pacing Congruence | criterion |
| SC-093 | Expectation-Silence-Surprise Pattern | criterion |
| SC-139 | Micro-Pacing (Line-Level Tempo Control) | criterion |
| SC-171 | Paragraph Length Variation | criterion |
| SC-172 | Paragraph Structure and Breaks | criterion |
| SC-185 | Prose Stress Pattern Awareness | criterion |
| SC-232 | Sentence Structure Variation (Beyond Length) | criterion |
| SC-233 | Sentence Variety and Rhythm | criterion |
| SC-234 | Sentence Variety and Rhythmic Variation | criterion |
| SC-235 | Sentence-Level Rhythm Variation | criterion |
| SC-247 | Sound and Euphony | criterion |
| SC-295 | White Space and Breath Units | criterion |
| SS-068 | Describe-Speak-Act Cycle in Dialogue | sentinel |
| SS-079 | Em-Dash Overuse for Artificial Pause | sentinel |
| SS-292 | Subject-Verb-Object Sentence Pattern Lock | sentinel |
| SS-297 | Symmetrical Dialogue Exchanges | sentinel |
| SS-308 | Three-Item List Pattern | sentinel |
| SS-318 | Uniform Sentence Beginnings Sentinel | sentinel |

---

### Auditor: Prose Style and Authorial Voice
**Evidence required**: Extended prose passages examined for distinctive authorial personality — diction, register, transparency/opacity choices, tonal control, and stylistic identity.
**Context needed**: scene, relevant_context
**Item count**: 13 criteria + 5 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-012 | Authorial Voice Distinctiveness | criterion |
| SC-016 | C11: Authorial Voice and Stylistic Identity | criterion |
| SC-069 | Diction Precision and Intentionality | criterion |
| SC-070 | Distinctive Voice | criterion |
| SC-077 | Economy of Language (Concision vs. Density) | criterion |
| SC-152 | Narrative Voice Distinctiveness | criterion |
| SC-186 | Prose Transparency vs. Opacity (Windowpane vs. Stained Glass) | criterion |
| SC-200 | Register Appropriateness and Consistency | criterion |
| SC-254 | Style-Content Alignment | criterion |
| SC-268 | Syntactic Sophistication (Hypotaxis vs. Parataxis) | criterion |
| SC-283 | Tonal Control and Modulation | criterion |
| SC-293 | Voice Layering (Author/Narrator/Character) | criterion |
| ML-041 | Specificity and Concrete Detail (scene formulation) | criterion |
| SS-041 | Alternating Prose Density Sentinel | sentinel |
| SS-119 | Harmless Filter / RLHF Blandness Sentinel | sentinel |
| SS-179 | Promotional Language in Narration Sentinel | sentinel |
| SS-238 | S47: "Showcasing" / "Underscores" / "Highlights" Commentary Language | sentinel |
| SS-295 | Swings Between Ponderous Similes and Cliche Short Lines | sentinel |

---

### Auditor: Prose Density and Layered Meaning
**Evidence required**: Paragraphs and passages examined for whether prose accomplishes multiple functions simultaneously — characterization through description, theme through imagery, exposition through action.
**Context needed**: scene
**Item count**: 10 criteria + 5 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| SC-074 | Earned Moments and Restraint | criterion |
| SC-106 | Filter Word and Psychic Distance Control | criterion |
| SC-113 | Free Indirect Style Execution | criterion |
| SC-127 | Information Density and Reader Trust | criterion |
| SC-149 | Narrative Economy (Multi-Function Exposition) | criterion |
| SC-243 | Showing vs. Telling Balance | criterion |
| ML-032 | Prose Density (Layered Meaning) (scene formulation) | criterion |
| ML-001 | Abstraction Trap Sentinel (scene formulation) | sentinel |
| ML-028 | Premise Clarity (scene formulation) | criterion |
| ML-030 | Premise Inexpressible in One Sentence (scene formulation) | sentinel |
| SS-089 | Emotions-as-Information Sentinel | sentinel |
| SS-092 | Equivocation Seesaw Sentinel | sentinel |
| SS-097 | Exposed Subtext Sentinel | sentinel |
| SS-104 | Flowery-But-Meaningless Prose | sentinel |
| SS-312 | Treadmill Effect Sentinel | sentinel |

---

### Auditor: Cliche Detection and Originality in Prose
**Evidence required**: Phrase-level and sentence-level constructions examined for stock phrases, tired imagery, formulaic transitions, and lack of originality.
**Context needed**: scene
**Item count**: 5 criteria + 9 sentinels = 14 total

| ID | Name | Type |
|---|---|---|
| SC-040 | Cliche Avoidance | criterion |
| SC-041 | Cliche Avoidance at Sentence Level | criterion |
| SC-054 | Defamiliarization (Making the Familiar Strange) | criterion |
| SC-055 | Defamiliarization / Making Strange | criterion |
| SC-114 | Freshness of Figurative Language | criterion |
| ML-003 | Cliche Avoidance at Story Level (scene formulation) | criterion |
| SS-057 | Cliché Clustering Under Stress | sentinel |
| SS-076 | Elegant Variation / Synonym Chains | sentinel |
| SS-113 | Generic Opening Situation (Mirror, Waking Up, Weather) | sentinel |
| SS-247 | S55: Excessive Elegant Variation (Synonym Substitution) | sentinel |
| SS-259 | S68: "Dance" as Default Metaphor for Interaction | sentinel |
| SS-267 | S76: "Effortlessly" / "Seamlessly" False Ease Descriptors | sentinel |
| SS-271 | S80: Simile Density ("Like a...") | sentinel |
| SS-290 | Stock Emotional Physicality | sentinel |

---

### Auditor: Echo Words and Repetition Control
**Evidence required**: Proximity analysis of word usage — detecting unintentional word repetition, vocabulary exhaustion, and redundant phrasing within passages.
**Context needed**: scene, preceding_scenes
**Item count**: 3 criteria + 8 sentinels = 11 total

| ID | Name | Type |
|---|---|---|
| SC-075 | Echo Word Avoidance | criterion |
| SC-199 | Redundancy Elimination (Show AND Tell Problem) | criterion |
| SC-244 | Backstory Integration (SC-244 variant) | criterion |
| SS-050 | Characters Repeat Same Words/Phrases | sentinel |
| SS-062 | Context Poisoning / Vocabulary Well Exhaustion | sentinel |
| SS-134 | Latinate Bias Sentinel | sentinel |
| SS-193 | Repetitive Looping | sentinel |
| SS-194 | Repetitive Name/Location/Occupation Defaults | sentinel |
| SS-210 | S19: Repeated Exact Phrases Across Passages | sentinel |
| SS-279 | Semantic Ablation | sentinel |
| SS-280 | Semantic Ablation Sentinel | sentinel |

---

### Auditor: Dialogue Voice and Distinctiveness
**Evidence required**: Dialogue exchanges with attribution removed — testing whether each character's speech patterns, vocabulary, syntax, and register are distinguishable.
**Context needed**: scene, relevant_context
**Item count**: 6 criteria + 8 sentinels = 14 total

| ID | Name | Type |
|---|---|---|
| SC-034 | Character Name Overuse in Dialogue | criterion |
| SC-036 | Character Voice Distinctiveness | criterion |
| SC-059 | Dialogue Compression and Naturalism Balance | criterion |
| SC-201 | Register and Sociolect Accuracy | criterion |
| SC-291 | Vocabulary and Diction Alignment with POV | criterion |
| ML-059 | Uniform Narrator Voice Across All POV Characters (scene formulation) | sentinel |
| SS-037 | All Characters Sound Identical | sentinel |
| SS-038 | All Characters Uniformly Eloquent | sentinel |
| SS-051 | Characters Sound Identical | sentinel |
| SS-094 | Excessive Character Name Address | sentinel |
| SS-156 | No Character Has a Distinct Voice | sentinel |
| SS-209 | S18: Identical Character Voices | sentinel |
| SS-314 | Uniform Character Voice | sentinel |
| SS-324 | Vocabulary Homogeneity Across Diverse Characters | sentinel |

---

### Auditor: Dialogue Craft and Exchange Dynamics
**Evidence required**: Dialogue scenes examined for dramatic function — purpose, pacing, conflict, subtext, non-verbal integration, and attribution technique.
**Context needed**: scene
**Item count**: 14 criteria + 4 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-045 | Conflict and Tension Within Exchanges | criterion |
| SC-048 | Correct Speaker Tag Verbs | criterion |
| SC-061 | Dialogue Pacing Variation | criterion |
| SC-063 | Dialogue Purpose and Economy | criterion |
| SC-064 | Dialogue Rhythm and Pacing | criterion |
| SC-065 | Dialogue Tag Craft | criterion |
| SC-066 | Dialogue Tag and Attribution Craft | criterion |
| SC-067 | Dialogue-Action Integration (Beats) | criterion |
| SC-068 | Dialogue-to-Narration Balance | criterion |
| SC-144 | Monologue and Long Speech Management | criterion |
| SC-147 | Multi-Character Conversation Management | criterion |
| SC-155 | Non-Linear Exchange Patterns | criterion |
| SC-181 | Power Dynamics in Conversation | criterion |
| SC-246 | Silence, Evasion, and Non-Response as Tools | criterion |
| SS-064 | Cooperative Q&A Pattern / No Deflection | sentinel |
| SS-159 | No Silence or Non-Response in Dialogue | sentinel |
| SS-191 | Repetitive Generic Action Beats | sentinel |
| SS-319 | Uniform Sentence Length in Dialogue | sentinel |

---

### Auditor: Dialogue Tags and Attribution Mechanics
**Evidence required**: Dialogue tag verbs and attribution patterns — examining said-bookisms, adverb-heavy tags, action beats, and participial constructions around dialogue.
**Context needed**: scene
**Item count**: 2 criteria + 5 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| SC-206 | Said Bookism Avoidance | criterion |
| SC-080 | Emotion Shown Through Speech Patterns Rather Than Declared | criterion |
| SS-003 | "A [Noun] of [Emotion]" Construction Repetition | sentinel |
| SS-035 | Adverb-Heavy Dialogue Attribution | sentinel |
| SS-171 | Participial Phrase Overuse in Action Beats | sentinel |
| SS-249 | S57: "Whispering" / "Murmuring" as Default Dialogue Tag | sentinel |
| SS-274 | Said-Bookism / Ornate Dialogue Tags | sentinel |

---

### Auditor: Dialogue Subtext and On-the-Nose Avoidance
**Evidence required**: Dialogue exchanges examined for gap between surface meaning and underlying intention — whether characters communicate through implication or state everything directly.
**Context needed**: scene
**Item count**: 5 criteria + 8 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| SC-060 | Dialogue Exposition Naturalness | criterion |
| SC-094 | Exposition Handling in Dialogue | criterion |
| SC-131 | Internal Monologue-Dialogue Integration | criterion |
| SC-161 | On-the-Nose Dialogue Avoidance | criterion |
| SC-256 | Subtext Quality | criterion |
| SS-005 | "As You Know, Bob" Dialogue | sentinel |
| SS-006 | "As You Know, Bob" Exposition Dumps | sentinel |
| SS-052 | Cliche Phrase Clustering in Dialogue | sentinel |
| SS-084 | Emotional Over-Articulation / Therapy-Speak Dialogue | sentinel |
| SS-117 | Genre/Emotion Announcement in Dialogue | sentinel |
| SS-121 | Hedge Words and Synthetic Politeness Markers | sentinel |
| SS-127 | Identical Scene-Level Repetition of Dialogue Beats | sentinel |
| SS-165 | On-the-Nose Dialogue (No Subtext) | sentinel |

---

### Auditor: Dialogue Grounding and Physical Integration
**Evidence required**: Dialogue scenes examined for physical setting, action beats, and spatial awareness — whether conversations happen in realized space or floating "white room."
**Context needed**: scene
**Item count**: 3 criteria + 3 sentinels = 6 total

| ID | Name | Type |
|---|---|---|
| SC-118 | Grounding Dialogue in Physical Space | criterion |
| SC-178 | Physical Grounding and Blocking | criterion |
| ML-040 | Setting-Character Integration (scene formulation) | criterion |
| SS-298 | Talking Heads Without Physical Grounding | sentinel |
| SS-325 | White Room Dialogue (Talking Heads) | sentinel |
| SS-326 | White Room Syndrome | sentinel |

---

### Auditor: Figurative Language Quality
**Evidence required**: Metaphors, similes, and figurative constructions examined for originality, coherence, aptness, and whether they illuminate or obscure meaning.
**Context needed**: scene
**Item count**: 8 criteria + 8 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| SC-097 | Extended/Controlling Metaphor Craft | criterion |
| SC-101 | Figurative Language Coherence | criterion |
| SC-102 | Figurative Language Originality | criterion |
| SC-103 | Figurative Language Quality | criterion |
| SC-175 | Pathetic Fallacy Control | criterion |
| SC-177 | Personification Quality | criterion |
| SC-267 | Synesthesia and Cross-Sensory Imagery | criterion |
| ML-021 | Metaphor Pile-Up Without Coherent Vehicle (scene formulation) | sentinel |
| SS-007 | "Dance of" / "Tapestry of" / "Symphony of" Stock Metaphor Vehicles | sentinel |
| SS-023 | "Something Shifted" and Unearned Profundity | sentinel |
| SS-043 | Awkward/Generic Analogies | sentinel |
| SS-103 | Flowery But Incoherent Metaphors for Depth | sentinel |
| SS-143 | Metaphor Spam in Final Sentences | sentinel |
| SS-181 | Purple Prose / Ornamental Metaphor Overload | sentinel |
| SS-248 | S56: "Forged in the Crucible of" and Metaphorical Overreach | sentinel |
| ML-034 | S58: "Eyeball Kicks" — Stacked Nonsensical Metaphors (scene formulation) | sentinel |

---

### Auditor: Description — Sensory Detail and Imagery
**Evidence required**: Descriptive passages examined for sensory engagement, specificity, balance across modalities, and concreteness of detail.
**Context needed**: scene
**Item count**: 11 criteria + 7 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-076 | Economy of Description | criterion |
| SC-122 | Imagery-Clarity Balance | criterion |
| SC-224 | Sensory Balance Across Modalities | criterion |
| SC-225 | Sensory Embodiment | criterion |
| SC-226 | Sensory Engagement | criterion |
| SC-227 | Sensory Grounding | criterion |
| SC-228 | Sensory Specificity | criterion |
| SC-249 | Specificity of Detail | criterion |
| SC-299 | Word-Level Precision (Le Mot Juste) | criterion |
| ML-006 | Concrete vs. Abstract Description (scene formulation) | criterion |
| ML-039 | Sensory Detail as Plot Device (scene formulation) | criterion |
| SS-029 | Absence of Meaningful Silence or Negative Space | sentinel |
| SS-042 | Atmosphere Without Specificity | sentinel |
| SS-115 | Generic Sensory Description | sentinel |
| SS-281 | Sensing Without Sensing Sentinel | sentinel |
| SS-283 | Sensory Inventory Pattern | sentinel |
| SS-288 | Stacked Sensory Details | sentinel |
| ML-038 | Sensory Detail Absence or Overload (scene formulation) | sentinel |

---

### Auditor: Description — Structure, Pacing, and Integration
**Evidence required**: How descriptive passages are organized — their timing, proportion, relationship to action, and narrative function.
**Context needed**: scene
**Item count**: 10 criteria + 9 sentinels = 19 total

| ID | Name | Type |
|---|---|---|
| SC-057 | Description Pacing and Proportion | criterion |
| SC-137 | Maximalist Density and Accumulation | criterion |
| SC-184 | Prose Rhythm in Description | criterion |
| SC-191 | Purple Prose vs. Purposeful Lushness | criterion |
| SC-207 | Scene Anchoring and Spatial Clarity | criterion |
| SC-237 | Setting as Active Element | criterion |
| SC-240 | Show vs. Tell in Description | criterion |
| SC-245 | Significant Detail Selection | criterion |
| SC-270 | Temporal Specificity in Description | criterion |
| ML-009 | Description-Action Integration (scene formulation) | criterion |
| SS-009 | "Gentle Breeze" and Stock Atmospheric Phrases | sentinel |
| SS-034 | Adjective Stacking on Sensory Nouns | sentinel |
| SS-045 | Blocky Description-Dialogue-Description Structure | sentinel |
| SS-069 | Description That Defaults to Summary Over Scene | sentinel |
| SS-105 | Formulaic Descriptive Openings | sentinel |
| SS-149 | Monotonous Descriptive Rhythm | sentinel |
| SS-170 | Parallel Structure Overuse in Description | sentinel |
| SS-258 | S67: "Gentle Breeze" / "Blooming Flowers" / Generic Nature Description | sentinel |
| SS-080 | Em-Dash Overuse in Description | sentinel |

---

### Auditor: Description Filtered Through Character
**Evidence required**: Descriptive passages examined for whether they reveal the observing character's psychology, knowledge, and emotional state — or are delivered from a neutral camera.
**Context needed**: scene
**Item count**: 5 criteria + 5 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| SC-056 | Description Filtered Through POV | criterion |
| SC-058 | Description as Characterization | criterion |
| SC-158 | Objective Correlative | criterion |
| SC-159 | Objective Correlative in POV | criterion |
| SC-229 | Sensory Specificity and Immersion | criterion |
| SS-111 | Generic Character Description on Introduction | sentinel |
| SS-282 | Sensory Detail Without POV Integration | sentinel |
| SS-109 | Front-Loaded Character Descriptions | sentinel |
| SS-098 | External Character Description Default | sentinel |
| SS-223 | S33: External Character Description as Default (Gemini-Specific) | sentinel |

---

### Auditor: Purple Prose and Overwrought Language
**Evidence required**: Passages where ornate, elaborate language may overwhelm narrative function — excessive metaphor stacking, florid descriptions in mundane scenes, style exceeding content.
**Context needed**: scene
**Item count**: 2 criteria + 7 sentinels = 9 total

| ID | Name | Type |
|---|---|---|
| SC-190 | Purple Prose Avoidance | criterion |
| SC-301 | Worldconjuring vs. Worldbuilding (Artistic Integration) | criterion |
| SS-168 | Overwrought Purple Prose | sentinel |
| SS-182 | Purple Prose / Overwrought Metaphor Sentinel | sentinel |
| SS-183 | Purple Prose in Expository Passages | sentinel |
| SS-243 | S51: Purple Prose and Overwrought Description | sentinel |
| SS-300 | Telling-Then-Showing Redundancy | sentinel |
| ML-136 | Triple-Stacked Descriptors (scene formulation) | sentinel |
| ML-054 | Tonal Consistency in Description (scene formulation) | criterion |

---

### Auditor: Atmosphere, Mood, and Setting Integration
**Evidence required**: How physical details, weather, architecture, and environment work together to create emotional atmosphere and serve the narrative.
**Context needed**: scene, chapter_plan
**Item count**: 5 criteria + 5 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| SC-007 | Atmosphere, Mood, and Tone Integration | criterion |
| SC-050 | Cultural Depth and Specificity | criterion |
| SC-223 | Sense of Wonder and the Numinous | criterion |
| ML-063 | Atmosphere and Mood Creation (scene formulation) | criterion |
| ML-018 | Internal Consistency of World Rules (scene formulation) | criterion |
| SS-036 | Adverb-Inflated Setting Description | sentinel |
| SS-054 | Cliche Reaching in Setting Description | sentinel |
| SS-116 | Generic Setting Description | sentinel |
| SS-309 | Throat-Clearing World Introduction | sentinel |
| SS-322 | View-From-Nowhere Setting Description | sentinel |

---

### Auditor: POV Consistency and Discipline
**Evidence required**: Sentence-level narrative voice examined for whether POV type, person, depth, and tense remain consistent — detecting head-hopping, knowledge boundary violations, and unauthorized perspective shifts.
**Context needed**: scene
**Item count**: 14 criteria + 3 sentinels = 17 total

| ID | Name | Type |
|---|---|---|
| SC-110 | Focalization Clarity | criterion |
| SC-116 | Genre-Appropriate POV Convention | criterion |
| SC-119 | Head-Hopping Control | criterion |
| SC-162 | POV Character Selection Per Scene | criterion |
| SC-163 | POV Consistency | criterion |
| SC-164 | POV Consistency at Prose Level | criterion |
| SC-165 | POV Discipline Within Scenes | criterion |
| SC-166 | POV Information Discipline | criterion |
| SC-167 | POV Knowledge Boundary Consistency | criterion |
| SC-169 | POV Transition Craft | criterion |
| SC-180 | Point of View Consistency | criterion |
| SC-272 | Tense Consistency and Purposefulness | criterion |
| SC-273 | Tense Selection Appropriateness | criterion |
| ML-022 | Narrative Voice and Tonal Consistency (scene formulation) | criterion |
| SS-010 | "He Felt / She Felt" Construction Density | sentinel |
| SS-120 | Head-Hopping Within Scene | sentinel |
| SS-242 | S50: Tense Inconsistency Within Passages | sentinel |

---

### Auditor: POV Techniques and Narrative Distance
**Evidence required**: Extended narration examined for how narrative distance is managed — free indirect discourse, filter words, psychic distance, narrator voice blending, and the spectrum from close interiority to objective distance.
**Context needed**: scene
**Item count**: 14 criteria + 6 sentinels = 20 total

| ID | Name | Type |
|---|---|---|
| SC-009 | Author Intrusion Avoidance | criterion |
| SC-010 | Author Intrusion Discipline | criterion |
| SC-011 | Author/Narrator Voice Separation | criterion |
| SC-047 | Contextual Distance Calibration | criterion |
| SC-104 | Filter Word Control | criterion |
| SC-105 | Filter Word Management | criterion |
| SC-107 | First-Person Self-Description Discipline | criterion |
| SC-112 | Free Indirect Discourse Skill | criterion |
| SC-128 | Information Management Through POV | criterion |
| SC-148 | Narrative Depth Variation | criterion |
| SC-150 | Narrative Stance/Tone Consistency | criterion |
| SC-188 | Psychic/Narrative Distance Control | criterion |
| SC-204 | Retrospective/Temporal Narrator Distance | criterion |
| SC-242 | Showing vs Telling Through POV | criterion |
| SS-030 | Absence of Narrator Intentionality | sentinel |
| SS-032 | Absence of Subtext in POV Character's Observations | sentinel |
| SS-046 | Blocky Prose Architecture | sentinel |
| SS-099 | Filter Word Saturation | sentinel |
| SS-102 | Flat Narrative Arc Within POV | sentinel |
| SS-150 | Monotonous Sentence Cadence | sentinel |

---

### Auditor: Specialized Narration Modes
**Evidence required**: Passages using specialized narration techniques — unreliable narration, omniscient voice, second person, epistolary, stream of consciousness — examining craft and purpose.
**Context needed**: scene
**Item count**: 8 criteria + 2 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| SC-072 | Dramatic Irony Through POV | criterion |
| SC-092 | Epistolary/Document Narration Craft | criterion |
| SC-129 | Interior Monologue Integration | criterion |
| SC-153 | Narrator-Narratee Relationship | criterion |
| SC-160 | Omniscient Narrator Voice Distinctiveness | criterion |
| SC-222 | Second Person Narration Craft | criterion |
| SC-252 | Stream of Consciousness Craft | criterion |
| SC-287 | Unreliable Narrator Craft | criterion |
| SS-136 | Lists of Three | sentinel |
| SS-174 | Personality Reset Between Scenes | sentinel |

---

### Auditor: Emotional Rendering Craft
**Evidence required**: Passages conveying character emotion — examining whether emotions are shown through behavior, physicality, dialogue, and action vs. labeled directly through narration.
**Context needed**: scene
**Item count**: 10 criteria + 8 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-021 | Emotional Rendering Quality | criterion |
| SC-081 | Emotional Authenticity | criterion |
| SC-084 | Emotional Exposition Quality | criterion |
| SC-085 | Emotional Mode Craft (Maass) | criterion |
| SC-086 | Emotional Mode Deployment | criterion |
| SC-193 | RUE (Resist the Urge to Explain) | criterion |
| SC-238 | Show vs Tell Calibration | criterion |
| SC-239 | Show vs. Tell Effectiveness | criterion |
| SC-241 | Show/Tell Balance for Pacing Control | criterion |
| SC-187 | Psychic Distance Management for Exposition | criterion |
| SS-053 | Cliche Physical Reactions | sentinel |
| SS-055 | Cliched Emotional Formulas | sentinel |
| SS-083 | Emotional Label-Dumping | sentinel |
| SS-095 | Explicit Emotion Labeling (On-the-Nose Narration) | sentinel |
| SS-132 | Labeled Emotion Exposition | sentinel |
| SS-151 | Narrative Tells Emotions Instead of Enacting Them | sentinel |
| SS-187 | Redundant Emotional Telling After Showing | sentinel |
| SS-299 | Tell-Over-Show Emotional Declarations | sentinel |

---

### Auditor: Emotional Tone and Positivity Bias
**Evidence required**: Emotional register across scenes — examining whether there is authentic tonal variety, genuine darkness, or whether the text defaults to positivity, rapid resolution, and emotional flatness.
**Context needed**: scene, preceding_scenes
**Item count**: 3 criteria + 14 sentinels = 17 total

| ID | Name | Type |
|---|---|---|
| SC-088 | Emotional Pacing for Heavy Content | criterion |
| SC-145 | Mood Transition Smoothness | criterion |
| ML-053 | Tonal Consistency (scene formulation) | criterion |
| SS-040 | All-Positive Emotional Palette | sentinel |
| SS-082 | Emotional Flatness in High-Stakes Scenes | sentinel |
| SS-086 | Emotional Tone Inconsistency | sentinel |
| SS-087 | Emotionally Flat During High-Stakes Events | sentinel |
| SS-088 | Emotionally Flat Narrative Despite Dramatic Events | sentinel |
| SS-112 | Generic Emotional Reactions | sentinel |
| SS-123 | Homogeneous Emotional Positivity | sentinel |
| SS-126 | Homogeneously Positive Emotional Register | sentinel |
| SS-148 | Monotone Emotional Register Sentinel | sentinel |
| SS-152 | Nauseatingly Upbeat Scene Endings | sentinel |
| SS-177 | Positive-Outcome Bias in Narrative Trajectory | sentinel |
| SS-206 | S15: Every Scene/Chapter Ends Positively | sentinel |
| SS-253 | S61: Homogeneously Positive Emotional Valence | sentinel |
| ML-055 | Tonal Whiplash Without Foreshadowing (scene formulation) | sentinel |

---

### Auditor: Character Interiority and Psychological Depth
**Evidence required**: Internal experience passages — examining the POV character's thoughts, feelings, unspoken reactions, psychological complexity, and how interiority creates reader connection.
**Context needed**: scene, relevant_context
**Item count**: 10 criteria + 5 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| SC-030 | Character Credibility | criterion |
| SC-032 | Character Interiority Quality | criterion |
| SC-130 | Interiority Balance | criterion |
| SC-197 | Reader-Character Identification Bond | criterion |
| ML-066 | Character Complexity Through Contradiction (scene formulation) | criterion |
| ML-067 | Character Consistency Under Change (scene formulation) | criterion |
| ML-069 | Character-Driven Stakes (scene formulation) | criterion |
| ML-070 | Character-as-Theme (scene formulation) | criterion |
| ML-079 | Meaningful vs Cosmetic Flaws (scene formulation) | criterion |
| ML-103 | Character Agency (scene formulation) | criterion |
| SS-180 | Protagonist Described as Determined/Brave/Kind Without Demonstration | sentinel |
| SS-287 | Single-Trait Character Repetition | sentinel |
| ML-093 | Cosmetic Flaws Only (scene formulation) | sentinel |
| ML-098 | Missing Character Wound (scene formulation) | sentinel |
| ML-100 | Stereotypical Character Details (scene formulation) | sentinel |

---

### Auditor: Reader Engagement and Immersion
**Evidence required**: The reading experience as a whole — examining whether the text produces absorption, transportation, identification, and sustained engagement through the combination of all craft elements.
**Context needed**: scene
**Item count**: 12 criteria + 6 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| SC-031 | Character Identification | criterion |
| SC-052 | Curiosity Gap Management | criterion |
| SC-090 | Empathic Character Connection | criterion |
| SC-100 | Fictive Dream Continuity (Gardner) | criterion |
| SC-142 | Microtension (Page-Level Engagement) | criterion |
| SC-151 | Narrative Transportation | criterion |
| SC-198 | Reading Flow State | criterion |
| SC-251 | Stakes and Reader Investment | criterion |
| SC-286 | Unreliable Narrator Cognitive Engagement | criterion |
| SC-290 | Vivid and Continuous Dream | criterion |
| ML-046 | Suspension of Disbelief (scene formulation) | criterion |
| ML-075 | Emotional Resonance and Memorability (scene formulation) | criterion |
| SS-031 | Absence of Subtext | sentinel |
| SS-074 | Dream Sequence or Flashback as Revelation | sentinel |
| SS-075 | Dream Sequences and Flashbacks as Default | sentinel |
| SS-122 | Hedging Qualifiers and Weasel Phrasing | sentinel |
| SS-137 | Lists of Three Descriptors | sentinel |
| SS-222 | S31: Dream Sequences as Default Narrative Device (GPT-Specific) | sentinel |

---

### Auditor: Exposition Handling and Information Delivery
**Evidence required**: Exposition passages — examining how background information, world mechanics, and context are delivered — timing, integration with action, and avoidance of info-dumps.
**Context needed**: scene
**Item count**: 10 criteria + 10 sentinels = 20 total

| ID | Name | Type |
|---|---|---|
| SC-013 | Backstory Integration | criterion |
| SC-073 | Dramatic Irony and Information Asymmetry Use | criterion |
| SC-095 | Exposition Handling | criterion |
| SC-096 | Exposition Vehicle Character Design | criterion |
| SC-125 | Information Delivery Timing (Rate of Revelation) | criterion |
| SC-141 | Micro-Tension in Expository Passages | criterion |
| SC-183 | Prologue Exposition Management | criterion |
| SC-260 | Subtext as Pacing Lubricant | criterion |
| SC-288 | Unreliable Narrator Information Control | criterion |
| SC-297 | Withholding Discipline (Fair Play Information Control) | criterion |
| SS-101 | Flat Exposition Voice | sentinel |
| SS-110 | Frontloaded Exposition Block | sentinel |
| SS-131 | Information-Free Dialogue Padding | sentinel |
| SS-157 | No Open Questions | sentinel |
| SS-162 | Normative Interpretation Imposition | sentinel |
| SS-188 | Redundant Explanation After Demonstration | sentinel |
| SS-192 | Repetitive Information Delivery | sentinel |
| SS-286 | Simultaneous Name Overload | sentinel |
| SS-327 | Worldbuilding Lecture Passage | sentinel |
| SS-301 | The "As You Know, Bob" Exposition Dump | sentinel |

---

### Auditor: Scene Structure and Dramatic Shape
**Evidence required**: The scene as a dramatic unit — examining goals, conflict, turning points, beats, polarity shifts, and whether the scene functions as a complete structural entity.
**Context needed**: scene, chapter_plan
**Item count**: 14 criteria + 8 sentinels = 22 total

| ID | Name | Type |
|---|---|---|
| SC-111 | Four-Question Scene Evaluation | criterion |
| SC-182 | Proactive vs. Reactive Character Balance | criterion |
| SC-208 | Scene Beat Rhythm | criterion |
| SC-210 | Scene Causality (Intra-Scene) | criterion |
| SC-211 | Scene Emotional Arc | criterion |
| SC-212 | Scene Ending Quality (Exit Hooks) | criterion |
| SC-213 | Scene Internal Pacing Curve | criterion |
| SC-214 | Scene Pacing Proportionality | criterion |
| SC-215 | Scene Structure Variety | criterion |
| SC-220 | Scene-Level Information Management | criterion |
| SC-221 | Scene-Level Plot-Character-Theme Integration | criterion |
| SC-236 | Sequel (Reaction) Quality | criterion |
| ML-035 | Scene Opening Quality (scene formulation) | criterion |
| ML-076 | Enter Late, Exit Early (scene formulation) | criterion |
| SS-073 | Disproportionate Scene Investment | sentinel |
| SS-082 | Emotional Flatness in High-Stakes Scenes (structure) | sentinel |
| SS-090 | Entrance/Exit Ceremony | sentinel |
| SS-100 | Flat Emotional Arcs Within Scenes | sentinel |
| SS-106 | Formulaic Scene Openings | sentinel |
| SS-114 | Generic Scene Stakes | sentinel |
| SS-164 | Obstacles Without Consequences | sentinel |
| SS-172 | Passive Protagonist Throughout Scenes | sentinel |

---

### Auditor: Scene Polarity, Turns, and Value Shifts
**Evidence required**: Whether scenes produce meaningful change — examining the value-charged condition at beginning and end, the turning mechanism, and whether static scenes masquerade as dynamic ones.
**Context needed**: scene, chapter_plan
**Item count**: 5 criteria + 8 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| SC-285 | Turn Variety Across Scenes | criterion |
| ML-016 | Impossible Choice Presence (scene formulation) | criterion |
| ML-026 | Passive Protagonist (scene formulation) | sentinel |
| ML-083 | Reaction Beat Pacing / Recovery Beats (scene formulation) | criterion |
| ML-060 | Promise-Progress-Payoff Integrity (scene formulation) | criterion |
| SS-147 | Missing Sequel / No Emotional Processing | sentinel |
| SS-190 | Repeated Emotional Tags Instead of Emotional Arcs | sentinel |
| SS-200 | Rule-of-Three Lists in Scene Description | sentinel |
| SS-275 | Scene-Level Information Dump | sentinel |
| SS-276 | Scenes Without Polarity Shifts | sentinel |
| SS-284 | Setup Without Payoff / Payoff Without Setup | sentinel |
| SS-285 | Seven Deadly Static Scene Types | sentinel |
| ML-090 | All Scenes End with Clean Resolution (scene formulation) | sentinel |

---

### Auditor: Scene-Level Subtext, Theme, and Irony
**Evidence required**: Scenes examined for layers of meaning beneath the surface — thematic content operating through implication, dramatic irony, and whether meaning is dramatized or declared.
**Context needed**: scene, chapter_plan
**Item count**: 6 criteria + 7 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| SC-262 | Subtext as Thematic Vehicle | criterion |
| SC-276 | Thematic Freshness and Originality | criterion |
| SC-278 | Theme-Plot Integration | criterion |
| ML-023 | No Thematic Counter-Argument Present (scene formulation) | sentinel |
| ML-045 | Surface-Level Thematic Details Without Structural Integration (scene formulation) | sentinel |
| ML-049 | Thematic Subplots and Mirroring (scene formulation) | criterion |
| ML-061 | Moral and Thematic Complexity (scene formulation) | criterion |
| ML-114 | Motif Development and Evolution (scene formulation) | criterion |
| SS-033 | Absence of Subtext in Thematic Dialogue | sentinel |
| SS-056 | Cliched Symbolic Imagery | sentinel |
| SS-096 | Exposed Subtext (Telling the Theme) | sentinel |
| SS-306 | Theme Stated Through Character Speech Rather Than Dramatized | sentinel |
| SS-067 | Denouement as Theme Statement | sentinel |

---

### Auditor: Pacing — Macro-Rhythm and Tempo Control
**Evidence required**: Scene and chapter pacing patterns — examining the alternation of fast/slow, dense/sparse, action/reflection, and whether the reading rhythm serves the narrative.
**Context needed**: scene, preceding_scenes, chapter_plan
**Item count**: 12 criteria + 7 sentinels = 19 total

| ID | Name | Type |
|---|---|---|
| SC-001 | Action-to-Reflection Ratio | criterion |
| SC-014 | Boredom Prevention | criterion |
| SC-026 | Chapter/Scene Length Variation | criterion |
| SC-115 | Genette's Duration Spectrum (Narrative Speed Control) | criterion |
| SC-120 | Hook Placement and Density | criterion |
| SC-126 | Information Density Management | criterion |
| SC-168 | POV Switch Pacing as Hook | criterion |
| SC-170 | Pacing Rhythm and Variation | criterion |
| SC-205 | Rhythm Pattern Variety | criterion |
| SC-218 | Scene vs. Summary Balance | criterion |
| SC-269 | Temporal Compression and Expansion | criterion |
| SC-294 | Weight Distribution (Word Count Proportional to Narrative Importance) | criterion |
| ML-020 | Macro Pacing Variation (scene formulation) | criterion |
| SS-071 | Deteriorating Quality in Later Chapters | sentinel |
| SS-072 | Dialogue-Exposition-Narration Block Structure | sentinel |
| SS-093 | Every Chapter Ends with a Cliffhanger | sentinel |
| SS-158 | No Recovery Beats Between Action Sequences | sentinel |
| SS-167 | Overexplicit Emotional Narration | sentinel |
| SS-173 | Perfectly Smooth Transitions | sentinel |
| ML-043 | Subplot Pacing as Counterpoint (scene formulation) | criterion |

---

### Auditor: Scene Transition and Backstory Integration
**Evidence required**: Transitions between scenes, time skips, flashbacks, and how backstory is woven into the present timeline without destroying momentum.
**Context needed**: scene, preceding_scenes
**Item count**: 7 criteria + 3 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| SC-216 | Scene Transition Craft | criterion |
| SC-217 | Scene Transition Quality | criterion |
| SC-219 | Scene vs. Summary Deployment | criterion |
| SC-274 | Tension Layering (Multiple Simultaneous Tensions) | criterion |
| SC-280 | Ticking Clock / Narrative Urgency | criterion |
| SC-281 | Time Skip Clarity and Justification | criterion |
| ML-077 | Flashback Integration Without Momentum Loss (scene formulation) | criterion |
| SS-047 | Blocky Prose Rhythm | sentinel |
| SS-166 | Oscillating Prose Modes | sentinel |
| ML-010 | Exposition Front-Loading (scene formulation) | sentinel |

---

### Auditor: Continuity — Factual Details and Physical Logic
**Evidence required**: Cross-referencing concrete details across scenes — character descriptions, object locations, spatial positions, factual claims, and physical actions for consistency.
**Context needed**: scene, relevant_context, preceding_scenes
**Item count**: 9 criteria + 10 sentinels = 19 total

| ID | Name | Type |
|---|---|---|
| SC-004 | Anachronism Avoidance | criterion |
| SC-033 | Character Knowledge Tracking | criterion |
| SC-043 | Commonsense Physical Plausibility | criterion |
| SC-098 | Fact-Checking for Fiction | criterion |
| SC-099 | Factual Detail Consistency | criterion |
| SC-123 | In-Scene Object and Action Continuity | criterion |
| SC-248 | Spatial Logic and Geography | criterion |
| SC-282 | Timeline and Chronological Coherence | criterion |
| ML-062 | Aggregate Consistency Across Length (scene formulation) | criterion |
| SS-049 | Character Name Inconsistency | sentinel |
| SS-060 | Context Loss Contradiction | sentinel |
| SS-063 | Convenient Amnesia | sentinel |
| SS-085 | Emotional State Reset | sentinel |
| SS-118 | Geographic Contradiction | sentinel |
| SS-130 | Impossible Information Access | sentinel |
| SS-145 | Mid-Narrative Detail Drift | sentinel |
| SS-163 | Object Teleportation | sentinel |
| SS-176 | Physical Description Contradiction | sentinel |
| SS-311 | Timeline Impossibility | sentinel |

---

### Auditor: Continuity — Internal Rules and World Consistency
**Evidence required**: Tracking consistency of story-specific rules — magic systems, technology, social rules, character abilities, and worldbuilding implications across the text.
**Context needed**: scene, relevant_context, preceding_scenes
**Item count**: 6 criteria + 6 sentinels = 12 total

| ID | Name | Type |
|---|---|---|
| SC-132 | Internal Rule Consistency (Magic Systems, Technology, Social Rules) | criterion |
| SC-179 | Plot Armor / Consequence Consistency | criterion |
| SC-203 | Retroactive Continuity (Retcon) Avoidance | criterion |
| SC-300 | Worldbuilding Implication Consistency | criterion |
| ML-027 | Perfect Internal Consistency With No Acknowledged Contradictions (scene formulation) | sentinel |
| ML-074 | Emotional Continuity (scene formulation) | criterion |
| SS-107 | Formulaic Structural Repetition | sentinel |
| SS-142 | Memory/Continuity Failures Across Scenes | sentinel |
| SS-175 | Personality Trait Reversal Without Arc | sentinel |
| SS-189 | Relationship State Incoherence | sentinel |
| SS-198 | Rule-Violating Convenience | sentinel |
| SS-260 | S69: Continuity Collapse in Long-Form Fiction | sentinel |

---

### Auditor: AI Structural Tells (Scene-Level)
**Evidence required**: Scene-level structural patterns characteristic of AI generation — predictable scene shapes, homogeneous emotional registers, therapy-speak resolutions, and sanitized conflict.
**Context needed**: scene
**Item count**: 3 criteria + 14 sentinels = 17 total

| ID | Name | Type |
|---|---|---|
| SC-135 | Literary Causation (Character-Driven) | criterion |
| ML-005 | Conceptual Originality (scene formulation) | criterion |
| ML-025 | Originality of Execution (scene formulation) | criterion |
| SS-061 | Context Poisoning (Escalating Cliche) | sentinel |
| SS-070 | Details Feel Random Rather Than Chosen | sentinel |
| SS-129 | Imposing Conventional Interpretive Frameworks | sentinel |
| SS-153 | Neat Resolution / Anti-Ambiguity Sentinel | sentinel |
| SS-160 | No Subtext in Dialogue | sentinel |
| SS-199 | Rule-of-Three Default | sentinel |
| SS-204 | S13: "Air Was Thick" / "Hung in the Air" / "Eyes Darting" | sentinel |
| SS-207 | S16: Characters State Their Emotions Directly | sentinel |
| SS-219 | S29: Sanitized Villain Behavior | sentinel |
| SS-237 | S46: "Fostering" / "Foster" as Default Growth Verb | sentinel |
| SS-240 | S49: "Something Shifted" / "Everything Changed" Unearned Transition | sentinel |
| SS-244 | S52: No Character Makes a Morally Questionable Choice | sentinel |
| SS-245 | S53: Dialogue Lacks Subtext (Characters Say What They Mean) | sentinel |
| SS-246 | S54: No Character Has a Backstory That Causes Present Pain | sentinel |

---

### Auditor: AI Structural Tells (Pattern Repetition)
**Evidence required**: Cross-scene and cross-chapter structural patterns — detecting whether every scene follows the same template, uses the same emotional arc, or produces the same resolution pattern.
**Context needed**: scene, preceding_scenes
**Item count**: 3 criteria + 12 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| ML-033 | Repetitive Scene Beat Pattern (scene formulation) | sentinel |
| ML-080 | Non-Default Narrative Choices (scene formulation) | criterion |
| ML-089 | Trope Awareness and Subversion (scene formulation) | criterion |
| ML-081 | Novelistic Discovery (scene formulation) | criterion |
| SS-039 | All Scenes End with Clean Resolution (sentinel) | sentinel |
| SS-218 | S28: "Landscape" as Abstract Metaphor | sentinel |
| SS-261 | S6: Tricolon/Rule-of-Three Abuse | sentinel |
| SS-263 | S71: Existential Themes as Default Subject Matter | sentinel |
| SS-264 | S72: Missing Cause-and-Effect Chains | sentinel |
| SS-265 | S73: Protagonist Lacks Agency / Is Passive Observer | sentinel |
| SS-266 | S74: Conflict Avoidance / Characters Too Nice | sentinel |
| SS-270 | S7: "The Weight of" / "A Sense of" / "A Mix of" Emotional Formulas | sentinel |
| SS-272 | S8: "Nestled" in Geographic Description | sentinel |
| SS-310 | Tidy Resolution / Positive Ending Default | sentinel |
| SS-313 | Tricolon Abuse (Rule of Three Overuse) | sentinel |

---

### Auditor: Reader Emotion and Engagement Mechanics
**Evidence required**: How specific craft techniques create reader emotional response — catharsis, subtext, therapy-speak avoidance, dramatic irony, and whether the text generates emotion or merely describes it.
**Context needed**: scene
**Item count**: 5 criteria + 7 sentinels = 12 total

| ID | Name | Type |
|---|---|---|
| ML-073 | Dramatic Irony (scene formulation) | criterion |
| ML-085 | Surprise and Misdirection (scene formulation) | criterion |
| ML-086 | Suspense and Anticipation (scene formulation) | criterion |
| ML-087 | Symbolism and Image System Effectiveness (scene formulation) | criterion |
| ML-127 | Empathic Engagement (scene formulation) | criterion |
| SS-197 | Rule of Three Overuse Sentinel | sentinel |
| SS-278 | Self-Contained Scene Syndrome Sentinel | sentinel |
| SS-291 | Story Reads Like Plot Summary Rather Than Lived Experience | sentinel |
| SS-293 | Subtext Vacuum Sentinel | sentinel |
| SS-294 | Subtext-Free Dialogue | sentinel |
| SS-305 | Thematic Thesis Statement | sentinel |
| SS-307 | Therapy-Speak Resolution | sentinel |

---

### Auditor: Scene-Level Plot Mechanics
**Evidence required**: How individual scenes connect to and drive the larger plot — causal chains, coincidence management, and whether scenes earn their place in the narrative.
**Context needed**: scene, chapter_plan, relevant_context
**Item count**: 7 criteria + 5 sentinels = 12 total

| ID | Name | Type |
|---|---|---|
| ML-002 | Circling Conflicts (scene formulation) | sentinel |
| ML-004 | Coincidence Management (scene formulation) | criterion |
| ML-014 | Genre-Flavored Non-Genre Story (scene formulation) | sentinel |
| ML-017 | Inciting Incident Timing (scene formulation) | criterion |
| ML-037 | Scenes Opening with Exposition Dumps (scene formulation) | sentinel |
| ML-051 | Three-Chapter Degradation (scene formulation) | sentinel |
| ML-052 | Tidy Single-Track Plots (scene formulation) | sentinel |
| ML-057 | Unfired Chekhov's Guns (scene formulation) | sentinel |
| ML-058 | Uniform Chapter/Scene Lengths (scene formulation) | sentinel |
| ML-064 | Audience Expectation Alignment (scene formulation) | criterion |
| ML-091 | Backstory Info-Dump in Opening (scene formulation) | sentinel |
| ML-092 | Conflict Resolved Through Communication (scene formulation) | sentinel |

---

### Auditor: Scene-Level Character Dynamics
**Evidence required**: How characters interact within scenes — relationship dynamics, ensemble differentiation, and whether characters function as distinct agents or interchangeable units.
**Context needed**: scene, relevant_context
**Item count**: 6 criteria + 6 sentinels = 12 total

| ID | Name | Type |
|---|---|---|
| ML-068 | Character Self-Revelation (scene formulation) | criterion |
| ML-078 | Flat vs Round Character Deployment (scene formulation) | criterion |
| ML-084 | Relationship Dynamics (scene formulation) | criterion |
| ML-088 | Three-Level Stakes Architecture (scene formulation) | criterion |
| ML-050 | Thematic Unity Across Story Elements (scene formulation) | criterion |
| SC-196 | Reader Ahead of Character Problem | criterion |
| SS-321 | Verbatim Scene/Paragraph Repetition | sentinel |
| SS-328 | Zero Subtext — Everything Is On-the-Nose | sentinel |
| SS-186 | Reconciliation Without Reckoning | sentinel |
| ML-094 | Episodic Scene Sequence (scene formulation) | sentinel |
| ML-095 | Homogeneous Ensemble (scene formulation) | sentinel |
| ML-097 | Immediate Forgiveness After Betrayal (scene formulation) | sentinel |

---

### Auditor: Scene-Level Worldbuilding in Prose
**Evidence required**: How worldbuilding manifests in actual prose — whether the world feels lived-in at the sentence level, whether speculative elements are integrated into character experience.
**Context needed**: scene, relevant_context
**Item count**: 4 criteria + 4 sentinels = 8 total

| ID | Name | Type |
|---|---|---|
| ML-031 | Premise Stated But Never Explored (scene formulation) | sentinel |
| ML-047 | Suspension of Disbelief Maintenance (scene formulation) | criterion |
| ML-102 | The Monoculture Alien (scene formulation) | sentinel |
| ML-135 | Opening Paragraph Uses Stock Attention-Grabbing Formula (scene formulation) | sentinel |
| ML-099 | Rapid Conflict Resolution (scene formulation) | sentinel |
| ML-096 | Homogeneous Narrative Structure (scene formulation) | sentinel |
| ML-101 | Sycophantic Resolution (scene formulation) | sentinel |
| SS-315 | Uniform Confidence in World Description | sentinel |

---

### Auditor: Worldbuilding in Setting Description
**Evidence required**: How setting and world details are presented in prose — whether world feels alive, specific, and integrated with the narrative vs. generic background.
**Context needed**: scene
**Item count**: 2 criteria + 3 sentinels = 5 total

| ID | Name | Type |
|---|---|---|
| SS-036 | Adverb-Inflated Setting Description | sentinel |
| SS-054 | Cliche Reaching in Setting Description | sentinel |
| SS-323 | Visually-Dominant Description Without Other Senses | sentinel |
| SS-304 | The Tonally Flat Genre Execution | sentinel |
| SS-303 | The Non-Barking Dog Void | sentinel |

---

## Chapter-Plan-Level Auditors

### Auditor: Plot Causality and Logical Structure
**Evidence required**: The scene-by-scene plan examined for cause-and-effect chains — whether each scene follows logically from the preceding one, and whether the causal spine holds.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 13 criteria + 5 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| CC-006 | Anti-Episodic Integration | criterion |
| CC-015 | Causal Chain Integrity | criterion |
| CC-030 | Commensurate Cause and Effect | criterion |
| CC-043 | Contrivance Avoidance | criterion |
| CC-053 | De-escalation Avoidance | criterion |
| CC-057 | Dual-Level Causal Logic (Plot + Character) | criterion |
| CC-096 | Internal Consistency / World Logic | criterion |
| CC-110 | Narrative Momentum | criterion |
| CC-112 | Nonlinear Structure Integrity | criterion |
| CC-121 | Pixar Causal Spine | criterion |
| CC-185 | The But/Therefore Test | criterion |
| ML-002 | Circling Conflicts (chapter-plan formulation) | sentinel |
| ML-004 | Coincidence Management (chapter-plan formulation) | criterion |
| CS-008 | And-Then Plotting | sentinel |
| CS-021 | Contradictory Plot Logic | sentinel |
| CS-023 | Convenient Information Arrival | sentinel |
| CS-055 | Missing Causality for Events | sentinel |
| CS-057 | Narrative Derailment | sentinel |

---

### Auditor: Protagonist Agency and Goal Pursuit
**Evidence required**: The plan examined for whether the protagonist actively drives the plot through choices — goal clarity, agency, try-fail cycles, and proactive decision-making.
**Context needed**: chapter_plan, novel_plan
**Item count**: 11 criteria + 6 sentinels = 17 total

| ID | Name | Type |
|---|---|---|
| CC-021 | Character Agency in Conflict | criterion |
| CC-024 | Character Desire Specificity | criterion |
| CC-092 | Idiot Plot Avoidance | criterion |
| CC-099 | Irreversibility of Key Decisions | criterion |
| CC-127 | Protagonist Agency | criterion |
| CC-128 | Protagonist Goal Specificity | criterion |
| CC-203 | Try-Fail Cycle Effectiveness | criterion |
| CC-204 | Try-Fail Cycles | criterion |
| ML-026 | Passive Protagonist (chapter-plan formulation) | sentinel |
| ML-103 | Character Agency (chapter-plan formulation) | criterion |
| CC-125 | Progressive Complications | criterion |
| CS-017 | Consequence-Free Action | sentinel |
| CS-026 | Dangling Setups | sentinel |
| CS-044 | Idiot Plot | sentinel |
| CS-045 | Idiot Plot Dependency | sentinel |
| CS-066 | Purposeless Detail | sentinel |
| CS-096 | Unearned Reversal | sentinel |

---

### Auditor: Conflict Quality and Escalation
**Evidence required**: The plan's conflict architecture — types, escalation pattern, variety, and whether conflicts arise organically from character and situation.
**Context needed**: chapter_plan, novel_plan
**Item count**: 14 criteria + 6 sentinels = 20 total

| ID | Name | Type |
|---|---|---|
| CC-016 | Central Conflict Clarity | criterion |
| CC-032 | Conflict Escalation Variety | criterion |
| CC-035 | Conflict Organicism | criterion |
| CC-038 | Conflict Variety | criterion |
| CC-039 | Conflict as Character Revelation | criterion |
| CC-040 | Conflict-Driven Escalation vs. Forced Escalation | criterion |
| CC-071 | Failure as Genuine Possibility | criterion |
| CC-097 | Internal-External Conflict Integration | criterion |
| CC-107 | Multi-Layered Conflict Structure | criterion |
| CC-113 | Obstacle Difficulty Calibration | criterion |
| CC-184 | Tension vs. Conflict Distinction | criterion |
| CC-205 | Unresolved Questions as Engagement | criterion |
| ML-105 | Conflict Evolution (chapter-plan formulation) | criterion |
| CC-079 | Four Throughline Completeness | criterion |
| CS-005 | Abstract Stakes Only | sentinel |
| CS-007 | All Conflict Is External | sentinel |
| CS-032 | Every Scene Is a Fight | sentinel |
| CS-036 | Flat Escalation (No Rising Action) | sentinel |
| CS-083 | Symmetrical Conflict (Neat Opposition) | sentinel |
| CS-097 | Uniform Conflict Mode | sentinel |

---

### Auditor: Stakes and Consequences
**Evidence required**: The plan examined for what characters stand to lose or gain — clarity, personal grounding, escalation, and whether consequences persist.
**Context needed**: chapter_plan, novel_plan
**Item count**: 10 criteria + 8 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| CC-041 | Consequence Persistence | criterion |
| CC-042 | Consequences Permanence | criterion |
| CC-048 | Cost of Victory | criterion |
| CC-174 | Stakes Clarity | criterion |
| CC-175 | Stakes Clarity and Escalation | criterion |
| CC-176 | Narrative Escalation | criterion |
| CC-207 | Urgency and Time Pressure | criterion |
| ML-082 | Personal Stakes Grounding (chapter-plan formulation) | criterion |
| ML-088 | Three-Level Stakes Architecture (chapter-plan formulation) | criterion |
| CC-195 | Threat Proximity and Imminence | criterion |
| CS-018 | Consequence-Free Action Scenes | sentinel |
| CS-030 | Escalation by External Event Only | sentinel |
| CS-038 | Flat Stakes (No Escalation) | sentinel |
| CS-062 | No-Cost Victory | sentinel |
| CS-078 | Stakes Never Articulated or Escalated | sentinel |
| CS-079 | Stakes Stated But Not Demonstrated | sentinel |
| CS-085 | Telescoped Emotional Processing | sentinel |
| CS-086 | Tension Without Payoff (Dangling Threat) | sentinel |

---

### Auditor: Conflict Resolution and Climax Quality
**Evidence required**: How conflicts resolve — whether resolutions are earned, emerge from character action, avoid deus ex machina, and deliver satisfying closure.
**Context needed**: chapter_plan, novel_plan
**Item count**: 8 criteria + 8 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| CC-027 | Climax Effectiveness and Earned Resolution | criterion |
| CC-036 | Conflict Resolution Earnedness | criterion |
| CC-054 | Deus Ex Machina Avoidance | criterion |
| CC-137 | Resolution Earned-ness | criterion |
| CC-138 | Resolution Quality | criterion |
| CC-140 | Reversal and Twist Quality | criterion |
| ML-129 | Surprise-Within-Expectations Balance (chapter-plan formulation) | criterion |
| CS-002 | Abrupt Resolution Without Development | sentinel |
| CS-014 | Conflict Resolved by Realization | sentinel |
| CS-015 | Conflict Through Misunderstanding Only | sentinel |
| CS-027 | Deus Ex Machina Resolution | sentinel |
| CS-072 | Sanitized Conflict / Conflict Avoidance | sentinel |
| CS-095 | Unearned Resolution | sentinel |
| ML-092 | Conflict Resolved Through Communication (chapter-plan formulation) | sentinel |
| ML-118 | Costless Victory (chapter-plan formulation) | sentinel |
| CC-037 | Conflict Resolution Promise | criterion |

---

### Auditor: Chapter and Act Structure
**Evidence required**: The plan's structural architecture — chapter functions, act proportions, turning points, pacing across the whole, and whether the structure serves the story.
**Context needed**: chapter_plan, novel_plan
**Item count**: 13 criteria + 7 sentinels = 20 total

| ID | Name | Type |
|---|---|---|
| CC-017 | Chapter Architecture | criterion |
| CC-018 | Chapter Length Variation | criterion |
| CC-058 | Dual/Parallel Timeline Balance | criterion |
| CC-073 | Five Commandments Completeness | criterion |
| CC-093 | In Medias Res Execution | criterion |
| CC-105 | Midpoint Effectiveness | criterion |
| CC-126 | Prologue/Epilogue Structural Justification | criterion |
| CC-162 | Second Act Structural Integrity | criterion |
| CC-165 | Section Break and Transition Craft | criterion |
| CC-177 | Story Grid Five Commandments Per Unit | criterion |
| CC-183 | Temporal Ordering Justification | criterion |
| ML-012 | Five Turning Points Presence (chapter-plan formulation) | criterion |
| ML-042 | Structural Beat Placement (chapter-plan formulation) | criterion |
| CS-003 | Absence of Structural Silence | sentinel |
| CS-031 | Every Chapter Ends on a Cliffhanger | sentinel |
| CS-059 | No Identifiable Midpoint Shift | sentinel |
| CS-061 | No Structural Distinction Between Beginning, Middle, and End | sentinel |
| CS-063 | Predictable Five-Paragraph-Essay Structure at Chapter Level | sentinel |
| CS-064 | Premature Turning Point Placement | sentinel |
| CS-065 | Prologue as Info-Dump | sentinel |

---

### Auditor: Pacing and Rhythm Across Chapters
**Evidence required**: How pacing varies across the chapter plan — scene variety, tempo changes, recovery beats, and whether the plan creates rhythmic interest.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 9 criteria + 7 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| CC-028 | Climax Pacing (Sufficient Buildup and Space) | criterion |
| CC-116 | Opening Pace and Inciting Incident Timing | criterion |
| CC-142 | Sagging Middle Prevention | criterion |
| CC-152 | Scene Variety (Avoiding Repetitive Scene Structure) | criterion |
| CC-161 | Scene-to-Summary Ratio | criterion |
| ML-020 | Macro Pacing Variation (chapter-plan formulation) | criterion |
| ML-033 | Repetitive Scene Beat Pattern (chapter-plan formulation) | sentinel |
| ML-043 | Subplot Pacing as Counterpoint (chapter-plan formulation) | criterion |
| ML-058 | Uniform Chapter/Scene Lengths (chapter-plan formulation) | sentinel |
| ML-083 | Reaction Beat Pacing / Recovery Beats (chapter-plan formulation) | criterion |
| CS-020 | Consistent Escalation Without Plateaus | sentinel |
| CS-034 | Flat Arousal/Tension Curve | sentinel |
| CS-067 | Repetitive Scene Structure | sentinel |
| CS-071 | Sagging Middle with Repetitive Obstacles | sentinel |
| CS-074 | Scene-Sequel Imbalance | sentinel |
| CS-080 | Structural Predictability (PowerPoint Architecture) | sentinel |

---

### Auditor: Opening and Hook Quality
**Evidence required**: The plan's opening chapters — whether they establish engagement, orient the reader, set up the narrative contract, and deliver the inciting incident at the right time.
**Context needed**: chapter_plan, novel_plan, premise
**Item count**: 12 criteria + 4 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| CC-090 | Hook Effectiveness | criterion |
| CC-091 | Hook Honesty | criterion |
| CC-094 | Inciting Incident Placement | criterion |
| CC-111 | Narrative Promise Establishment | criterion |
| CC-114 | Opening Hook | criterion |
| CC-115 | Opening Orientation | criterion |
| CC-117 | Opening Pacing Balance | criterion |
| CC-123 | Premise Exploitation (Fun and Games) | criterion |
| CC-124 | Problem Statement Establishment | criterion |
| CC-131 | Reader-Writer Contract Establishment | criterion |
| CC-199 | Tonal Promise Fulfillment | criterion |
| ML-017 | Inciting Incident Timing (chapter-plan formulation) | criterion |
| CS-016 | Conflict-Free Opening | sentinel |
| CS-046 | Inciting Incident Buried Past 15% Mark | sentinel |
| CS-048 | Info-Dump Opening / Encyclopedic Prologue | sentinel |
| ML-010 | Exposition Front-Loading (chapter-plan formulation) | sentinel |

---

### Auditor: Setup-Payoff Architecture and Foreshadowing
**Evidence required**: The plan examined for whether significant elements introduced early are used later, and whether major payoffs are properly prepared.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 8 criteria + 5 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| CC-078 | Setup Payoff Completeness | criterion |
| CC-078b | Payoff Earned-ness | criterion |
| CC-132 | Reader-Writer Contract Fulfillment | criterion |
| CC-135 | Red Herring vs. Broken Promise Distinction | criterion |
| CC-139 | Revelation Scheduling | criterion |
| CC-170 | Setup-Payoff Consistency (Chekhov's Gun) | criterion |
| CC-172 | Signposting Quality | criterion |
| ML-060 | Promise-Progress-Payoff Integrity (chapter-plan formulation) | criterion |
| CS-010 | Chekhov's Guns Left Unfired | sentinel |
| CS-053 | Memory Loss Across Structural Spans | sentinel |
| ML-044 | Subversion Without Foundation (Bait-and-Switch) (chapter-plan formulation) | sentinel |
| ML-057 | Unfired Chekhov's Guns (chapter-plan formulation) | sentinel |
| CS-069 | S24: Absent Foreshadowing | sentinel |

---

### Auditor: Subplot Management
**Evidence required**: How subplots are planned — integration with the main plot, pacing function, thematic mirroring, and resolution.
**Context needed**: chapter_plan, novel_plan
**Item count**: 5 criteria + 3 sentinels = 8 total

| ID | Name | Type |
|---|---|---|
| CC-178 | Subplot Integration | criterion |
| CC-180 | Subplot as Thematic Mirror | criterion |
| ML-052 | Tidy Single-Track Plots (chapter-plan formulation) | sentinel |
| ML-049 | Thematic Subplots and Mirroring (chapter-plan formulation) | criterion |
| ML-130 | Flat Narrative Arc (chapter-plan formulation) | sentinel |
| CS-081 | Subplots That Never Intersect the Main Plot | sentinel |
| CS-084 | Symmetrical Resolution of All Subplots | sentinel |
| ML-128 | Narrative Coherence (chapter-plan formulation) | criterion |

---

### Auditor: Scene-Level Planning Quality
**Evidence required**: Individual scene plans examined for whether they contain the essential dramatic elements — goals, conflict, turns, polarity shifts, and structural completeness.
**Context needed**: chapter_plan
**Item count**: 13 criteria + 5 sentinels = 18 total

| ID | Name | Type |
|---|---|---|
| CC-067 | Escalation Within Scenes | criterion |
| CC-145 | Scene Causality (Inter-Scene) | criterion |
| CC-146 | Scene Disaster / Outcome Quality | criterion |
| CC-147 | Scene Goal Clarity | criterion |
| CC-148 | Scene Necessity (The Deletion Test) | criterion |
| CC-149 | Scene Purpose and Necessity | criterion |
| CC-150 | Scene Structure Completeness (Five Commandments) | criterion |
| CC-151 | Scene Turn / Polarity Shift | criterion |
| CC-153 | Scene-Level Causal Structure | criterion |
| CC-154 | Scene-Level Conflict and Opposition | criterion |
| CC-155 | Scene-Level Conflict/Tension Presence | criterion |
| CC-156 | Scene-Level Setup and Payoff | criterion |
| CC-157 | Scene-Level Stakes | criterion |
| CS-073 | Scale-as-Decoration Space Opera (if applicable) | sentinel |
| CS-075 | Single Emotion per Character per Scene | sentinel |
| CS-098 | Uniform Scene Template | sentinel |
| ML-035 | Scene Opening Quality (chapter-plan formulation) | criterion |
| ML-076 | Enter Late, Exit Early (chapter-plan formulation) | criterion |

---

### Auditor: Scene-Sequel and Emotional Rhythm
**Evidence required**: The scene-sequel pattern across the plan — whether action scenes alternate with reflective sequels, and whether the emotional rhythm works.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 5 criteria + 5 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| CC-159 | Scene-Level Value Shift | criterion |
| CC-160 | Scene-Sequel Structure | criterion |
| ML-016 | Impossible Choice Presence (chapter-plan formulation) | criterion |
| ML-108 | Emotional Arc Shape (chapter-plan formulation) | criterion |
| ML-075 | Emotional Resonance and Memorability (chapter-plan formulation) | criterion |
| ML-037 | Scenes Opening with Exposition Dumps (chapter-plan formulation) | sentinel |
| ML-090 | All Scenes End with Clean Resolution (chapter-plan formulation) | sentinel |
| ML-091 | Backstory Info-Dump in Opening (chapter-plan formulation) | sentinel |
| ML-094 | Episodic Scene Sequence (chapter-plan formulation) | sentinel |
| ML-099 | Rapid Conflict Resolution (chapter-plan formulation) | sentinel |

---

### Auditor: Character Arc and Psychological Architecture
**Evidence required**: Character plans examined for psychological depth — wound/lie/want/need structure, arc trajectory, complexity, and whether character development is earned.
**Context needed**: chapter_plan, novel_plan, completed_chapters_summary
**Item count**: 10 criteria + 7 sentinels = 17 total

| ID | Name | Type |
|---|---|---|
| CC-002 | Antagonist Complexity | criterion |
| CC-004 | Antagonist Goal Clarity | criterion |
| CC-005 | Antagonistic Force Credibility | criterion |
| ML-066 | Character Complexity Through Contradiction (chapter-plan formulation) | criterion |
| ML-067 | Character Consistency Under Change (chapter-plan formulation) | criterion |
| ML-068 | Character Self-Revelation (chapter-plan formulation) | criterion |
| ML-069 | Character-Driven Stakes (chapter-plan formulation) | criterion |
| ML-079 | Meaningful vs Cosmetic Flaws (chapter-plan formulation) | criterion |
| ML-104 | Character Arc Execution (chapter-plan formulation) | criterion |
| ML-111 | Ghost/Wound/Lie/Weakness Architecture (chapter-plan formulation) | criterion |
| CS-004 | Absence of Want/Need Tension | sentinel |
| CS-009 | Character Wound Never Activated | sentinel |
| CS-012 | Conflict Contradicts Established Character | sentinel |
| ML-093 | Cosmetic Flaws Only (chapter-plan formulation) | sentinel |
| ML-098 | Missing Character Wound (chapter-plan formulation) | sentinel |
| ML-120 | Flat Character Arc Where Round Arc Is Required (chapter-plan formulation) | sentinel |
| CS-101 | Vague Antagonist Motivation | sentinel |

---

### Auditor: Ensemble and Relationship Design
**Evidence required**: The cast plan examined for differentiation — whether characters serve distinct functions, develop distinct relationships, and avoid interchangeability.
**Context needed**: chapter_plan, novel_plan
**Item count**: 7 criteria + 3 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| CC-023 | Character Continuity | criterion |
| CC-108 | Multi-POV Management | criterion |
| CC-118 | POV Selection Appropriateness | criterion |
| ML-070 | Character-as-Theme (chapter-plan formulation) | criterion |
| ML-078 | Flat vs Round Character Deployment (chapter-plan formulation) | criterion |
| ML-084 | Relationship Dynamics (chapter-plan formulation) | criterion |
| ML-109 | Ensemble Differentiation (chapter-plan formulation) | criterion |
| ML-095 | Homogeneous Ensemble (chapter-plan formulation) | sentinel |
| ML-097 | Immediate Forgiveness After Betrayal (chapter-plan formulation) | sentinel |
| ML-116 | Want/Need Tension (chapter-plan formulation) | criterion |

---

### Auditor: Thematic Integration and Development
**Evidence required**: How theme manifests across the chapter plan — whether it's dramatized through events, explored through multiple perspectives, and developed through the story rather than stated.
**Context needed**: chapter_plan, novel_plan, premise
**Item count**: 11 criteria + 5 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| CC-059 | Earned Thematic Resolution | criterion |
| CC-120 | Philosophical Depth Without Didacticism | criterion |
| CC-158 | Scene-Level Thematic Integration | criterion |
| CC-188 | Thematic Complexity (Multiple/Competing Themes) | criterion |
| CC-189 | Thematic Presence and Identifiability | criterion |
| CC-191 | Thematic Subtlety | criterion |
| CC-192 | Theme as Question vs. Theme as Answer | criterion |
| CC-194 | Theme-Character Arc Integration | criterion |
| ML-045 | Surface-Level Thematic Details Without Structural Integration (chapter-plan formulation) | sentinel |
| ML-048 | Thematic Premise as Dramatic Argument (chapter-plan formulation) | criterion |
| ML-050 | Thematic Unity Across Story Elements (chapter-plan formulation) | criterion |
| ML-061 | Moral and Thematic Complexity (chapter-plan formulation) | criterion |
| CS-033 | Explicit Moral Statement at Story End | sentinel |
| CS-092 | Theme Disconnected from Character Wound/Stakes | sentinel |
| CS-099 | Uniform Thematic Pattern Across Stories | sentinel |
| ML-023 | No Thematic Counter-Argument Present (chapter-plan formulation) | sentinel |

---

### Auditor: Thematic Craft (Symbols, Motifs, Ambiguity)
**Evidence required**: How thematic meaning is delivered through craft elements — symbolism, motif development, interpretive richness, and reader meaning-making.
**Context needed**: chapter_plan, novel_plan
**Item count**: 6 criteria + 2 sentinels = 8 total

| ID | Name | Type |
|---|---|---|
| CC-190 | Thematic Resonance (Emotional Impact of Theme) | criterion |
| ML-087 | Symbolism and Image System Effectiveness (chapter-plan formulation) | criterion |
| ML-112 | Interpretive Richness and Ambiguity (chapter-plan formulation) | criterion |
| ML-113 | Meaning Inseparable from Form (chapter-plan formulation) | criterion |
| ML-114 | Motif Development and Evolution (chapter-plan formulation) | criterion |
| ML-115 | Reader Agency in Meaning-Making (chapter-plan formulation) | criterion |
| ML-121 | Generic/Platitudinous Theme (chapter-plan formulation) | sentinel |
| ML-122 | Loss of Thematic Thread Across Long Text (chapter-plan formulation) | sentinel |

---

### Auditor: Dramatic Irony and Reader Engagement
**Evidence required**: How the plan structures information asymmetry between reader and characters, and how it builds anticipation, suspense, and emotional payoff.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 8 criteria + 2 sentinels = 10 total

| ID | Name | Type |
|---|---|---|
| CC-007 | Anticipation and Dread Construction | criterion |
| CC-014 | Catharsis | criterion |
| CC-019 | Chapter-Level Forward Momentum | criterion |
| CC-026 | Cliffhanger Distribution and Trust | criterion |
| CC-056 | Dramatic Irony Deployment | criterion |
| CC-171 | Showing vs. Telling Conflict | criterion |
| ML-073 | Dramatic Irony (chapter-plan formulation) | criterion |
| ML-086 | Suspense and Anticipation (chapter-plan formulation) | criterion |
| ML-085 | Surprise and Misdirection (chapter-plan formulation) | criterion |
| ML-127 | Empathic Engagement (chapter-plan formulation) | criterion |

---

### Auditor: Exposition and Information Architecture
**Evidence required**: How background information is planned for delivery — pacing of revelation, distribution across chapters, and avoidance of dumps.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 5 criteria + 2 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| CC-010 | Backstory Distribution | criterion |
| CC-011 | Backstory-Tension Balance | criterion |
| CC-095 | Incluing and Worldbuilding Integration | criterion |
| ML-072 | Curiosity Engine (Question Architecture) (chapter-plan formulation) | criterion |
| ML-077 | Flashback Integration Without Momentum Loss (chapter-plan formulation) | criterion |
| ML-133 | Cognitive Load Management (chapter-plan formulation) | criterion |
| ML-132 | "What If" Question Compellingness (chapter-plan formulation) | criterion |

---

### Auditor: Worldbuilding Coherence and Depth
**Evidence required**: The plan's world examined for internal consistency, depth, plausibility, and whether the world serves the narrative.
**Context needed**: chapter_plan, novel_plan, premise
**Item count**: 14 criteria + 7 sentinels = 21 total

| ID | Name | Type |
|---|---|---|
| CC-008 | Avoidance of Monocultures (Planet of Hats) | criterion |
| CC-031 | Completeness and Illusion of Depth (Iceberg Principle) | criterion |
| CC-050 | Creativity and Originality of Conceits | criterion |
| CC-052 | Daily Life Texture and Material Culture | criterion |
| CC-060 | Economics and Infrastructure Believability | criterion |
| CC-064 | Environmental Change and Dynamism | criterion |
| CC-086 | Geography and Physical World Plausibility | criterion |
| CC-089 | History Informing Present | criterion |
| CC-101 | Language and Naming Consistency | criterion |
| CC-103 | Magic/Technology System Design | criterion |
| CC-119 | Perspective-Filtered Worldbuilding | criterion |
| CC-136 | Religion and Belief Systems | criterion |
| CC-163 | Second-Order Consequences and Ripple Effects | criterion |
| CC-164 | Secondary Belief vs. Suspension of Disbelief | criterion |
| CS-022 | Contradictory World Rules Across Scenes | sentinel |
| CS-025 | Cultures as Aesthetic Skins Over Default Society | sentinel |
| CS-028 | Economy Operates on Convenient Vagueness | sentinel |
| CS-039 | Food/Clothing/Material Culture Absent or Generic | sentinel |
| CS-041 | Generic Pseudo-Medieval European Setting | sentinel |
| CS-054 | Missing Authority Structures | sentinel |
| CS-060 | No Knowledge Gaps in Characters About Their Own World | sentinel |

---

### Auditor: Worldbuilding Integration and Delivery
**Evidence required**: How worldbuilding information is delivered within the plan — balance between world detail and narrative momentum, and whether world serves story.
**Context needed**: chapter_plan, novel_plan
**Item count**: 8 criteria + 5 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| CC-168 | Setting as Active Force (World-as-Character) | criterion |
| CC-173 | Social Structures and Power Dynamics | criterion |
| CC-181 | Technology Level Consistency | criterion |
| CC-186 | The Compelling C (Reader Engagement with World) | criterion |
| CC-200 | Travel Time and Distance Consistency | criterion |
| CC-211 | World Anchoring Through Familiar Elements | criterion |
| CC-212 | Worldbuilding Delivery (Content vs. Exposition) | criterion |
| CC-215 | Worldbuilding-Story Balance | criterion |
| CS-047 | Inconsistent Travel Times / Rubber-Band Geography | sentinel |
| CS-077 | Speculative Elements Without Second-Order Effects | sentinel |
| CS-082 | Symmetric Load-Balancing of World Elements | sentinel |
| CS-102 | World Exists Only Where the Plot Needs It | sentinel |
| ML-018 | Internal Consistency of World Rules (chapter-plan formulation) | criterion |

---

### Auditor: Worldbuilding Through Absence and Speculation
**Evidence required**: The plan examined for negative-space worldbuilding — strategic omission, the feeling of a world beyond what's shown, and speculative element integration.
**Context needed**: chapter_plan, novel_plan
**Item count**: 5 criteria + 2 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| CC-214 | Worldbuilding Through Absence and Negative Space | criterion |
| ML-027 | Perfect Internal Consistency With No Acknowledged Contradictions (chapter-plan formulation) | sentinel |
| ML-040 | Setting-Character Integration (chapter-plan formulation) | criterion |
| ML-046 | Suspension of Disbelief (chapter-plan formulation) | criterion |
| ML-047 | Suspension of Disbelief Maintenance (chapter-plan formulation) | criterion |
| ML-063 | Atmosphere and Mood Creation (chapter-plan formulation) | criterion |
| ML-102 | The Monoculture Alien (chapter-plan formulation) | sentinel |

---

### Auditor: Continuity and Consistency (Chapter-Plan)
**Evidence required**: Cross-scene tracking for factual consistency — character details, world rules, timeline coherence, and setup-payoff tracking across the plan.
**Context needed**: chapter_plan, completed_chapters_summary
**Item count**: 6 criteria + 3 sentinels = 9 total

| ID | Name | Type |
|---|---|---|
| CC-206 | Unresolved Storyline Tracking | criterion |
| ML-008 | Cross-Reference and Internal Consistency (chapter-plan formulation) | criterion |
| ML-022 | Narrative Voice and Tonal Consistency (chapter-plan formulation) | criterion |
| ML-062 | Aggregate Consistency Across Length (chapter-plan formulation) | criterion |
| ML-065 | Character Behavioral Consistency (chapter-plan formulation) | criterion |
| ML-074 | Emotional Continuity (chapter-plan formulation) | criterion |
| CS-001 | Abandoned Subplot | sentinel |
| ML-009 | Description-Action Integration (chapter-plan formulation) | criterion |
| ML-006 | Concrete vs. Abstract Description (chapter-plan formulation) | criterion |

---

### Auditor: AI Structural Tells (Chapter-Plan Level)
**Evidence required**: Structural patterns characteristic of AI generation at the plan level — uniform structure, sanitized conflict, therapy-speak resolution, homogeneous arcs, and formulaic templates.
**Context needed**: chapter_plan
**Item count**: 3 criteria + 10 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| ML-053 | Tonal Consistency (chapter-plan formulation) | criterion |
| ML-055 | Tonal Whiplash Without Foreshadowing (chapter-plan formulation) | sentinel |
| ML-064 | Audience Expectation Alignment (chapter-plan formulation) | criterion |
| ML-080 | Non-Default Narrative Choices (chapter-plan formulation) | criterion |
| CS-037 | Flat Event Escalation | sentinel |
| CS-070 | S32: Flatter Event Escalation (Claude-Specific) | sentinel |
| ML-003 | Cliche Avoidance at Story Level (chapter-plan formulation) | sentinel |
| ML-005 | Conceptual Originality (chapter-plan formulation) | sentinel |
| ML-014 | Genre-Flavored Non-Genre Story (chapter-plan formulation) | sentinel |
| ML-015 | Grandiose Stakes Inflation (chapter-plan formulation) | sentinel |
| ML-025 | Originality of Execution (chapter-plan formulation) | sentinel |
| ML-051 | Three-Chapter Degradation (chapter-plan formulation) | sentinel |
| ML-096 | Homogeneous Narrative Structure (chapter-plan formulation) | sentinel |

---

### Auditor: Sycophantic and Sanitized Resolution Patterns
**Evidence required**: The plan's resolution patterns — whether conflicts resolve too neatly, too positively, or through validation rather than genuine dramatic cost.
**Context needed**: chapter_plan
**Item count**: 2 criteria + 5 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| ML-089 | Trope Awareness and Subversion (chapter-plan formulation) | criterion |
| ML-071 | Creative Problem-Solving Within the Story (chapter-plan formulation) | criterion |
| ML-095 | Homogeneous Ensemble (chapter-plan formulation) | sentinel |
| ML-100 | Stereotypical Character Details (chapter-plan formulation) | sentinel |
| ML-101 | Sycophantic Resolution (chapter-plan formulation) | sentinel |
| ML-119 | Emotional Architecture Collapse / Homogeneously Positive Arc (chapter-plan formulation) | sentinel |
| ML-041 | Specificity and Concrete Detail (chapter-plan formulation) | criterion |

---

### Auditor: Scene Description and Planning Quality
**Evidence required**: Whether scene descriptions in the plan use specific, concrete language rather than abstract summaries — and whether the plan communicates clear dramatic situations.
**Context needed**: chapter_plan, premise
**Item count**: 4 criteria + 3 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| ML-032 | Prose Density (Layered Meaning) (chapter-plan formulation) | criterion |
| ML-039 | Sensory Detail as Plot Device (chapter-plan formulation) | criterion |
| ML-054 | Tonal Consistency in Description (chapter-plan formulation) | criterion |
| ML-001 | Abstraction Trap Sentinel (chapter-plan formulation) | sentinel |
| ML-028 | Premise Clarity (chapter-plan formulation) | criterion |
| ML-029 | Premise Completeness (chapter-plan formulation) | criterion |
| ML-126 | Central Dramatic Question Clarity (chapter-plan formulation) | criterion |

---

### Auditor: Thematic Safety and Moral Complexity (Chapter-Plan)
**Evidence required**: Whether the plan engages with morally challenging territory — genuine moral complexity, competing valid perspectives, and willingness to explore uncomfortable territory.
**Context needed**: chapter_plan, novel_plan, premise
**Item count**: 3 criteria + 4 sentinels = 7 total

| ID | Name | Type |
|---|---|---|
| ML-110 | Foil and Mirror Cast Architecture (chapter-plan formulation) | criterion |
| ML-106 | Conflict Hierarchy (chapter-plan formulation) | criterion |
| ML-107 | Dilemma Quality (chapter-plan formulation) | criterion |
| ML-117 | All Characters Agree on the Moral Position (chapter-plan formulation) | sentinel |
| ML-124 | Thematic Idea Merely Repeated Rather Than Developed (chapter-plan formulation) | sentinel |
| ML-125 | Thematic Safety (chapter-plan formulation) | sentinel |
| CS-058 | No Dilemmas (Only Obstacles) | sentinel |

---

## Novel-Plan-Level Auditors

### Auditor: Overall Arc and Structural Design
**Evidence required**: The novel plan's macro-structure — act proportions, structural models, beat completeness, and whether the chosen structure serves the story.
**Context needed**: novel_plan, premise
**Item count**: 12 criteria + 3 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| NC-004 | Circular/Chiastic Structural Resonance | criterion |
| NC-007 | Dan Harmon Story Circle Completeness | criterion |
| NC-008 | Denouement Proportionality | criterion |
| NC-010 | Dramatica Completeness of Argument | criterion |
| NC-012 | Frame Narrative and Nested Structure Coherence | criterion |
| NC-016 | Kishotenketsu Structural Awareness | criterion |
| NC-018 | Novel Length Appropriateness | criterion |
| NC-019 | Organic Unity of Structure | criterion |
| NC-027 | Redundancy and Structural Efficiency | criterion |
| NC-028 | Save the Cat Beat Completeness | criterion |
| NC-030 | Seven-Point Symmetry | criterion |
| NC-031 | Structural Approach Appropriateness | criterion |
| NC-035 | Three-Act Proportional Balance | criterion |
| NS-021 | Three-Act Structure Applied as Rigid Template | sentinel |
| ML-056 | Turning Points at Default Intervals (novel-plan formulation) | sentinel |

---

### Auditor: Narrative Promise and Contract
**Evidence required**: The novel plan examined for whether it establishes clear promises and delivers on them — genre contract, premise delivery, and audience engagement.
**Context needed**: novel_plan, premise
**Item count**: 9 criteria + 6 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| NC-002 | Cause-and-Effect Chain Integrity | criterion |
| NC-005 | Commonsense Plausibility | criterion |
| NC-009 | Difficulty/Challenge Calibration | criterion |
| NC-013 | Genre Contract Adherence | criterion |
| NC-014 | Genre-Specific Obligation Fulfillment | criterion |
| NC-015 | Interestingness/Engagement | criterion |
| NC-025 | Protagonist Active Agency in Climax | criterion |
| NC-033 | Surprise/Suspense Generation | criterion |
| NC-034 | Technology/Magic Consistency | criterion |
| NS-001 | Conflict-Free or Sanitized Central Tension | sentinel |
| NS-003 | Every Chapter Ends on Upbeat Forward-Looking Note | sentinel |
| NS-004 | False Hook (Opening Action Disconnected from Story) | sentinel |
| NS-006 | Genre Unidentifiable After First Chapter | sentinel |
| NS-011 | Misdirected Promise (Opening Genre ≠ Story Genre) | sentinel |
| NS-018 | Resolution Arrives Without Character Struggle | sentinel |

---

### Auditor: Character Arc Design (Novel-Plan)
**Evidence required**: The novel plan's character architecture — protagonist transformation, wound/lie/need structure, ensemble design, and relationship arcs across the full story.
**Context needed**: novel_plan, premise
**Item count**: 12 criteria + 4 sentinels = 16 total

| ID | Name | Type |
|---|---|---|
| ML-065 | Character Behavioral Consistency (novel-plan formulation) | criterion |
| ML-067 | Character Consistency Under Change (novel-plan formulation) | criterion |
| ML-068 | Character Self-Revelation (novel-plan formulation) | criterion |
| ML-069 | Character-Driven Stakes (novel-plan formulation) | criterion |
| ML-070 | Character-as-Theme (novel-plan formulation) | criterion |
| ML-078 | Flat vs Round Character Deployment (novel-plan formulation) | criterion |
| ML-079 | Meaningful vs Cosmetic Flaws (novel-plan formulation) | criterion |
| ML-084 | Relationship Dynamics (novel-plan formulation) | criterion |
| ML-104 | Character Arc Execution (novel-plan formulation) | criterion |
| ML-109 | Ensemble Differentiation (novel-plan formulation) | criterion |
| ML-110 | Foil and Mirror Cast Architecture (novel-plan formulation) | criterion |
| ML-111 | Ghost/Wound/Lie/Weakness Architecture (novel-plan formulation) | criterion |
| ML-093 | Cosmetic Flaws Only (novel-plan formulation) | sentinel |
| ML-095 | Homogeneous Ensemble (novel-plan formulation) | sentinel |
| ML-100 | Stereotypical Character Details (novel-plan formulation) | sentinel |
| ML-120 | Flat Character Arc Where Round Arc Is Required (novel-plan formulation) | sentinel |

---

### Auditor: Conflict and Stakes Architecture (Novel-Plan)
**Evidence required**: The novel plan's conflict design — hierarchy, evolution, stakes at all three levels, and whether the central conflict drives a satisfying arc.
**Context needed**: novel_plan, premise
**Item count**: 9 criteria + 4 sentinels = 13 total

| ID | Name | Type |
|---|---|---|
| ML-082 | Personal Stakes Grounding (novel-plan formulation) | criterion |
| ML-088 | Three-Level Stakes Architecture (novel-plan formulation) | criterion |
| ML-103 | Character Agency (novel-plan formulation) | criterion |
| ML-105 | Conflict Evolution (novel-plan formulation) | criterion |
| ML-106 | Conflict Hierarchy (novel-plan formulation) | criterion |
| ML-107 | Dilemma Quality (novel-plan formulation) | criterion |
| ML-116 | Want/Need Tension (novel-plan formulation) | criterion |
| ML-071 | Creative Problem-Solving Within the Story (novel-plan formulation) | criterion |
| ML-096 | Homogeneous Narrative Structure (novel-plan formulation) | sentinel |
| ML-097 | Immediate Forgiveness After Betrayal (novel-plan formulation) | sentinel |
| ML-092 | Conflict Resolved Through Communication (novel-plan formulation) | sentinel |
| ML-101 | Sycophantic Resolution (novel-plan formulation) | sentinel |
| ML-118 | Costless Victory (novel-plan formulation) | sentinel |

---

### Auditor: Pacing, Momentum, and Structural Rhythm (Novel-Plan)
**Evidence required**: The novel plan's pacing across its full arc — chapter intensity variation, act pacing, and whether the plan creates satisfying rhythm.
**Context needed**: novel_plan
**Item count**: 8 criteria + 3 sentinels = 11 total

| ID | Name | Type |
|---|---|---|
| ML-020 | Macro Pacing Variation (novel-plan formulation) | criterion |
| ML-011 | Fichtean Curve Crisis Escalation (novel-plan formulation) | criterion |
| ML-012 | Five Turning Points Presence (novel-plan formulation) | criterion |
| ML-042 | Structural Beat Placement (novel-plan formulation) | criterion |
| ML-060 | Promise-Progress-Payoff Integrity (novel-plan formulation) | criterion |
| ML-077 | Flashback Integration Without Momentum Loss (novel-plan formulation) | criterion |
| ML-064 | Audience Expectation Alignment (novel-plan formulation) | criterion |
| NC-029 | Scene Entrance and Exit Craft | criterion |
| NS-010 | Identical Narrative Arc Across Stories | sentinel |
| ML-119 | Emotional Architecture Collapse / Homogeneously Positive Arc (novel-plan formulation) | sentinel |
| ML-130 | Flat Narrative Arc (novel-plan formulation) | sentinel |

---

### Auditor: Thematic Architecture (Novel-Plan)
**Evidence required**: The novel plan's thematic design — controlling idea, thematic argument, complexity, and how theme is dramatized across the full arc.
**Context needed**: novel_plan, premise
**Item count**: 10 criteria + 5 sentinels = 15 total

| ID | Name | Type |
|---|---|---|
| NC-006 | Controlling Idea Coherence (McKee) | criterion |
| ML-048 | Thematic Premise as Dramatic Argument (novel-plan formulation) | criterion |
| ML-050 | Thematic Unity Across Story Elements (novel-plan formulation) | criterion |
| ML-061 | Moral and Thematic Complexity (novel-plan formulation) | criterion |
| ML-087 | Symbolism and Image System Effectiveness (novel-plan formulation) | criterion |
| ML-112 | Interpretive Richness and Ambiguity (novel-plan formulation) | criterion |
| ML-113 | Meaning Inseparable from Form (novel-plan formulation) | criterion |
| ML-114 | Motif Development and Evolution (novel-plan formulation) | criterion |
| ML-115 | Reader Agency in Meaning-Making (novel-plan formulation) | criterion |
| ML-081 | Novelistic Discovery (novel-plan formulation) | criterion |
| ML-117 | All Characters Agree on the Moral Position (novel-plan formulation) | sentinel |
| ML-121 | Generic/Platitudinous Theme (novel-plan formulation) | sentinel |
| ML-122 | Loss of Thematic Thread Across Long Text (novel-plan formulation) | sentinel |
| ML-124 | Thematic Idea Merely Repeated Rather Than Developed (novel-plan formulation) | sentinel |
| ML-125 | Thematic Safety (novel-plan formulation) | sentinel |

---

### Auditor: Worldbuilding and Consistency (Novel-Plan)
**Evidence required**: The novel plan's world examined for consistency across the full arc and whether speculative elements are maintained coherently.
**Context needed**: novel_plan, premise
**Item count**: 7 criteria + 2 sentinels = 9 total

| ID | Name | Type |
|---|---|---|
| ML-062 | Aggregate Consistency Across Length (novel-plan formulation) | criterion |
| ML-074 | Emotional Continuity (novel-plan formulation) | criterion |
| ML-046 | Suspension of Disbelief (novel-plan formulation) | criterion |
| ML-044 | Subversion Without Foundation (Bait-and-Switch) (novel-plan formulation) | sentinel |
| ML-052 | Tidy Single-Track Plots (novel-plan formulation) | sentinel |
| ML-094 | Episodic Scene Sequence (novel-plan formulation) | sentinel |
| ML-090 | All Scenes End with Clean Resolution (novel-plan formulation) | sentinel |
| ML-073 | Dramatic Irony (novel-plan formulation) | criterion |
| ML-072 | Curiosity Engine (Question Architecture) (novel-plan formulation) | criterion |

---

### Auditor: AI Structural Tells and Originality (Novel-Plan)
**Evidence required**: The novel plan examined for AI-characteristic patterns — stock plot archetypes, uniform chapter endings, sanitized premises, and lack of originality.
**Context needed**: novel_plan, premise
**Item count**: 7 criteria + 7 sentinels = 14 total

| ID | Name | Type |
|---|---|---|
| NC-001 | C8: Plot Diversity and Narrative Uniqueness | criterion |
| ML-003 | Cliche Avoidance at Story Level (novel-plan formulation) | criterion |
| ML-005 | Conceptual Originality (novel-plan formulation) | criterion |
| ML-025 | Originality of Execution (novel-plan formulation) | criterion |
| ML-028 | Premise Clarity (novel-plan formulation) | criterion |
| ML-080 | Non-Default Narrative Choices (novel-plan formulation) | criterion |
| ML-089 | Trope Awareness and Subversion (novel-plan formulation) | criterion |
| NS-002 | Consistent Repetition of Specific Names/Locations/Themes Across Works | sentinel |
| NS-012 | Narrative Clustering (All Stories Feel the Same) | sentinel |
| NS-013 | Opening Revealed as Dream/Simulation/Fantasy | sentinel |
| NS-014 | Opening Saturated with Backstory/Exposition | sentinel |
| NS-015 | Plot Echo Repetition | sentinel |
| NS-016 | Protagonist Absent from Opening | sentinel |
| NS-017 | Protagonist Returns to Small Town and Resolves Conflict Through Community | sentinel |

---

### Auditor: Engagement and Reader Experience (Novel-Plan)
**Evidence required**: The novel plan examined for whether it will create sustained reader engagement — emotional resonance, suspense, surprise, and transportation.
**Context needed**: novel_plan, premise
**Item count**: 8 criteria + 1 sentinel = 9 total

| ID | Name | Type |
|---|---|---|
| ML-041 | Specificity and Concrete Detail (novel-plan formulation) | criterion |
| ML-075 | Emotional Resonance and Memorability (novel-plan formulation) | criterion |
| ML-085 | Surprise and Misdirection (novel-plan formulation) | criterion |
| ML-086 | Suspense and Anticipation (novel-plan formulation) | criterion |
| ML-108 | Emotional Arc Shape (novel-plan formulation) | criterion |
| ML-127 | Empathic Engagement (novel-plan formulation) | criterion |
| ML-129 | Surprise-Within-Expectations Balance (novel-plan formulation) | criterion |
| ML-134 | Concept-to-Premise Development (novel-plan formulation) | criterion |
| ML-131 | Homogeneous Plot Structure (novel-plan formulation) | sentinel |

---

### Auditor: Novel-Plan Genre Contract and Structure
**Evidence required**: The novel plan examined for genre-specific structural requirements and whether the plan will deliver genre-appropriate experience.
**Context needed**: novel_plan, premise
**Item count**: 6 criteria + 2 sentinels = 8 total

| ID | Name | Type |
|---|---|---|
| ML-007 | Convergence and Payoff (Multi-POV) (novel-plan formulation) | criterion |
| ML-013 | Genre Contract Fulfillment (novel-plan formulation) | criterion |
| ML-014 | Genre-Flavored Non-Genre Story (novel-plan formulation) | sentinel |
| ML-024 | Obligatory Scene Delivery (novel-plan formulation) | criterion |
| ML-031 | Premise Stated But Never Explored (novel-plan formulation) | sentinel |
| ML-032 | Prose Density (Layered Meaning) (novel-plan formulation) | criterion |
| ML-128 | Narrative Coherence (novel-plan formulation) | criterion |
| ML-132 | "What If" Question Compellingness (novel-plan formulation) | criterion |

---

### Auditor: Novel-Plan Consistency
**Evidence required**: The novel plan examined for internal consistency — whether facts, character descriptions, and world rules remain consistent across chapter summaries.
**Context needed**: novel_plan
**Item count**: 5 criteria + 1 sentinel = 6 total

| ID | Name | Type |
|---|---|---|
| ML-065 | Character Behavioral Consistency (novel-plan formulation) | criterion |
| ML-001 | Abstraction Trap Sentinel (novel-plan formulation) | sentinel |
| ML-133 | Cognitive Load Management (novel-plan formulation) | criterion |
| ML-066 | Character Complexity Through Contradiction (novel-plan formulation) | criterion |
| ML-123 | Melodramatic Stakes Inflation (novel-plan formulation) | sentinel |
| ML-126 | Central Dramatic Question Clarity (novel-plan formulation) | criterion |

---

## Premise-Ideation Guidance (not an auditor -- injected into brainstorming prompts)

These criteria and sentinels are not evaluated by an auditor. They are injected as guidance into the brainstorming agents that generate premise candidates, so the agent is steered away from common failure modes during ideation rather than catching them after the fact.

### Premise Strength and Concept Quality
- IC-003: Concept Strength (Pre-Premise Appeal)
- IC-005: High-Concept Pitchability
- IC-007: Premise Originality
- ML-028: Premise Clarity
- ML-029: Premise Completeness
- ML-005: Conceptual Originality
- ML-025: Originality of Execution
- ML-080: Non-Default Narrative Choices
- ML-126: Central Dramatic Question Clarity
- ML-132: "What If" Question Compellingness
- ML-134: Concept-to-Premise Development
- ML-030 (sentinel): Premise Inexpressible in One Sentence
- ML-031 (sentinel): Premise Stated But Never Explored
- ML-131 (sentinel): Homogeneous Plot Structure

### Character Concept and Psychological Architecture
- ML-066: Character Complexity Through Contradiction
- ML-079: Meaningful vs Cosmetic Flaws
- ML-103: Character Agency
- ML-104: Character Arc Execution
- ML-107: Dilemma Quality
- ML-109: Ensemble Differentiation
- ML-110: Foil and Mirror Cast Architecture
- ML-111: Ghost/Wound/Lie/Weakness Architecture
- ML-116: Want/Need Tension
- ML-127: Empathic Engagement
- ML-098 (sentinel): Missing Character Wound
- ML-100 (sentinel): Stereotypical Character Details
- ML-123 (sentinel): Melodramatic Stakes Inflation

### Thematic and Moral Foundation
- ML-048: Thematic Premise as Dramatic Argument
- ML-050: Thematic Unity Across Story Elements
- ML-061: Moral and Thematic Complexity
- ML-070: Character-as-Theme
- ML-081: Novelistic Discovery
- ML-089: Trope Awareness and Subversion
- ML-112: Interpretive Richness and Ambiguity
- ML-113: Meaning Inseparable from Form
- ML-003: Cliche Avoidance at Story Level
- ML-117 (sentinel): All Characters Agree on the Moral Position
- ML-121 (sentinel): Generic/Platitudinous Theme
- ML-125 (sentinel): Thematic Safety
- IS-003 (sentinel): S75: "Echoed" Plot Elements Across Generations

### Premise Craft and AI Tells
- ML-006: Concrete vs. Abstract Description
- ML-041: Specificity and Concrete Detail
- ML-046: Suspension of Disbelief
- ML-047: Suspension of Disbelief Maintenance
- ML-014 (sentinel): Genre-Flavored Non-Genre Story
- ML-019 (sentinel): Invented Concept Labels
- ML-021 (sentinel): Metaphor Pile-Up Without Coherent Vehicle
- ML-034 (sentinel): S58: "Eyeball Kicks" -- Stacked Nonsensical Metaphors
- ML-038 (sentinel): Sensory Detail Absence or Overload

### Premise-Level AI Tells and Opening Hooks
- ML-001 (sentinel): Abstraction Trap Sentinel
- ML-135 (sentinel): Opening Paragraph Uses Stock Attention-Grabbing Formula
- ML-102 (sentinel): The Monoculture Alien
- IS-002 (sentinel): S66: Invented Concept Labels Presented as Established Terms

---

## Chapter-Ideation Guidance (not an auditor -- injected into brainstorming prompts)

These criteria are injected as guidance into the brainstorming agents that generate chapter plan candidates.

- ML-061: Moral and Thematic Complexity
- ML-133: Cognitive Load Management

---

## Genre-Specific Auditors (separated for toggle)

### Mystery/Detective: Fair Play and Clue Architecture
**Level**: chapter_plan
**Genre**: detective-mystery
**Context needed**: chapter_plan, novel_plan

| ID | Name | Type |
|---|---|---|
| CC-029 | Clue Architecture (Mystery) | criterion |
| CC-044 | Convention Delivery — Hardboiled/Noir | criterion |
| CC-046 | Convention Delivery — Mystery/Detective | criterion |
| CC-049 | Cozy Mystery Convention Compliance | criterion |
| CC-072 | Fair Play with the Reader (Mystery) | criterion |
| CC-100 | Knox's Decalogue Compliance | criterion |
| CC-109 | Mystery Difficulty Calibration | criterion |
| CC-122 | Plot Twist Satisfaction (Mystery/Thriller) | criterion |
| CC-134 | Red Herring and Misdirection Quality | criterion |
| CC-208 | Van Dine Rules Compliance | criterion |
| CS-011 | Clues Without Architecture | sentinel |
| CS-087 | The Anti-Climactic Villain Reveal | sentinel |
| CS-088 | The Convenient Knowledge Gap | sentinel |
| CS-089 | The Investigation-Free Mystery | sentinel |
| CS-068 | Resolution-by-Coincidence | sentinel |

---

### Space Opera: Scale, Technology, and Spectacle
**Level**: chapter_plan
**Genre**: space opera
**Context needed**: chapter_plan, novel_plan

| ID | Name | Type |
|---|---|---|
| CC-001 | Action/Spectacle Meaning (Space Opera) | criterion |
| CC-047 | Convention Delivery — Space Opera | criterion |
| CC-070 | FTL and Technology Consistency (Space Opera) | criterion |
| CC-085 | Genre-Specific Quality Markers (Space Opera) | criterion |
| CC-144 | Scale and Scope Management (Space Opera) | criterion |
| CC-167 | Sense of Wonder | criterion |
| CC-182 | Technology as Worldbuilding Driver (SF) | criterion |
| CS-019 | Consequence-Free Magic | sentinel |
| CS-073 | Scale-as-Decoration Space Opera | sentinel |
| CS-076 | Spectacle-Without-Stakes Action | sentinel |
| SS-184 | Purple Prose in Wonder Scenes | sentinel |

---

### High Fantasy: Quest, Magic, and Sub-Creation
**Level**: chapter_plan
**Genre**: high fantasy
**Context needed**: chapter_plan, novel_plan

| ID | Name | Type |
|---|---|---|
| CC-025 | Chekhov's Gun Compliance | criterion |
| CC-045 | Convention Delivery — High Fantasy | criterion |
| CC-084 | Genre-Specific Quality Markers (High Fantasy) | criterion |
| CC-088 | Hero's Journey Execution (Fantasy) | criterion |
| CC-102 | Magic System Coherence (Fantasy) | criterion |
| CC-198 | Tolkien's Sub-Creation Standard | criterion |
| CC-187 | The Four Cs of Worldbuilding | criterion |
| CS-040 | Generic Alien/Fantasy Naming | sentinel |
| CS-050 | Magic System Without Limitations or Costs | sentinel |
| CS-051 | Medieval-Europe-With-Elves Worldbuilding | sentinel |

---

### Fantasy/SF: Quest Structure
**Level**: novel_plan
**Genre**: high fantasy
**Context needed**: novel_plan, premise

| ID | Name | Type |
|---|---|---|
| NC-026 | Quest Structure Execution (Fantasy) | criterion |
| NS-019 | The Default Dark Lord | sentinel |
| NS-020 | The Prophecy-Fulfillment Conveyor Belt | sentinel |

---

### General Genre: Convention and Trope Management
**Level**: chapter_plan
**Genre**: general (applies to any genre fiction)
**Context needed**: chapter_plan, novel_plan

| ID | Name | Type |
|---|---|---|
| CC-051 | Cultural Distinctiveness (Space Opera/Fantasy) | criterion |
| CC-062 | Emotional Payoff Appropriate to Genre | criterion |
| CC-080 | Genre Blending Coherence | criterion |
| CC-081 | Genre Innovation vs. Convention Violation | criterion |
| CC-082 | Genre-Appropriate Ending Resolution | criterion |
| CC-083 | Genre-Appropriate Pacing Structure | criterion |
| CC-130 | Reader Expectation Awareness | criterion |
| CC-141 | Safety-to-Threat Spectrum Calibration | criterion |
| CC-143 | Satisfying vs. Derivative Balance | criterion |
| CC-201 | Trope Execution Quality | criterion |
| CC-202 | Trope Subversion Skill | criterion |
| CC-209 | Villain/Antagonist Genre Appropriateness | criterion |
| CC-213 | Worldbuilding Integration (Fantasy/SF) | criterion |
| CS-043 | Genre Trope Checklist Syndrome | sentinel |
| CS-094 | Unearned Genre Subversion | sentinel |
| CS-103 | Worldbuilding Inconsistency Accumulation | sentinel |
| NS-007 | Genre-Label-Only Classification | sentinel |

---

### General Genre: Novel-Plan Genre Delivery
**Level**: novel_plan
**Genre**: general (applies to any genre fiction)
**Context needed**: novel_plan, premise

| ID | Name | Type |
|---|---|---|
| ML-007 | Convergence and Payoff (Multi-POV) (novel-plan formulation) | criterion |
| ML-013 | Genre Contract Fulfillment (novel-plan formulation) | criterion |
| ML-024 | Obligatory Scene Delivery (novel-plan formulation) | criterion |

Note: These are also listed in the Novel-Plan Genre Contract and Structure auditor above. They appear here to indicate their genre-toggle nature. In implementation, they would be assigned to one location and toggled by genre.

---

## Unclustered Items

All items have been clustered. No items remain unassigned.

Note: Some items appear in closely related auditors where their evidence overlaps naturally. A few items whose evidence straddles two clusters were assigned to the cluster where they fit most naturally. The ML (multi-level) items each appear once per level they apply to, in the auditor that matches the evidence requirements at that level.
