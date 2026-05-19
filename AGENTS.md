# AGENTS.md

This repo is a collection of Claude Code plugins, each bundling one or more related skills. It is installed as a plugin marketplace via `/plugin marketplace add awojtas/aidans-agent-skills`.

## Repo structure

```
.claude-plugin/
  marketplace.json           # Registry of all plugins — must be updated when adding a new plugin
plugins/
  <plugin-name>-plugin/
    .claude-plugin/
      plugin.json            # Plugin metadata (name, description, version, author, skills path)
    skills/
      <skill-name-1>/
        SKILL.md             # Skill definition (frontmatter + instructions)
        references/          # Optional — supplementary docs the skill can reference
          *.md
      <skill-name-2>/        # Plugins typically contain multiple skills.
        SKILL.md
      ...
```

That's it. There is no build step, no dependencies, no config beyond these files.

## How to add a new skill

### Decide first: existing plugin, or new plugin?

**Default: add to an existing plugin.** Multi-skill plugins are the norm here. Check whether your skill fits an existing one before scaffolding anything new:

- **Software-lifecycle work** (anything from bootstrap → design → provisioning → requirements → planning → implementation → audit → operate) — goes in `sdlc-plugin`.
- **Prose, content, or content migration** — goes in `content-plugin`.
- **UI / design-system** — goes in `design-system-aurora-plugin` (if Aurora-themed) or a new design-system plugin (if a different style).

**Only create a new plugin if** the skill is genuinely off-theme from every existing plugin AND you can foresee one or two more siblings joining it within a reasonable timeframe. A 1-skill plugin is a smell — the marketplace browser shouldn't be cluttered with one-trick entries.

### Adding a skill to an existing plugin (the common case)

1. Create the skill directory and SKILL.md:
   ```
   plugins/<existing-plugin>/skills/<your-skill-name>/SKILL.md
   ```
2. Optionally add a `references/` subdirectory next to `SKILL.md` for supplementary material.
3. Write the SKILL.md content (see "Writing the SKILL.md" below).
4. **Bump the plugin's version** in `plugins/<existing-plugin>/.claude-plugin/plugin.json` — minor bump for a new skill.
5. If the plugin's `plugin.json` description or `marketplace.json` description mentions specific skill names or counts, update them.

No README change is needed — the top-level README is deliberately minimal and doesn't list individual skills.

### Adding a new plugin (the rare case)

#### 1. Create the directory structure

```
plugins/<your-plugin-name>-plugin/
  .claude-plugin/
    plugin.json
  skills/
    <your-first-skill-name>/
      SKILL.md
```

The plugin directory name should end in `-plugin` and describe the *theme* of the bundle, not any single skill (e.g., `sdlc-plugin`, `content-plugin`).

#### 2. Write `plugin.json`

Place this in `.claude-plugin/plugin.json`:

```json
{
  "name": "<your-plugin-name>-plugin",
  "description": "<One-line theme description, ~150 chars. Don't enumerate individual skills.>",
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

#### 3. Register the plugin in `marketplace.json`

Add an entry to the `plugins` array in `.claude-plugin/marketplace.json`:

```json
{
    "name": "<your-plugin-name>-plugin",
    "source": "./plugins/<your-plugin-name>-plugin",
    "description": "<One-line theme description, ~150 chars.>"
}
```

If you skip this step, the plugin won't be installable.

### Writing the SKILL.md

This is the core of every skill. It has two parts:

**Frontmatter** (YAML between `---` fences):
```yaml
---
name: <skill-name>
description: <One paragraph. Used by Claude Code to decide when to trigger the skill — be specific about trigger phrases, user intents, and what the skill covers.>
---
```

**Body** (Markdown after the frontmatter):
The full instructions Claude follows when the skill is invoked. Write this as a step-by-step runbook. Be explicit — the agent executing this has no prior context about your skill. Include:
- What the skill does (one-line summary at the top)
- A numbered workflow with clear steps
- Classification tables or decision trees where appropriate
- Edge cases and when to stop / ask the user
- Important guidelines or guardrails

### Optional: reference documents

If your skill needs supplementary material (design tokens, API specs, worked examples, lookup tables), put them in a `references/` subdirectory next to `SKILL.md`. Reference them from the skill body. See `design-system-aurora-plugin` or any of the larger `sdlc-plugin` skills (e.g., `requirements-create-from-design/references/`) for examples.

## Key conventions

- **Multi-skill plugins are the norm.** Before scaffolding a new plugin, see if your skill fits an existing one.
- **Skill names use kebab-case**, with **subject-verb** ordering preferred (e.g., `requirements-add`, `task-implement`, `platform-provision`). This groups related skills together when scanning a plugin's `skills/` folder. Deliverable-noun names (e.g., `solution-design`, `requirements-validation`) are also fine where natural.
- **Plugin directory names end in `-plugin`** and describe the *theme* of the bundle.
- **The `description` field in SKILL.md frontmatter is critical** — it controls when Claude Code auto-triggers the skill. Include specific trigger phrases users might say.
- **SKILL.md is a prompt, not documentation.** Write it as instructions for an agent, not as a human-readable guide.
- **Don't duplicate skill content in `README.md`.** The top-level README is deliberately minimal — orient-and-point only. Skill content lives in `marketplace.json`, each `plugin.json`, and each `SKILL.md`.

## Versioning

**Whenever you change a plugin, bump its `version` in `plugin.json`.** This applies to adding, modifying, or removing skills; editing SKILL.md content; adding/changing reference docs; or any other change inside a plugin's directory.

**Why this matters:** the Claude Code marketplace update check compares only the `version` field in `plugin.json` — it does not diff the contents. If you change a skill but leave the version untouched, users who run `/plugin marketplace update` will be told they're already up to date and will never pull your changes.

Use semver:
- **Patch** (`1.0.0` → `1.0.1`) — typo fixes, small wording tweaks, internal clarifications that don't change behavior.
- **Minor** (`1.0.0` → `1.1.0`) — new skill added, new reference doc, expanded triggers, or a meaningful behavior change that remains backward-compatible.
- **Major** (`1.0.0` → `2.0.0`) — removing a skill, renaming a skill, or any change that breaks how users invoke the plugin.

Bump the version in the same change as the edit — don't defer it.

## Background tooling — `scripts/git-auto-commit.ps1`

The repo ships with a PowerShell script at `scripts/git-auto-commit.ps1` that automates the common `pull → stage → commit → push` loop using AI-generated commit messages (via the GitHub Copilot CLI, defaulting to a small OpenAI model).

What it does:

- `git pull` (stashing local changes first if needed).
- `git add -A`.
- Generates a commit message from the staged diff using the Copilot CLI (or accepts one via `-Message`).
- `git commit && git push`.

Why this matters for AI agents working in this repo:

- If you observe commits in `git log` that you don't remember making — for example, a commit message that summarises a SKILL.md edit you just wrote — it may have been produced by this script running from another shell or session. **Run `git fetch` and inspect; don't assume the repo is corrupted.**
- Don't `git reset --hard` or otherwise destroy work in response to unexpected commits without first inspecting. The commits are usually real and intentional.
- The script is opt-in (a human runs it). It is not wired into a hook and does not run automatically as part of any Claude Code skill in this repo.

If you're working in this repo through a Claude Code session, you don't need to invoke this script — just commit normally. The script exists for the maintainer's convenience when working from a Windows shell.
