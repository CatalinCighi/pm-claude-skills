# PM Sprint Agent — Agent Template

> **An end-to-end sprint planning agent built from existing skills in pm-claude-skills. Pulls your backlog, calculates capacity, drafts the sprint plan, flags risks, and posts the result.**

This is the first agent template in the pm-claude-skills library. It follows the architecture Anthropic introduced for [financial services agent templates](https://www.anthropic.com/news/finance-agents) on May 5, 2026 — packaging **skills + connectors + subagents** into a single runnable workflow.

---

## What it does

You point this agent at your team's backlog and a sprint goal. It does the rest:

1. **Pulls open issues** from Linear or Jira, filtered by the sprint scope
2. **Calculates team capacity** for the upcoming sprint (using the Capacity Analyst subagent)
3. **Drafts a sprint plan** using the `sprint-planning` skill from this library
4. **Generates a sprint kickoff brief** using the `sprint-brief` skill
5. **Scores delivery risks** for the proposed plan (using the Risk Scorer subagent)
6. **Posts the result** to a Slack channel for team review

End-to-end: roughly 90 seconds for a 25-issue backlog.

---

## What's inside this template

```
templates/pm-sprint-agent/
├── README.md                          ← you are here
├── AGENT.md                           ← agent definition (system prompt + tool list)
├── orchestrate.sh                     ← orchestration script
├── skills/                            ← skills used by this agent (linked from main library)
│   ├── sprint-planning/SKILL.md       ← (symlink to ../../skills/sprint-planning/)
│   ├── sprint-brief/SKILL.md          ← (symlink to ../../skills/sprint-brief/)
│   ├── retro/SKILL.md                 ← (symlink to ../../skills/retro/)
│   └── project-status-report/SKILL.md ← (symlink to ../../skills/project-status-report/)
├── subagents/
│   ├── capacity-analyst.md            ← team capacity calculation subagent
│   └── risk-scorer.md                 ← delivery risk scoring subagent
├── connectors/
│   ├── README.md                      ← connector setup guide
│   ├── linear.example.json            ← Linear connector example config
│   └── jira.example.json              ← Jira connector example config
├── examples/
│   ├── input-example.md               ← what you feed the agent
│   └── output-example.md              ← what the agent produces
└── tests/
    └── smoke-test.md                  ← manual smoke test for new installations
```

---

## Quick install (5 minutes)

### Prerequisites

- Claude Code installed
- The full skills library installed: `/plugin marketplace add mohitagw15856/pm-claude-skills`
- A Linear or Jira workspace
- A Slack workspace (optional — for the post-to-Slack step)

### Setup steps

**1. Configure your connectors.**

Open `connectors/linear.example.json` (or `jira.example.json` if you use Jira) and fill in your team's specifics. Save as `connectors/linear.json` (without the `.example`). Add your API token to the credentials section.

```bash
cd templates/pm-sprint-agent/connectors
cp linear.example.json linear.json
# Edit linear.json with your team_id, workspace_url, and API token
```

**2. Configure the agent.**

Open `AGENT.md` and update the configuration block at the top with your team's defaults — sprint length, capacity buffer, default Slack channel.

**3. Test the smoke test.**

Run the smoke test to verify everything is wired up:

```bash
bash orchestrate.sh --dry-run --sprint-goal "Test sprint planning"
```

If the dry-run completes without errors, you're ready to run a real sprint plan.

---

## Running the agent

### Standard usage

```bash
bash orchestrate.sh \
  --sprint-goal "Reduce checkout abandonment by 20%" \
  --sprint-number 23 \
  --team-size 5 \
  --duration-weeks 2
```

The agent will:

1. Pull open issues tagged with the sprint goal scope
2. Run the Capacity Analyst subagent to calculate available capacity
3. Run the `sprint-planning` skill to draft the sprint plan
4. Run the Risk Scorer subagent to flag delivery risks
5. Run the `sprint-brief` skill to generate the kickoff brief
6. Output everything to `output/sprint-23-plan.md`
7. (Optionally) post a summary to your configured Slack channel

### Configuration options

| Flag | Required | Default | Description |
|---|---|---|---|
| `--sprint-goal` | Yes | — | Short description of what the sprint should achieve |
| `--sprint-number` | Yes | — | Which sprint this is (e.g., 23) |
| `--team-size` | No | 5 | Number of engineers on the team |
| `--duration-weeks` | No | 2 | Sprint length in weeks |
| `--capacity-buffer` | No | 0.2 | Buffer for unplanned work (0-1 range) |
| `--include-bugs` | No | true | Include open bugs in the sprint plan |
| `--post-to-slack` | No | true | Post summary to Slack |
| `--dry-run` | No | false | Validate config without running the workflow |

---

## Why this architecture

The template follows Anthropic's three-component pattern:

**Skills** provide the structured output formats. The `sprint-planning` skill knows what a sprint plan should contain. The `sprint-brief` skill knows what a kickoff brief should look like. These already exist in this library — the agent doesn't reinvent them.

**Connectors** provide governed access to data. The agent doesn't hold your Linear API token in a prompt — it uses the configured Linear connector with proper authentication and rate limiting.

**Subagents** handle specialised analysis. Calculating team capacity isn't a one-shot generation task — it requires reading PTO calendars, assessing historical velocity, and adjusting for known capacity hits. That's a focused job for a subagent. Same logic for risk scoring.

This separation matters because each component can be tested, swapped, and improved independently. If you want to use a different sprint planning skill, swap it. If you switch from Linear to Jira, swap the connector. If you build a better capacity model, replace the subagent. The orchestration script doesn't change.

---

## Customisation

### Use your team's templates

This agent uses the generic `sprint-planning` and `sprint-brief` skills from the main library. If your team has specific conventions — story point scale, definition of done format, retro categories — fork the skills into the `skills/` folder of this template and modify them. The orchestration script will pick up the local versions.

### Add additional analysis steps

Add new subagents to `subagents/` for any specialised analysis your team needs — engineering manager reviews, stakeholder impact assessment, dependency mapping. Update `orchestrate.sh` to call them at the appropriate point in the workflow.

### Switch ticketing systems

The connectors are decoupled from the orchestration. Swap `linear.json` for `jira.json` (or build a connector for any other system) without touching the agent definition.

---

## Limitations and honest caveats

**Capacity calculation is heuristic, not exact.** The Capacity Analyst subagent makes reasonable estimates based on historical velocity and team size. For more accurate capacity calculation, integrate with your team's actual time-tracking system.

**Risk scoring is directional, not predictive.** The Risk Scorer flags items that historically correlate with delivery risk (large story points, dependencies, team members on PTO). It doesn't predict what will actually slip. Use it as a discussion starter, not a forecast.

**Linear and Jira are tier-1 supported.** Other ticketing systems (Shortcut, Asana, Trello, ClickUp) can be added by following the connector pattern in `connectors/README.md` but aren't included out of the box.

**No autonomous execution.** This template runs as a Claude Code plugin — meaning it produces outputs for human review, it doesn't autonomously create or modify tickets. For autonomous execution, deploy via [Claude Managed Agents](https://www.anthropic.com/news/managed-agents) using the same skills, connectors, and subagent definitions.

---

## Contributing

If you build on this template — adding a new connector, improving the subagents, supporting a new ticketing system — consider raising a PR back to the main repo. Improvements that benefit the broader community are welcome.

For a full template contribution guide, see [`templates/CONTRIBUTING.md`](../CONTRIBUTING.md) (coming soon).

---

## Where to learn more

- [Anthropic's announcement of agent templates](https://www.anthropic.com/news/finance-agents) (May 2026)
- [Anthropic's Claude Managed Agents documentation](https://www.anthropic.com/news/managed-agents)
- [The pm-claude-skills main README](../../README.md)
- [Part 16 article — Building My First Agent Template](#) *(link added when published)*

---

*Built and maintained by [Mohit Aggarwal](https://medium.com/@mohit15856) | First agent template in [pm-claude-skills](https://github.com/mohitagw15856/pm-claude-skills)*
