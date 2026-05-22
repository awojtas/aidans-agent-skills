---
name: status-help
description: Analyses the current state of the repo (docs/design/, docs/architecture/, docs/requirements/, open issues, git state) and recommends the next concrete step in the SDLC bundle workflow. Recognises which skills have already run, which have incomplete or messy output, and which one is next. Can also recommend re-running a prior skill if its output looks unfinished or incongruous. Also rebuilds the SDLC progress tracker at the bottom of README.md from the scan and commits/pushes it. Designed for the "I'm not sure where I am or what to do next" moment in a multi-step SDLC project. Trigger phrases include "what's next", "what should I do next", "status help", "where am I in the workflow", "what step am I on", "recommend next step", "navigate the SDLC", "update the progress tracker", "what now".
---

Surveys the current state of the project and recommends a single concrete next action in the SDLC bundle workflow.

## What this skill does

Reads the repo (and any connected systems it can reach — GitHub, MCPs) to figure out where the project is along the sequence:

```
repo-bootstrap → solution-design → platform-design → platform-provision → platform-verify
  → repo-release-ready → requirements-create-from-design → requirements-validation
  → tasks-create-from-requirements → task-implement
  → requirements-verify-post-implementation
```

Recommends a single concrete next action, or a small ranked list if multiple paths are reasonable. Can also flag a *rewind* if a prior step produced unfinished or incongruous output. As a side effect, it rebuilds the SDLC progress tracker in the repo's `README.md` so the current state is visible at a glance.

## Workflow

1. **Scan repo state.** Read just enough to triangulate position:
   - Top-level structure: `README.md`, `AGENTS.md`, `CLAUDE.md`, `.git/`, `.github/workflows/`
   - SDLC artefacts: `docs/design/solution-design.md`, `docs/architecture/*`, `docs/architecture/provisioning-log.md`, `docs/architecture/platform-verification.md`, `docs/requirements/*`, `docs/implementation-plan.md`
   - Git state: branches (especially `release/uat`, `release/prod`), recent commits, open PRs
   - GitHub issues: count, milestones, labels (especially `human-required`, `blocked`)

2. **Map state to phase.** Use the artefact presence + git state to identify the furthest phase reached:

   | Phase | Evidence of completion |
   |---|---|
   | `/repo-bootstrap` | Repo exists, basic scaffolding (`.gitignore`, etc.) present |
   | `/solution-design` | `docs/design/solution-design.md` present and substantive |
   | `/platform-design` | `docs/architecture/` tree present (`00-system-overview.md` etc.) |
   | `/platform-provision` | `docs/architecture/provisioning-log.md` present with entries |
   | `/platform-verify` | Verification block in provisioning log or `platform-verification.md` present |
   | `/repo-release-ready` | `release/uat` + `release/prod` branches exist; promotion workflows in `.github/workflows/` |
   | `/requirements-create-from-design` | `docs/requirements/` tree with FR/NFR files |
   | `/requirements-validation` | Requirements with `Status: Reviewed`+ or session-log entries showing validation runs |
   | `/tasks-create-from-requirements` | `docs/implementation-plan.md` + GitHub issues organised into phase milestones |
   | `/task-implement` | Closed issues, merged PRs |
   | `/requirements-verify-post-implementation` | `docs/requirements/verification-report.md` present |

3. **If Step 2 lands on `/task-implement` (closed issues + merged PRs, no in-flight forward artefacts), run quick repo-health probes before recommending.** Artifact-presence is blind to common silent-rot modes in mature repos; these `gh` + `git` calls catch them in seconds:
   - `gh run list --workflow ci.yml --branch <default> --limit 10` — if recent runs are mostly failing, recommend `/test-fix` or `/build-fix` first.
   - Inspect `.github/workflows/ci.yml` triggers. If `push: branches: [<default>]` is missing, surface explicitly — many repos rot silently because CI only runs on PRs and nobody reads dependabot's red checks.
   - `gh pr list --state open --search "created:<$(date -d '-60 days' +%Y-%m-%d)"` — flag stale PRs for human decision (rebase + review, or close).
   - For every local + remote feature branch, `git cherry main <branch>`. Branches with no `+` lines are squash-merge ghosts; recommend `/branch-prune`.

4. **Look for incompleteness or incongruity.** Some heuristics:
   - Solution-design file exists but is mostly empty / has many placeholder TODOs → re-run `/solution-design`
   - Architecture tree exists but ADR file is empty → architecture incomplete
   - Provisioning log present but no GitHub Actions secrets visible → provisioning may not have been wired in
   - Requirements exist but all `Draft` and never validated → `/requirements-validation` is overdue
   - Implementation plan exists but no GitHub issues created → plan was approved but never instantiated
   - Lots of unaddressed `human-required` open issues → human work is the bottleneck; flag it

5. **Recommend the next action.** Prefer a single concrete recommendation:
   > Next: run `/platform-design` — solution design is in place but `docs/architecture/` is empty.

   If multiple paths are reasonable, list up to 3 in priority order with a one-line rationale each.

6. **Flag rewinds explicitly.** If a prior step looks like it ran but produced messy output, surface it:
   > Note: `docs/design/solution-design.md` looks like a first-draft skeleton — consider re-running `/solution-design` in evolve-mode before proceeding.

7. **Report concisely.** The output is the recommendation in chat, ~10 lines.

8. **Rebuild and push the lifecycle tracker.** Update the SDLC progress tracker at the bottom of the repo's `README.md` from this scan, then commit and push it. See the [Lifecycle tracker](#lifecycle-tracker) section below.

## Guardrails

- **Don't be exhaustive.** This isn't an audit skill. One next action, maybe two alternatives, then stop. For deep audit, use `/ai-check-work`.
- **Don't run other skills.** Recommend only. The user decides what to invoke.
- **Don't speculate beyond evidence.** If you can't tell whether a step was completed (e.g., no log file exists), say so plainly — don't infer.
- **Don't ignore explicit signals.** If the user just ran a skill (visible from `git log` or session context), give them credit — suggest forward motion, not "are you sure you ran X".
- **Match the user's mental model.** "What's next" wants forward motion; "what's wrong" wants gap analysis. Read the room.

## Output

A short markdown summary in chat, roughly:

```
**Current phase:** <phase>

**Recommendation:** <single next action>

**Why:** <2-3 lines of evidence>

[Optional: **Concerns** — anything looking incomplete worth knowing about]

[Optional: **Alternatives** — other reasonable paths]
```

## Lifecycle tracker

After scanning, `/status-help` rebuilds the **entire** SDLC progress tracker at the bottom of the acted-on repo's `README.md` — every one of the eleven lifecycle stages gets ✅ / ⏳ / ❓ based on what the scan found — then commits and pushes that one file. This makes `/status-help` the way to see, at a glance in the README, exactly how far a repo has progressed.

Follow [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, stage list, and create-or-update algorithm. Specifically:

1. **Map each stage to an emoji** from the Step 2 evidence table and the Step 4 incompleteness heuristics:
   - Evidence present and complete → ✅
   - Evidence present but partial / messy / mid-session → ⏳
   - No evidence → ❓
2. **Write the block** at the very bottom of `README.md`. Create the file if it's missing; append the block if the file exists without it; replace it in place if it's already there.
3. **Commit and push.** Stage **only** `README.md`, commit `docs: update SDLC lifecycle tracker`, and push to the current branch. If the block already matches the scan, skip the commit — don't make an empty one. If there's no remote or the push fails, keep the local commit and tell the user.

This is the one file `/status-help` writes. It still doesn't run any other skill or modify any SDLC artefact.
