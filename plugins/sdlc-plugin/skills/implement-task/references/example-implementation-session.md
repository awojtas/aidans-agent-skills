# Worked Example: Implementing issue #42

A condensed run of `/implement-task 42` on a hypothetical issue: *"2.1 Implement `POST /api/auth/signin` endpoint with email+password"*. Issue body says it implements FR-AUTH-001 and FR-AUTH-002. Phase 0 through Phase 10. Each persona's GitHub comment is shown verbatim; the orchestrator's state shown inline.

The example is condensed (no full code shown) — purpose is to demonstrate the orchestration pattern, the comment trail, the Work Checker findings, and the Project Manager bounce-back.

---

## Phase 0 — PE: Branch setup

**Orchestrator state:** `{ issue: 42, current_phase: 0 }`.

PE spawns. Reads `references/role-principal-engineer.md`. Does:

```bash
git fetch origin
git checkout main
git pull --ff-only
git checkout -b 42-add-signin-endpoint
git push -u origin 42-add-signin-endpoint
```

PE posts:

> **[Principal Engineer]** Phase 0 — Branch setup complete.
>
> Branch `42-add-signin-endpoint` created from `main` at `a3f8d11` and pushed.
> Ready for Phase 1.

**Work Checker** spawns. Checks: branch name pattern (`<issue>-<slug>` ✓), branch exists locally and remotely (✓), main was clean before checkout (✓). Returns **clean**.

WC posts:

> **[Work Checker]** Audit of Principal Engineer's Phase 0 work — clean. Checked: branch name format, remote existence, clean working tree at switch.

---

## Phase 1 — QA: Ticket validation

**Orchestrator state:** `current_phase: 1`.

QA spawns. Reads issue #42's body. AC reads:

```
- [ ] Given valid email + password, when POST /api/auth/signin, then 200 + session cookie
- [ ] Given invalid credentials, when POST /api/auth/signin, then 401 with clear error
- [ ] Sign-in is reasonably fast
- [ ] Too many failed attempts trigger throttling
```

QA spots two vague clauses ("reasonably fast", "too many"). Edits the issue:

```
- [ ] Given valid email + password, when POST /api/auth/signin, then 200 + session cookie
- [ ] Given an unregistered email OR a wrong password, when POST /api/auth/signin, then 401 with body `{ "error": "invalid_credentials" }` (same response for both — no side-channel)
- [ ] P95 of POST /api/auth/signin under 100 req/s steady-state load is ≤ 500ms (NFR-PERF-001)
- [ ] After 5 failed attempts in 15 minutes from the same IP, the 6th attempt returns 429 for 1 hour (FR-AUTH-002)
```

QA posts:

> **[QA Engineer]** Phase 1 — Ticket validation complete.
>
> AC reviewed: 4 clauses. Tightened AC2 (no-side-channel requirement, explicit response body); replaced AC3 "reasonably fast" with a measurable p95 budget; replaced AC4 "too many failed attempts" with explicit 5-in-15-min / 1-hour ban.
>
> Test seams identified: handler unit-testable with stubbed user repo; integration test against testcontainers Postgres; perf check via load-test harness.
>
> Test data: need 3 user fixtures (valid, locked, deleted). Will be created in Phase 4 by TAE; QA validates in Phase 5.
>
> Ready for Phase 2.

**WC** spawns. Checks: no hedge words remain in AC ✓, test seams named ✓, AC clauses count matches DoD ✓. **Clean.**

---

## Phase 2 — CA: Cloud architecture review

CA spawns. Reads issue + project IaC (`terraform/`). Walks the decision heuristic:

- New external service? No.
- New persistent store? No (existing users table).
- New env var? Yes — `AUTH_RATE_LIMIT_REDIS_URL` for the rate-limiting backing store.
- New IAM permission? No.
- ...

CA edits `terraform/envs/dev.tfvars`, `staging.tfvars`, `prod.tfvars` to add the new env var (pointing at existing Redis instances per env). Commits.

CA posts:

> **[Cloud Architect]** Phase 2 — Cloud architecture review complete.
>
> Required IaC changes — done in this branch:
> - `terraform/envs/dev.tfvars` — added `auth_rate_limit_redis_url` (existing dev Redis) (commit `4e2c7a1`)
> - `terraform/envs/staging.tfvars` — same against staging Redis (commit `4e2c7a1`)
> - `terraform/envs/prod.tfvars` — same against prod Redis (commit `4e2c7a1`)
>
> No human-required changes — the Redis instances already exist; no new accounts or secrets needed.
>
> Ready for Phase 3.

