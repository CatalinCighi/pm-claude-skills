# Extraction List — pm-claude-skills

Self-sufficient reference for re-implementing structural patterns in vanilla code.
No copied prose. Source pointers are for audit only — re-implementation should
proceed from the notes below.

**Per-entry fields for the relevance-triage agent:**
- **Idea** — the mechanic in one sentence
- **Structure** — data shape / fields
- **Decision logic** — how it scores, ranks, filters, or sequences
- **Distinctive** — what makes it more than a generic template
- **Use when** — triggering condition; if true, this pattern is a candidate
- **Skip when** — anti-fit / precondition failure; if true, ignore this entry

Priority key:
- **H** = immediate harvest candidate when the matching use-case appears
- **M** = worth implementing when a project naturally touches the area
- **L** = nice-to-have / commodity with one differentiating twist

Total: 41 patterns across 6 categories.

---

## Engineering (8)

### 1. Technical spec section rubric — H
- **Source:** `skills/technical-spec-template/SKILL.md`
- **Idea:** Fixed-order section template that forces decision artefacts, not narrative.
- **Structure:** Sections in order — Context → Goals (with non-goals) → Proposed design → Alternatives considered → Trade-offs → Rollout plan → Open questions.
- **Decision logic:** Each alternative must list at least one reason it was rejected. Open questions block sign-off until resolved.
- **Distinctive:** "Non-goals" and "Alternatives considered" are mandatory sections, not optional appendices. Forces scope discipline.
- **Use when:** writing a design doc for a system that crosses team boundaries or has high reversibility cost.
- **Skip when:** trivial change, single-team internal refactor, or spike/exploration where decisions aren't yet made.

### 2. Build / buy / extend decision rubric — H
- **Source:** `skills/technical-spec-template/SKILL.md` (decision matrix section)
- **Idea:** Three-column scorecard for build-vs-buy-vs-extend decisions.
- **Structure:** Criteria rows (time-to-value, ongoing cost, customisation ceiling, vendor lock-in, team capability, strategic differentiation) × three columns (build/buy/extend). Each cell: score 1–5 + 1-line justification.
- **Decision logic:** Strategic differentiation column is weighted 2×; if a "buy" option scores ≤2 there, build/extend wins regardless of cost.
- **Distinctive:** Explicit weighting prevents cost-only decisions on strategic systems.
- **Use when:** evaluating a 3+ month investment where credible vendors exist and time-to-value matters.
- **Skip when:** commodity tooling (e.g., logging library) or differentiated core where build is the obvious answer.

### 3. Risk-tier test prioritisation (P0/P1/P2) — H
- **Source:** `skills/test-strategy-doc/SKILL.md`
- **Idea:** Tag each test case by tier based on blast radius, not coverage percentage.
- **Structure:** P0 = revenue/data-loss risk (must pass before deploy); P1 = user-visible flow regression (must pass before merge); P2 = edge cases (best-effort).
- **Decision logic:** Tier determined by answering — "If this breaks silently for 24h, what's the cost?" >$10k or data corruption → P0; user-visible but reversible → P1; cosmetic → P2.
- **Distinctive:** Tier is assigned by business impact of failure, not by code complexity or area.
- **Use when:** test suite is growing faster than CI budget, or coverage % has stopped predicting incidents.
- **Skip when:** pre-PMF prototype where breaking things has no production cost.

### 4. Coverage-by-risk allocation — M
- **Source:** `skills/test-strategy-doc/SKILL.md`
- **Idea:** Allocate test effort proportional to risk tier, not by file/component.
- **Structure:** Budget table — P0: 60% effort, P1: 30%, P2: 10%. Map each test back to a risk tier.
- **Decision logic:** If P0 coverage <90% line + branch, block release. P1 coverage <70% triggers review. P2 has no minimum.
- **Distinctive:** Decouples coverage targets from code volume. A small P0 module gets more attention than a sprawling P2 one.
- **Use when:** multiple modules/areas compete for limited test-author bandwidth.
- **Skip when:** small codebase where blanket high coverage is achievable for less effort than tiering.

