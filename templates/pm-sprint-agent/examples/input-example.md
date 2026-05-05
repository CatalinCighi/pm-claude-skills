# Example: Input to the PM Sprint Agent

This is what you provide when running the agent. Use this as a reference for what to pass in real usage.

## Command-line invocation

```bash
bash orchestrate.sh \
  --sprint-goal "Reduce checkout abandonment by 20%" \
  --sprint-number 23 \
  --team-size 5 \
  --duration-weeks 2 \
  --capacity-buffer 0.2 \
  --include-bugs true \
  --post-to-slack true
```

## What the agent reads from your connector

The agent automatically pulls these from Linear or Jira — you don't need to provide them:

### From the ticketing system
- All open issues in the configured project, filtered by:
  - State: backlog or ready (not "in progress" or "done")
  - Not already assigned to an active sprint
  - Tagged with the sprint goal scope (if such tags exist)
- For each issue:
  - Title and description
  - Story point estimate
  - Priority
  - Assignee (if any)
  - Dependencies and blockers
  - Recent comments
  - Labels and components

### From the team's velocity history
- Story points completed in each of the last 3 sprints
- Items that slipped from the last 3 sprints
- Average issue size and standard deviation

### From the team's calendar (if calendar integration is set up)
- PTO entries for the upcoming sprint window
- Public holidays affecting the team
- Conferences or training days
- Known on-call rotations

## What the agent does NOT need from you

You do NOT need to provide:
- A list of items to include — the agent picks based on capacity and priority
- Story point estimates — the agent uses what's already in the ticketing system
- Risk assessments — the agent generates these
- Brief content — the agent generates this from the plan

If items don't have story point estimates, the agent will flag this and ask you to estimate before continuing.

## What the agent expects you to know

You should be able to answer:

- **What is the sprint goal?** A single-sentence outcome the team is committing to.
- **Which sprint number is this?** Used for tracking and continuity.
- **How big is the team?** Number of engineers actually working on the sprint.
- **How long is the sprint?** Usually 1 or 2 weeks.

If you're not sure of any of these, the agent will ask. But the workflow is fastest when you know them upfront.

## Example: Real-world invocation

```bash
# Standard 2-week sprint with default settings
bash orchestrate.sh \
  --sprint-goal "Ship the new pricing page A/B test" \
  --sprint-number 47

# Small team, 1-week sprint
bash orchestrate.sh \
  --sprint-goal "Fix high-priority bugs before launch" \
  --sprint-number 48 \
  --team-size 3 \
  --duration-weeks 1 \
  --include-bugs true

# Larger team, with conservative buffer
bash orchestrate.sh \
  --sprint-goal "Migrate authentication to new identity provider" \
  --sprint-number 49 \
  --team-size 8 \
  --capacity-buffer 0.3 \
  --include-bugs false

# Dry run to validate config without executing
bash orchestrate.sh \
  --sprint-goal "Test sprint" \
  --sprint-number 99 \
  --dry-run
```
