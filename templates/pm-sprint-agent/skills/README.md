# Skills Used by This Agent

The PM Sprint Agent uses these skills from the main pm-claude-skills library:

| Skill | What it does | Used in step |
|---|---|---|
| [`sprint-planning`](../../../skills/sprint-planning/) | Drafts the sprint plan with selected items, capacity allocation, definition of done | Step 3 |
| [`sprint-brief`](../../../skills/sprint-brief/) | Generates the kickoff brief from the sprint plan | Step 5 |
| [`retro`](../../../skills/retro/) | Available for the retro at sprint end (not called in main flow) | (optional) |
| [`project-status-report`](../../../skills/project-status-report/) | Available for mid-sprint status updates (not called in main flow) | (optional) |

## How skills are referenced

This agent template uses **symbolic links** to point to the canonical skill definitions in the main library at `../../../skills/`. This means:

- When the main library updates a skill, the agent automatically uses the updated version
- You can override a skill by replacing the symlink with a local copy
- The agent doesn't duplicate skill content — it references the source of truth

## To use a custom version of a skill

If your team has a customised version of one of these skills (for example, a sprint-planning skill that follows your specific conventions), you can override the default by replacing the symlink:

```bash
cd templates/pm-sprint-agent/skills/sprint-planning

# Remove the symlink
rm SKILL.md

# Copy your custom version
cp /path/to/your/custom-sprint-planning.md ./SKILL.md
```

The agent will pick up the local version automatically — no other changes needed.

## To add a new skill to this agent

If you want this agent to use an additional skill from the library:

1. Create a folder in this directory matching the skill name
2. Symlink the SKILL.md from the main library:
   ```bash
   ln -s ../../../skills/your-skill-name/SKILL.md SKILL.md
   ```
3. Update `AGENT.md` to reference the new skill in the workflow
4. Update `orchestrate.sh` to call the skill at the appropriate step