### 5. Capacity-estimation worksheet — H
- **Source:** `skills/system-design-interview/SKILL.md`
- **Idea:** Back-of-envelope worksheet for QPS, storage, bandwidth, memory.
- **Structure:** Inputs — DAU, actions/user/day, payload size, retention period. Outputs — QPS (peak = 3× avg), storage/day, storage/year, peak bandwidth, hot-set memory.
- **Decision logic:** Peak multiplier 3×; hot-set assumed 20% of total; replication factor 3 for storage; 80/20 read/write unless specified.
- **Distinctive:** Standardised multipliers (3× peak, 20% hot, 3× replication) so estimates are comparable across designs.
- **Use when:** scoping a new service, capacity planning, or interview-style system design.
- **Skip when:** existing system with telemetry — measure instead of estimate.

### 6. Bottleneck identification table — M
- **Source:** `skills/system-design-interview/SKILL.md`
- **Idea:** Table that walks each component against the four resource classes to surface the binding constraint.
- **Structure:** Rows = components (LB, app, cache, DB, queue, storage). Columns = CPU, memory, network, disk I/O. Each cell: utilisation estimate + headroom %.
- **Decision logic:** Component with <20% headroom in any column is the bottleneck candidate. If multiple, the one earliest in request path wins.
- **Distinctive:** Forces explicit consideration of all four resource types per component, so memory or I/O bottlenecks don't hide behind CPU thinking.
- **Use when:** design review for a system expected to grow >10× current load.
- **Skip when:** ad-hoc perf debugging — use profiler/APM data on the actual system instead.

### 7. SQL four-mode framework — H
- **Source:** `skills/sql-query-explainer/SKILL.md`
- **Idea:** One skill, four modes selected by user intent — Explain / Optimise / Write / Document.
- **Structure:** Mode-router prompt that detects intent from verbs (explain/walk-through → Explain mode; slow/optimise/index → Optimise; want/need/get → Write; document/comment → Document). Each mode has its own output template.
- **Decision logic:** Explain = line-by-line annotation; Optimise = EXPLAIN-plan-driven rewrite with before/after cost; Write = requirements → query with assumed schema; Document = inline comment generation + business-purpose summary.
- **Distinctive:** A single multi-mode skill collapses what most teams treat as 4 separate prompts; the intent router is the value.
- **Use when:** building SQL-tooling for analysts or supporting mixed-intent requests in one assistant.
- **Skip when:** one-off query against a known schema — single-mode is simpler.

### 8. Velocity-calibrated sprint capacity — M
- **Source:** `skills/sprint-planning/SKILL.md`
- **Idea:** Capacity formula that combines rolling velocity with explicit deductions for known absences.
- **Structure:** capacity = (rolling_avg_velocity_last_3_sprints) × (1 − pto_days/total_days) × (1 − meeting_overhead_pct) − unplanned_buffer.
- **Decision logic:** Unplanned buffer = 15% if team is stable, 25% if any new joiner or shifting priorities. Rolling avg over 3 sprints, not 6+, to react to team changes.
- **Distinctive:** Two-factor adjustment (PTO + meeting overhead) and the explicit unplanned-buffer that scales with stability.
- **Use when:** team has ≥3 sprints of history and runs fixed-cadence sprints.
- **Skip when:** team <3 sprints old, kanban/continuous flow, or major team composition change in the last month.

---

## PM / Product (10)

### 9. Two-stage RICE — H
- **Source:** `skills/rice-impact-matrix/SKILL.md`
- **Idea:** Filter before ranking — apply binary go/no-go gates before computing RICE scores.
- **Structure:** Stage 1 = strategic-fit gate (binary yes/no on alignment with current quarter theme). Stage 2 = standard RICE (reach × impact × confidence / effort) for items that passed Stage 1.
- **Decision logic:** Items failing Stage 1 are deferred regardless of RICE score. Prevents high-RICE-but-off-strategy items from crowding the roadmap.
- **Distinctive:** The strategic gate. Vanilla RICE has no filter and produces rankings that frequently conflict with strategy.
- **Use when:** backlog has >15 candidates and a strategic theme for the period is defined.
- **Skip when:** <10 candidates (filter overhead exceeds value) or theme is not yet set.

### 10. Strategic-alignment conflict flag — H
- **Source:** `skills/rice-impact-matrix/SKILL.md`
- **Idea:** When RICE ranking conflicts with strategic priority, surface the conflict explicitly rather than overriding silently.
- **Structure:** For each ranked item, compute strategic_priority (1–5) separately. Flag any item where RICE_rank − strategic_rank > 3 as a "review item."
- **Decision logic:** Review items go to a separate "needs leadership decision" list, not auto-included or auto-excluded.
- **Distinctive:** Treats strategy/score mismatch as a decision artefact, not a bug to silently resolve.
- **Use when:** leadership and product team are at impedance over a roadmap and need transparent decision artefacts.
- **Skip when:** single decision-maker with full authority — just decide and move on.

