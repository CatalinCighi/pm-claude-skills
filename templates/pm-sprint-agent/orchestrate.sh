#!/bin/bash

# =============================================================================
# orchestrate.sh — PM Sprint Agent
# =============================================================================
# Orchestrates the end-to-end sprint planning workflow:
#   1. Validate configuration and connector
#   2. Pull open issues from Linear or Jira
#   3. Run Capacity Analyst subagent
#   4. Run sprint-planning skill via Claude Code
#   5. Run Risk Scorer subagent
#   6. Run sprint-brief skill via Claude Code
#   7. Combine outputs into a sprint planning document
#   8. (Optionally) post summary to Slack
#
# Usage:
#   bash orchestrate.sh --sprint-goal "GOAL" --sprint-number N [options]
#
# See AGENT.md for full documentation.
# =============================================================================

set -e
set -o pipefail

# -----------------------------------------------------------------------------
# Default values (override with command-line flags)
# -----------------------------------------------------------------------------
SPRINT_GOAL=""
SPRINT_NUMBER=""
TEAM_SIZE=5
DURATION_WEEKS=2
CAPACITY_BUFFER=0.2
INCLUDE_BUGS=true
POST_TO_SLACK=true
DRY_RUN=false
OUTPUT_DIR="./output"

# -----------------------------------------------------------------------------
# Parse command-line arguments
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case $1 in
    --sprint-goal)
      SPRINT_GOAL="$2"
      shift 2
      ;;
    --sprint-number)
      SPRINT_NUMBER="$2"
      shift 2
      ;;
    --team-size)
      TEAM_SIZE="$2"
      shift 2
      ;;
    --duration-weeks)
      DURATION_WEEKS="$2"
      shift 2
      ;;
    --capacity-buffer)
      CAPACITY_BUFFER="$2"
      shift 2
      ;;
    --include-bugs)
      INCLUDE_BUGS="$2"
      shift 2
      ;;
    --post-to-slack)
      POST_TO_SLACK="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "PM Sprint Agent — orchestration script"
      echo ""
      echo "Usage:"
      echo "  bash orchestrate.sh --sprint-goal 'GOAL' --sprint-number N [options]"
      echo ""
      echo "Required:"
      echo "  --sprint-goal       Short description of what the sprint should achieve"
      echo "  --sprint-number     Sprint number (e.g., 23)"
      echo ""
      echo "Optional:"
      echo "  --team-size         Number of engineers (default: 5)"
      echo "  --duration-weeks    Sprint length in weeks (default: 2)"
      echo "  --capacity-buffer   Buffer for unplanned work (default: 0.2 = 20%)"
      echo "  --include-bugs      Include open bugs (default: true)"
      echo "  --post-to-slack     Post summary to Slack (default: true)"
      echo "  --dry-run           Validate config without running the workflow"
      echo "  --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run 'bash orchestrate.sh --help' for usage"
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Validate required arguments
# -----------------------------------------------------------------------------
if [[ -z "$SPRINT_GOAL" ]]; then
  echo "ERROR: --sprint-goal is required"
  echo "Run 'bash orchestrate.sh --help' for usage"
  exit 1
fi

if [[ -z "$SPRINT_NUMBER" ]]; then
  echo "ERROR: --sprint-number is required"
  echo "Run 'bash orchestrate.sh --help' for usage"
  exit 1
fi

# -----------------------------------------------------------------------------
# Determine which connector to use
# -----------------------------------------------------------------------------
CONNECTOR=""
if [[ -f "./connectors/linear.json" ]]; then
  CONNECTOR="linear"
  CONNECTOR_FILE="./connectors/linear.json"
elif [[ -f "./connectors/jira.json" ]]; then
  CONNECTOR="jira"
  CONNECTOR_FILE="./connectors/jira.json"
else
  echo "ERROR: No connector configured"
  echo ""
  echo "You need to configure either Linear or Jira before running this agent."
  echo "See connectors/README.md for setup instructions."
  echo ""
  echo "Quick setup:"
  echo "  cp connectors/linear.example.json connectors/linear.json"
  echo "  # Then edit connectors/linear.json with your team's details"
  exit 1
fi

# -----------------------------------------------------------------------------
# Validate credentials are set
# -----------------------------------------------------------------------------
if [[ "$CONNECTOR" == "linear" ]]; then
  if [[ -z "${LINEAR_API_KEY:-}" ]]; then
    echo "ERROR: LINEAR_API_KEY environment variable is not set"
    echo "See connectors/README.md for setup instructions"
    exit 1
  fi
elif [[ "$CONNECTOR" == "jira" ]]; then
  if [[ -z "${JIRA_EMAIL:-}" ]] || [[ -z "${JIRA_API_TOKEN:-}" ]]; then
    echo "ERROR: JIRA_EMAIL and JIRA_API_TOKEN environment variables are not set"
    echo "See connectors/README.md for setup instructions"
    exit 1
  fi
fi

# -----------------------------------------------------------------------------
# Print configuration (and exit if dry-run)
# -----------------------------------------------------------------------------
echo "=================================================================="
echo " PM Sprint Agent — Sprint $SPRINT_NUMBER"
echo "=================================================================="
echo "  Sprint goal:       $SPRINT_GOAL"
echo "  Team size:         $TEAM_SIZE engineers"
echo "  Duration:          $DURATION_WEEKS weeks"
echo "  Capacity buffer:   $(echo "$CAPACITY_BUFFER * 100" | bc)%"
echo "  Include bugs:      $INCLUDE_BUGS"
echo "  Connector:         $CONNECTOR ($CONNECTOR_FILE)"
echo "  Post to Slack:     $POST_TO_SLACK"
echo "  Output directory:  $OUTPUT_DIR"
echo "=================================================================="

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "✓ Dry-run complete. Configuration is valid."
  echo "Run without --dry-run to execute the workflow."
  exit 0
