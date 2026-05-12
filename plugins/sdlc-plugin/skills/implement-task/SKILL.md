---
name: implement-task
description: Implements a single GitHub issue end-to-end through a multi-persona orchestration — branch setup → ticket validation → cloud architecture review → UX design specification → implementation → UX design review → tests → test validation → lint+build → diligence audit → PR + self-review → review-feedback handling. Each persona (Principal Engineer, QA Engineer, Cloud Architect, UX/UI Designer, Test Automation Engineer, Project Manager, Work Checker) is spawned as a focused sub-agent, posts a `[Role Name]` comment on the GitHub issue with their status, and hands off to the next. The UX Designer establishes the design spec before implementation and verifies the rendered output afterwards using Playwright; the QA Engineer is also authorised to use Playwright for AC oversight. The Work Checker runs after every other persona and audits their work — empirically catches defects ~80% of the time. The Project Manager runs near the end and bounces back any phase where the audit finds gaps. Designed for long-running comprehensive work (potentially hours) on important tasks where quality outweighs speed. Use when the user says "implement task #X", "do issue #X properly", "fully implement issue #X", "take this through to PR", "comprehensive implementation", or wants a thorough multi-role pass on a single ticket. Companion to the lighter `/issue-worker` skill — `/implement-task` is the heavyweight version with structured handoffs and audit gates.
---

# Implementing a task end-to-end with role-based orchestration

This skill takes one GitHub issue from "picked up" to "PR ready for human merge". It is **deliberately heavyweight**. Each phase is run by a focused sub-agent under a clear persona; each persona posts an audit-trail comment on the issue; the Work Checker audits every phase; the Project Manager does a diligence pass before PR. Expect it to run for **hours** on a non-trivial task — that's the point.

## When to use this vs the lighter alternatives

- `/issue-worker` — single-agent quick pass. Use when the task is small and the quality bar is "merges cleanly".
- `/implement-task` — multi-agent orchestration. Use when the task is important, complex, or risk-bearing, and the quality bar is "audited, fully tested, self-reviewed".

If you're not sure, default to `/issue-worker` for tasks under ~half a day of work and `/implement-task` for anything bigger or anything carrying production risk.

## The personas

Seven personas. Each is a sub-agent the orchestrator spawns with a focused brief.

| Persona | Mandate | Reference doc | Posts comment as |
|---------|---------|----------------|------------------|
| **Principal Engineer (PE)** | Build it. Branch setup, implementation, lint+build, PR, review-feedback. | `references/role-principal-engineer.md` | `[Principal Engineer]` |
| **QA Engineer (QA)** | Make it testable; verify it's tested. Can use Playwright for AC oversight. | `references/role-qa-engineer.md` | `[QA Engineer]` |
| **Cloud Architect (CA)** | Identify and apply (or surface) infra/IaC/pipeline changes. | `references/role-cloud-architect.md` | `[Cloud Architect]` |
| **UX/UI Designer (UX)** | Establish the design spec before implementation; verify the rendered output after. Uses the project's design system if one exists, or defines principles if not. Uses Playwright to verify. | `references/role-ux-designer.md` | `[UX/UI Designer]` |
| **Test Automation Engineer (TAE)** | Write the tests at the right level. | `references/role-test-automation-engineer.md` | `[Test Automation Engineer]` |
| **Project Manager (PM)** | Diligence audit; bounce back if work isn't actually done. | `references/role-project-manager.md` | `[Project Manager]` |
| **Work Checker (WC)** | Audit every phase before handoff. Catches the ~80% of self-audit defects. | `references/role-work-checker.md` | `[Work Checker]` |

The orchestrator is the eighth actor — the conductor. It tracks state (current phase, branch, PR number, bounce-back counts) and dispatches each persona.

## The reference material

The orchestrator and each spawned sub-agent should consult these as needed:

| File | Purpose |
|------|---------|
| `references/role-principal-engineer.md` | PE charter, GitHub comment template, what they don't do, lazy-PE failure modes. |
| `references/role-qa-engineer.md` | QA charter, testable-AC patterns, AC→Test mapping, Playwright oversight, comment templates. |
| `references/role-cloud-architect.md` | CA charter, IaC change detection heuristic, when to escalate to human. |
| `references/role-ux-designer.md` | UX charter, design-system detection, design principles for projects with none, Playwright usage, Phase 3 + Phase 5 comment templates. |
| `references/role-test-automation-engineer.md` | TAE charter, test pyramid application, per-test discipline. |
| `references/role-project-manager.md` | PM charter, audit checklist, bounce-back protocol. |
| `references/role-work-checker.md` | WC charter, universal + role-specific audit lists, "check your work" prompt. |
| `references/sdlc-pitfalls.md` | 15 named pitfalls + lazy-AI failure modes. |
| `references/solid-applied.md` | SOLID with smell+fix per principle; when not to apply. |
| `references/test-strategy.md` | Test pyramid, coverage philosophy, determinism rules. |
| `references/code-review-checklist.md` | The PE's self-review checklist; same one a human reviewer uses. |
| `references/example-implementation-session.md` | A worked end-to-end run showing all 13 phases. |

## Prerequisites

1. **Working directory is inside a git repo** with a GitHub remote.
2. **`gh` CLI authenticated** with write access to the repo (issues + PRs + comments). `gh auth status` shows `repo` scope.
3. **The issue exists.** The user passes the issue number (e.g. `/implement-task 42`). If they didn't, ask which issue.
4. **The issue has a clear Definition of Done and Acceptance Criteria** — these were authored by `/plan-from-requirements` typically. If the issue is sparse, recommend `/confirm-requirements` on the linked requirement first.
5. **`main` is the default branch** and is in a clean state. If there's local uncommitted work, stash or commit before invoking.
6. **The user has time.** This skill can run for hours. Set the expectation.

## Workflow

The full 11-phase sequence:

```text
implement-task progress:
- [ ] Phase 0  — PE: Branch setup
- [ ] Phase 1  — QA: Ticket validation
- [ ] Phase 2  — CA: Cloud architecture review
- [ ] Phase 3  — PE: Implementation
- [ ] Phase 4  — TAE: Tests
- [ ] Phase 5  — QA: Test validation
- [ ] Phase 6  — PE: Lint + build
- [ ] Phase 7  — PM: Diligence audit (can bounce back to any earlier phase)
- [ ] Phase 8  — PE: PR + self-review
- [ ] Phase 9  — PE: Review feedback addressed
- [ ] Phase 10 — Summary + handoff to human
```

**After every phase except 0 and 10**, the Work Checker runs. If WC finds defects, the phase re-runs with the defect list as input. (See "Work Checker pattern" below.)

### How the orchestrator dispatches a persona

For each phase, the orchestrator launches a sub-agent using the `Agent` tool. The general pattern:

```
Agent({
  description: "<role>: Phase <N> — <phase name>",
  subagent_type: "claude",
  prompt: "
    You are acting as the <role> for issue #<N> in <owner>/<repo>.

    Your mandate, GitHub comment template, and failure modes are described in
    full in references/role-<role-slug>.md — read it before doing anything.

    Additional references for this phase:
    - references/<applicable-ref-1>.md
    - references/<applicable-ref-2>.md

    Phase context:
    - Issue: <number, title, link>
    - Branch: <branch name>
    - Previous phase comments on the issue: <copied verbatim>
    - This phase's specific objective: <what done looks like>

    When complete, post a single GitHub comment on the issue as `[<role>]` per
    your role's comment template. Then return a structured summary to me:
      - Did you complete the phase? (yes / no — if no, why)
      - What you produced (commits, edits, comments)
      - Any pushback or surprises
  "
})
```

The orchestrator collects the sub-agent's return value, runs the Work Checker on the result, and either proceeds to the next phase or returns control to the same phase with WC's defect list.

### Phase 0 — PE: Branch setup

Spawn PE with phase context: *"Set up a new branch for issue #N off the latest main. Confirm clean working tree. Push the branch to origin."*

PE does:
- `git fetch origin && git checkout main && git pull --ff-only`
- `git checkout -b <issue-number>-<short-slug>`
- `git push -u origin <branch>`
- Posts `[Principal Engineer]` comment: *"Branch `<name>` created from main at `<sha>` and pushed. Ready for Phase 1."*

Work Checker runs (light — checks branch name format, that it actually exists, that main was clean).

### Phase 1 — QA: Ticket validation

