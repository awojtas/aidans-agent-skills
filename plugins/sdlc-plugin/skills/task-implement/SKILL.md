---
name: task-implement
description: Implements a single GitHub issue end-to-end through a multi-persona orchestration — branch setup → ticket validation → cloud architecture review → UX design specification → implementation → UX design review → security review → tests → test validation → lint+build → production-readiness review → process audit → outcome audit → PR + self-review → review-feedback handling. Each persona (Principal Engineer, QA Engineer, Cloud Architect, UX/UI Designer, Security Engineer, Test Automation Engineer, Site Reliability Engineer, Project Manager, Product Manager, Work Checker) is spawned as a focused sub-agent, posts a `[Role Name]` comment on the GitHub issue with their status, and hands off to the next. The UX Designer establishes the design spec before implementation and verifies the rendered output afterwards using Playwright; the QA Engineer is also authorised to use Playwright for AC oversight; the Security Engineer audits the diff for OWASP-shape defects; the SRE audits observability, rollback, capacity, and failure modes; the Project Manager audits *process* delivery and the Product Manager audits *outcome* against the originating requirement. The Work Checker runs after every other persona and audits their work — empirically catches defects ~80% of the time. The Project Manager runs near the end and bounces back any phase where process gaps appear; the Product Manager runs at the end and bounces if the user-facing outcome misses. Designed for long-running comprehensive work (potentially hours) on important tasks where quality outweighs speed. Use when the user says "implement task #X", "do issue #X properly", "fully implement issue #X", "take this through to PR", "comprehensive implementation", or wants a thorough multi-role pass on a single ticket. Companion to the lighter `/issue-work` skill — `/task-implement` is the heavyweight version with structured handoffs and audit gates.
---

# Implementing a task end-to-end with role-based orchestration

This skill takes one GitHub issue from "picked up" to "PR ready for human merge". It is **deliberately heavyweight**. Each phase is run by a focused sub-agent under a clear persona; each persona posts an audit-trail comment on the issue; the Work Checker audits every phase; the Project Manager does a process-diligence pass and the Product Manager does an outcome pass before PR. Expect it to run for **hours** on a non-trivial task — that's the point.

## When to use this vs the lighter alternatives

- `/issue-work` — single-agent quick pass. Use when the task is small and the quality bar is "merges cleanly".
- `/task-implement` — multi-agent orchestration. Use when the task is important, complex, or risk-bearing, and the quality bar is "audited, fully tested, self-reviewed".

If you're not sure, default to `/issue-work` for tasks under ~half a day of work and `/task-implement` for anything bigger or anything carrying production risk.

## The personas

Ten personas. Each is a sub-agent the orchestrator spawns with a focused brief.

| Persona | Mandate | Reference doc | Posts comment as |
|---------|---------|----------------|------------------|
| **Principal Engineer (PE)** | Build it. Branch setup, implementation, lint+build, PR, review-feedback. | `references/role-principal-engineer.md` | `[Principal Engineer]` |
| **QA Engineer (QA)** | Make it testable; verify it's tested. Can use Playwright for AC oversight. | `references/role-qa-engineer.md` | `[QA Engineer]` |
| **Cloud Architect (CA)** | Identify and apply (or surface) infra/IaC/pipeline changes. | `references/role-cloud-architect.md` | `[Cloud Architect]` |
| **UX/UI Designer (UX)** | Establish the design spec before implementation; verify the rendered output after. Uses the project's design system if one exists, or defines principles if not. Uses Playwright to verify. | `references/role-ux-designer.md` | `[UX/UI Designer]` |
| **Security Engineer (Sec)** | Audit the diff for OWASP-shape defects — authn/authz, injection, secrets, crypto, session, dependency hygiene, rate-limit and abuse. Bounces on Critical / High. | `references/role-security-engineer.md` | `[Security Engineer]` |
| **Test Automation Engineer (TAE)** | Write the tests at the right level. | `references/role-test-automation-engineer.md` | `[Test Automation Engineer]` |
| **Site Reliability Engineer (SRE)** | Verify production-readiness — observability, alerting, runbook, rollback, capacity, failure modes, deploy safety. Per-feature scope, distinct from platform-level `/platform-verify`. | `references/role-sre.md` | `[SRE]` |
| **Project Manager (PrjM)** | Process-diligence audit; bounce back if work isn't actually delivered. | `references/role-project-manager.md` | `[Project Manager]` |
| **Product Manager (PdM)** | Outcome audit against the originating requirement — does the user-facing result match the intent? Actually tries the feature. | `references/role-product-manager.md` | `[Product Manager]` |
| **Work Checker (WC)** | Audit every phase before handoff. Catches the ~80% of self-audit defects. | `references/role-work-checker.md` | `[Work Checker]` |

