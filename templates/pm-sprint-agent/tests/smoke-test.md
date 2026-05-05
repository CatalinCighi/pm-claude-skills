# Smoke Test — PM Sprint Agent

A quick manual test to verify your installation is working correctly. Run this after first-time setup.

## What this tests

- Connector configuration is valid
- Credentials are correctly set
- Skills are accessible from the main library
- Subagents are correctly defined
- Orchestration script runs without errors

## How to run

### Step 1: Verify connector setup

```bash
cd templates/pm-sprint-agent

# Should show one of these files (or both):
ls connectors/linear.json connectors/jira.json 2>/dev/null

# If neither exists, you haven't configured a connector yet
# See connectors/README.md
```

### Step 2: Verify credentials

```bash
# For Linear:
echo "LINEAR_API_KEY length: ${#LINEAR_API_KEY}"
# Should print a non-zero number (typically 40+ characters)

# For Jira:
echo "JIRA_EMAIL: $JIRA_EMAIL"
echo "JIRA_API_TOKEN length: ${#JIRA_API_TOKEN}"
# Both should be set
```

### Step 3: Run the dry-run

```bash
bash orchestrate.sh \
  --sprint-goal "Smoke test" \
  --sprint-number 999 \
  --dry-run
```

**Expected output:**
- Configuration banner showing all parameters
- "✓ Dry-run complete. Configuration is valid."
- Exit code 0

If you see errors, check:
- Required arguments are provided (`--sprint-goal` and `--sprint-number`)
- Connector file exists in `connectors/`
- Credentials environment variables are set

### Step 4: Run a real sprint plan against a test workspace

If you have access to a test/dev Linear or Jira workspace, run a real plan:

```bash
bash orchestrate.sh \
  --sprint-goal "Test sprint plan from PM Sprint Agent" \
  --sprint-number 999 \
  --team-size 2 \
  --duration-weeks 1
```

**Expected output:**
- Six steps complete with ✓ indicators
- Output file created at `output/sprint-999-plan.md`
- (If post-to-Slack is enabled) Slack summary posted

## What to do if a step fails

| Failure | Likely cause | Fix |
|---|---|---|
| "No connector configured" | Missing `connectors/linear.json` or `connectors/jira.json` | Copy the `.example.json`, fill in your values |
| "API key not set" | Environment variable not exported | Add `export LINEAR_API_KEY=...` to your shell config |
| "Skills not found" | Main library not installed | Run `/plugin marketplace add mohitagw15856/pm-claude-skills` in Claude Code |
| "Subagent not found" | Path issue in template structure | Verify you cloned the full repo, not just the agent folder |
| "Output directory not writable" | Permissions issue | Run `mkdir -p output && chmod u+w output` |

## Reporting issues

If the smoke test fails and you can't resolve it from the table above, [open an issue](https://github.com/mohitagw15856/pm-claude-skills/issues) with:

- The exact command you ran
- The full error output
- Which connector you're using (Linear or Jira)
- Your operating system

Don't include credentials or API keys in the issue.