### 11. Responsible-AI canvas rubric — H
- **Source:** `skills/ai-product-canvas/SKILL.md`
- **Idea:** Six-dimension rubric scored before building any AI feature.
- **Structure:** Dimensions — Fairness (bias exposure), Transparency (explainability needed?), Privacy (training-data leakage risk), Safety (worst-case output), Accountability (who owns failures), Sustainability (compute cost). Score 1–5 per dimension with rationale.
- **Decision logic:** Any dimension scoring ≤2 requires mitigation plan before launch. Aggregate <18 → not ready.
- **Distinctive:** Sustainability is included as a dimension. Most canvases drop it; this one keeps compute cost in the conversation.
- **Use when:** building any user-facing AI feature that touches humans (recommendations, content, identity, money).
- **Skip when:** internal-only AI tooling with no external users and no decision-impacting outputs.

### 12. AI-fallback UX pattern catalogue — M
- **Source:** `skills/ai-product-canvas/SKILL.md`
- **Idea:** Pre-built menu of UX behaviours for AI failure modes (low confidence, refusal, latency, hallucination).
- **Structure:** Failure mode × UX response table. Low confidence → show confidence band + "verify" prompt. Refusal → human handoff CTA. Latency → progressive disclosure / skeleton. Hallucination → citation requirement + edit affordance.
- **Decision logic:** Every AI feature must have a documented fallback for at least 3 of the 4 modes.
- **Distinctive:** Makes the fallback a first-class design artefact, not an afterthought.
- **Use when:** shipping AI-powered UI to non-technical end users.
- **Skip when:** developer-facing AI surface (API/CLI/SDK) — failure-mode paradigm differs.

### 13. D/F/V/U assumption matrix — H
- **Source:** `skills/assumption-mapper/SKILL.md`
- **Idea:** Sort assumptions into four risk categories — Desirability, Feasibility, Viability, Usability — and prioritise testing by uncertainty × impact.
- **Structure:** 2×2 per category — uncertainty (low/high) × impact (low/high). Top-right quadrant (high/high) is the test-first list.
- **Decision logic:** Test order = D-quadrant first (the assumption that no one wants it kills the product cheapest), then V, then F, then U.
- **Distinctive:** The fixed test-order (D→V→F→U). Most assumption-mapping treats all four as equal; this one explicitly burns desirability risk first.
- **Use when:** net-new product concept or major pivot, pre-build.
- **Skip when:** incremental feature on a validated product — risks are localised, not categorical.

### 14. JTBD opportunity score — H
- **Source:** `skills/job-story-mapper/SKILL.md`
- **Idea:** Score job-to-be-done opportunities as importance − satisfaction (capped at 0).
- **Structure:** Survey or interview captures importance (1–10) and current-solution-satisfaction (1–10) per job. Score = importance + max(importance − satisfaction, 0).
- **Decision logic:** Score >12 = strong opportunity; 10–12 = consider; <10 = ignore. Importance must be ≥7 to qualify regardless.
- **Distinctive:** The asymmetric formula — under-satisfied important jobs get a double-counted bonus, well-served important jobs are deprioritised.
- **Use when:** you have quantified customer research (importance + satisfaction signals) and a feature backlog to rank.
- **Skip when:** no quantified customer data available — use #9 two-stage RICE instead.

### 15. North Star + counter-metric pair — H
- **Source:** `skills/metrics-framework/SKILL.md`
- **Idea:** Every North Star metric must be paired with at least one counter-metric to prevent gaming.
- **Structure:** Table — North Star | Definition | Counter-metric(s) | Why this counter exists. Example: DAU paired with session-quality-score so engagement can't be inflated by notification spam.
- **Decision logic:** A North Star without a documented counter is rejected. If counter moves opposite to North Star, investigate before celebrating.
- **Distinctive:** The mandatory-pairing rule. Most frameworks list metrics; this one makes counters mandatory.
- **Use when:** setting a top-line OKR or quarterly metric for a product surface.
- **Skip when:** defining team-internal velocity/health metrics where there's no gaming incentive.