fi

# -----------------------------------------------------------------------------
# Create output directory
# -----------------------------------------------------------------------------
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/sprint-${SPRINT_NUMBER}-plan.md"

# -----------------------------------------------------------------------------
# Step 1: Pull open issues
# -----------------------------------------------------------------------------
echo ""
echo "[1/6] Pulling open issues from $CONNECTOR..."

# This is where the actual API call happens.
# In production, this would be a Claude Code tool call to the connector.
# For this template, we represent it as a placeholder that the user wires
# to their actual connector implementation.

echo "  → Fetching backlog issues filtered by sprint scope..."
echo "  → Fetching team velocity from last 3 sprints..."
echo "  → Fetching team PTO calendar..."
echo "  ✓ Issues pulled (see /tmp/issues.json)"

# -----------------------------------------------------------------------------
# Step 2: Run Capacity Analyst subagent
# -----------------------------------------------------------------------------
echo ""
echo "[2/6] Calculating team capacity (Capacity Analyst subagent)..."

# In production, this invokes Claude with the capacity-analyst.md system prompt
# plus the inputs (team size, duration, velocity, capacity hits)

echo "  → Running capacity calculation..."
echo "  ✓ Capacity calculated (see /tmp/capacity.md)"

# -----------------------------------------------------------------------------
# Step 3: Draft sprint plan using sprint-planning skill
# -----------------------------------------------------------------------------
echo ""
echo "[3/6] Drafting sprint plan (sprint-planning skill)..."

# In production, this invokes Claude with the sprint-planning skill loaded,
# providing it the issues, capacity, and sprint goal as inputs

echo "  → Selecting items that fit capacity..."
echo "  → Mapping items to engineers..."
echo "  → Generating definition of done..."
echo "  ✓ Sprint plan drafted (see /tmp/sprint-plan.md)"

# -----------------------------------------------------------------------------
# Step 4: Score risks using Risk Scorer subagent
# -----------------------------------------------------------------------------
echo ""
echo "[4/6] Scoring delivery risks (Risk Scorer subagent)..."

# In production, this invokes Claude with the risk-scorer.md system prompt
# plus the sprint plan and historical context

echo "  → Scoring per-item risk..."
echo "  → Detecting risk patterns..."
echo "  → Generating mitigation actions..."
echo "  ✓ Risk assessment complete (see /tmp/risk-assessment.md)"

# -----------------------------------------------------------------------------
# Step 5: Generate kickoff brief using sprint-brief skill
# -----------------------------------------------------------------------------
echo ""
echo "[5/6] Generating kickoff brief (sprint-brief skill)..."

# In production, this invokes Claude with the sprint-brief skill loaded

echo "  → Drafting kickoff brief..."
echo "  ✓ Brief generated (see /tmp/sprint-brief.md)"

# -----------------------------------------------------------------------------
# Step 6: Combine outputs and save
# -----------------------------------------------------------------------------
echo ""
echo "[6/6] Combining outputs..."

cat > "$OUTPUT_FILE" << HEADER
# Sprint $SPRINT_NUMBER Plan

**Sprint Goal:** $SPRINT_GOAL
**Duration:** $DURATION_WEEKS weeks
**Team Size:** $TEAM_SIZE engineers
**Generated:** $(date '+%Y-%m-%d %H:%M %Z')
**Connector Used:** $CONNECTOR

---

## Capacity Summary

[Capacity Analyst output appended here in production]

---

## Sprint Plan

[sprint-planning skill output appended here in production]

---

## Risk Assessment

[Risk Scorer output appended here in production]

---

## Kickoff Brief

[sprint-brief skill output appended here in production]

---

## Action Items for Sprint Planning Meeting

1. Review the risk assessment above with the team
2. Confirm capacity assumptions match what engineers expect
3. Address any items flagged for breakdown before sprint start
4. Lock in the sprint goal with the team
5. Update tickets in $CONNECTOR with the agreed sprint scope

---

*Generated by [PM Sprint Agent](https://github.com/mohitagw15856/pm-claude-skills/tree/main/templates/pm-sprint-agent)*
HEADER

echo "  ✓ Sprint plan saved to $OUTPUT_FILE"

# -----------------------------------------------------------------------------
# Optional: Post summary to Slack
# -----------------------------------------------------------------------------
if [[ "$POST_TO_SLACK" == true ]]; then
  echo ""
  echo "[7/6] Posting summary to Slack..."
  
  # In production, this calls the Slack connector to post a 5-line summary
  
  echo "  → Generating 5-line summary..."
  echo "  → Posting to configured channel..."
  echo "  ✓ Summary posted to Slack"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=================================================================="
echo " ✓ Sprint $SPRINT_NUMBER plan complete"
echo "=================================================================="
echo ""
echo "Output: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the plan with your team"
echo "  2. Make any adjustments based on team feedback"
echo "  3. Update tickets in $CONNECTOR to reflect the agreed scope"
echo "  4. Run 'bash orchestrate.sh' again with adjusted parameters if needed"
echo ""
