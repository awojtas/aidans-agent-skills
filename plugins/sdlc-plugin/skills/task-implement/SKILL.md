---
name: task-implement
description: 'Adaptive multi-persona SDLC workflow for a single GitHub issue. Opens with a complexity-routing step that scores risk (real money? public users? publicly visible? embarrassment/legal exposure?) and decides which specialist personas to activate — Cloud Architect, Security Engineer, and SRE can be skipped for low-risk or local-only work; PE, QA, TAE, PrjM, PdM, and Work Checker always run. Active personas post audit-trail comments; the run culminates in a reviewed, merged PR. Scales from a lean few-persona pass to hours of full-suite orchestration. Use when the user says "task-implement", "thoroughly implement", "careful implementation", "production-critical", "complex feature", or wants multi-persona review with an audit trail. For single-agent quick tasks use /issue-work.'
---

# Implementing a task end-to-end with role-based orchestration

This skill takes one GitHub issue from "picked up" to **merged and closed**. Each phase is run by focused personas; each persona posts an audit-trail comment on the issue; the Work Checker audits every phase. Phase 0 routes the complexity — low-risk work skips conditional phases and can finish in minutes; production-critical work runs the full suite and takes hours.

## When to use this vs the lighter alternatives

- `/issue-work` — single-agent quick pass. Use when the task is small and the quality bar is "merges cleanly".
- `/task-implement` — adaptive multi-persona orchestration. **Phase 0 runs first** and decides which specialist personas are actually needed based on a risk score. Low-risk local work might skip Cloud Architect, Security, and SRE entirely and finish quickly; production-critical work gets the full suite. If you're not sure whether you need the full workflow, use `/task-implement` — the routing step sizes it correctly.

The gap between the two is a spectrum, not a cliff. `/issue-work` is right for truly routine single-agent tasks; `/task-implement` covers everything from "a bit more rigour" up to "full production audit trail".

## The personas

Within combined phases, personas run sequentially; one Work Checker audits the whole phase at the end.

| Persona | Mandate | Conditional? | Reference doc | Posts comment as |
|---------|---------|--------------|----------------|------------------|
| **Principal Engineer (PE)** | Build it. Branch setup, implementation, lint+build, PR, review-feedback. | Always active | `references/role-principal-engineer.md` | `[Principal Engineer]` |
| **QA Engineer (QA)** | Make it testable; verify it's tested. | Always active | `references/role-qa-engineer.md` | `[QA Engineer]` |
| **Cloud Architect (CA)** | Identify and apply (or surface) infra/IaC/pipeline changes. | **Conditional** — skipped if no cloud deployment or IaC detected at LOW risk | `references/role-cloud-architect.md` | `[Cloud Architect]` |
| **UX/UI Designer (UX)** | Establish the design spec before implementation; verify the rendered output after. | **Conditional** — skipped if backend-only task at LOW risk | `references/role-ux-designer.md` | `[UX/UI Designer]` |
| **Security Engineer (Sec)** | Audit the diff for OWASP-shape defects. Bounces on Critical / High. | **Conditional** — skipped at LOW risk with no auth/data surface; lightweight at MEDIUM | `references/role-security-engineer.md` | `[Security Engineer]` |
| **Test Automation Engineer (TAE)** | Write the tests at the right level. | Always active | `references/role-test-automation-engineer.md` | `[Test Automation Engineer]` |
| **Site Reliability Engineer (SRE)** | Verify production-readiness — observability, alerting, runbook, rollback, capacity, failure modes, deploy safety. | **Conditional** — skipped if not deployed to any environment | `references/role-sre.md` | `[SRE]` |
| **Project Manager (PrjM)** | Process-diligence audit; bounce back if work isn't actually delivered. | Always active (scope varies by tier) | `references/role-project-manager.md` | `[Project Manager]` |
| **Product Manager (PdM)** | Outcome audit — does the user-facing result match the intent? Actually tries the feature. | Always active (scope varies by tier) | `references/role-product-manager.md` | `[Product Manager]` |
| **Work Checker (WC)** | Audit every active phase. Catches the ~80% of self-audit defects. | Runs after every active phase | `references/role-work-checker.md` | `[Work Checker]` |