Spawn QA with phase context: *"Validate issue #N is implementable. Re-read the AC; tighten anything vague. Identify test seams and test data needs."*

QA does:
- Reads the issue + linked requirement(s) in `docs/requirements/`.
- For each AC clause, applies the testable-AC test (see `role-qa-engineer.md`).
- Edits the issue body via `gh issue edit` if AC needs tightening.
- Posts `[QA Engineer]` comment per Phase 1 template.

Work Checker runs (checks for hedge words remaining in AC, test data identified, no AC missing).

### Phase 2 — CA: Cloud architecture review

Spawn CA with phase context: *"Determine whether issue #N needs any IaC / pipeline / DevOps changes. Make the ones you can; surface the ones you can't."*

CA does:
- Reads the issue + the requirement(s).
- Walks the project's IaC files.
- Applies the heuristic in `role-cloud-architect.md`.
- For changes within reach: edits IaC + commits on the branch (`chore(infra): ...`).
- For human-needed changes: posts a structured checklist comment on the issue.
- Posts `[Cloud Architect]` comment with the outcome.

Most tasks: *"No IaC / pipeline / DevOps changes needed"* — that's the most common outcome. Don't manufacture work.

Work Checker runs (checks that "no changes needed" wasn't claimed without reading IaC, env vars not added to one place only, no oversized infra additions).

### Phase 3 — PE: Implementation

Spawn PE with phase context: *"Implement issue #N. Match project conventions. Apply SOLID where it earns its keep. Two Hats — refactors get their own commits. Don't write the tests (TAE does that next). Posts when done."*

PE does:
- Reads the codebase to understand conventions.
- Plans the change.
- Implements in small, atomic commits with Conventional Commits messages.
- If a preparatory refactor would make the change cleaner, does it as its own commit first.
- Pushes commits to the branch.
- Posts `[Principal Engineer]` comment with: what was done, commit shas, any decisions worth surfacing, any pushback if the task revealed a problem.

Work Checker runs (applies the PE checklist in `role-work-checker.md`: TODO/FIXME, swallowed exceptions, magic numbers, commented code, debug prints, atomic commits).

This phase often takes the longest in absolute terms. If the implementation is bigger than expected, the orchestrator may suggest pausing and resuming later — but doesn't auto-pause without the user.

### Phase 4 — TAE: Tests

Spawn TAE with phase context: *"PE has implemented. Read the diff. Write tests at the right level per the pyramid (`references/test-strategy.md`). Use the project's existing test patterns. Deterministic data only."*

TAE does:
- Reads the diff.
- Identifies which level (unit/integration/E2E) each piece needs.
- Writes the tests with seeded factories / frozen clocks / mocked I/O.
- Runs the tests locally; they must pass.
- Commits with `test: ...` Conventional Commits.
- Posts `[Test Automation Engineer]` comment.

If the TAE finds the code is hard to test (untestable seams), they post a flag and the orchestrator bounces back to the PE: *"PE — TAE found this function takes a global; please refactor to take it as a parameter so it can be stubbed."*

Work Checker runs (truthy assertions, mock-the-world tests, flaky timing, hardcoded data, `.skip` without justification, E2E for things that should be unit).

### Phase 5 — QA: Test validation

Spawn QA with phase context: *"TAE has written tests. Validate them. Build the AC → Test map. Confirm every AC clause has a test. Run the full test suite. Fix any flake by tightening determinism."*

QA does:
- Re-reads the AC.
- Walks every test the TAE added — confirms each tests a real outcome.
- Builds the AC → Test map (table per template).
- Runs the full test suite via the project's runner.
- If any flake: identifies the source (random data, real clock, real network) and either fixes or bounces back to TAE.
- Adds any missing fixtures.
- Posts `[QA Engineer]` comment with the AC → Test map and pass/fail status.

Work Checker runs (AC → Test map complete, no uncovered AC clauses, no flake silently ignored).

### Phase 6 — PE: Lint + build

Spawn PE with phase context: *"Tests pass. Run lint and build. Fix every warning the project flags. Re-run until clean."*

PE does:
- Identifies the project's lint command (from `package.json` scripts, `pyproject.toml`, etc.).
- Runs lint. Fixes warnings.
- Runs the build. Fixes failures.
- Re-runs both until clean.
- Commits with `chore: ...` or `fix: ...` for lint/build fixes.
- Posts `[Principal Engineer]` comment with confirmation both are green.

Work Checker runs (no `// eslint-disable` added to silence, no `any` / `# type: ignore` added without justification, no warning-silencing config changes).

### Phase 7 — PM: Diligence audit (the bounce-back checkpoint)

Spawn PM with phase context: *"Audit the work for issue #N. Read the issue's DoD + AC. Read every prior phase's comment. Inspect the actual artefacts. Verify each claim. If anything's missing, bounce back to the responsible role."*

PM does:
- Reads the issue.
- Reads every `[<Role>]` comment posted on the issue.
- Inspects the diff via `gh pr diff` or `git diff origin/main...HEAD`.
- Runs the test suite themselves to verify "green" claims.
- Runs lint + build themselves to verify "green" claims.
- Walks the audit checklist in `role-project-manager.md`.
- Posts the audit result.

**Two outcomes:**

- **Clean.** PM posts `APPROVED`. Skill proceeds to Phase 8.
- **Defects.** PM posts the bounce-back comment naming the responsible role and the specific gaps. The orchestrator returns control to that role's phase. **Bounce-back limit: 3 per role per session.** If a role gets bounced 3 times, the skill stops and escalates to the user.

Work Checker runs after PM's audit (checks for "looks good" without specifics, missed TODO additions).

### Phase 8 — PE: PR + self-review

Spawn PE with phase context: *"PM approved. Push final commits. Raise the PR following the template in `role-principal-engineer.md`. Self-review the diff line-by-line per `code-review-checklist.md`. Fix anything the self-review surfaces."*

PE does:
- Pushes any final commits.
- `gh pr create --title "<type>(<scope>): <subject>" --body "$(cat <<'EOF' ...)"` — body following the PR template.
- Opens the PR in the GitHub UI (mental model — actually opens the diff via `gh pr diff` for line-by-line).
- Walks the code-review checklist.
- For each "hmm" — fixes, commits, pushes.
- Adds the **Self-review** section to the PR body listing what the pass found and fixed.
- Posts `[Principal Engineer]` comment with the PR URL.

Work Checker runs (PR description complete, Self-review section present, Closes #N link, CI is green).

### Phase 9 — PE: Review feedback

This phase is **conditional**. It only runs if a human reviewer has commented on the PR.

If no human review yet, skill moves to Phase 10. The user can re-invoke `/implement-task <issue>` later after human review lands to run Phase 9 (the orchestrator detects this state).

When invoked for Phase 9:

Spawn PE with phase context: *"Human review left comments. Address each one. For legitimate comments — fix, commit, push. For ones you disagree with — reply explaining the reasoning. Resolve threads only after the change or after the reviewer agrees. Resolve any merge conflicts."*

PE does:
- `gh pr view <num> --comments` to read every review comment and thread.
- For each: classifies as `fix` / `disagree` / `clarify`.
- `fix` → makes the change, commits with `fix(review): <subject>`, pushes.
- `disagree` → replies on the PR comment with the reasoning. Does not resolve the thread until the reviewer agrees.
- `clarify` → asks a follow-up question on the comment.
- For merge conflicts: `git fetch origin && git rebase origin/main` (preferred per project policy) or `git merge origin/main`. Resolves manually. `git push --force-with-lease` if rebase; `git push` if merge.
- Posts `[Principal Engineer]` comment summarising what was addressed.

Work Checker runs (every legitimate comment addressed, no comments silently dismissed, merge conflicts cleanly resolved).

### Phase 10 — Summary + handoff

Final summary post by the orchestrator (not a persona) to the GitHub issue, plus a final terminal summary to the user:

```markdown
**[Orchestrator]** Implementation session complete.

- Branch: `<branch-name>`
- PR: <URL>
- Commits: <N>
- Tests added: <unit-count> unit / <int-count> integration / <e2e-count> E2E
- Bounce-backs during session: <count> (see PM comments)
- Human-required infra checklist items: <count> (see CA comment)

PR is ready for human review and merge.
```

The terminal summary:

- PR link.
- Time elapsed.
- Bounce-back count (visible signal of quality friction).
- Number of WC findings caught and fixed (visible signal of self-audit value).
- Pointer: *"Next: human reviewer assignment. After review, re-invoke `/implement-task <issue-number>` for Phase 9 to address feedback."*

## Work Checker pattern (the audit gate after every phase)

After **every** persona phase except Phase 0 and Phase 10, the orchestrator spawns the Work Checker:

```
Agent({
  description: "Work Checker: audit Phase <N> (<role>'s work)",
  subagent_type: "claude",
  prompt: "
    You are the Work Checker. The <role> just claimed to be done with Phase <N>
    for issue #<N> on <owner>/<repo>.

    Read references/role-work-checker.md — the universal checklist + the
    role-specific 'Lazy-<role> failure modes' from references/role-<role>.md.

    Audit the artefacts the <role> produced:
    - Their GitHub comment: <comment text>
    - Diff: <relevant files>
    - Commits since Phase <N-1>: <commit shas>

    Apply your prompt internally: 'Please just check your work carefully on
    this. Look for: ...'

    Return: 'clean' (with a one-line summary) or 'defects' (with a numbered list).
  "
})
```

If WC returns **clean**: proceed to the next phase.

If WC returns **defects**: the orchestrator returns to the same phase with the defect list, dispatched to the same role. The role addresses each defect, then the WC re-audits.

**Bounce-back limit per WC pass: 3.** If the WC finds defects 3 times in a row on the same phase, the orchestrator stops and escalates to the user — something deeper is wrong.

The empirical hit rate from `references/role-work-checker.md`: ~80% of phases produce defects on first WC pass. That's the value. Backed by Madaan et al.'s **Self-Refine** (~20% absolute quality lift on second-pass critique — https://arxiv.org/abs/2303.17651).

## State the orchestrator tracks

Across the long-running session:

```text
{
  "issue_number": 42,
  "owner_repo": "awojtas/example",
  "branch": "42-add-rate-limit-to-signin",
  "pr_number": null,  // until Phase 8
  "current_phase": 3,
  "bounce_back_counts": {
    "PE": { "Phase 3": 1 },
    "TAE": { "Phase 4": 0 }
  },
  "wc_findings_total": 4
}
```

Stored in memory across the session; printed in the final summary.

## Strict non-goals

- **No skipping phases.** The 11-phase sequence is intentional. If the user wants a lighter pass, use `/issue-worker`.
- **No silent merging.** This skill never merges the PR. That's a human decision.
- **No auto-fixing across roles.** The Work Checker reports; it doesn't fix. The role fixes.
- **No infinite bounce-back.** 3 strikes per role per session, then escalate to the user.
- **No multi-issue batching.** One issue per session. If the user wants multiple, run the skill multiple times.
- **No requirement rework.** If the implementation reveals the requirement is wrong, the PE stops and recommends `/rework` — this skill does not modify requirements.

## Edge cases

- **Issue doesn't exist.** `gh issue view <N>` fails — stop with a clear error.
- **Issue is closed.** Ask the user if they want to reopen it before starting.
- **Branch already exists** (re-running after a prior partial session). Detect: `git ls-remote --heads origin <branch>`. If exists, ask the user: resume on this branch, or delete and restart?
- **PR already exists** for this branch. Resume from Phase 9 (review feedback) or, if no review yet, Phase 8 (re-self-review and post status).
- **Bounce-back limit hit.** Stop. Post a `[Orchestrator]` comment summarising the situation. Don't continue.
- **Issue has no AC.** Phase 1 (QA) detects this. If AC can't be inferred from the requirement, the orchestrator stops and recommends `/confirm-requirements` first.
- **Project has no test setup at all** (no test runner, no test directories). TAE detects this and surfaces it — implementation can proceed but the skill warns the PE before Phase 6 (lint + build) that there's nothing to lint/build the test target against. PM in Phase 7 will treat "no tests added" as a defect unless the project genuinely has no testing infrastructure (and even then it's a flag for the user).
- **CI is red on main when we start.** Stop. Don't add work to a broken main. Tell the user to fix main first.
- **User aborts mid-session.** The branch + any commits remain. The orchestrator's last GitHub comment indicates which phase was in flight. Re-invoking resumes from there.
- **Long-running session timeout.** Claude Code's context compresses automatically; the skill is resumable from the GitHub comment trail. Each persona's comment is the durable state.
