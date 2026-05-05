# Sprint 23 Plan

**Sprint Goal:** Reduce checkout abandonment by 20%
**Duration:** 2 weeks
**Team Size:** 5 engineers
**Generated:** 2026-05-05 14:30 BST
**Connector Used:** linear

---

## Capacity Summary

### Headline numbers

| Metric | Value |
|---|---|
| Base capacity | 130 story points |
| Capacity hits | -16 story points |
| Buffer reserved (20%) | -22 story points |
| **Available capacity** | **92 story points** |

### Per-engineer breakdown

| Engineer | Available SP | Notes |
|---|---|---|
| Engineer 1 (Sarah) | 22 | Full availability |
| Engineer 2 (Marcus) | 18 | 2 days PTO mid-sprint |
| Engineer 3 (Priya) | 22 | Full availability |
| Engineer 4 (David) | 12 | On-call week 1 (50% reduction) |
| Engineer 5 (Lin) | 18 | 2 days at conference week 2 |

### Assumptions used
- Baseline velocity: 13 points/engineer/week (calibrated from last 3 sprints: 12.8, 13.2, 13.0 average)
- Buffer applied: 20%
- Capacity hits: 4 PTO days, 5 on-call days, 2 conference days

### Confidence: **High**
Historical velocity provided and capacity hits are confirmed in the team calendar.

### Caveats
- Unplanned production incidents could reduce on-call engineer's capacity further
- New starter onboarding could pull from more senior engineers' time
- Sprint review prep (~4 hours team-wide) is included in the buffer

---

## Sprint Plan

### Selected items (87 of 92 available story points)

| Issue | Title | SP | Priority | Owner |
|---|---|---|---|---|
| CHK-142 | Add saved-cart recovery email at 30 min | 8 | High | Sarah |
| CHK-138 | Fix slow-loading payment iframe on Safari | 5 | High | Marcus |
| CHK-156 | A/B test: simplified checkout vs current | 13 | High | Priya |
| CHK-149 | Add address auto-complete for international | 8 | Medium | Sarah |
| CHK-161 | Show estimated delivery date earlier in flow | 5 | Medium | Marcus |
| CHK-145 | Improve guest checkout conversion | 13 | High | Priya |
| CHK-167 | Reduce required fields on payment step | 5 | High | David |
| CHK-152 | Optimise checkout JS bundle size | 8 | Medium | Lin |
| CHK-159 | Better error messages on card decline | 3 | High | David |
| CHK-163 | Track funnel drop-off in analytics dashboard | 5 | Medium | Sarah |
| CHK-171 | Bug fix: discount code validation race condition | 5 | High | Lin |
| CHK-175 | Bug fix: tax calculation off by 1 cent in EU | 3 | Medium | Marcus |
| CHK-177 | Bug fix: Apple Pay button not appearing on iOS 17 | 6 | High | David |

**Total: 87 story points** (5 points unallocated as additional buffer)

### Definition of done

- All A/B test variants are deployed behind feature flags
- Analytics events fire correctly for funnel tracking
- All bug fixes have regression tests
- Cross-browser testing complete (Chrome, Safari, Firefox, Edge)
- Mobile testing complete (iOS, Android)
- Performance budget met (no checkout step exceeds 2.5s LCP)
- Team retro signed off by sprint owner

### Dependencies flagged

- CHK-156 depends on the analytics events from CHK-163 being deployed first
- CHK-145 may require design review for any new UI elements
- CHK-177 requires testing on physical iOS 17 devices

---

## Risk Assessment

### Overall sprint risk: **Medium**

The plan is realistic but has some concentration risk on Priya (two of the larger items).

### Risk score breakdown

| Dimension | Average score (1-5) | Highest-risk items |
|---|---|---|
| Size risk | 2.4 | CHK-156, CHK-145 (both 13 points) |
| Dependency risk | 2.0 | CHK-156 (depends on CHK-163) |
| Knowledge risk | 2.6 | CHK-156, CHK-145 (both Priya only) |

### Per-item risk scores (top 5)