## The reference material

| File | Purpose |
|------|---------|
| `references/role-principal-engineer.md` | PE charter, GitHub comment template, lazy-PE failure modes. |
| `references/role-qa-engineer.md` | QA charter, testable-AC patterns, AC→Test mapping, comment templates. |
| `references/role-cloud-architect.md` | CA charter, IaC change detection heuristic, when to escalate to human. |
| `references/role-ux-designer.md` | UX charter, design-system detection, design principles for projects with none, Playwright usage, Phase 2 + Phase 4 comment templates. |
| `references/role-security-engineer.md` | Sec charter, OWASP-shape threat-surface checklist, severity classification, comment templates. |
| `references/role-test-automation-engineer.md` | TAE charter, test pyramid application, per-test discipline. |
| `references/role-sre.md` | SRE charter, production-readiness checklist, severity classification. |
| `references/role-project-manager.md` | PrjM charter (process audit), audit checklist, bounce-back protocol. |
| `references/role-product-manager.md` | PdM charter (outcome audit), originating-requirement check, walk-the-feature discipline, bounce destinations. |
| `references/role-work-checker.md` | WC charter, universal + role-specific audit lists, "check your work" prompt. |
| `references/sdlc-pitfalls.md` | Named pitfalls + lazy-AI failure modes. |
| `references/solid-applied.md` | SOLID with smell+fix per principle; when not to apply. |
| `references/test-strategy.md` | Test pyramid, coverage philosophy, determinism rules. |
| `references/code-review-checklist.md` | The PE's self-review checklist. |
| `references/example-implementation-session.md` | A worked end-to-end run showing every phase. |

## Prerequisites

1. **Working directory is inside a git repo** with a GitHub remote.
2. **`gh` CLI authenticated** with write access to the repo. `gh auth status` shows `repo` scope.
3. **The issue exists.** The user passes the issue number (e.g. `/task-implement 42`). If they didn't, ask which issue.
4. **The issue has clear Acceptance Criteria** — authored by `/tasks-create-from-requirements` typically. If the issue is sparse, recommend `/requirements-validation` first.
5. **`main` is in a clean state.** Stash or commit any local uncommitted work before invoking.
6. **`docs/architecture/` is present** (recommended). If missing, surface this before starting — *"No architecture folder found. Personas will be implementing against unstated assumptions. Run `/platform-design` first?"* If the user says proceed, the personas treat the existing code as the de facto architecture.

---

## Phase 0 — Complexity routing (runs before everything)

**The orchestrator runs this step directly — no sub-agent spawned.** Reads the task and repo context, scores the risk, builds a run profile, and confirms with the user before Phase 1 begins. This is the only gate that can authorise skipping a phase.

### Step 1: Auto-detect signals

- `AGENTS.md`, `CLAUDE.md`, `README.md` — what kind of project? Local tool, web app, API service?
- IaC / deployment config presence: `vercel.json`, `firebase.json`, `serverless.yml`, `*.tf`, `cdk.json`, `Dockerfile`, `.github/workflows/*.yml` with deploy steps, `fly.toml`, `render.yaml`
- Payment library evidence: `stripe`, `paypal`, `braintree`, `plaid`, `adyen` in package manifests or imports
- Auth surface evidence: `clerk`, `auth0`, `supabase-auth`, `next-auth`, `passport`, `jwt` in manifests or imports
- Issue body / title — does the user say "local only", "personal project", "dev machine", "just for me"?

### Step 2: Ask what can't be auto-detected

If signals don't give a clear picture, ask in a single batch (not one at a time). Skip any question auto-detection already answered:

1. **Real users?** — "Do non-developer users interact with this app today, even a small number?"
2. **Real money?** — "Does this feature touch payment processing, billing, financial accounts, or real money in any form?"
3. **Public visibility?** — "Is this accessible to the public internet, or only on your local machine / internal network?"
4. **Embarrassment / legal exposure?** — "If a bug in this feature went live undetected, would users, customers, or the public see the impact?"