### 16. Input/output/health metric tiering — M
- **Source:** `skills/metrics-framework/SKILL.md`
- **Idea:** Three-tier metric taxonomy so teams know which to optimise (inputs), which to track (outputs), and which to defend (health).
- **Structure:** Input metrics = leading, controllable (e.g. activation rate). Output metrics = lagging, business (e.g. revenue). Health metrics = ceiling/floor guardrails (e.g. p99 latency, error rate).
- **Decision logic:** Teams own input metrics. Leadership owns output metrics. Health metrics are shared on-call. Never set a team target on an output metric directly.
- **Distinctive:** Ownership rule — separate accountability for inputs vs outputs.
- **Use when:** org has ≥3 teams contributing to a shared product surface and ownership is unclear.
- **Skip when:** single team owning end-to-end — accountability is implicit.

### 17. Tested-rollback launch gate — H
- **Source:** `skills/launch-readiness/SKILL.md`
- **Idea:** Rollback procedure must be tested in staging within 7 days of launch, not just documented.
- **Structure:** Gate checklist — (1) Rollback runbook exists; (2) Rollback executed end-to-end in staging; (3) Rollback time-to-recovery measured and <30 min; (4) Data-migration reversibility verified.
- **Decision logic:** All 4 must be green to launch. Item 4 (data migration) can be waived only if migration is additive-only.
- **Distinctive:** The staging-execution requirement. Most launch checklists ask "do you have a rollback plan?" — this one demands proof it works.
- **Use when:** launch touches paid, regulated, or data-migration surface.
- **Skip when:** feature-flag rollout already gives instant revert (the flag IS the rollback).

### 18. Cross-functional sign-off checklist — M
- **Source:** `skills/launch-readiness/SKILL.md`
- **Idea:** Named sign-offs from 6 functions, each with one accountable owner, before launch.
- **Structure:** Owner table — Eng (tests + on-call ready), Design (a11y + responsive), PM (success metric + telemetry wired), Legal (T&Cs + data flow), Marketing (messaging + comms), CS (training + macros). Each row has named person and date.
- **Decision logic:** Missing or stale (>7 days) sign-off blocks launch.
- **Distinctive:** Named individual, not function. "PM team" is not a valid sign-off; "Jane Doe, 2026-05-10" is.
- **Use when:** launch is externally visible and crosses ≥3 functions.
- **Skip when:** internal-only or single-team feature.

---

## Sales / CS / Marketing (8)

### 19. Stage-weighted pipeline forecast — H
- **Source:** `skills/sales-forecasting-model/SKILL.md`
- **Idea:** Forecast = Σ (deal_ARR × stage_probability), where stage probabilities come from historical conversion data, not gut feel.
- **Structure:** Stage table — Discovery 10%, Demo 25%, Proposal 45%, Negotiation 70%, Verbal 90%, Closed-won 100%. Tunable per company.
- **Decision logic:** Probabilities must be recalibrated quarterly against actual stage-to-close conversion. Static probabilities decay.
- **Distinctive:** The quarterly recalibration. Most pipeline forecasts use defaults forever.
- **Use when:** SaaS sales org with ≥1 year of CRM history and defined stages.
- **Skip when:** <6 months of pipeline data — averages are noise.

### 20. Best/likely/worst scenario forecast — M
- **Source:** `skills/sales-forecasting-model/SKILL.md`
- **Idea:** Three forecasts published, not one — narrows decision-making to the range that matters.
- **Structure:** Best = pipeline × stage_prob × 1.2; Likely = pipeline × stage_prob; Worst = pipeline × stage_prob × 0.7. Show all three to leadership.
- **Decision logic:** If best-worst spread >40% of likely, pipeline is too thin/speculative — flag for review.
- **Distinctive:** The spread-trigger. The width of the range is itself a signal.
- **Use when:** presenting to a board or planning headcount on uncertain pipeline.
- **Skip when:** short-horizon (this-week) forecasts — the spread doesn't help that close in.

### 21. Stakeholder conversation-sequencing taxonomy — H
- **Source:** `skills/stakeholder-influence-mapper/SKILL.md`
- **Idea:** Order in which you talk to stakeholders matters more than what you say.
- **Structure:** Power × Interest matrix (2×2). Sequence = high-power-high-interest first (champions/blockers), then high-power-low-interest (educate to gain support), then low-power-high-interest (build coalition), then low-power-low-interest (inform).
- **Decision logic:** Skipping ahead to high-power-low-interest before securing champions = predictable failure.
- **Distinctive:** Explicit ordering rule. Most stakeholder maps show who; this one shows when.
- **Use when:** rolling out a change/decision needing buy-in from ≥5 people across hierarchy.
- **Skip when:** small flat-structure team where everyone is in the same conversation anyway.

