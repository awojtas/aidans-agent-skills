---
name: tasks-from-requirements
description: Turns the requirements in docs/requirements/ into a concrete implementation plan of GitHub issues. Reads every requirement, decomposes each one into small-batch tasks (≤1 day each), names them with staged numbering (1.1, 1.2, 2.1...), identifies which tasks need a human (account creation, secrets, design decisions, legal review) and front-loads them into Phase 1 because humans are slower than AI, then creates GitHub milestones (one per phase) and issues with clear Definition of Done plus Given-When-Then acceptance criteria. Applies a minimal 8-label set (priority + type + human-required + blocked) — never uses labels for phases (those are milestones). Shows the proposed plan for user approval before any GitHub mutations happen. Use when the user says "plan the implementation", "create issues from requirements", "break this down into tasks", "what do we build first", "make a backlog", "issuify the requirements", or wants to translate a requirements doc into actionable work in GitHub.
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
- **Front-loads human work** so the AI doesn't stall waiting on accounts/secrets/decisions. (See `references/human-required-checklist.md`.)

## Reference material the agent should consult

| File                                            | When to consult                                                       |
|-------------------------------------------------|------------------------------------------------------------------------|
| `references/task-decomposition-guide.md`        | How to break a requirement into small tasks. Size rule. Layer-by-layer recipe. |
| `references/human-required-checklist.md`        | What needs a human. The front-loading principle.                       |
| `references/labels-and-milestones.md`           | The 8-label scheme + milestone naming.                                 |
| `references/issue-template.md`                  | The issue body skeleton (standard, human-required, bug overlays).      |
| `references/example-plan.md`                    | Worked plan for the file-view toggle case (22 issues across 5 phases). |

## Prerequisites

1. **`docs/requirements/` exists and has content.** If it's missing or all stub templates, stop and point the user at `/create-requirements`.
2. **Most requirements are at Status: Reviewed (or better).** If the doc is mostly `Draft`, the plan will inherit ambiguity. Suggest a pass of `/confirm-requirements` first.
3. **`gh` CLI authenticated with write access** to the target repo. `gh auth status` should show repo write/admin scope. Without it, the skill can produce the plan markdown but cannot create issues.
4. **Working directory is inside the target git repo.** `gh` uses the local git remote to know which repo to write to.

## Workflow

```text
Plan-from-requirements progress:
- [ ] Step 1: Read all requirements docs + prioritisation
- [ ] Step 2: Verify gh CLI access and detect existing labels/milestones/issues
- [ ] Step 3: Decompose each in-scope requirement into tasks (in memory)
- [ ] Step 4: Identify human-required tasks
- [ ] Step 5: Order tasks into phases — human-required front-loaded into Phase 1
- [ ] Step 6: Show proposed plan markdown to user; iterate to approval
- [ ] Step 7: Create missing labels
- [ ] Step 8: Create missing milestones
- [ ] Step 9: Create issues (with labels + milestone + body from template)
- [ ] Step 10: Print summary with GitHub links
```

### Step 1: Read all requirements docs (and the architecture, if present)

**First, if `docs/architecture/` exists, read it.** The recorded architectural decisions (`04-decisions.md`) and integrations list (`03-external-integrations.md`) drive which Phase 1 [HUMAN] tasks the plan needs — account creation for each integration, secrets for the chosen stack, hosting setup per the ADRs. Open questions in `docs/architecture/05-open-questions.md` may also become [HUMAN] decision tasks in Phase 1 if they block downstream work.

If `docs/architecture/` is missing, **mention it to the user** before planning — *"No architecture folder. The plan will inherit assumptions about stack and hosting from `docs/requirements/06-constraints.md` and the existing code. Consider running `/initial-design` first to make those choices explicit."* If the user proceeds, the plan defaults to whatever the code + constraints imply.

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

### Step 5: Order tasks into phases

Sort tasks into phases. Use these heuristics:

- **Phase 1 (Foundation):** human-required tasks, project-wide setup, decisions / open-question resolutions that block multiple downstream tasks. Aim for **mostly human** with a few AI tasks that can run in parallel (e.g., set up test scaffolding, CI baseline).
- **Phase 2+:** Implementation phases, ordered by dependencies. A reasonable theme per phase — e.g., "Core Auth", "Billing", "Polish". Aim for **3–7 phases total**.

Within each phase, **number tasks** with the phase prefix (`1.1`, `1.2`, ..., `2.1`, `2.2`, ...). The order within a phase reflects dependency — `1.2` may depend on `1.1`, but not the other way around. Use the issue body's `Blocked by:` field to record dependencies.

For tasks that depend on Phase 1 outcomes but live in a later phase, apply the `blocked` label. Remove it once Phase 1's blocking task closes.