### Step 3: Score the risk tier

| Signal | Points |
|---|---|
| Real users (non-developers) using it today | +2 |
| Handles real money or financial data | +3 |
| Publicly visible to the internet | +2 |
| Bug would cause user-visible embarrassment or legal/regulatory exposure | +2 |
| Deployed to any cloud environment | +1 |
| Auth surface present (login, sessions, roles, permissions) | +1 |

**Total → tier:**
- **0–2: LOW** — local dev tool, personal project, no real users, not deployed
- **3–5: MEDIUM** — deployed or has real users, limited exposure
- **6+: HIGH** — public-facing, financial, or reputationally / legally sensitive

### Step 4: Build the run profile

| Phase | Personas | LOW | MEDIUM | HIGH |
|---|---|---|---|---|
| 1: Setup | PE + QA | ✅ | ✅ | ✅ |
| 2: Pre-build | CA + UX | Skip unless IaC/UI detected | ✅ if IaC/deploy or UI present | ✅ Always |
| 3: Build | PE | ✅ | ✅ | ✅ |
| 4: Review | UX + Sec | Skip if Phase 2 skipped | UX if UI; Sec lightweight | ✅ Always |
| 5: Tests | TAE + QA | ✅ | ✅ | ✅ |
| 6: Readiness | SRE | Skip if not deployed | ✅ if deployed | ✅ Always |
| 7: Audit | PrjM + PdM | Abbreviated | Full | Full |
| 8: Ship | PE | ✅ | ✅ | ✅ |

**Abbreviated scope (LOW tier):**
- PrjM Phase 7: Confirm work was done, tests pass, lint is green. Skip deep process audit.
- PdM Phase 7: Confirm the feature does what the issue asked. Skip the walk-from-entry-point and originating-requirement deep-read.

**MEDIUM Sec lightweight pass:** walk the diff for obvious auth/injection/secret issues; skip the full OWASP category sweep.

### Step 5: Present and confirm

```
Run profile for issue #<N>: <title>

Risk tier: <LOW / MEDIUM / HIGH>
Risk factors: <signals that contributed points>

Phases:
✅ Phase 1 — PE + QA: Setup
⏭ Phase 2 — CA + UX: Pre-build     [SKIPPED — no deployment config or UI surface detected]
✅ Phase 3 — PE: Build
⏭ Phase 4 — UX + Sec: Review       [SKIPPED — Phase 2 skipped]
✅ Phase 5 — TAE + QA: Tests
⏭ Phase 6 — SRE: Readiness         [SKIPPED — not deployed]
✅ Phase 7 — PrjM + PdM: Audit      [abbreviated scope]
✅ Phase 8 — PE: Ship

Confirm, or override any phase decision before we start.
```

Accept plain-language overrides (e.g. "skip CA but keep UX"). Lock the profile after confirmation — no changes after this point.

For each skipped phase, post a comment on the GitHub issue:
`[Orchestrator] Phase <N> (<Personas>) skipped — run profile: <one-line reason>`

---

## Workflow

```text
task-implement progress:
- [ ] Phase 0 — Orchestrator:  Complexity routing + run profile
- [ ] Phase 1 — PE + QA:       Setup (branch + ticket validation)
- [ ] Phase 2 — CA + UX:       Pre-build (arch review + design spec)   [conditional]
- [ ] Phase 3 — PE:            Build (implementation + lint/build)
- [ ] Phase 4 — UX + Sec:      Review (design review + security)       [conditional]
- [ ] Phase 5 — TAE + QA:      Tests (write + validate)
- [ ] Phase 6 — SRE:           Readiness                               [conditional]
- [ ] Phase 7 — PrjM + PdM:    Audit (process + outcome)
- [ ] Phase 8 — PE:            Ship (PR + merge + close)
- [ ] Phase 9 — PE:            Review feedback                         (opt-in)
- [ ] Summary
```

**After every active phase except Phase 0**, the Work Checker runs. For combined-persona phases, one Work Checker covers all personas' work in the phase together.

### How the orchestrator dispatches a persona