### 22. BLUF (bottom-line-up-front) update — H
- **Source:** `skills/stakeholder-update/SKILL.md`
- **Idea:** First sentence = the conclusion, decision needed, or status. No build-up.
- **Structure:** First line: status (green/yellow/red) + one-sentence headline. Then: what changed, what's next, what I need from you.
- **Decision logic:** If reader stops after sentence 1, they still got the headline. If status is yellow/red, paragraph 2 must include unblocking ask.
- **Distinctive:** The headline-only-rule for sentence 1. No context, no backstory, no "as discussed."
- **Use when:** writing an async update for busy stakeholders (exec, board, customer).
- **Skip when:** peer-to-peer technical discussion where shared context makes headlines feel curt.

### 23. Metrics-dashboard delta-vs-target — M
- **Source:** `skills/stakeholder-update/SKILL.md`
- **Idea:** Numbers in updates must always be shown as actual + target + delta + trend arrow, never just absolute.
- **Structure:** `Metric: 42 (target 50, −16%, ↓ from 47)`. Four facts per metric.
- **Decision logic:** Bare numbers are rejected. "DAU is 42k" is not informative; "DAU 42k (target 50k, -16%, ↓)" is.
- **Distinctive:** The four-facts-per-number rule.
- **Use when:** any recurring written update with numeric content.
- **Skip when:** a real-time dashboard UI already shows deltas (the formatting would be redundant noise).

### 24. Objection-response catalogue — H
- **Source:** `skills/sales-battlecard/SKILL.md`
- **Idea:** Pre-written responses to the top-N objections, indexed by category (price, integration, security, features, timing).
- **Structure:** Per objection — (a) acknowledge phrase, (b) reframe phrase, (c) evidence/proof point, (d) advance question.
- **Decision logic:** Every battlecard must cover the top 5 objections by frequency from CRM data. Refresh when an unhandled objection shows up >3 times.
- **Distinctive:** The four-part response template (acknowledge → reframe → evidence → question). Stops sellers from skipping straight to rebuttal.
- **Use when:** outbound or inbound sales motion with repeatable buyer personas.
- **Skip when:** highly-customised enterprise deal where every conversation is bespoke.

### 25. Landmine-question planting — M
- **Source:** `skills/sales-battlecard/SKILL.md`
- **Idea:** Questions asked during discovery that, if the buyer also asks competitors, expose competitor weaknesses without naming them.
- **Structure:** Per known competitor weakness, draft a buyer-side question — "How do you handle X?" where X is the weakness. Buyer asks competitors. Competitors either lie or admit gap.
- **Decision logic:** Never disparage competitor directly. Plant the question and let competitor expose self.
- **Distinctive:** Indirect competitive positioning via discovery questions.
- **Use when:** competitive sales process with known, specific competitor weaknesses.
- **Skip when:** greenfield market with no incumbent — nothing to landmine against.

### 26. Search-intent taxonomy — M
- **Source:** `skills/seo-content-brief/SKILL.md`
- **Idea:** Classify target query into Informational / Navigational / Transactional / Commercial-investigation before drafting content.
- **Structure:** Intent table mapping query patterns (what is, how to, near me, vs, best, review, buy, pricing) → intent class → content format (guide, comparison, listing, landing page).
- **Decision logic:** Content format must match intent. Writing a comparison page for an informational query = bounce. Writing a guide for a transactional query = low conversion.
- **Distinctive:** Format-from-intent mapping table. Most SEO briefs pick keyword first; this one picks format first.
- **Use when:** planning SEO content strategy across multiple queries.
- **Skip when:** writing for an already-acquired audience (newsletter, in-product content) where intent is known.

---

## Design / Figma (5)

### 27. Design-system health rubric — H
- **Source:** `skills/figma-component-audit/SKILL.md`
- **Idea:** Five-axis scorecard for design system health.
- **Structure:** Axes — Coverage (% UI built from system), Consistency (visual drift between products), Adoption (% PRs using system tokens), Documentation (% components with usage docs), Maintenance (median age of unresolved component bugs).
- **Decision logic:** Each axis scored 1–5. Score <3 on any axis triggers remediation sprint. Aggregate <16/25 = system at risk.
- **Distinctive:** Adoption-via-PR-data — measures actual code usage, not Figma counts.
- **Use when:** design system has shipped to ≥2 product surfaces and is showing drift.
- **Skip when:** pre-launch design system — measure adoption later.