### Step 6: Show the proposed plan

Render the plan as a single markdown document. Show:

- **Header.** Project name, source (`docs/requirements/`), generation date.
- **Labels needed.** The 8-label set, indicating which are new vs. already exist.
- **Milestones.** Phase number + theme + one-line description, indicating new vs. existing.
- **Tasks per phase.** Numbered list with title, labels, implements-IDs, estimated effort. Annotate human-required tasks clearly.
- **Estimated phase totals.** Issue count + rough effort (e.g., "Phase 1: 8 tasks, ~1 day human click-time + 1 day AI work").

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
  -f title="Phase 1: Foundation" \
  -f description="Foundation phase. Accounts, secrets, design decisions, and project scaffolding. Mostly human work — front-loaded so the AI doesn't stall waiting. Phase complete when all secrets are in place, design decisions are recorded, and Phase 2 can start unblocked."
```

Don't set due dates unless the user asked for them — false deadlines create noise.

### Step 9: Create issues

For each task in the approved plan that doesn't already exist as an issue:

```bash
gh issue create \
  --title "1.1 [HUMAN] Decide on browser support matrix" \
  --body "$(cat <<'EOF'
<full body from references/issue-template.md with substitutions>
EOF
)" \
  --label "priority:high,human-required,chore" \
  --milestone "Phase 1: Foundation"
```

**Issue body substitutions:**

- Fill `What`, `Why now`, `Definition of Done`, `Acceptance Criteria`, `Implements`, `Context` from the decomposition.
- For human-required tasks, **prepend** the `## ⚠️ Human Required` block per `references/issue-template.md`.
- For bug tasks (rare in a fresh plan), use the bug overlay.
- Resolve `Blocked by:` and `Blocks:` with real issue numbers as you create them in order. Pass 1 creates all issues; Pass 2 goes back and edits the body of each to fill in the now-known issue numbers. (`gh issue edit <num> --body-file <path>`.)

### Step 10: Summary

Print:

- **Labels created.** Count + names.
- **Milestones created.** Phase list with URLs.
- **Issues created.** Count, grouped by milestone, with a couple of highlighted entries (the first human-required, the first Phase 2 implementation task).
- **What's next for the user.**
  - Open the milestones page in GitHub to see the burndown.
  - Start Phase 1 by working through the human-required issues — these are batch-friendly (knock out in one focused session).
  - The AI can take Phase 1 non-human issues in parallel.

Also commit the `docs/implementation-plan.md` file so the plan is preserved in git history. Show the diff; let the user commit.

## Strict non-goals

- **No phase labels.** Phases are milestones; resist user requests to add `phase:1` or `phase:2` labels.
- **No code generation.** This is a planning skill. Actual implementation happens after issues are created, in separate sessions.
- **No requirement editing.** If decomposition surfaces that a requirement is unclear or wrong, point the user at `/confirm-requirements` rather than fixing in place.
- **No auto-assigning issues.** Assignment is a human decision. (The skill may suggest "this is a good candidate for the AI" via the absence of `human-required`, but doesn't assign.)
- **No `Won't (this release)` items.** Explicitly out of scope per the requirements doc; no issues created for them.
- **No size labels** (S/M/L), no **phase labels**, no `wip`/`in-progress` labels (those are PR states).

## Edge cases

- **`docs/requirements/` is missing.** Stop and point at `/create-requirements`.
- **`docs/requirements/` is all stubs.** Stop and point at `/create-requirements` to populate.
- **Most requirements are `Draft`.** Suggest `/confirm-requirements` to firm them up first, but offer to plan anyway with all-issues-marked-Draft.
- **`gh` not authenticated.** Produce the plan markdown but skip Steps 7-9. Tell the user to authenticate and re-run.
- **Labels exist with different colours.** Leave them alone — the user has a system, don't override it.
- **Existing issues with matching titles.** Surface them. Ask: skip (don't recreate), update (re-edit the body), or create-with-suffix (e.g., "1.1 [HUMAN] Decide on browser support matrix (replan 2026-05-13)").
- **A requirement has no implementable tasks** (e.g., it's purely an assumption / open question). Skip it; surface in the summary as "Skipped, requires resolution first".
- **The plan ends up with >50 issues.** This is a smell — either the requirements doc is too big for one plan, or decomposition is too granular. Stop and ask the user: is this really one release, or should we scope down?
- **A human-required task lands in Phase 5.** Push it earlier unless there's a hard dependency on Phase 4 output. Front-loading is the default; deviations need explicit reason.
- **User wants to "just do Phase 1 first, replan later".** Excellent default — create only Phase 1 issues, leave the rest of the plan markdown for the next session.