The orchestrator is the eleventh actor — the conductor. It tracks state (current phase, branch, PR number, bounce-back counts) and dispatches each persona.

## The reference material

The orchestrator and each spawned sub-agent should consult these as needed:

| File | Purpose |
|------|---------|
| `references/role-principal-engineer.md` | PE charter, GitHub comment template, what they don't do, lazy-PE failure modes. |
| `references/role-qa-engineer.md` | QA charter, testable-AC patterns, AC→Test mapping, Playwright oversight, comment templates. |
| `references/role-cloud-architect.md` | CA charter, IaC change detection heuristic, when to escalate to human. |
| `references/role-ux-designer.md` | UX charter, design-system detection, design principles for projects with none, Playwright usage, Phase 3 + Phase 5 comment templates. |
| `references/role-security-engineer.md` | Sec charter, OWASP-shape threat-surface checklist, severity classification, comment templates. |
| `references/role-test-automation-engineer.md` | TAE charter, test pyramid application, per-test discipline. |
| `references/role-sre.md` | SRE charter, production-readiness checklist (observability / alerting / runbook / rollback / capacity / failure modes / deploy safety), severity classification. |
| `references/role-project-manager.md` | PrjM charter (process audit), audit checklist, bounce-back protocol. |
| `references/role-product-manager.md` | PdM charter (outcome audit), originating-requirement check, walk-the-feature discipline, bounce destinations. |
| `references/role-work-checker.md` | WC charter, universal + role-specific audit lists (all ten roles), "check your work" prompt. |
| `references/sdlc-pitfalls.md` | 15 named pitfalls + lazy-AI failure modes. |
| `references/solid-applied.md` | SOLID with smell+fix per principle; when not to apply. |
| `references/test-strategy.md` | Test pyramid, coverage philosophy, determinism rules. |
| `references/code-review-checklist.md` | The PE's self-review checklist; same one a human reviewer uses. |
| `references/example-implementation-session.md` | A worked end-to-end run showing all 16 phases. |

## Prerequisites

1. **Working directory is inside a git repo** with a GitHub remote.
2. **`gh` CLI authenticated** with write access to the repo (issues + PRs + comments). `gh auth status` shows `repo` scope.
3. **The issue exists.** The user passes the issue number (e.g. `/task-implement 42`). If they didn't, ask which issue.
4. **The issue has a clear Definition of Done and Acceptance Criteria** — these were authored by `/tasks-create-from-requirements` typically. If the issue is sparse, recommend `/requirements-validation` on the linked requirement first.
5. **`main` is the default branch** and is in a clean state. If there's local uncommitted work, stash or commit before invoking.
6. **The user has time.** This skill can run for hours. Set the expectation.
7. **`docs/architecture/` is present.** Implementation work without a recorded architecture risks drift from the agreed technical shape. If `docs/architecture/` is missing, surface this to the user before starting — *"No architecture folder found. Implementation can proceed but personas will be implementing against unstated architectural assumptions. Run `/platform-design` first?"* If the user says proceed, the personas treat the existing code as the de facto architecture.

