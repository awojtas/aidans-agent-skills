---
name: tasks-create-from-requirements
description: Turns the requirements in docs/requirements/ into a concrete implementation plan of GitHub issues. Reads every requirement, decomposes each one into small-batch tasks (≤1 day each), names them with staged numbering, isolates all human-required tasks (account creation, secrets, design decisions, legal review) into a dedicated Phase 0 — Operator Setup milestone so delivery phases contain only agent-executable work, then creates GitHub milestones (one per phase) and issues with clear Definition of Done plus Given-When-Then acceptance criteria. Applies a minimal 8-label set (priority + type + human-required + blocked) — never uses labels for phases (those are milestones). Shows the proposed plan for user approval before any GitHub mutations happen. Use when the user says "plan the implementation", "create issues from requirements", "break this down into tasks", "what do we build first", "make a backlog", "issuify the requirements", or wants to translate a requirements doc into actionable work in GitHub.
---

# Tasks from Requirements

This skill is the bridge between **what we're building** (requirements) and **what we're going to do next** (issues). It walks `docs/requirements/`, decomposes each requirement into small tasks, organises them into phases with a human-front-loaded ordering, and creates GitHub milestones + issues so the work is ready to start.

## Why this skill exists

A requirements doc tells you what done looks like. A backlog of issues tells you what to do today. Without a planning step, teams either:

- **Skip planning entirely** and freestyle from the requirements doc — the AI agent ends up re-decomposing the same requirement every session, work is duplicated, and the human can't see progress.
- **Over-plan** with a Gantt chart for 200 items before starting — most of which will be wrong, since plans don't survive contact with code.

The middle path: produce a **small-batch** plan, phase by phase, that's concrete enough to execute and loose enough to adapt. Each task is a single PR-able unit. Phases are real groupings the team will work through. Humans get their work up front because they're the bottleneck.

## Operating mode

- **Interactive at the planning step.** Shows the full proposed plan in a single markdown document and asks for approval before creating anything in GitHub.
- **Idempotent.** Existing labels and milestones are detected and skipped. Existing issues (by title-prefix match) are surfaced to the user, not duplicated.
- **No issues created without explicit user yes.** The plan is read, edited, then created — not the other way around.
- **No phase information in labels.** Phases are milestones. (See `references/labels-and-milestones.md`.)
- **Isolates human work into Phase 0 — Operator Setup** so delivery phases are purely agent-executable. The AI can't complete a milestone that contains human tasks — the agent loops. (See `references/human-required-checklist.md`.)

## Reference material the agent should consult

| File                                            | When to consult                                                       |
|-------------------------------------------------|------------------------------------------------------------------------|
| `references/task-decomposition-guide.md`        | How to break a requirement into small tasks. Size rule. Layer-by-layer recipe. |
| `references/human-required-checklist.md`        | What needs a human. The front-loading principle.                       |
| `references/labels-and-milestones.md`           | The 8-label scheme + milestone naming.                                 |
| `references/issue-template.md`                  | The issue body skeleton (standard, human-required, bug overlays).      |
| `references/example-plan.md`                    | Worked plan for the file-view toggle case (22 issues across 5 phases). |

## Prerequisites

1. **`docs/requirements/` exists and has content.** If it's missing or all stub templates, stop and point the user at `/requirements-create-from-design`.
2. **Most requirements are at Status: Reviewed (or better).** If the doc is mostly `Draft`, the plan will inherit ambiguity. Suggest a pass of `/requirements-validation` first.
3. **`gh` CLI authenticated with write access** to the target repo. `gh auth status` should show repo write/admin scope. Without it, the skill can produce the plan markdown but cannot create issues.
4. **Working directory is inside the target git repo.** `gh` uses the local git remote to know which repo to write to.

## Workflow

```text
Tasks-from-requirements progress:
- [ ] Step 1: Read all requirements docs + prioritisation
- [ ] Step 2: Verify gh CLI access and detect existing labels/milestones/issues
- [ ] Step 3: Decompose each in-scope requirement into tasks (in memory)
- [ ] Step 4: Identify human-required tasks
- [ ] Step 5: Order tasks into phases — human-required isolated into Phase 0 — Operator Setup
- [ ] Step 6: Show proposed plan markdown to user; iterate to approval
- [ ] Step 7: Create missing labels
- [ ] Step 8: Create missing milestones
- [ ] Step 9: Create issues (with labels + milestone + body from template)
- [ ] Step 10: Print summary with GitHub links
```

### Step 1: Read all requirements docs (and the architecture, if present)