```
Agent({
  description: "<role>: Phase <N> — <phase name>",
  subagent_type: "claude",
  prompt: "
    You are acting as the <role> for issue #<N> in <owner>/<repo>.

    Your mandate, GitHub comment template, and failure modes are in
    references/role-<role-slug>.md — read it before doing anything.

    Phase context:
    - Issue: <number, title, link>
    - Branch: <branch name>
    - Previous phase comments on the issue: <copied verbatim>
    - This phase's specific objective: <what done looks like>

    Cap parallel tool calls at 3 at a time. Hard cap — not 'try to be modest'.

    When complete, post a GitHub comment on the issue as `[<role>]` per your
    role's template. Then return a structured summary:
      - Did you complete the phase? (yes / no — if no, why)
      - What you produced (commits, edits, comments)
      - Any pushback or surprises
  "
})
```

---

## Concurrency and rate limits

Phases run **strictly sequentially** — never parallel personas. Even single-persona runs can trip Anthropic's shared-capacity rate limit: *"Server is temporarily limiting requests"*.

- **Per-agent tool-call cap.** Each persona's brief includes: *"Cap parallel tool calls at 3 at a time. Hard cap."*
- **Back-off on rate-limited responses.** Three retries with doubling waits: **60s → 120s → 240s**. After the third retry still fails, post an `[Orchestrator]` "Hit shared-capacity rate limit; pausing — resume in 10 minutes" comment and stop.
- **Inter-phase pause.** 5 seconds between phases and between a persona finishing and its Work Checker starting.

| Condition | Response |
|---|---|
| Shared-capacity rate limit (transient) | Wait + retry per back-off. Never skip work. |
| Daily / monthly account usage limit | Post `[Orchestrator]` comment, stop. Resume later. |
| Context pressure / "running low on tokens" | Never a legitimate excuse. Pause-and-resume. |

---

### Phase 1 — Setup: branch + ticket validation

Two personas run sequentially.

**PE — branch setup:**
- `git fetch origin && git checkout main && git pull --ff-only`
- `git checkout -b <issue-number>-<short-slug>`
- `git push -u origin <branch>`
- Posts `[Principal Engineer]` comment: *"Branch `<name>` created from main at `<sha>`."*

**QA — ticket validation:**
- Reads the issue + linked requirement(s) in `docs/requirements/`.
- For each AC clause, applies the testable-AC test (see `role-qa-engineer.md`).
- Edits the issue body via `gh issue edit` if AC needs tightening.
- Identifies test seams and test data needs.
- Posts `[QA Engineer]` comment per Phase 1 template.

**Work Checker checks:** branch name format and existence; no hedge words remaining in AC; test data identified; no AC clause missing.

---

### Phase 2 — Pre-build: arch review + design spec [conditional per run profile]

Two personas run sequentially. Skip entirely if the run profile says so.

**CA — cloud architecture review:**
- Reads the issue + requirement(s).
- Reads `docs/architecture/` (especially `01-stack-and-hosting.md`, `03-external-integrations.md`, `04-decisions.md`).
- Walks the project's IaC files. Applies the heuristic in `role-cloud-architect.md`.
- For changes within reach: edits IaC + commits on the branch (`chore(infra): ...`).
- For human-needed changes: posts a structured checklist comment on the issue.
- Posts `[Cloud Architect]` comment. Most tasks: *"No IaC / pipeline / DevOps changes needed."* Don't manufacture work.

**UX — design specification:**
- Reads the issue + requirement(s) + any existing `docs/design/` + CA's comment from this phase.
- Reads `docs/architecture/` — system type shapes what surfaces exist (web pages, CLI, API, mobile).
- Detects design-system artefacts (Storybook, design tokens, Figma reference, component library).
- For UI tasks: produces a full design spec covering every state (default / hover / focus / active / disabled / loading / empty / error / success), responsive behaviour, accessibility plan, motion, performance.
- For backend-only tasks: spec covers response shape, error messages, log structure, client-facing semantics.
- If no design system exists: includes a "Design principles (initial)" block — typographic scale, palette, spacing, radius, shadows.
- Posts `[UX/UI Designer]` comment per the Phase 2 template in `references/role-ux-designer.md`.