## Workflow

The full 16-phase sequence:

```text
task-implement progress:
- [ ] Phase 0  — PE:   Branch setup
- [ ] Phase 1  — QA:   Ticket validation
- [ ] Phase 2  — CA:   Cloud architecture review
- [ ] Phase 3  — UX:   Design specification
- [ ] Phase 4  — PE:   Implementation
- [ ] Phase 5  — UX:   Design review
- [ ] Phase 6  — Sec:  Security review
- [ ] Phase 7  — TAE:  Tests
- [ ] Phase 8  — QA:   Test validation
- [ ] Phase 9  — PE:   Lint + build
- [ ] Phase 10 — SRE:  Production-readiness review
- [ ] Phase 11 — PrjM: Process-diligence audit (can bounce back to any earlier phase)
- [ ] Phase 12 — PdM:  Outcome review (can bounce or recommend /requirements-rework)
- [ ] Phase 13 — PE:   PR + self-review
- [ ] Phase 14 — PE:   Review feedback addressed
- [ ] Phase 15 — Summary + handoff to human
```

**After every phase except 0 and 15**, the Work Checker runs. If WC finds defects, the phase re-runs with the defect list as input. (See "Work Checker pattern" below.)

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

Spawn CA with phase context: *"Determine whether issue #N needs any IaC / pipeline / DevOps changes. Read `docs/architecture/` first — your job is to keep this implementation consistent with the recorded architecture. If the implementation would deviate (e.g. introduce a new managed service not in `03-external-integrations.md`), flag the deviation as a candidate ADR before making changes. Make the changes you can; surface the ones you can't."*

CA does:
- Reads the issue + the requirement(s).
- **Reads `docs/architecture/` if present** — especially `01-stack-and-hosting.md`, `03-external-integrations.md`, and `04-decisions.md`. The CA's job in this phase is to keep implementation consistent with the architecture *or* surface the need for a new ADR if the task requires deviating.
- Walks the project's IaC files.
- Applies the heuristic in `role-cloud-architect.md`.
- For changes within reach: edits IaC + commits on the branch (`chore(infra): ...`).
- For human-needed changes: posts a structured checklist comment on the issue.
- Posts `[Cloud Architect]` comment with the outcome.

Most tasks: *"No IaC / pipeline / DevOps changes needed"* — that's the most common outcome. Don't manufacture work.