**First, if `docs/architecture/` exists, read it.** The recorded architectural decisions (`04-decisions.md`) and integrations list (`03-external-integrations.md`) drive which Phase 1 [HUMAN] tasks the plan needs — account creation for each integration, secrets for the chosen stack, hosting setup per the ADRs. Open questions in `docs/architecture/05-open-questions.md` may also become [HUMAN] decision tasks in Phase 1 if they block downstream work.

If `docs/architecture/` is missing, **mention it to the user** before planning — *"No architecture folder. The plan will inherit assumptions about stack and hosting from `docs/requirements/06-constraints.md` and the existing code. Consider running `/platform-design` first to make those choices explicit."* If the user proceeds, the plan defaults to whatever the code + constraints imply.

Then walk `docs/requirements/`. Build an in-memory model from:

- Every functional requirement in `03-functional/*.md` (parse `### FR-…` blocks: ID, Statement, Priority, Status, AC, Source, Traces to).
- Every NFR in `04-non-functional/*.md` that isn't marked "Applies? No".
- `10-prioritisation.md` — MoSCoW priority per requirement, force-ranked Musts.
- `06-constraints.md` — technology mandates that drive Phase 1 setup tasks (cross-check with `docs/architecture/01-stack-and-hosting.md` if present — they should agree).
- `05-data-and-integrations.md` — integration list drives human-required account-creation tasks (cross-check with `docs/architecture/03-external-integrations.md` if present — they should agree).
- `07-assumptions.md` — `Unvalidated` assumptions that block requirements (likely → human task to validate).
- `08-open-questions.md` — unresolved questions block any requirement that depends on them (→ human task to decide).
- `09-risks.md` — open risks may suggest mitigation tasks worth scheduling.

**In-scope filter for issue creation:**

| MoSCoW       | Status      | Action                                                          |
|--------------|-------------|-----------------------------------------------------------------|
| Must         | Any         | In scope. Label `priority:high`.                                |
| Should       | Any         | In scope. Label `priority:medium`.                              |
| Could        | Any         | In scope unless user opts out. Label `priority:low`.            |
| Won't (this) | —           | **Not in scope.** Skip — explicitly out of scope per the spec.  |

### Step 2: Verify gh access + inventory

```bash
gh auth status
gh repo view --json owner,name -q '.owner.login + "/" + .name'
gh label list --json name --jq '[.[].name]'
gh api repos/:owner/:repo/milestones --jq '[.[] | {title, number, state}]'
gh issue list --state all --limit 200 --json number,title --jq '[.[] | .title]'
```

Note which labels and milestones already exist, and which proposed issues' titles already match existing issue titles. The skill will avoid creating duplicates.

If `gh` is not authenticated, surface clearly: *"I can produce the plan markdown but can't write to GitHub. Run `gh auth login -s repo`, then re-run."*

### Step 3: Decompose

For each requirement, apply the decomposition recipe in `references/task-decomposition-guide.md`:

1. Schema / data layer (migrations).
2. Server / API layer (endpoints, validation, jobs).
3. Client / UI layer (pages, components, states).
4. Integration layer (third-party API touches).
5. Cross-cutting (telemetry, flags, docs, tests — usually bundled).
6. Acceptance verification — every AC of the requirement maps to at least one task.

Aim for **3–10 tasks per substantive requirement**. Trivial requirements may produce one task; large ones may produce many.

For each task:

- Working title (will get the staged number in Step 5).
- Which layer / what it does.
- Implements: one or more requirement IDs.
- Acceptance criteria, lifted/adapted from the requirement's Given-When-Then.
- Estimated effort (≤1 day target).

**Scaffold/setup task DoD — pin the CI install command.** For any task that scaffolds a dependency-managed project (Node, Python, etc.), the generated Definition of Done must require running the **exact install command CI uses**, not a looser local one. For Node specifically: "regenerate a clean lockfile and verify `npm ci` succeeds (not just `npm install`)". Rationale: an incrementally-built `package-lock.json` can be missing transitive optional deps — `npm install` passes locally but `npm ci` fails in CI. The DoD must call out the CI command by name.

### Step 4: Identify human-required

Walk the task list. For each task, check it against `references/human-required-checklist.md`. Apply the `human-required` flag if **any** of these apply:

- Account or identity work on a third-party service.
- Credential / secret generation or rotation.
- Domain / DNS / email auth configuration.
- Legal, compliance, policy review.
- Design or brand decisions.
- Sign-off or approval gates.
- External vendor contact.
- Physical-world tasks.

When in doubt, **bias toward the AI doing it** unless one of the catalogue criteria fires. Don't over-flag.

For each human-required task, fill in the human-required block per `references/issue-template.md`: why human, click-time estimate, elapsed-time estimate, step-by-step instructions, where to record outputs.

Also classify **agent-verifiability** for each human-required task and include it in the issue body:

```
Agent-verifiable: <yes — agent confirms via: <concrete check>> | <no — operator self-certifies on close>
```

