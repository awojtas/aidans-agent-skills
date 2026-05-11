---
name: repo-bootstrap
description: Bootstraps a brand-new GitHub repository end-to-end — prompts for a project name and short intro, creates a private GitHub repo under the user's account, clones it to ~/src/<repo-name>, scaffolds .gitignore, .gitattributes, AGENTS.md, CLAUDE.md, README.md, LICENSE, .github/copilot-instructions.md, .github/pull_request_template.md, and a minimal check-root-docs workflow, then makes the initial commit and pushes. Use when the user says "new project", "new repo", "start a new project", "bootstrap a repo", "create a GitHub repo", "spin up a project", "scaffold a new repo", or describes wanting to begin something from scratch with a fresh GitHub repo. Deliberately scoped to day-0 scaffolding — branching strategy, CI/CD, deploys, observability, dependabot, and other maturity concerns belong to the separate repo-promote-maturity skill.
---

# Bootstrapping a new GitHub repository

This skill creates a brand-new repo from nothing. It is **only** for day-0 scaffolding. Branching strategy, full CI, deploy workflows, dependabot, and other "mature repo" concerns are explicitly out of scope — they belong to the separate `repo-promote-maturity` skill. Do not add anything from that list here.

## Prerequisites

Confirm before starting:

1. `gh` CLI is installed and authenticated (`gh auth status`).
2. `~/src/` exists on disk (`ls ~/src` — create it if missing).
3. The user's GitHub login (`gh api user --jq .login`) — used as the owner for the new repo.

If any of these fails, surface the problem and stop.

## Workflow

Track progress with this checklist:

```text
Bootstrap progress:
- [ ] Step 1: Collect project name + intro
- [ ] Step 2: Derive repo slug + target path; check both are free
- [ ] Step 3: Collect copyright holder for LICENSE
- [ ] Step 4: Create private GitHub repo
- [ ] Step 5: Initialise local repo and scaffold files
- [ ] Step 6: Initial commit + push to origin/main
- [ ] Step 7: Report and hand off
```

### Step 1: Collect project name + intro

Ask the user **once**, in a single AskUserQuestion-style prompt, for:

1. **Project name** (required). Free-form — accept any string the user types.
2. **Brief intro** (optional). One or two sentences on what the project is for. Empty/blank is fine — treat that as a "vanilla project" and use a placeholder intro in scaffolded files.

If the user invoked the skill with a name (e.g. `/repo-bootstrap turnsies`), use that as the default for the name prompt rather than asking from scratch.

If the user gave no intro, use this placeholder in scaffolded files:

```
{{PROJECT_NAME}} is a new project. Update this section with a short description once the direction is clear.
```

### Step 2: Derive repo slug + check it's free

- **Slug** = the project name, lowercased, with non-alphanumeric runs collapsed to single hyphens, leading/trailing hyphens stripped. Example: `My Cool Project!` → `my-cool-project`.
- **Target path** = `~/src/<slug>`.

Verify both are free **before** creating anything:

```bash
gh repo view "$(gh api user --jq .login)/<slug>" 2>/dev/null && echo "REPO_EXISTS" || echo "REPO_FREE"
test -e ~/src/<slug> && echo "PATH_EXISTS" || echo "PATH_FREE"
```

If either exists, surface the collision and ask the user for an alternative slug. Do not overwrite.

### Step 3: Collect copyright holder

