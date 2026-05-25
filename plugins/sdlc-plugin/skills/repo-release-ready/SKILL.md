---
name: repo-release-ready
description: 'Levels up a GitHub repo to release-ready maturity by adding release branches, promotion workflows, security and automation scaffolding, branch protection, PR templates, and a human admin checklist. Use after repo bootstrap or when preparing a repo for UAT/prod.'
---

# Levelling up a repo to release-ready

Takes a day-0 repo (typically one scaffolded by `/repo-bootstrap`) and adds the maturity layer: release branches, promotion workflows, security scanning, branch protection, and a human-admin checklist issue. Stack-agnostic where possible; Vercel-flavoured in the promote workflows by design (the user confirmed this is the eventual target).

## Prerequisites

Run these checks first. If anything fails, stop and surface the gap — don't half-apply changes.

1. **Working directory is inside a git repo with a GitHub remote.**
   ```bash
   git rev-parse --show-toplevel
   gh repo view --json owner,name,defaultBranchRef -q '.owner.login + "/" + .name + " (default: " + .defaultBranchRef.name + ")"'
   ```
   If the user passed a path as an argument, `cd` there first.

2. **`gh` authenticated with admin scope on the repo.** `gh auth status` should show write/admin. Ruleset creation needs admin.

3. **`main` branch exists locally and on the remote.**
   ```bash
   git fetch origin
   git rev-parse --verify origin/main
   ```
   If the default branch isn't `main`, surface it and ask the user how to proceed before continuing.

4. **None of the artefacts we're about to create exist yet.** Check for the workflow files, the two release branches, and any rulesets named `Main {{REPO_NAME_TITLE}}` / `UAT {{REPO_NAME_TITLE}}` / `Production {{REPO_NAME_TITLE}}`:
   ```bash
   git ls-remote --heads origin release/uat release/prod
   gh api repos/<owner>/<name>/rulesets --jq '.[].name'
   ```
   If anything is already there, ask the user before overwriting/recreating it.

5. **Working tree is clean.** Uncommitted changes will get swept into the level-up commit.
   ```bash
   git status --porcelain
   ```
   If there's output, ask the user to commit, stash, or discard before proceeding. Do not stash silently.

## Workflow

Track with this checklist:

```text
Level-up progress:
- [ ] Step 1: Discover repo identity (owner, name, display name)
- [ ] Step 2: Create a feature branch for the level-up
- [ ] Step 3: Scaffold workflow + config files
- [ ] Step 4: Replace PR template, append deployment section to AGENTS.md
- [ ] Step 5: Commit and open a PR
- [ ] Step 6: Create release/uat and release/prod branches
- [ ] Step 7: Install branch-protection rulesets (Phase A — basic, no required checks)
- [ ] Step 7.5: Auto-enable Code Security features where the plan allows
- [ ] Step 8: Open the "Checklist for Human Admin" issue
- [ ] Step 9: Report and hand off
```

### Step 1: Discover repo identity

Compute three values once and reuse them everywhere:

- `REPO_OWNER` — from `gh repo view --json owner -q .owner.login`
- `REPO_NAME` — from `gh repo view --json name -q .name` (typically already lowercase-kebab e.g. `turnsies`)
- `REPO_NAME_TITLE` — `REPO_NAME` with the first letter of each hyphen-separated word capitalised (`turnsies` → `Turnsies`, `my-cool-app` → `My-Cool-App`). Used in ruleset names and the `Production X` reference inside the promote workflow.

### Step 2: Create a level-up branch

```bash
git checkout main
git pull --ff-only
git checkout -b chore/repo-release-ready
```

All file scaffolding goes on this branch. Don't push directly to `main`.

### Step 3: Scaffold workflow + config files

Copy each reference file into the repo, performing the substitutions in the table.

**Substitutions** (applied to file contents only):

| Placeholder              | Replace with                                  |
|--------------------------|------------------------------------------------|
| `{{REPO_NAME}}`          | `REPO_NAME` (lowercase, kebab — used in `Vercel – <name>` status context). |
| `{{REPO_NAME_TITLE}}`    | `REPO_NAME_TITLE` (used in ruleset names + the AGENTS section). |

**Files to scaffold** (source → destination, paths relative to repo root):

| Source (`references/`)                    | Destination                                       |
|--------------------------------------------|---------------------------------------------------|
| `workflows/gitguardian-scan.yml`           | `.github/workflows/gitguardian-scan.yml`          |
| `workflows/claude-on-demand.yml`           | `.github/workflows/claude-on-demand.yml`          |
| `workflows/promote-to-uat.yml`             | `.github/workflows/promote-to-uat.yml`            |
| `workflows/promote-to-production.yml`      | `.github/workflows/promote-to-production.yml`     |
| `workflows/vibe-guard-scan.yml`            | `.github/workflows/vibe-guard-scan.yml`           |
| `workflows/copilot-setup-steps.yml`        | `.github/workflows/copilot-setup-steps.yml`       |
| `dependabot.yml`                           | `.github/dependabot.yml`                          |
| `gitguardian.yaml`                         | `.gitguardian.yaml`                               |
| `pr-template.md`                           | `.github/pull_request_template.md` (overwrite)    |