### 28. Orphan/duplicate detection rule set — M
- **Source:** `skills/figma-component-audit/SKILL.md`
- **Idea:** Heuristics to find components that should be deleted or merged.
- **Structure:** Rules — (a) Used in 0 frames → orphan, mark for deletion. (b) Name distance <3 chars from another component → duplicate candidate. (c) Used <3 places + age >6 months → demotion candidate. (d) Variants <2 → consider removing variant set.
- **Decision logic:** Run quarterly. Author of duplicate gets first refusal to merge.
- **Distinctive:** Specific quantitative thresholds (3 chars, 3 places, 6 months) — turns vibe checks into routine maintenance.
- **Use when:** design library has ≥6 months of organic growth and >50 components.
- **Skip when:** new or small library — manual review is faster than running heuristics.

### 29. Pre-handoff QA checklist — H
- **Source:** `skills/figma-design-qa/SKILL.md`
- **Idea:** 12-item checklist run before any design is handed to engineering.
- **Structure:** Items — (1) all text uses styles, (2) all colours use tokens, (3) spacing on 4/8pt grid, (4) responsive breakpoints defined, (5) empty/loading/error states present, (6) a11y contrast verified, (7) interactions/animations specified, (8) edge content (long names, RTL) tested, (9) component variants documented, (10) hand-off frames named consistently, (11) export settings configured, (12) developer notes attached.
- **Decision logic:** All 12 must be green to mark "ready for dev." Auto-checkable items (grid, contrast) run via plugin.
- **Distinctive:** Items 5 and 8 (states + edge content) — most QA lists skip these.
- **Use when:** dedicated design→eng handoff motion exists (separate roles, not joint).
- **Skip when:** designer and engineer pair on every feature — checklist becomes overhead.

### 30. 4/8pt token grid — M
- **Source:** `skills/figma-spacing-system/SKILL.md`
- **Idea:** All spacing/sizing values are multiples of 4 (or 8 for layout-level) — exposed as named tokens.
- **Structure:** Tokens — xs(4), sm(8), md(16), lg(24), xl(32), 2xl(48), 3xl(64). Layout grid uses 8pt minimum.
- **Decision logic:** Any value not a token is rejected. Custom values require new token + rationale.
- **Distinctive:** Strict token-only rule (vs "prefer tokens"). And the layout/component split (8pt for layout, 4pt for component internals).
- **Use when:** setting up a new design system or rationalising an inconsistent one.
- **Skip when:** marketing landing page or one-off design where strict grid limits expressive freedom.

### 31. Pre-build variant property matrix — H
- **Source:** `skills/figma-variant-matrix/SKILL.md`
- **Idea:** Before building a component, list its variant properties × values and prune combinations.
- **Structure:** Property × value grid. Example for Button — Variant (primary/secondary/tertiary) × State (default/hover/active/disabled) × Size (sm/md/lg) × Icon (none/leading/trailing) = 144 combos. Prune obviously-invalid ones (e.g. disabled+hover = same as disabled).
- **Decision logic:** If pruned-combo-count >36, split into smaller components. If property count >5, split.
- **Distinctive:** Combinatorial budget — keeps variant sets from exploding to 200+ unmanageable variants.
- **Use when:** component will have ≥3 variant properties or is foundational (button, input, card).
- **Skip when:** one-off layout or compositional component — just build it.

---

## Ops / HR / Cross-Functional (6)

### 32. Activity-time-energy budget — H
- **Source:** `skills/workshop-facilitation-guide/SKILL.md`
- **Idea:** Plan a workshop as a budget across three axes — time, attention, energy.
- **Structure:** Per activity — time (min), attention-cost (low/med/high), energy-cost (low/med/high), output. Day-long total caps — 6h speaking time, 3 high-attention activities, 2 high-energy activities.
- **Decision logic:** Exceeding any cap = facilitator pre-failed the day. Re-plan.
- **Distinctive:** Three-axis budget (most planning treats only time). Captures why 8 back-to-back medium activities are worse than 4 mixed-intensity ones.
- **Use when:** facilitating a multi-hour workshop with diverse stakeholders.
- **Skip when:** standing meeting or single-purpose decision call.