Work Checker runs (checks that "no changes needed" wasn't claimed without reading IaC, env vars not added to one place only, no oversized infra additions).

### Phase 3 — UX: Design specification

Spawn UX with phase context: *"Establish the design specification for issue #N. Read `docs/architecture/` (especially `00-system-overview.md` and `01-stack-and-hosting.md`) so the spec aligns with the technical shape — the UX of a serverless web app differs from a native mobile app or a CLI tool. Detect the project's design system; use it consistently if it exists. If none exists, define initial design principles. Document the spec on the GitHub issue so the PE can build to it. For backend-only tasks, the spec covers response shape, error messages, and observability semantics — still UX, just a different surface."*

UX does:
- Reads the issue + the requirement(s) + any existing `docs/design/` content.
- **Reads `docs/architecture/` if present** — the system type from `00-system-overview.md` shapes what UX surfaces exist (web pages, CLI output, API responses, mobile screens, etc.).
- Detects design-system artefacts (Storybook, design tokens, Figma reference, in-repo component library, design-system plugin like the Glass Aurora plugin).
- For UI tasks: produces a full design spec covering every state (default / hover / focus / active / disabled / loading / empty / error / success), responsive behaviour, accessibility plan, motion, performance considerations.
- For backend-only tasks: writes a narrower spec for the response shape, error messages, log structure, and any client-facing semantics.
- If no design system exists: includes a "Design principles for this project (initial)" block in the comment (typographic scale, palette, spacing, radius, shadows) — the seed for the eventual system.
- Posts `[UX/UI Designer]` comment per the Phase 3 template in `references/role-ux-designer.md`.

Work Checker runs (checks: every state covered including error / loading / empty, copy specified, responsive plan, a11y plan, no vague "modern" / "clean" claims without specifics, design tokens reused from existing system if one exists).

### Phase 4 — PE: Implementation

Spawn PE with phase context: *"Implement issue #N. Read `docs/architecture/` first — the implementation must match the recorded architectural choices (stack, hosting, data stores, integrations). If a task makes you want to deviate, stop and surface that to the user as a candidate new ADR rather than silently going off-architecture. Match project conventions. Build to the UX spec from Phase 3 (link in the issue comments). Apply SOLID where it earns its keep. Two Hats — refactors get their own commits. Don't write the tests (TAE does that next). Posts when done."*

PE does:
- **Reads `docs/architecture/` if present** — the architectural choices recorded there constrain implementation. If the task would deviate, stop and flag before continuing.
- Reads the codebase to understand conventions.
- Reads the Phase 3 UX spec from the issue comments.
- Plans the change.
- Implements in small, atomic commits with Conventional Commits messages.
- If a preparatory refactor would make the change cleaner, does it as its own commit first.
- Pushes commits to the branch.
- Posts `[Principal Engineer]` comment with: what was done, commit shas, any decisions worth surfacing, any pushback if the task revealed a problem.

Work Checker runs (applies the PE checklist in `role-work-checker.md`: TODO/FIXME, swallowed exceptions, magic numbers, commented code, debug prints, atomic commits).

This phase often takes the longest in absolute terms. If the implementation is bigger than expected, the orchestrator may suggest pausing and resuming later — but doesn't auto-pause without the user.

### Phase 5 — UX: Design review

Spawn UX with phase context: *"PE has implemented. Re-read your Phase 3 spec. Inspect the rendered output. Use Playwright where the surface is user-visible — verify states, responsive behaviour, accessibility. If anything drifts from the spec, bounce back to PE with the specific gap."*

UX does:
- Re-reads the Phase 3 design spec they wrote earlier.
- For UI tasks: starts the dev server (or uses Playwright against a built version), walks each state from the spec, captures screenshots, runs `@axe-core/playwright` for accessibility.
- For backend-only tasks: reviews the response shape and error messages against the spec, confirms the implementation matches.
- Posts `[UX/UI Designer]` comment per the Phase 5 template in `references/role-ux-designer.md` — either **APPROVED** with verification details, or **Drift from spec found** with specific items.

Drift bounces back to PE Phase 4 (same bounce-back limit applies — 3 strikes then escalate).

Work Checker runs (checks: every state actually verified, Playwright was actually run if applicable, axe-core results, no "looks fine" without specifics, design tokens used not invented).

### Phase 6 — Sec: Security review

Spawn Sec with phase context: *"PE has implemented and UX has approved. Read `docs/architecture/` (especially `01-stack-and-hosting.md` and any security-relevant ADRs in `04-decisions.md`). Walk the threat-surface checklist in `references/role-security-engineer.md`: authn/authz, input validation, secrets, crypto, session/CSRF, CORS/headers, dependency sniff, logging, rate limiting. Bounce on Critical or High. Surface Medium and Low for the PR record."*

Sec does:
- **Reads `docs/architecture/` if present** — to know what the threat model assumes (where data lives, what's exposed, what the trust boundaries are).
- Reads the diff (`git diff origin/main...HEAD`) including production + test code.
- Walks every applicable category from `role-security-engineer.md`. For categories that aren't applicable, says so explicitly with a reason — silence is not proof.
- Classifies findings by severity (Critical / High / Medium / Low / Informational).
- For **Critical / High**: bounces to PE with file:line references and a one-line remediation per finding.
- For **Medium / Low**: posts findings for the PR record but does not block.
- Posts `[Security Engineer]` comment per the template in `role-security-engineer.md`.

Most tasks: a clean walk with informational notes only. Don't manufacture findings.

Work Checker runs (checks: no "all clear" claim without naming categories walked, authz check not skipped on a new endpoint, secret-in-diff check ran, dependency additions sniffed, no silent CORS broadening).

### Phase 7 — TAE: Tests

Spawn TAE with phase context: *"PE has implemented; UX has approved the design; Sec has cleared the diff. Read the diff. Write tests at the right level per the pyramid (`references/test-strategy.md`). Use the project's existing test patterns. Deterministic data only. For user-visible flows, consider one Playwright test on the happy path — UX has already validated rendering, so the test asserts behaviour. If Sec flagged a Medium / Low concern, consider whether a regression test is warranted."*

TAE does:
- Reads the diff.
- Identifies which level (unit/integration/E2E) each piece needs.
- Writes the tests with seeded factories / frozen clocks / mocked I/O.
- For E2E: writes Playwright tests on critical user-visible paths (informed by UX's Phase 5 review).
- Runs the tests locally; they must pass.
- Commits with `test: ...` Conventional Commits.
- Posts `[Test Automation Engineer]` comment.

If the TAE finds the code is hard to test (untestable seams), they post a flag and the orchestrator bounces back to the PE: *"PE — TAE found this function takes a global; please refactor to take it as a parameter so it can be stubbed."*

Work Checker runs (truthy assertions, mock-the-world tests, flaky timing, hardcoded data, `.skip` without justification, E2E for things that should be unit).

### Phase 8 — QA: Test validation

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

### Phase 9 — PE: Lint + build

Spawn PE with phase context: *"Tests pass. Run lint and build. Fix every warning the project flags. Re-run until clean."*

PE does:
- Identifies the project's lint command (from `package.json` scripts, `pyproject.toml`, etc.).
- Runs lint. Fixes warnings.
- Runs the build. Fixes failures.
- Re-runs both until clean.
- Commits with `chore: ...` or `fix: ...` for lint/build fixes.
- Posts `[Principal Engineer]` comment with confirmation both are green.

Work Checker runs (no `// eslint-disable` added to silence, no `any` / `# type: ignore` added without justification, no warning-silencing config changes).

### Phase 10 — SRE: Production-readiness review

Spawn SRE with phase context: *"Implementation is final and lint+build are green. Read `docs/architecture/` (especially `01-stack-and-hosting.md` for runtime topology and any operational ADRs in `04-decisions.md`). Walk the production-readiness checklist in `references/role-sre.md`: observability (logs/metrics/traces on new code path), alerting (new failure modes covered), runbook + rollback path (is `git revert + redeploy` clean?), capacity + cost sanity, failure modes (timeouts, retries, graceful degradation), deploy safety (env vars in all envs, canary-compatibility). Bounce on Blocker or High."*

SRE does:
- **Reads `docs/architecture/` if present** — runtime topology and operational ADRs constrain what "ready" looks like.
- Reads the diff for new code paths, new external calls, new background jobs, migrations.
- Walks every applicable category in `role-sre.md`. Explicit "N/A — reason" for inapplicable categories.
- Classifies findings (Blocker / High / Medium / Low).
- For **Blocker / High**: bounces back to PE (or CA where infra-level) with the specific gap.
- For **Medium / Low**: notes in the comment, does not block.
- Posts `[SRE]` comment per the template in `role-sre.md`.

Per-feature scope. The platform-level "is the cloud wired right?" question belongs to `/platform-verify`, not here.

Work Checker runs (checks: no "production ready" without naming categories walked, observability not skipped on new code paths, no timeout-less external calls approved, no irreversible migrations approved, SLO-less projects flagged not waved through).

### Phase 11 — PrjM: Process-diligence audit (the bounce-back checkpoint)

Spawn PrjM with phase context: *"Audit the work for issue #N for **process and execution**. Read the issue's DoD + AC. Read every prior phase's comment. Inspect the actual artefacts. Verify each claim. If anything's missing, bounce back to the responsible role. The PdM in the next phase will audit *outcome* — your job here is delivery quality."*

PrjM does:
- Reads the issue.
- Reads every `[<Role>]` comment posted on the issue (PE, QA, CA, UX, Sec, TAE, SRE comments).
- Inspects the diff via `gh pr diff` or `git diff origin/main...HEAD`.
- Runs the test suite themselves to verify "green" claims.
- Runs lint + build themselves to verify "green" claims.
- Walks the audit checklist in `role-project-manager.md`.
- Posts the audit result.

**Two outcomes:**

- **Clean.** PrjM posts `APPROVED`. Skill proceeds to Phase 12.
- **Defects.** PrjM posts the bounce-back comment naming the responsible role and the specific gaps. The orchestrator returns control to that role's phase. **Bounce-back limit: 3 per role per session.** If a role gets bounced 3 times, the skill stops and escalates to the user.

Work Checker runs after PrjM's audit (checks for "looks good" without specifics, missed TODO additions, drifting into outcome-auditing).

### Phase 12 — PdM: Outcome review

Spawn PdM with phase context: *"PrjM has confirmed the work was *executed* properly. Your job is to confirm it was the *right thing* to do. Read the originating requirement(s) in `docs/requirements/` — not the issue, the requirement. Read the UX Phase 5 design review comment. Then actually use the feature (dev server, Playwright, or whatever surface is appropriate). Walk the outcome checklist in `references/role-product-manager.md`. Bounce if the user-facing result misses the requirement's intent."*

PdM does:
- Reads the originating requirement (followed via `Implements:` references in the issue).
- Reads the issue body + the UX Phase 5 comment.
- Runs the feature themselves (dev server, click through, exercise the path the user would take).
- Walks the outcome checklist in `role-product-manager.md`: intent, experience, scope, trade-offs surfaced, feedback loop.
- Posts the audit result.

**Three outcomes:**

- **Clean.** PdM posts `APPROVED`. Skill proceeds to Phase 13.
- **Outcome gap.** PdM bounces back to PE or UX with the specific gap (see `role-product-manager.md` bounce-destination table).
- **Requirement-level wrongness.** If the implementation faithfully built what the requirement asked for but the requirement itself was wrong, PdM does not bounce within this session — they recommend `/requirements-rework` and the skill stops. This is a deliberate hard exit.

**Bounce-back limit: 3 per role per session** (same as PrjM's).

Work Checker runs after PdM's audit (checks: requirement actually read, feature actually tried not just diff-read, fit-criterion measurability addressed, no taste-pedantry passed off as defect).

### Phase 13 — PE: PR + self-review

Spawn PE with phase context: *"PrjM + PdM both approved. Push final commits. Raise the PR following the template in `role-principal-engineer.md`. Self-review the diff line-by-line per `code-review-checklist.md`. Fix anything the self-review surfaces."*

PE does:
- Pushes any final commits.
- `gh pr create --title "<type>(<scope>): <subject>" --body "$(cat <<'EOF' ...)"` — body following the PR template.
- Opens the PR in the GitHub UI (mental model — actually opens the diff via `gh pr diff` for line-by-line).
- Walks the code-review checklist.
- For each "hmm" — fixes, commits, pushes.
- Adds the **Self-review** section to the PR body listing what the pass found and fixed.
- Posts `[Principal Engineer]` comment with the PR URL.

Work Checker runs (PR description complete, Self-review section present, Closes #N link, CI is green).

### Phase 14 — PE: Review feedback

This phase is **conditional**. It only runs if a human reviewer has commented on the PR.

If no human review yet, skill moves to Phase 15. The user can re-invoke `/task-implement <issue>` later after human review lands to run Phase 14 (the orchestrator detects this state).

When invoked for Phase 14:

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

### Phase 15 — Summary + handoff

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
- Pointer: *"Next: human reviewer assignment. After review, re-invoke `/task-implement <issue-number>` for Phase 14 to address feedback."*

## Work Checker pattern (the audit gate after every phase)

After **every** persona phase except Phase 0 and Phase 15, the orchestrator spawns the Work Checker:

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
  "pr_number": null,  // until Phase 13
  "current_phase": 4,
  "bounce_back_counts": {
    "PE": { "Phase 4": 1 },
    "TAE": { "Phase 7": 0 }
  },
  "wc_findings_total": 4
}
```

Stored in memory across the session; printed in the final summary.

## Strict non-goals

- **No skipping phases.** The 16-phase sequence is intentional. If the user wants a lighter pass, use `/issue-work`.
- **No silent merging.** This skill never merges the PR. That's a human decision.
- **No auto-fixing across roles.** The Work Checker reports; it doesn't fix. The role fixes.
- **No infinite bounce-back.** 3 strikes per role per session, then escalate to the user.
- **No multi-issue batching.** One issue per session. If the user wants multiple, run the skill multiple times.
- **No requirement rework.** If the implementation reveals the requirement is wrong, the PE stops and recommends `/requirements-rework` — this skill does not modify requirements.

## Edge cases

- **Issue doesn't exist.** `gh issue view <N>` fails — stop with a clear error.
- **Issue is closed.** Ask the user if they want to reopen it before starting.
- **Branch already exists** (re-running after a prior partial session). Detect: `git ls-remote --heads origin <branch>`. If exists, ask the user: resume on this branch, or delete and restart?
- **PR already exists** for this branch. Resume from Phase 14 (review feedback) or, if no review yet, Phase 13 (re-self-review and post status).
- **Bounce-back limit hit.** Stop. Post a `[Orchestrator]` comment summarising the situation. Don't continue.
- **Issue has no AC.** Phase 1 (QA) detects this. If AC can't be inferred from the requirement, the orchestrator stops and recommends `/requirements-validation` first.
- **Project has no test setup at all** (no test runner, no test directories). TAE detects this and surfaces it — implementation can proceed but the skill warns the PE before Phase 9 (lint + build) that there's nothing to lint/build the test target against. PrjM in Phase 11 will treat "no tests added" as a defect unless the project genuinely has no testing infrastructure (and even then it's a flag for the user).
- **Project has no observability at all** (no logger, no metrics framework, no tracing). SRE in Phase 10 detects this and surfaces it to the user — implementation can proceed but production-readiness is degraded. SRE flags adding minimal logging as a follow-up issue.
- **Project has no SLOs.** SRE in Phase 10 surfaces this — alert thresholds without SLOs are arbitrary. Flag as a candidate decision for the user; do not manufacture SLOs in-session.
- **Backend-only task with no user-visible surface.** The UX Designer in Phase 3 produces a short spec covering response shape / error messages / observability semantics, and Phase 5 is a brief review of those. Both still happen — the audit trail captures the consideration.
- **No design system in the repo.** The UX Designer in Phase 3 defines initial design principles (typographic scale, palette, spacing, radius, shadows) and posts them on the issue. These seed the project's eventual design system.
- **Playwright not set up in the repo.** UX Designer and TAE detect this. They proceed with the verification they can do (visual inspection, axe-core stand-alone, manual run) and flag Playwright setup as a follow-up issue.
- **CI is red on main when we start.** Stop. Don't add work to a broken main. Tell the user to fix main first.
- **User aborts mid-session.** The branch + any commits remain. The orchestrator's last GitHub comment indicates which phase was in flight. Re-invoking resumes from there.
- **Long-running session timeout.** Claude Code's context compresses automatically; the skill is resumable from the GitHub comment trail. Each persona's comment is the durable state.
