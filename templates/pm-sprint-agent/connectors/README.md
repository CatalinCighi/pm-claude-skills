# Connectors — Setup Guide

This folder contains the connector configurations for the PM Sprint Agent. Connectors provide governed access to your team's data sources — they are how the agent reaches Linear, Jira, Slack, and other systems without holding credentials in prompts.

## What's in this folder

- `linear.example.json` — Linear connector configuration template
- `jira.example.json` — Jira connector configuration template (use this if your team uses Jira)
- `slack.example.json` — Slack connector for posting summaries (coming soon)

## How to set up a connector

You only need to set up the connector for the ticketing system your team uses. Skip the others.

### Linear setup (5 minutes)

1. Generate a Linear API key:
   - Go to https://linear.app/settings/account/security
   - Click "Create Key"
   - Copy the key (starts with `lin_api_`)

2. Set the environment variable:
   ```bash
   export LINEAR_API_KEY='lin_api_xxxxxxxxxxxxxxxxxxxxxxxx'
   ```
   
   To make this permanent, add the line to your `~/.zshrc` or `~/.bashrc`.

3. Find your team ID:
   ```bash
   curl -H "Authorization: $LINEAR_API_KEY" \
     https://api.linear.app/graphql \
     -d '{"query": "{ teams { nodes { id name } } }"}'
   ```
   
   You'll get a JSON response with all your teams and their IDs.

4. Copy the example config and customise:
   ```bash
   cp linear.example.json linear.json
   ```
   
   Edit `linear.json` and update:
   - `workspace_url` — your Linear workspace URL
   - `team_id` — the team ID from step 3

5. Test:
   ```bash
   cd ../  # back to pm-sprint-agent root
   bash orchestrate.sh --dry-run --sprint-goal "test"
   ```

### Jira setup (5 minutes)

1. Generate a Jira API token:
   - Go to https://id.atlassian.com/manage-profile/security/api-tokens
   - Click "Create API token"
   - Give it a label (e.g., "PM Sprint Agent")
   - Copy the token

2. Set environment variables:
   ```bash
   export JIRA_EMAIL='you@yourcompany.com'
   export JIRA_API_TOKEN='ATATT3xFfGF0...'
   ```

3. Find your project key and board ID:
   - **Project key**: visible in any issue URL (e.g., "PROJ" from `your-domain.atlassian.net/browse/PROJ-123`)
   - **Board ID**: navigate to your board, the URL contains `boards/{ID}` (e.g., 123)

4. Copy the example config and customise:
   ```bash
   cp jira.example.json jira.json
   ```
   
   Edit `jira.json` and update:
   - `instance_url` — your Atlassian instance URL
   - `project_key` — your project key from step 3
   - `board_id` — your board ID from step 3

5. Test:
   ```bash
   cd ../
   bash orchestrate.sh --dry-run --sprint-goal "test"
   ```

## Building a connector for another system

If your team uses a ticketing system that's not in this folder (Shortcut, Asana, ClickUp, GitHub Issues), you can build a connector by following the same pattern.

A connector needs three things:

1. **A configuration file** (`{name}.json`) defining the data source URL, credentials, and available operations
2. **An API client** that the orchestration script can call to fetch data
3. **A mapping** from the source's data model to the standard fields the agent expects (issue ID, title, story points, status, assignee, dependencies)

The cleanest place to start is to copy `linear.example.json` or `jira.example.json` and modify it for your system.

If you build a connector for a new system, consider raising a PR back to the main pm-claude-skills repo so others can use it.

## Security notes

**Credentials live in environment variables, not in the JSON files.** The connector configs reference environment variable names, not the actual credentials. This means you can commit your `linear.json` or `jira.json` to source control without leaking credentials — but make sure your `LINEAR_API_KEY` or `JIRA_API_TOKEN` are stored securely (use a password manager or `.env` file with `.gitignore`).

**Rotate API keys periodically.** Both Linear and Jira allow you to revoke and regenerate API keys. Do this every 90 days as a security best practice.

**Use scoped permissions.** Where possible, generate API keys with only the permissions the agent needs (read-only access to issues, sprints, and team data — not write access).
