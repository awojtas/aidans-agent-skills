# AGENTS.md

This repo is a collection of Claude Code plugins, each containing one or more skills. It is installed as a plugin marketplace via `/plugin marketplace add awojtas/aidans-agent-skills`.

## Repo structure

```
.claude-plugin/
  marketplace.json           # Registry of all plugins — must be updated when adding a new plugin
plugins/
  <plugin-name>-plugin/
    .claude-plugin/
      plugin.json            # Plugin metadata (name, description, version, author, skills path)
    skills/
      <skill-name>/
        SKILL.md             # Skill definition (frontmatter + instructions)
        references/          # Optional — supplementary docs the skill can reference
          *.md
```

That's it. There is no build step, no dependencies, no config beyond these files.

## How to add a new plugin + skill

### 1. Create the directory structure

```
plugins/<your-plugin-name>-plugin/
  .claude-plugin/
    plugin.json
  skills/
    <your-skill-name>/
      SKILL.md
```

Follow the `<name>-plugin` naming convention for the plugin directory.

### 2. Write `plugin.json`

Place this in `.claude-plugin/plugin.json`:

```json
{
  "name": "<your-plugin-name>-plugin",
  "description": "Adds a /<skill-name> skill for <what it does>",
  "version": "1.0.0",
  "author": {
    "name": "Aidan Wojtas",
    "url": "https://github.com/awojtas/aidans-agent-skills"
  },
  "repository": "https://github.com/awojtas/aidans-agent-skills",
  "skills": "./skills/"
}
```

The `"skills"` field must point to `"./skills/"` — Claude Code discovers skills by scanning that directory for `SKILL.md` files.

### 3. Write `SKILL.md`

This is the core of the skill. It has two parts:

**Frontmatter** (YAML between `---` fences):
```yaml
---
name: <skill-name>
description: <One paragraph. This is used by Claude Code to decide when to trigger the skill, so be specific about trigger phrases, user intents, and what the skill covers.>
---
```

**Body** (Markdown after the frontmatter):
The full instructions Claude follows when the skill is invoked. Write this as a step-by-step runbook. Be explicit — the agent executing this has no prior context about your skill. Include:
- What the skill does (one-line summary at the top)
- A numbered workflow with clear steps
- Classification tables or decision trees where appropriate
- Edge cases and when to stop / ask the user
- Important guidelines or guardrails

### 4. Optional: Add reference documents

If your skill needs supplementary material (design tokens, API specs, lookup tables), put them in a `references/` subdirectory next to `SKILL.md`. Reference them from the skill body. See `design-system-aurora-plugin` for an example.

### 5. Update `README.md`

Add a section for the new skill following the existing pattern: heading, description, "What it does" bullet list, and a "Trigger it" line.

## Key conventions

- **One skill per plugin** is the current pattern, though the structure supports multiple skills per plugin.
- **Skill names use kebab-case** (e.g., `build-fixer`, `issue-worker`).
- **Plugin directory names** are `<skill-name>-plugin`.
- **The `description` field in SKILL.md frontmatter is critical** — it controls when Claude Code auto-triggers the skill. Include specific trigger phrases users might say.
- **SKILL.md is a prompt, not documentation.** Write it as instructions for an agent, not as a human-readable guide.