**WC** spawns. Checks: env var added to *all three* env tfvars (✓ — common miss), no secrets hardcoded (✓), no oversized infra additions (✓). **Clean.**

---

## Phase 3 — PE: Implementation

PE spawns. Reads codebase. Plans the change.

Notices: the existing `apps/web/api/auth/login.ts` (legacy name) has the handler logic but no rate-limit middleware. **Preparatory refactor needed**: extract the rate-limit middleware as a generic util the new signin endpoint can also use.

PE does, in order:

1. `refactor: extract rate-limit middleware to lib/rate-limit.ts` (commit A — pure refactor, no behaviour change, the legacy `login.ts` keeps working)
2. `feat(auth): add POST /api/auth/signin handler` (commit B — uses the new util)
3. `feat(auth): wire signin into the API router` (commit C — exposes the route)

Pushes commits. Posts:

> **[Principal Engineer]** Phase 3 — Implementation complete.
>
> Commits:
> - `4f12e8a` refactor: extract rate-limit middleware to lib/rate-limit.ts
> - `c8d2916` feat(auth): add POST /api/auth/signin handler
> - `a05b3d3` feat(auth): wire signin into the API router
>
> Two Hats: the rate-limit refactor is its own commit (commit A) so it can be reviewed independently. The signin handler (commit B) uses the new util.
>
> Decisions: returned `invalid_credentials` for both unregistered-email and wrong-password cases (no side channel, per AC2). Used a constant-time string comparison for the password hash check.
>
> Ready for Phase 4 (tests).

**WC** spawns. Reads the diff. Findings:

- ❌ `apps/web/api/auth/signin.ts:42` — `console.log("user signed in", user.id)` left in.
- ❌ `apps/web/api/auth/signin.ts:78` — `TODO: handle session rotation` comment without an issue tracking it.

WC posts:

> **[Work Checker]** Audit of Principal Engineer's Phase 3 work — defects found.
>
> 1. **`apps/web/api/auth/signin.ts:42`** — `console.log("user signed in", user.id)` is debug output, should be removed (or replaced with a structured log call if telemetry is wanted).
> 2. **`apps/web/api/auth/signin.ts:78`** — `// TODO: handle session rotation` — either implement now or open a tracking issue and reference it in the comment.
>
> Principal Engineer: please address. Will re-audit when fixed.

**Orchestrator state:** `bounce_back_counts.PE["Phase 3"] = 1`.

PE re-spawns with the defect list. Removes the `console.log`. The session-rotation TODO is genuinely out-of-scope for this task — PE creates issue #67 "Session rotation policy for signin" and replaces the TODO with `// see #67`. Commits as `chore: remove debug, link TODO to tracking issue (commit D)`.

PE posts an updated comment.

**WC** re-spawns. Re-audits. **Clean.**

---

## Phase 4 — TAE: Tests

TAE spawns. Reads the diff. Plans:

- Unit tests for the handler logic (validation, password check, error mapping) — many.
- Integration test against testcontainers Postgres for the happy path + 401 + rate-limit kick-in — three.
- E2E test for the user-visible signin flow (login form → dashboard) — one.

TAE writes the tests. Uses `faker.seed(42)`, frozen system clock at `'2026-05-13T10:00:00Z'`, mocked Redis client (in-memory) for unit tests, real Redis via testcontainers for integration. Runs locally — all pass.

Notices: the handler reads `process.env.AUTH_RATE_LIMIT_WINDOW_SECONDS` directly inside the handler function — hard to test cleanly. Flags back to PE: *"please refactor to accept the window as a parameter (default to the env value)."*

**Orchestrator:** This is a TAE-to-PE bounce-back during Phase 4, not a defect from WC. The orchestrator dispatches PE to do the small refactor, then resumes TAE.

PE does the refactor, commits as `refactor(auth): accept rate-limit window as parameter for testability`. TAE resumes; tests now cleaner.

TAE posts:

> **[Test Automation Engineer]** Phase 4 — Tests written.
>
> Added 14 unit tests, 3 integration tests, 1 E2E test.
>
> Coverage approach:
> - Unit: validation helpers, password-check (constant-time), rate-limit math, error mapping, request shape parsing, response shape building
> - Integration: signin happy path against testcontainers Postgres; 401 returns same body for unregistered-email vs wrong-password; 429 fires at attempt 6 within 15min window
> - E2E: happy-path signin from `/signin` page to `/dashboard` redirect
>
> Test data: 3 user fixtures in `tests/fixtures/users.json` (valid, locked, deleted). Faker seeded with 42, system clock frozen to 2026-05-13T10:00:00Z.
>
> Suite: passes locally (`pnpm test`). 18 new tests, all green.
>
> One PE refactor requested mid-phase (extract rate-limit window as parameter) — done, applied to tests cleanly.
>
> Ready for Phase 5.

**WC** spawns. Checks tests for truthy assertions (none — every test asserts a specific outcome), mock-the-world tests (none — mocks are on collaborators only), `Math.random()` driving outcomes (none), `.skip` without justification (none), E2E for things that should be unit (no — E2E covers the user-visible happy path, all other tests are at the right level). **Clean.**

---

## Phase 5 — QA: Test validation

QA spawns. Walks every test. Builds the AC → Test map:

| AC clause | Test |
|-----------|------|
| AC1: Given valid creds, when POST, then 200 + cookie | `signin.test.ts > authenticates valid email + password` + `signin.integration.test.ts > happy path returns session cookie` |
| AC2: Same 401 for unregistered email OR wrong password | `signin.integration.test.ts > unregistered email and wrong password return same body` |
| AC3: p95 ≤ 500ms at 100 req/s | `perf.benchmark.test.ts > signin p95 under steady load` *(runs in nightly perf job, not PR CI)* |
| AC4: 5 failed → 6th 429 for 1h | `signin.integration.test.ts > rate-limits after 5 failed attempts; 1-hour ban` |

Runs the suite. All green. No flake.

QA posts:

> **[QA Engineer]** Phase 5 — Test validation complete.
>
> Tests added: 18. Coverage: AC1 ✓ AC2 ✓ AC3 ✓ (nightly perf job) AC4 ✓
>
> | AC | Test |
> |----|------|
> | AC1 | `signin.test.ts > authenticates valid email + password` + integration happy-path |
> | AC2 | `signin.integration.test.ts > unregistered email and wrong password return same body` |
> | AC3 | `perf.benchmark.test.ts > signin p95 under steady load` (nightly; not gating this PR) |
> | AC4 | `signin.integration.test.ts > rate-limits after 5 failed attempts; 1-hour ban` |
>
> Test run: all green on first run, no flake observed across 3 consecutive runs.
>
> Test data: 3 fixtures added (`tests/fixtures/users.json`), factory seeded.
>
> Ready for Phase 6.

**WC** spawns. Checks: every AC has at least one test ✓, AC3 perf test exists but won't gate this PR (acceptable — performance budgets are typically nightly), no skipped tests, no flake silently ignored. **Clean.**

---

## Phase 6 — PE: Lint + build

PE spawns. Runs `pnpm lint`. 2 warnings — both in the new code (one unused import, one prefer-const). Fixes both.

Runs `pnpm build`. Clean.

Re-runs both. Clean.

Commits as `chore: lint fixes (commit E)`. Pushes.

PE posts:

> **[Principal Engineer]** Phase 6 — Lint + build complete.
>
> Lint: ran `pnpm lint`. 2 warnings fixed (1 unused import in signin.ts, 1 prefer-const in rate-limit.ts). Now clean.
>
> Build: ran `pnpm build`. Clean.
>
> Re-ran both after fixes — clean.
>
> Commit: `e91a4b2` chore: lint fixes
>
> Ready for Phase 7 (PM diligence audit).

**WC** spawns. Checks: no `// eslint-disable` was added (✓ — lint was actually fixed), no `any` / `# type: ignore` added in this diff, no warning-silencing config changes. **Clean.**

---

## Phase 7 — PM: Diligence audit

PM spawns. Reads issue #42's DoD + AC. Reads all 6 phase comments above. Inspects the diff.

Walks the audit checklist:

- DoD items: 6/6 verified done.
- AC → Test map: 4/4 AC clauses have tests (per QA's Phase 5 comment, cross-checked with the diff).
- Lint + build: PM runs both themselves. Both green.
- Commits: 6 commits, all Conventional Commits, atomic (one logical change each). ✓
- TODO/FIXME: PM greps the diff. None added in this PR (the original TODO was replaced with a reference to issue #67 — verified that issue exists).
- Tests: PM runs the suite. All green.
- CA's human-required checklist: none (CA verified no human-required infra changes needed).

PM posts:

> **[Project Manager]** Phase 7 — Diligence audit complete. **APPROVED.**
>
> Checked:
> - DoD checklist: 6/6 items verified done.
> - AC → Test mapping: 4/4 AC clauses have tests; verified against QA's map and the diff.
> - Lint + build: ran `pnpm lint && pnpm build`, both green.
> - Commits: 6 atomic commits, Conventional Commits format, no WIP/typo commits.
> - No TODO/FIXME/debug-prints added in this diff (one original TODO replaced with link to tracking issue #67).
> - Tests: ran `pnpm test`, 18 new tests pass, no flake across 3 runs.
> - CA: no human-required infra changes; Redis already provisioned in all envs.
>
> Issue ready for PE Phase 8 (PR + self-review).

**WC** spawns. Checks: PM's claims itemised (✓), PM ran the tests themselves (✓ — referenced specific output), missed TODO scans (✓ — caught the issue-#67 link). **Clean.**

---

## Phase 8 — PE: PR + self-review

PE spawns. `gh pr create` with the PR template body. Self-reviews the diff line-by-line in the GitHub UI (mental model — actually via `gh pr diff` and reading carefully). Walks the code-review checklist.

Finds during self-review: the `rate-limit.ts` doc comment is missing a `@param` line for the new `windowSeconds` parameter. Fixes. Commits as `docs: complete jsdoc on rate-limit util`.

Adds the Self-review section to the PR body:

```markdown
## Self-review

I've reviewed this diff myself before requesting human review. The review pass found and fixed:
- Missing `@param` jsdoc on the new `windowSeconds` parameter (commit `f3a8d1c`).
```

PE posts:

> **[Principal Engineer]** Phase 8 — PR + self-review complete.
>
> PR: https://github.com/awojtas/example/pull/89
>
> PR body follows the template; Self-review section included. Self-review found 1 issue (missing jsdoc on the new parameter), fixed in commit `f3a8d1c`.
>
> CI is running. Will report green/red when complete.
>
> Ready for human review.

**WC** spawns. Checks: PR description follows the template (✓), Closes #42 link present (✓), Self-review section is honest (lists what was actually found, not "self-review clean" when there were fixes), CI status reachable. **Clean.**

---

## Phase 9 — Pending

Phase 9 only runs if a human reviewer comments. The orchestrator pauses here. The user re-invokes `/implement-task 42` after human review lands to resume.

---

## Phase 10 — Summary + handoff

Orchestrator posts:

> **[Orchestrator]** Implementation session complete (Phase 0-8). Awaiting human review.
>
> - Branch: `42-add-signin-endpoint`
> - PR: https://github.com/awojtas/example/pull/89
> - Commits: 7 (3 feat, 2 refactor, 1 chore, 1 docs)
> - Tests added: 14 unit / 3 integration / 1 E2E
> - Bounce-backs during session: 1 (PE Phase 3 — debug log + bare TODO)
> - Work Checker findings caught: 2 (the debug log + the bare TODO, both fixed in commit D)
> - Human-required infra checklist items: 0
> - Self-review found and fixed: 1 (missing jsdoc)
>
> PR is ready for human review and merge.
>
> When review feedback lands, re-invoke `/implement-task 42` to run Phase 9 (address feedback).

Terminal summary to the user matches the above.

---

## What this example demonstrates

1. **The Work Checker earns its keep.** Phase 3 had 2 defects the PE missed (debug log + bare TODO). The WC caught both. Without the WC, those would have either shipped or been caught later in human review.
2. **The Project Manager is satisfiable.** Phase 7 approved on first pass. That's the desired outcome — the PM's existence as an audit gate is what makes the prior phases tight enough to pass on first pass.
3. **Bounce-backs are normal and named.** 1 bounce-back is healthy. 3+ in the same phase = orchestrator escalates.
4. **The TAE-to-PE handoff is fluid.** When TAE found the handler was hard to test, the orchestrator dispatched PE for a small refactor mid-phase rather than blocking the entire flow. The Two Hats discipline made this clean.
5. **The audit trail is durable.** Every persona's comment is on the issue. Six months later, anyone can read the issue and reconstruct exactly what happened, who did what, and what the audit findings were.
6. **The PR has a Self-review section.** That's the visible artefact to the human reviewer that this skill took the work seriously.