**Work Checker checks:** CA didn't claim "no changes needed" without reading IaC; env vars not added to one place only; UX covered every state including error / loading / empty; copy specified; responsive plan; a11y plan; design tokens reused from existing system if one exists.

---

### Phase 3 — Build: implementation + lint/build

One persona (PE) owns implementation through to a clean verify chain — lint and build are the final step, not a separate phase.

**PE:**
- **Reads `docs/architecture/`** — implementation must match the recorded choices. If a task would deviate, flag as a candidate ADR before continuing.
- Reads the codebase to understand conventions.
- Reads the Phase 2 UX spec from the issue comments (if Phase 2 ran).
- Implements in small, atomic commits with Conventional Commits messages.
- If a preparatory refactor would make the change cleaner, does it as its own commit first.
- **For any user-facing UI surface, invokes `/frontend-design`** — it produces distinctive, production-grade interfaces rather than generic scaffold output.
- Applies SOLID where it earns its keep.
- **As the final step before signaling done**, runs the full verify chain — reads `AGENTS.md` / `CLAUDE.md` for the documented chain; if undocumented:
  - `<pm> lint`
  - `<pm> type-check` (frequently NOT included in `test:unit` — run explicitly)
  - `<pm> build`
  - `<pm> test:unit`
- Re-runs until every command exits clean. Fixes at root cause — no `// eslint-disable`, no `// @ts-ignore` / `any`, no test-skipping.
- Posts `[Principal Engineer]` comment: what was done, commit shas, every verify command and its exit status.

**Work Checker checks:** TODO/FIXME, swallowed exceptions, magic numbers, commented code, debug prints, atomic commits; no `// eslint-disable` added to silence; no `any` / `# type: ignore` added without justification; no warning-silencing config changes; all verify commands reported green.

---

### Phase 4 — Review: design review + security [conditional per run profile]

Two personas run sequentially. Skip entirely if the run profile says so. If only one sub-phase applies (e.g. UI present but LOW risk → UX review only, Sec skipped), run the applicable persona and note the skip in the phase comment.

**UX — design review:**
- Re-reads the Phase 2 design spec.
- For UI tasks: starts the dev server (or uses Playwright), walks each state from the spec, captures screenshots, runs `@axe-core/playwright` for accessibility.
- For backend-only tasks: reviews the response shape and error messages against the spec.
- Posts `[UX/UI Designer]` comment per the Phase 4 template in `references/role-ux-designer.md` — either **APPROVED** or **Drift from spec found** with specific items.
- Drift bounces back to PE (Phase 3). Bounce limit: 3 per session, then escalate.

**Sec — security review:**
- Reads `docs/architecture/` — knows the threat model and trust boundaries.
- Reads the diff (`git diff origin/main...HEAD`).
- Walks every applicable category from `role-security-engineer.md`: authn/authz, input validation, secrets, crypto, session/CSRF, CORS/headers, dependency sniff, logging, rate limiting. For inapplicable categories: says so explicitly with a reason — silence is not proof.
- Classifies findings: Critical / High / Medium / Low / Informational.
- **Critical / High**: bounces back to PE (Phase 3) with file:line references and one-line remediation per finding.
- **Medium / Low**: posts findings for the PR record, does not block.
- Posts `[Security Engineer]` comment. Most tasks: a clean walk with informational notes only. Don't manufacture findings.

**Work Checker checks:** UX actually verified states (not just diff-read); Playwright was actually run if applicable; axe-core results present; no "looks fine" without specifics; Sec named every category walked or said N/A with reason; authz check not skipped on a new endpoint; secret-in-diff check ran; dependency additions sniffed.

---

### Phase 5 — Tests: write + validate

Two personas run sequentially.