Read each template, apply substitutions in memory, Write the destination. Create `.github/workflows/` with `mkdir -p` first if it doesn't exist.

### Step 4: Replace PR template, append AGENTS.md section

The PR template overwrite happens in Step 3 already. For AGENTS.md:

- If `AGENTS.md` exists, **append** the contents of `references/agents-deployment-section.md` (after substituting `{{REPO_NAME_TITLE}}`) to the end of the file. Do not replace existing content.
- If `AGENTS.md` doesn't exist, create it with the deployment section as the only content and leave a note in the PR description that the bootstrap-style AGENTS scaffolding is missing.

### Step 5: Commit and open a PR

```bash
git add .github/ AGENTS.md .gitguardian.yaml
git commit -m "Level up: promotion flow, secret scan, rulesets, PR template"
git push -u origin chore/repo-release-ready

gh pr create \
  --base main \
  --title "Repo level-up: release branches, promotion flow, security scanning" \
  --body "Adds the maturity layer scaffolded by /repo-release-ready. See the linked 'Checklist for Human Admin' issue (opened after merge) for the remaining manual setup steps."
```

**Do not auto-merge.** Let the user review and merge themselves — this PR drops branch-protection-relevant scaffolding and they'll want to eyeball it.

### Step 6: Create `release/uat` and `release/prod` branches

These have to exist before rulesets can target them. Create them off the **current `main` tip** (not the level-up branch — those branches start clean, and the level-up content reaches them later via the promotion workflows):

```bash
git fetch origin
git push origin origin/main:refs/heads/release/uat
git push origin origin/main:refs/heads/release/prod
```

If either branch already exists, skip without error (`git push` will fail with "already exists" — catch and continue).

### Step 7: Install branch-protection rulesets (Phase A — basic protection)

These rulesets establish **Phase A** basic branch protection (require PR, no force-push, no deletion). They install cleanly on a fresh repo because they require no check history. **Required status checks come later** — the human-admin checklist (Step 8) walks the user through **Phase B**, which they do once CI has run at least once and the picker is populated. This split avoids the trap of installing a ruleset that references checks GitHub has never observed.

For each of the three ruleset templates (`rulesets/main.json`, `rulesets/uat.json`, `rulesets/production.json`):

1. Read the template, substitute `{{REPO_NAME_TITLE}}` in the `name` field.
2. Write to a temp file (e.g. `/tmp/ruleset-<branch>.json`).
3. `gh api repos/<owner>/<name>/rulesets --method POST --input /tmp/ruleset-<branch>.json`.

If any call returns 422 ("name already exists"), surface the conflict and skip — don't overwrite. The user can clean up in the Settings UI and re-run if needed.

After all three are installed, verify with:

```bash
gh api repos/<owner>/<name>/rulesets --jq '.[] | {name, enforcement, target}'
```

Expect three entries: `Main <Title>`, `UAT <Title>`, `Production <Title>`, all `active`, all targeting `branch`.

### Step 7.5: Auto-enable Code Security features where the plan allows

Some Code Security features (Secret scanning, Push protection, Dependabot security updates, Code scanning) are free on public repos and on private repos with **GitHub Advanced Security**, but **plan-gated** on private repos without GHAS (Free plan; Team/Enterprise without the GHAS license; no Code Security add-on). On a plan-gated repo the toggles are visible-but-disabled with an upsell — listing them as actionable in the checklist would be cruel.

Detect visibility, then try to enable. Capture which calls succeed and set `IS_PLAN_GATED` for Step 8.

```bash
VISIBILITY=$(gh api repos/<owner>/<name> --jq '.visibility')
```

**For private repos**, GHAS must be turned on first (this is the plan-gated knob):

```bash
gh api -X PATCH repos/<owner>/<name> \
  --field security_and_analysis='{
    "advanced_security": {"status": "enabled"},
    "secret_scanning": {"status": "enabled"},
    "secret_scanning_push_protection": {"status": "enabled"},
    "dependabot_security_updates": {"status": "enabled"}
  }'
```

**For public repos**, GHAS is permanently on; omit `advanced_security`:

```bash
gh api -X PATCH repos/<owner>/<name> \
  --field security_and_analysis='{
    "secret_scanning": {"status": "enabled"},
    "secret_scanning_push_protection": {"status": "enabled"},
    "dependabot_security_updates": {"status": "enabled"}
  }'
```

**Code scanning default setup** (separate endpoint, both visibilities):

```bash
gh api -X PATCH repos/<owner>/<name>/code-scanning/default-setup \
  --field state=configured \
  --field query_suite=default
```

Classify each response:

- **HTTP 200/204** → enabled. Add to the success list.
- **HTTP 422 / 403** with an error mentioning `Advanced security`, `advanced_security`, `GitHub Advanced Security`, or `not available` → **plan-gated**. Set `IS_PLAN_GATED=true` and stop attempting further enables on this repo.
- **Other 4xx/5xx** → surface in the summary as an unknown failure. Do not set `IS_PLAN_GATED`. Possible causes: missing admin scope, repo not found, transient API error.