### 33. Facilitation-move catalogue — M
- **Source:** `skills/workshop-facilitation-guide/SKILL.md`
- **Idea:** Named moves for common facilitation situations, so the facilitator has a vocabulary instead of improvising.
- **Structure:** Move → trigger → script. E.g. "Park it" (off-topic tangent) → "Great point, parking on the board, back to X." "Round robin" (one person dominating) → "Let's hear from everyone — 30 seconds each."
- **Decision logic:** Facilitator practises 5–10 moves before workshop. Picks 3–5 to use that day.
- **Distinctive:** Named, reusable moves vs generic "manage the room" advice.
- **Use when:** a new or developing facilitator is preparing for a high-stakes workshop.
- **Skip when:** experienced facilitator with their own move repertoire already.

### 34. Weighted vendor scorecard — H
- **Source:** `skills/vendor-evaluation/SKILL.md`
- **Idea:** Criteria × vendor matrix with explicit weights set before vendors are scored.
- **Structure:** Criteria rows (functionality, security, integration, price, vendor health, support, roadmap fit) × weight (0–10, sum to 100) × vendor columns (score 1–5). Total = Σ(weight × score).
- **Decision logic:** Weights locked before scoring (to prevent post-hoc tuning to favourite). Sensitivity check — if shifting any weight ±20% changes winner, decision is fragile.
- **Distinctive:** Lock-weights-first rule and the sensitivity check.
- **Use when:** vendor decision involves ≥3 functions evaluating ≥3 candidates.
- **Skip when:** single-criterion decision (e.g., cheapest commodity) or sole-source candidate.

### 35. Resistance-vs-change-curve framework — M
- **Source:** `skills/change-management-plan/SKILL.md`
- **Idea:** Map each stakeholder group to a position on the change curve (denial / resistance / exploration / commitment) and design interventions per stage.
- **Structure:** Group × stage matrix. Interventions per stage — denial → information, resistance → empathy + small wins, exploration → enablement, commitment → reinforcement.
- **Decision logic:** Don't push commitment-stage tactics on resistance-stage groups. Wrong-stage intervention deepens resistance.
- **Distinctive:** Stage-matched intervention. Most plans push one message at all groups simultaneously.
- **Use when:** rolling out org-wide process change (tooling switch, restructure, methodology).
- **Skip when:** voluntary opt-in change with no enforcement — resistance management is over-engineering.

### 36. 30/60/90 onboarding milestones — H
- **Source:** `skills/onboarding-plan/SKILL.md`
- **Idea:** Three milestone gates with measurable success criteria, not "ramp up."
- **Structure:** Day 30 = understand (can describe team, codebase, key stakeholders); Day 60 = contribute (shipped non-trivial change with mentor); Day 90 = own (leads a feature/area independently).
- **Decision logic:** Manager check-in at each gate. Miss a gate → reset expectations explicitly, don't drift.
- **Distinctive:** Behavioural criteria per gate. "Understand the team" is vague; "can name top 3 stakeholders and their priorities" is checkable.
- **Use when:** hiring into a role with >2 weeks ramp time and an available manager.
- **Skip when:** contractor or short-term role — set narrower week-by-week milestones instead.

### 37. Multi-framework compliance crosswalk — M
- **Source:** `skills/compliance-checklist/SKILL.md`
- **Idea:** One control list mapped to multiple frameworks (GDPR, SOC 2, ISO 27001, HIPAA, PCI DSS) — implement once, satisfy many.
- **Structure:** Control row × framework columns. Example — "Access logs retained 12 months" satisfies GDPR Art. 30, SOC 2 CC6.1, ISO A.12.4, HIPAA §164.312(b).
- **Decision logic:** Maximise overlap. Implement the strictest version of each control to satisfy all mapped frameworks.
- **Distinctive:** The strictest-wins implementation rule, plus the crosswalk format.
- **Use when:** org pursues ≥2 frameworks (e.g., SOC 2 + GDPR + ISO 27001) and wants to deduplicate work.
- **Skip when:** single-framework target — direct mapping is simpler than a crosswalk.

---

## Additional High-Value Patterns (4)