**TAE — write tests:**
- Reads the diff.
- Identifies which level (unit / integration / E2E) each piece needs per `references/test-strategy.md`.
- Writes tests with seeded factories / frozen clocks / mocked I/O.
- For E2E: writes Playwright tests on critical user-visible paths (informed by UX's Phase 4 review if applicable).
- Runs the tests locally; they must pass.
- Commits with `test: ...` Conventional Commits.
- Posts `[Test Automation Engineer]` comment.
- If code is hard to test (untestable seams): flags it; orchestrator bounces back to PE (Phase 3) to refactor.

**QA — validate tests:**
- Re-reads the AC.
- Walks every test the TAE added — confirms each tests a real outcome.
- Builds the AC → Test map (table per template in `role-qa-engineer.md`).
- Runs the full test suite. If any flake: identifies the source (random data, real clock, real network) and fixes or bounces back to TAE.
- Posts `[QA Engineer]` comment with the AC → Test map and pass/fail status.

**Work Checker checks:** AC → Test map complete; no uncovered AC clauses; no truthy assertions; no mock-the-world tests; no flaky timing; no hardcoded data; no `.skip` without justification; no E2E for things that should be unit; no flake silently ignored.

---

### Phase 6 — Readiness: SRE [conditional per run profile]

Skip entirely if the run profile says so.

**SRE:**
- Reads `docs/architecture/` — runtime topology and operational ADRs.
- Reads the diff for new code paths, external calls, background jobs, migrations.
- Walks every applicable category in `role-sre.md`: observability (logs/metrics/traces), alerting (new failure modes covered), runbook + rollback path (`git revert + redeploy` clean?), capacity + cost sanity, failure modes (timeouts, retries, graceful degradation), deploy safety (env vars in all envs, canary-compatibility). Explicit "N/A — reason" for inapplicable categories.
- Classifies findings: Blocker / High / Medium / Low.
- **Blocker / High**: bounces back to PE (Phase 3) with specific gap.
- **Medium / Low**: notes in comment, does not block.
- Posts `[SRE]` comment.
- **For deployed apps: checks the live endpoint** — fetches the URL and reads the latest deploy/runtime logs. Build-time success and runtime success are two separate gates.

**Work Checker checks:** no "production ready" without naming categories walked; observability not skipped on new code paths; no timeout-less external calls approved; no irreversible migrations approved; SLO-less projects flagged not waved through.

---

### Phase 7 — Audit: PrjM + PdM

Two personas run sequentially. This is the final gate before shipping.

**PrjM — process audit:**
- Reads the issue (DoD + AC).
- Reads every prior `[<Role>]` comment posted on the issue.
- Inspects the diff via `git diff origin/main...HEAD`.
- **Runs the test suite themselves** to verify "green" claims.
- **Runs lint + build themselves** to verify "green" claims.
- **For deployed apps: checks the live endpoint** — fetches the URL and reads latest deploy/runtime logs. A green build doesn't guarantee a running function.
- Walks the audit checklist in `role-project-manager.md`.
- Posts result: **APPROVED** or a bounce-back comment naming the responsible role and specific gaps.
- Bounce limit: 3 per role per session, then escalate to user.

**PdM — outcome audit:**
- Reads the originating requirement in `docs/requirements/` (via `Implements:` references in the issue).
- Reads the issue body + the UX Phase 4 comment (if applicable).
- **Actually uses the feature.** Starts from the app's natural entry point — `/` or the main navigation — not the feature's direct URL. If the feature isn't reachable from existing navigation, that's a bounce-worthy gap. Checks that empty states have a meaningful next step.
- Walks the outcome checklist in `role-product-manager.md`: intent, experience, scope, trade-offs surfaced, feedback loop.
- Posts result: **APPROVED**, a bounce-back (specific gap), or a recommendation for `/requirements-rework` (requirement itself was wrong — hard exit, does not bounce within this session).
- Bounce limit: 3 per role per session.

**Work Checker checks:** PrjM didn't just read the diff — claims verified; PrjM didn't drift into outcome-auditing; PdM actually tried the feature (not just diff-read); requirement actually read by PdM; fit-criterion measurability addressed; no taste-pedantry passed off as defect.

---

### Phase 8 — Ship: PR + merge + close

**PE:**
- Pushes any final commits.
- `gh pr create --title "<type>(<scope>): <subject>" --body "$(cat <<'EOF' ...)"` — body following the PR template in `role-principal-engineer.md`.
- Self-reviews the diff line-by-line per `code-review-checklist.md`. Fixes anything surfaced; commits and pushes.
- Adds the **Self-review** section to the PR body listing what the pass found and fixed.
- Posts `[Principal Engineer]` comment with the PR URL.
- **Merges:** `gh pr merge <num> --squash --delete-branch`. If the repo has branch-protection CI, use `--auto`.
- **Closes the issue** if not auto-closed by merge: `gh issue close <N>`.

**Work Checker checks:** PR description complete; Self-review section present; `Closes #N` link in PR; PR merged; issue closed.

---

### Phase 9 — Review feedback (opt-in)

**Opt-in only.** Runs when the user explicitly asked for human review before merge (e.g. invoked with `--review`). In the default flow Phase 9 is skipped entirely.

If the user requested review: the skill pauses after Phase 8 PR creation (without merging). User re-invokes `/task-implement <issue>` after review lands; the orchestrator detects the existing PR and open review comments and runs Phase 9.

**PE:**
- `gh pr view <num> --comments` — reads every review comment and thread.
- For each: classifies as `fix` / `disagree` / `clarify`.
- `fix` → makes the change, commits with `fix(review): <subject>`, pushes.
- `disagree` → replies on the PR comment with the reasoning. Does not resolve the thread until the reviewer agrees.
- `clarify` → asks a follow-up on the comment.
- Resolves merge conflicts: `git fetch origin && git rebase origin/main` (preferred) or merge. `git push --force-with-lease` if rebase.
- Posts `[Principal Engineer]` comment summarising what was addressed.
- Merges the PR after reviewer approves.

**Work Checker checks:** every legitimate comment addressed; no comments silently dismissed; merge conflicts cleanly resolved.

---

### Summary

Final summary by the orchestrator (not a persona) posted to the GitHub issue, plus a terminal summary to the user:

```markdown
**[Orchestrator]** Implementation session complete.

- Branch: `<branch-name>` (deleted)
- PR: <URL> (merged)
- Commits: <N>
- Tests added: <unit-count> unit / <int-count> integration / <e2e-count> E2E
- Risk tier: <LOW / MEDIUM / HIGH> (score: <N>)
- Phases skipped: <list from run profile, or "none">
- Bounce-backs during session: <count>
- Human-required infra checklist items: <count> (see CA comment if Phase 2 ran)

Issue closed. Done.
```

Terminal summary: PR link, time elapsed, risk tier + phases skipped, bounce-back count, WC findings caught and fixed.

---

## Work Checker pattern

After **every active phase except Phase 0**, the orchestrator spawns the Work Checker. For combined-persona phases, one WC covers all work produced in that phase.

```
Agent({
  description: "Work Checker: audit Phase <N> (<personas>)",
  subagent_type: "claude",
  prompt: "
    You are the Work Checker. The following personas just completed Phase <N>
    for issue #<N> on <owner>/<repo>: <list of personas in this phase>.

    Read references/role-work-checker.md — the universal checklist + the
    role-specific 'Lazy-<role> failure modes' for each persona in this phase.

    Audit all artefacts produced:
    - GitHub comments posted this phase: <comment texts>
    - Diff since last phase: <relevant files>
    - New commits: <commit shas>

    Return: 'clean' (one-line summary) or 'defects' (numbered list, specific).
  "
})
```

If WC returns **clean**: proceed to the next active phase.

If WC returns **defects**: return to the responsible persona in the same phase with the defect list. That persona addresses each defect; WC re-audits. **Bounce-back limit per WC pass: 3.** After 3 consecutive defect findings on the same phase, stop and escalate to the user.

Hit rate: ~80% of phases produce defects on first WC pass. Backed by Madaan et al.'s **Self-Refine** (~20% absolute quality lift — https://arxiv.org/abs/2303.17651).

---

## State the orchestrator tracks

```text
{
  "issue_number": 42,
  "owner_repo": "<owner>/<repo>",
  "branch": "42-add-rate-limit-to-signin",
  "pr_number": null,            // until Phase 8
  "current_phase": 3,
  "risk_tier": "LOW",           // set in Phase 0; LOW / MEDIUM / HIGH
  "risk_score": 2,
  "run_profile": {              // set in Phase 0; locked after user confirms
    "Phase 2 (CA+UX)":  "SKIPPED — no deployment config or UI surface",
    "Phase 4 (UX+Sec)": "SKIPPED — Phase 2 skipped",
    "Phase 6 (SRE)":    "SKIPPED — not deployed"
  },
  "bounce_back_counts": {
    "PE": { "Phase 3": 1 }
  },
  "wc_findings_total": 4
}
```

---

## Strict non-goals

- **No unilateral phase skipping.** Phases may only be skipped when Phase 0's complexity routing explicitly authorises it, with the reason in the run profile and an audit-trail comment on the issue. Skipping for any other reason — speed, context pressure, "it seems unnecessary", rate limit, token budget — is not allowed. Surface any additional skip reasoning to the user during Phase 0 and get sign-off before locking the profile.
- **No limit-citing shortcuts.** Daily usage limits, rate limits, context pressure, "running low on tokens", or session length are **never** legitimate reasons to skip a phase, skip the Work Checker, mark a phase done without running it, or declare the task complete with phases outstanding. The correct response is to **pause and report**: post an `[Orchestrator]` comment naming the phase in flight and what's left, then stop. The user resumes later — every persona's prior comment is the durable state.
- **No skipping the merge.** In the default flow the skill merges the PR at the end of Phase 8. If the user asked for human review, the skill pauses before merging — but never silently drops the merge step.
- **No auto-fixing across roles.** The Work Checker reports; it doesn't fix. The role fixes.
- **No infinite bounce-back.** 3 strikes per role per session, then escalate to the user.
- **No multi-issue batching.** One issue per session.
- **No requirement rework.** If implementation reveals the requirement is wrong, PE stops and recommends `/requirements-rework`.

---

## Edge cases

- **Issue doesn't exist.** `gh issue view <N>` fails — stop.
- **Issue is closed.** Ask the user to reopen before starting.
- **Branch already exists** (resuming a prior partial session). Detect: `git ls-remote --heads origin <branch>`. Ask: resume on this branch, or delete and restart?
- **PR already exists** for this branch. Resume from Phase 9 (review feedback) or Phase 8 (re-self-review) as appropriate.
- **Bounce-back limit hit.** Stop. Post `[Orchestrator]` comment summarising the situation.
- **Issue has no AC.** Phase 1 (QA) detects this. If AC can't be inferred, stop and recommend `/requirements-validation` first.
- **Project has no test setup.** TAE in Phase 5 detects this. PrjM in Phase 7 treats "no tests added" as a defect unless the project genuinely has no testing infrastructure.
- **Project has no observability.** SRE in Phase 6 flags minimal logging as a follow-up issue.
- **Project has no SLOs.** SRE in Phase 6 surfaces this — don't manufacture SLOs in-session.
- **Backend-only task with no UI surface.** UX in Phase 2 writes a spec for response shape / error messages / observability semantics; UX in Phase 4 reviews those. Both still happen if Phase 2 is active.
- **No design system in the repo.** UX in Phase 2 defines initial design principles — scale, palette, spacing, radius, shadows.
- **Playwright not set up.** UX and TAE detect this. Proceed with available verification; flag Playwright setup as a follow-up issue.
- **CI is red on main.** Stop. Don't add work to a broken main.
- **User aborts mid-session.** Branch + commits remain. Last `[Orchestrator]` comment indicates which phase was in flight. Re-invoking resumes from there.
- **Long-running session timeout.** Resumable from the GitHub comment trail — each persona's comment is the durable state.

---

## Lifecycle tracker

This skill owns the **Implementation** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after Phase 0 completes and the user confirms the run profile), set the `Implementation` line to ⏳ (in progress).
- **When this skill completes successfully**, set the `Implementation` line to ✅ (done).

Touch only the `Implementation` line — leave every other stage exactly as found.