- **Prefer a concrete machine-checkable signal** where one exists — a `gh api` call, a file or env var presence check, a reachable endpoint returning 200, a secret name appearing in `gh secret list`. Name the exact command or check.
- Use **"no — operator self-certifies on close"** only when the output is genuinely unobservable by an agent (e.g., a secret stored only in an external vault, a console toggle with no API). This is the fallback, not the default.

### Step 5: Order tasks into phases

Sort tasks into phases. The hard structural rule: **delivery phases must contain only agent-executable tasks.** An agent assigned to "implement Phase N" must be able to close every issue in that phase without waiting on a human. Mixing human and AI tasks inside a delivery phase breaks this — the agent finishes what it can, can't close the human issues, and loops.

- **Phase 0 — Operator Setup:** contains **all and only** human-required tasks. No AI-executable tasks here. This is the first milestone. The human works through it at their pace; the AI waits on Phase 0 issues only where there's an explicit `Blocked by:` dependency on that issue in a delivery phase.
- **Phase 1 (Foundation / first delivery):** agent-executable project-wide setup and scaffolding tasks (CI baseline, test scaffolding, migrations framework, etc.). No human tasks.
- **Phase 2+:** Implementation phases, ordered by dependencies. A reasonable theme per phase — e.g., "Core Auth", "Billing", "Polish". All AI-executable. Aim for **3–7 delivery phases total**.

**Numbering:** Phase 0 tasks use the `0.x` prefix (`0.1`, `0.2`, ...); delivery phases use `1.x`, `2.x`, etc.

**Dependencies:** for any delivery task that depends on a Phase 0 human task completing (e.g., a secret being present before a CI job can run), apply the `blocked` label to the delivery task and add `Blocked by: #<Phase 0 issue>` in its body. Remove the `blocked` label once the Phase 0 task closes. Phase 0 tasks themselves are rarely blocked — only in the unusual case where a human task can't proceed until a deployment exists (e.g., verifying a domain after production deploy), in which case the Phase 0 issue carries the `Blocked by:` reference.

The order within a phase reflects dependency — `1.2` may depend on `1.1`, but not the other way around.

### Step 6: Show the proposed plan

Render the plan as a single markdown document. Show:

- **Header.** Project name, source (`docs/requirements/`), generation date.
- **Labels needed.** The 8-label set, indicating which are new vs. already exist.
- **Milestones.** Phase number + theme + one-line description, indicating new vs. existing.
- **Tasks per phase.** Numbered list with title, labels, implements-IDs, estimated effort. Annotate human-required tasks clearly.
- **Rough effort per phase.** Human-time estimate + AI-time estimate (e.g., "Phase 0: ~half a day human click-time; Phase 1: ~1 day AI work"). Do **not** embed issue counts in the plan prose — the task list is the count. Hardcoded numbers ("6 tasks", "Phase N total: X issues") go stale the moment the plan changes.

Save the plan markdown to `docs/implementation-plan.md` (or a name the user prefers) so the user can edit it. Tell them: *"Open `docs/implementation-plan.md`, make any edits, then say 'approved' to create the GitHub issues."*

Iterate: if the user edits the file, re-read and confirm changes before proceeding.

**Do not proceed to GitHub mutation steps without explicit user approval.**

### Step 7: Create missing labels

Per the approved plan, for each of the 8 labels that is missing:

```bash
gh label create "priority:high"   --color "B60205" --description "Blocks MVP. Without this, the release does not ship."
gh label create "priority:medium" --color "D93F0B" --description "Important. Friction or risk if missing, but shippable without."
gh label create "priority:low"    --color "FBCA04" --description "Nice to have. First on the chopping block if scope tightens."
gh label create "bug"             --color "D73A4A" --description "Fixing broken behaviour."
gh label create "chore"           --color "C5DEF5" --description "Infrastructure, setup, refactoring, dependency updates."
gh label create "docs"            --color "0075CA" --description "Documentation work."
gh label create "human-required"  --color "5319E7" --description "Needs a human (account creation, secrets, design decisions, legal review)."
gh label create "blocked"         --color "1D76DB" --description "Cannot start until a prerequisite task closes. See Blocked by in the issue."
```

If a label exists with a different colour/description, **leave it as-is**. Don't overwrite the user's choices.

### Step 8: Create missing milestones

For each phase milestone that doesn't exist yet:

```bash
gh api repos/:owner/:repo/milestones \
  --method POST \
  -f title="Phase 0: Operator Setup" \
  -f description="Human setup track. All tasks requiring a human — account creation, secrets, design decisions, domain config, legal review. No AI tasks here. Work through these first; delivery phases (Phase 1+) can start on any task not blocked by a Phase 0 issue. Phase complete when all human-required outputs are in place and dependent delivery tasks are unblocked."
```