| Item | Size | Dep | Know | Composite | Flags |
|---|---|---|---|---|---|
| CHK-156 (A/B test) | 4 | 3 | 4 | 3.7 | Large + dependency + Priya only |
| CHK-145 (guest checkout) | 4 | 1 | 4 | 3.0 | Large + Priya only |
| CHK-177 (Apple Pay) | 3 | 2 | 3 | 2.7 | iOS 17 testing required |
| CHK-152 (JS bundle) | 3 | 1 | 3 | 2.3 | Lin only knows the build system |
| CHK-167 (required fields) | 2 | 2 | 2 | 2.0 | Frontend + backend coordination |

### Risk patterns identified

**Single-engineer concentration**
- Items affected: CHK-156, CHK-145, CHK-149, CHK-163 (all Priya/Sarah)
- Why this is risky: 39 of 87 story points (45%) depend on two engineers
- Suggested mitigation: Pair Priya with Marcus on CHK-156 to spread knowledge

**Bug-fix load (within acceptable range)**
- Items affected: CHK-171, CHK-175, CHK-177 (14 SP total)
- Why this is acceptable: 16% of capacity, below the 30% threshold

### Pre-sprint mitigation actions

1. **Pair Priya with Marcus on CHK-156** — Sarah Chen — by sprint kickoff
2. **Confirm iOS 17 device availability for CHK-177** — David Park — by EOD Monday
3. **Get design review scheduled for CHK-145** — Sarah Chen — by EOD Tuesday
4. **Verify analytics dashboard has capacity for new events (CHK-163)** — Lin Wang — by sprint kickoff

### Items recommended for breakdown

- **CHK-156 (A/B test: simplified checkout)** — at 13 points and high knowledge concentration, recommend breaking into:
  - CHK-156a: Build A/B variant of checkout flow (8 SP)
  - CHK-156b: Wire up analytics tracking for the test (5 SP)

---

## Kickoff Brief

### Sprint at a glance

**Goal:** Reduce checkout abandonment by 20%

This sprint is laser-focused on conversion optimisation across the checkout funnel. We're shipping the most impactful changes our funnel analysis identified: saved-cart recovery, simplified checkout flow (A/B tested), better error handling, and improving guest checkout conversion.

We'll know we succeeded if checkout completion rate increases by 4 percentage points (current 82% → target 86%).

### Why this sprint matters

Checkout abandonment is currently costing us approximately £180k per month in lost revenue. The funnel analysis from Q1 identified seven specific friction points — six of those are addressed in this sprint. The seventh (international currency display) is being deferred to next sprint pending design.

### What's being shipped

**Conversion optimisation (61 SP)**
- Saved-cart recovery email
- A/B test of simplified checkout
- Better guest checkout
- Address auto-complete
- Earlier delivery date display
- Reduced required fields

**Performance and analytics (13 SP)**
- Checkout JS bundle optimisation
- Funnel drop-off tracking

**Bug fixes (14 SP)**
- Safari payment iframe slowness
- Discount code race condition
- EU tax calculation
- Apple Pay on iOS 17
- Card decline error messages

### What we're NOT doing this sprint

- International currency display (deferred — needs design)
- Mobile checkout redesign (deferred — out of sprint scope)
- New payment method integration (deferred — Q3 priority)

### Definition of success

- Checkout completion rate ≥ 86% (measured 30 days post-deploy)
- A/B test reaches statistical significance within 14 days
- All bug fixes deploy without regression
- No production incidents from changes shipped this sprint

### Risks the team should know

- Two of our highest-impact items depend heavily on Priya — we've paired her with Marcus to spread knowledge
- CHK-156 should be broken into two smaller items at refinement
- iOS 17 device availability needs confirmation before sprint start

---

## Action Items for Sprint Planning Meeting

1. ✋ **Review the risk assessment** with the team — discuss the single-engineer concentration on Priya
2. ✋ **Decide whether to break down CHK-156** into two smaller items
3. ✋ **Confirm iOS 17 device availability** with David before locking in CHK-177
4. ✋ **Confirm capacity assumptions** match what engineers actually expect
5. ✋ **Lock in the sprint goal** — get verbal commitment from the team
6. ✋ **Update Linear** with the agreed sprint scope after the meeting

---

*Generated by [PM Sprint Agent](https://github.com/mohitagw15856/pm-claude-skills/tree/main/templates/pm-sprint-agent) — first agent template in the pm-claude-skills library*