Ask the user for the LICENSE copyright holder. Default to **`Grainbox Limited`** (the user's commercial entity). Year = current year, auto-derived (`date +%Y`).

### Step 4: Create the GitHub repo

Always private. Always under the authenticated user's account.

```bash
gh repo create "<slug>" \
  --private \
  --description "<one-line description from the intro, or empty if blank>"
```

Do **not** pass `--clone`, `--source`, `--gitignore`, or `--license` — we are scaffolding everything locally to control the exact contents.

### Step 5: Initialise local repo and scaffold files

```bash
mkdir -p ~/src/<slug>
cd ~/src/<slug>
git init -b main
git remote add origin "git@github.com:$(gh api user --jq .login)/<slug>.git"
```

Then write every file below by copying the matching reference template, performing the substitutions in the table.

**Substitutions** (apply to every template):

| Placeholder            | Replace with                                          |
|------------------------|--------------------------------------------------------|
| `{{PROJECT_NAME}}`     | The project name the user gave (verbatim).             |
| `{{PROJECT_INTRO}}`    | The intro, or the placeholder from Step 1 if blank.    |
| `{{YEAR}}`             | Current 4-digit year (`date +%Y`).                     |
| `{{COPYRIGHT_HOLDER}}` | The entity from Step 3.                                |

**Files to scaffold** (source → destination, all paths relative to repo root):

| Source (in `references/`)                    | Destination                              |
|----------------------------------------------|------------------------------------------|
| `gitignore.template`                         | `.gitignore`                             |
| `gitattributes.template`                     | `.gitattributes`                         |
| `AGENTS.md.template`                         | `AGENTS.md`                              |
| `CLAUDE.md.template`                         | `CLAUDE.md`                              |
| `README.md.template`                         | `README.md`                              |
| `LICENSE.template`                           | `LICENSE`                                |
| `copilot-instructions.md.template`           | `.github/copilot-instructions.md`        |
| `pr-template.md.template`                    | `.github/pull_request_template.md`       |
| `workflows/check-root-docs.yml`              | `.github/workflows/check-root-docs.yml`  |

Use the Read tool to load each reference template, do the substitutions in memory, then Write to the destination. Create `.github/workflows/` first with `mkdir -p`.

### Step 6: Initial commit + push

```bash
git add .
git commit -m "Initial commit: scaffold repo"
git push -u origin main
```

If the push fails because the remote already had a commit (rare — only possible if Step 4's `gh repo create` auto-initialised, which it shouldn't without `--add-readme`), surface the conflict and let the user resolve it. Do **not** force-push.

### Step 7: Report and hand off

Print a short summary:

- Repo URL: `https://github.com/<owner>/<slug>`
- Local path: `~/src/<slug>`
- Files scaffolded (a flat list)
- One-line pointer: _"When you're ready to add a branching strategy, CI, deploys, etc., run `/repo-promote-maturity`."_

## Strict non-goals

Do **not** add any of the following from this skill. They belong to `repo-promote-maturity`:

- `develop` / `release/preprod` / `release/prod` branches or any branching workflow files
- CI workflows for lint, type-check, build, unit tests, integration tests, E2E, Lighthouse
- Deploy workflows (Firebase, Vercel, Cloudflare, AWS, etc.)
- Promote-to-* workflows
- Dependabot / Renovate config
- GitGuardian or other secret-scanning workflows
- Sentry / observability wiring
- Issue and PR labels beyond what GitHub creates by default
- Any language-specific tooling (package.json, pyproject.toml, Cargo.toml, etc.) — the user picks the stack later

If the user asks for any of these during the bootstrap, acknowledge the request and say it will be handled by `/repo-promote-maturity` once the repo is up.

## Edge cases

- **`~/src` doesn't exist.** Create it (`mkdir -p ~/src`) before Step 2.
- **`gh` not authenticated.** Tell the user to run `gh auth login` and stop.
- **User aborts mid-flow.** Don't leave a half-scaffolded GitHub repo. If the local scaffold fails after `gh repo create` succeeded, offer to delete the remote with `gh repo delete <owner>/<slug> --yes` (ask first — destructive).
- **User wants the repo public.** This skill is private-by-default by design. Tell them to flip visibility with `gh repo edit --visibility public` after bootstrap, or to do it manually in the GitHub UI.
- **Project name contains characters that don't slug cleanly** (e.g. all-emoji, all-punctuation). Show the derived slug and confirm before creating anything.