Don't set due dates unless the user asked for them — false deadlines create noise.

### Step 9: Create issues

For each task in the approved plan that doesn't already exist as an issue:

```bash
gh issue create \
  --title "0.1 [HUMAN] Decide on browser support matrix" \
  --body "$(cat <<'EOF'
<full body from references/issue-template.md with substitutions>
EOF
)" \
  --label "priority:high,human-required,chore" \
  --milestone "Phase 0: Operator Setup"
```

**Issue body substitutions:**

- Fill `What`, `Why now`, `Definition of Done`, `Acceptance Criteria`, `Implements`, `Context` from the decomposition.
- For human-required tasks, **prepend** the `## ⚠️ Human Required` block per `references/issue-template.md`.
- For bug tasks (rare in a fresh plan), use the bug overlay.
- Resolve `Blocked by:` and `Blocks:` with real issue numbers as you create them in order. Pass 1 creates all issues; Pass 2 goes back and edits the body of each to fill in the now-known issue numbers. (`gh issue edit <num> --body-file <path>`.)

### Step 10: Summary

Print:

- **Labels created.** Names.
- **Milestones created.** Phase list with URLs.
- **Issues created.** Grouped by milestone, with a couple of highlighted entries (the first human-required in Phase 0, the first Phase 1 implementation task).
- **What's next for the user.**
  - Open the milestones page in GitHub to see the burndown.
  - Start by working through Phase 0 — Operator Setup. These are batch-friendly (knock out in one focused session). Phase 1 delivery tasks unblocked by Phase 0 can run in parallel.
  - The AI picks up Phase 1 and beyond once its dependencies are clear.

**Commit and push.** Stage `docs/implementation-plan.md` and `README.md` (lifecycle tracker), commit with `docs(plan): create implementation plan and issues`, then follow [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). The GitHub milestones and issues themselves are already pushed via `gh` in Steps 7-9 — no further action needed for them.

## Strict non-goals

- **No phase labels.** Phases are milestones; resist user requests to add `phase:1` or `phase:2` labels.
- **No code generation.** This is a planning skill. Actual implementation happens after issues are created, in separate sessions.
- **No requirement editing.** If decomposition surfaces that a requirement is unclear or wrong, point the user at `/requirements-validation` rather than fixing in place.
- **No auto-assigning issues.** Assignment is a human decision. (The skill may suggest "this is a good candidate for the AI" via the absence of `human-required`, but doesn't assign.)
- **No `Won't (this release)` items.** Explicitly out of scope per the requirements doc; no issues created for them.
- **No size labels** (S/M/L), no **phase labels**, no `wip`/`in-progress` labels (those are PR states).
- **No hardcoded counts in the generated plan.** Prose that says "6 tasks", "Phase N total: X issues", or "22 issues across 5 phases" goes stale the moment the plan changes. Let the task tables speak for themselves; don't narrate their length in surrounding prose.

## Edge cases

- **`docs/requirements/` is missing.** Stop and point at `/requirements-create-from-design`.
- **`docs/requirements/` is all stubs.** Stop and point at `/requirements-create-from-design` to populate.
- **Most requirements are `Draft`.** Suggest `/requirements-validation` to firm them up first, but offer to plan anyway with all-issues-marked-Draft.
- **`gh` not authenticated.** Produce the plan markdown but skip Steps 7-9. Tell the user to authenticate and re-run.
- **Labels exist with different colours.** Leave them alone — the user has a system, don't override it.
- **Existing issues with matching titles.** Surface them. Ask: skip (don't recreate), update (re-edit the body), or create-with-suffix (e.g., "1.1 [HUMAN] Decide on browser support matrix (replan 2026-05-13)").
- **A requirement has no implementable tasks** (e.g., it's purely an assumption / open question). Skip it; surface in the summary as "Skipped, requires resolution first".
- **The plan ends up with >50 issues.** This is a smell — either the requirements doc is too big for one plan, or decomposition is too granular. Stop and ask the user: is this really one release, or should we scope down?
- **A human-required task has a dependency on a delivery-phase output** (e.g., domain verification can only happen after production deploys). Keep it in Phase 0 — Operator Setup (that's the home for all human tasks) but mark it `blocked` with `Blocked by: #<delivery issue>`. Never place human-required tasks inside a delivery phase.
- **User wants to "just do Phase 1 first, replan later".** Excellent default — create only Phase 1 issues, leave the rest of the plan markdown for the next session.

## Lifecycle tracker

This skill owns the **Tasks planned** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Tasks planned` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Tasks planned` line to ✅ (done).

Touch only the `Tasks planned` line — leave every other stage exactly as found.