### 38. Now / Next / Later roadmap horizons — H
- **Source:** `skills/roadmap-narrative/SKILL.md`
- **Idea:** Three time horizons with deliberately decreasing specificity, paired with a strategic narrative arc.
- **Structure:** Now (this quarter, named items, owners, dates), Next (1–2 quarters out, themes, no dates), Later (beyond, bets, no commitments). Narrative arc connects them — what we believe, what we're proving, what we'll know.
- **Decision logic:** Specificity is inversely related to horizon. Date-committing Later items = anti-pattern.
- **Distinctive:** The narrative arc binding the three horizons — they're not just three columns, they're a story.
- **Use when:** communicating roadmap externally (customers, board) or to an org >50 people.
- **Skip when:** small-team internal planning where committed dates are tracked in a sprint tool already.

### 39. Sample size + MDE calculator — M
- **Source:** `skills/experiment-designer/SKILL.md` (and/or `skills/ab-test-planner/SKILL.md`)
- **Idea:** Pre-experiment calculation of required sample size for detectable effect.
- **Structure:** Inputs — baseline conversion, MDE (minimum detectable effect), power (0.8 default), significance (0.05 default). Output — required sample per arm.
- **Decision logic:** If sample size > available traffic in target window, either widen MDE, extend duration, or abandon. Don't run underpowered tests.
- **Distinctive:** The abandon-underpowered rule. Most experiment templates compute sample size and then ignore the inconvenient answer.
- **Use when:** A/B test with a binary outcome and a constrained traffic budget.
- **Skip when:** traffic is plentiful AND effect size is large — just run it and read the result.

### 40. Latency budget breakdown — M
- **Source:** `skills/system-design-interview/SKILL.md`
- **Idea:** Allocate p99 latency budget across the request path, then verify each component meets its share.
- **Structure:** Total budget (e.g. 500ms p99) → split by component (LB 10ms, app 100ms, cache 5ms, DB 200ms, serialise 50ms, network round-trips 100ms, buffer 35ms).
- **Decision logic:** Component over budget = optimisation target. Sum must include all hops and a buffer ≥10%.
- **Distinctive:** Explicit per-component allocation. Most designs pick total target then "try to be fast" everywhere.
- **Use when:** user-facing system with a stated SLA (e.g. <500ms p99).
- **Skip when:** batch / async workloads where p99 doesn't apply.

### 41. Control-mapping evidence table — L
- **Source:** `skills/compliance-checklist/SKILL.md`
- **Idea:** For each compliance control, document the artefact that demonstrates it (log file, policy doc, runbook, screenshot) and where it lives.
- **Structure:** Control | Framework refs | Evidence type | Evidence location | Owner | Last verified.
- **Decision logic:** Evidence verified quarterly. Stale evidence (>90 days) flagged. Missing evidence blocks audit.
- **Distinctive:** Evidence-location field. Auditors don't want "we do this" — they want "see file X in system Y."
- **Use when:** preparing for an external audit (SOC 2, ISO 27001, HIPAA).
- **Skip when:** pre-audit posture-building — focus on implementing controls first, evidence-trail later.

---

## How to use this list (agent-facing)

**Relevance triage flow:**

1. Read the section heading matching your target domain (or scan all if cross-cutting).
2. For each entry in scope, check `Use when` against your target context. If it matches, the entry is a candidate.
3. Check `Skip when`. If it matches, drop the entry even if `Use when` matched — anti-fit overrides fit.
4. For remaining candidates, read `Distinctive` to confirm the pattern isn't redundant with something you already have.
5. If still a strong fit, use `Structure` + `Decision logic` to re-implement in vanilla code. Source path is for last-resort validation only.

**False-positive cost > false-negative cost.** Be conservative on the `Use when` match — when in doubt, skip rather than extract.

**Adjacencies worth knowing:**
- #14 (JTBD opportunity score) pairs with #13 (D/F/V/U) — score after assumption-mapping
- #15 (North Star + counter) feeds into #39 (MDE calculator) — North Star drives the test metric
- #9 (two-stage RICE) and #10 (alignment conflict flag) are usually adopted together
- #36 (30/60/90 onboarding) extends naturally with #33 (facilitation moves) for the manager
- #19 (stage-weighted forecast) and #20 (best/likely/worst) are usually adopted together
- #34 (vendor scorecard) reuses the same locked-weights mechanic from #2 (build/buy/extend)

## Gaps this list does not cover

- Exact wording / voice of original prompts
- Verbatim checklist items beyond the illustrative ones above
- Domain-specific examples that the original skills carry
- Tone calibration for end-user-facing outputs

If you hit a gap, that's the signal to either expand the entry or do a targeted re-read of the named SKILL.md.