Public repos: every call should succeed (or be a no-op if already on). `IS_PLAN_GATED=false`.

This step never aborts the skill. If every call fails for an unexpected reason, the checklist in Step 8 still goes out — `IS_PLAN_GATED` defaults to `false` (treat the features as user-addressable) so the user can troubleshoot in the UI.

### Step 8: Open the "Checklist for Human Admin" issue

Read `references/checklist-issue.md`, substitute `{{REPO_NAME}}` and `{{REPO_NAME_TITLE}}`. Then resolve the conditional Code Security block using the `IS_PLAN_GATED` value from Step 7.5:

- **If `IS_PLAN_GATED=false`** (features enabled, or user can enable them via the UI): delete the block bounded by `<!-- code-security-plan-gated:start -->` and `<!-- code-security-plan-gated:end -->` (inclusive of those marker lines). Strip just the `<!-- code-security:start -->` / `<!-- code-security:end -->` marker lines themselves, keeping their content.
- **If `IS_PLAN_GATED=true`**: delete the block bounded by `<!-- code-security:start -->` and `<!-- code-security:end -->` (inclusive). Strip just the `<!-- code-security-plan-gated:start -->` / `<!-- code-security-plan-gated:end -->` marker lines, keeping their content.

Either way the resulting body should not contain any `<!-- code-security…-->` HTML comments.

Then create the issue:

```bash
gh issue create \
  --title "Repo Level-Up: Checklist for Human Admin" \
  --body-file /tmp/checklist-issue.md
```

Capture the issue URL — you'll cite it in the summary.

If GitHub issue labels `priority:high` and `setup` exist in the repo, add them with `--label`. If they don't exist, do **not** create them (per the agent guidelines in AGENTS.md) — just open the issue label-less.

### Step 9: Report and hand off

Print a tight summary:

- PR URL (Step 5)
- Branches created (`release/uat`, `release/prod`)
- Rulesets created (with their names)
- Checklist issue URL (Step 8) — this is the most important link for the user
- One-line pointer: _"Merge the level-up PR, then work through the checklist issue. Until the secrets are in place, the GitGuardian and Claude On-Demand workflows will fail loudly — that's expected."_

## Strict non-goals

Do **not** add any of the following from this skill — they're stack-specific, repo-specific, or operational:

- Full CI (lint/type-check/unit/integration/E2E/Lighthouse) — the user will add when stack is chosen
- Deploy workflows (Firebase, Vercel deploy, Cloudflare, AWS) — provisioning belongs to the human (see checklist)
- Stack-specific `dependabot` ecosystems beyond `github-actions`
- Smoke tests / dastardly / vibe-pentester — these need a hosted URL
- Data-sync workflows
- Sentry / observability wiring
- Issue labels beyond what the user already has
- `LICENSE` changes (already set by `/repo-bootstrap`)

If the user asks for any of these during level-up, acknowledge and tell them the level-up scope is fixed; that work should go through a follow-up PR (or wait for a stack-specific skill).

## Edge cases

- **Repo has no `main` branch** (legacy `master`, or default branch was renamed). Surface and ask before proceeding. Do not silently rename.
- **`gh` lacks admin scope.** Ruleset POST will return 403. Tell the user to re-auth with `gh auth refresh -h github.com -s admin:repo`.
- **`release/uat` or `release/prod` already exists.** Don't force-push. Skip the create, log it, and let Step 7 proceed (rulesets work on existing branches).
- **Existing ruleset with the same name.** GitHub returns 422 on POST. Surface to the user — don't try to PUT-update an unknown ruleset; the shape might differ.
- **`AGENTS.md` already has a "Deployment & Branching Strategy" section.** Don't double-append. Detect the heading and skip, mentioning it in the PR description.
- **Repo is public.** Everything still works, but warn the user that secrets in failing workflows produce visible failure noise — recommend they add the secrets quickly.
- **The PR doesn't merge cleanly** (e.g. the user already has a different PR template). Don't try to auto-resolve. Surface the conflict and let the user pick a side.
- **Private repo on a plan without GHAS.** Step 7.5 will detect this (PATCH to `security_and_analysis` returns 403/422 with an Advanced Security error). Don't treat it as a failure — set `IS_PLAN_GATED=true`, continue to Step 8, and the checklist will route the affected toggles into the "Skipped — requires GitHub Advanced Security" section. The user has work that's literally not possible on their current plan; the skill must not present those items as actionable.
- **Empty "Require status checks" picker after Phase A ruleset install.** Expected on a fresh repo — checks GitHub has never observed cannot be required. The Phase B section of the checklist (Step 8 output, Section 2) explains the three ways to populate the picker: merge this PR, manually trigger the scan workflows via `gh workflow run` (both have `workflow_dispatch:`), or wait for the Vercel integration to produce its first deploy status. Do not bake required checks into the Phase A ruleset templates — that's the trap this split avoids.

## Lifecycle tracker

This skill owns the **Release-ready** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Release-ready` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Release-ready` line to ✅ (done).

Touch only the `Release-ready` line — leave every other stage exactly as found.
