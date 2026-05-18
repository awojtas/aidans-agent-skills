# Worked Example: Implementing issue #42

A condensed run of `/task-implement 42` on a hypothetical issue: *"2.1 Implement `POST /api/auth/signin` endpoint with email+password"*. Issue body says it implements FR-AUTH-001 and FR-AUTH-002. Phase 0 through Phase 15. Each persona's GitHub comment is shown verbatim; the orchestrator's state shown inline.

The example is condensed (no full code shown) — purpose is to demonstrate the orchestration pattern, the comment trail, the Work Checker findings, the Project Manager bounce-back, the Security and SRE per-feature gates, the Project Manager (process) / Product Manager (outcome) split, and how the UX Designer's two phases handle a backend-only task without manufacturing work.

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
> Test data: need 3 user fixtures (valid, locked, deleted). Will be created in Phase 7 by TAE; QA validates in Phase 8.
>
> Ready for Phase 2.

**WC** spawns. Checks: no hedge words remain in AC ✓, test seams named ✓, AC clauses count matches DoD ✓. **Clean.**

---

## Phase 2 — CA: Cloud architecture review

CA spawns. Reads `docs/architecture/` first: confirms the system is on Vercel + Supabase Postgres + Upstash Redis per ADR-002 / ADR-001. Reads issue + project IaC (`terraform/`). Walks the decision heuristic:

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

## Phase 3 — UX: Design specification

UX spawns. Reads `docs/architecture/00-system-overview.md` — confirms the system is a web app with REST API surface; `01-stack-and-hosting.md` confirms TypeScript + Next.js. Then reads issue + the linked requirements. Detects: this is a **backend-only task** — no user-visible UI surface added in this PR.

UX walks the project for a design system anyway:

- `packages/ui/` exists with a small in-house component library — confirms the project has design tokens at `packages/ui/tokens.json` (typography scale, palette, spacing).
- No Storybook yet, no Figma reference. Components are documented by inspection.
- The frontend `/signin` page already exists (the legacy `login.ts` is what's being replaced); UX confirms this PR doesn't touch its UI.

Since the surface is **backend** (the POST endpoint), the UX spec covers what the *frontend* consumer will see when it calls this endpoint:

UX posts:

> **[UX/UI Designer]** Phase 3 — Design specification.
>
> **Surface(s) affected:** API response shape only. No UI surface added in this PR. The existing `/signin` page (already designed) will consume this endpoint when the legacy `login.ts` is removed in a follow-up.
>
> **Design system in use:** `packages/ui/tokens.json` (existing) — no new tokens needed for this PR since no UI is added.
>
> **API response shape (backend UX):**
>
> | Outcome | Status | Body | Frontend renders |
> |---------|--------|------|-------------------|
> | Success | 200 | `Set-Cookie: session=…; HttpOnly; Secure; SameSite=Lax` + body `{ "ok": true }` | Redirect to `/dashboard` (existing flow). |
> | Invalid credentials | 401 | `{ "error": "invalid_credentials" }` | Existing inline error message: *"That email or password didn't match. Try again."* — already in `packages/ui/strings/auth.json`. No new copy needed. |
> | Rate-limited | 429 | `{ "error": "too_many_attempts", "retry_after_seconds": <number> }` + `Retry-After` header | New error message needed: *"Too many failed attempts. Please wait <X minutes> and try again."* — add the string key `auth.error.rate_limited` to `packages/ui/strings/auth.json`. |
> | Server error | 500 | `{ "error": "server_error" }` | Existing generic error toast. No new copy. |
>
> **Copy added (new):**
> - `auth.error.rate_limited` → "Too many failed attempts. Please wait {{minutes}} minute(s) and try again."
>
> **Accessibility:**
> - No UI added in this PR. The existing `/signin` page's screen-reader pass and keyboard navigation aren't affected.
> - The new rate-limited error string is announced via the existing `aria-live="polite"` region on the signin form (already in place).
>
> **Phase 5 review plan:** verify the actual response bodies match this table exactly; confirm the new copy key was added to `packages/ui/strings/auth.json`; confirm `Retry-After` header is correctly set on 429.
>
> PE: ready for Phase 4 (implementation). Build the response shapes per the table above; add the one new string key.

**WC** spawns. Checks: every response case has a defined body + frontend rendering (✓), new copy strings called out by key (✓), accessibility considered for the live region (✓), no vague "modern"/"clean" claims (✓). **Clean.**

---

## Phase 4 — PE: Implementation

PE spawns. Reads `docs/architecture/` first — confirms Postgres via Supabase (ADR-001), serverless functions on Vercel (ADR-002), and Upstash Redis for rate-limit state (recorded in `02-data-and-storage.md`). The task aligns with these choices — no architectural deviation, so no new ADR needed. Then reads codebase. Plans the change.

Notices: the existing `apps/web/api/auth/login.ts` (legacy name) has the handler logic but no rate-limit middleware. **Preparatory refactor needed**: extract the rate-limit middleware as a generic util the new signin endpoint can also use.

PE does, in order:

1. `refactor: extract rate-limit middleware to lib/rate-limit.ts` (commit A — pure refactor, no behaviour change, the legacy `login.ts` keeps working)
2. `feat(auth): add POST /api/auth/signin handler` (commit B — uses the new util; response shapes per UX spec)
3. `feat(auth): wire signin into the API router` (commit C — exposes the route)
4. `feat(ui): add auth.error.rate_limited copy key` (commit D — adds the string per UX spec)

Pushes commits. Posts:

> **[Principal Engineer]** Phase 4 — Implementation complete.
>
> Commits:
> - `4f12e8a` refactor: extract rate-limit middleware to lib/rate-limit.ts
> - `c8d2916` feat(auth): add POST /api/auth/signin handler
> - `a05b3d3` feat(auth): wire signin into the API router
> - `b7e1d2f` feat(ui): add auth.error.rate_limited copy key
>
> Two Hats: the rate-limit refactor is its own commit (commit A) so it can be reviewed independently. The signin handler (commit B) uses the new util.
>
> Built to UX spec: response shapes per the Phase 3 table; new copy key added in `packages/ui/strings/auth.json`.
>
> Decisions: returned `invalid_credentials` for both unregistered-email and wrong-password cases (no side channel, per AC2). Used a constant-time string comparison for the password hash check.
>
> Ready for Phase 5 (UX design review).

**WC** spawns. Reads the diff. Findings:

- ❌ `apps/web/api/auth/signin.ts:42` — `console.log("user signed in", user.id)` left in.
- ❌ `apps/web/api/auth/signin.ts:78` — `TODO: handle session rotation` comment without an issue tracking it.

WC posts:

> **[Work Checker]** Audit of Principal Engineer's Phase 4 work — defects found.
>
> 1. **`apps/web/api/auth/signin.ts:42`** — `console.log("user signed in", user.id)` is debug output, should be removed (or replaced with a structured log call if telemetry is wanted).
> 2. **`apps/web/api/auth/signin.ts:78`** — `// TODO: handle session rotation` — either implement now or open a tracking issue and reference it in the comment.
>
> Principal Engineer: please address. Will re-audit when fixed.

**Orchestrator state:** `bounce_back_counts.PE["Phase 4"] = 1`.

PE re-spawns with the defect list. Removes the `console.log`. The session-rotation TODO is genuinely out-of-scope for this task — PE creates issue #67 "Session rotation policy for signin" and replaces the TODO with `// see #67`. Commits as `chore: remove debug, link TODO to tracking issue` (commit E).

PE posts an updated comment.

**WC** re-spawns. Re-audits. **Clean.**

---

## Phase 5 — UX: Design review

UX spawns. Re-reads the Phase 3 spec.

Inspects the diff:

- Verifies the JSON response shapes match the spec table.
- Verifies the `Retry-After` header is set on the 429 (was a small omission until the WC review prompted PE to double-check — Playwright not needed because the surface is HTTP not UI).
- Verifies the new copy key `auth.error.rate_limited` is added to `packages/ui/strings/auth.json` with the exact wording from the spec.
- Runs `curl -i -X POST localhost:3000/api/auth/signin ...` locally for each AC case and pipes through `jq` to confirm the response body shapes match.

UX posts:

> **[UX/UI Designer]** Phase 5 — Design review complete. **APPROVED.**
>
> Reviewed: response shapes for all four cases (200 / 401 / 429 / 500) against the Phase 3 spec table.
>
> Verification:
> - 200 success: response body matches spec ✓; `Set-Cookie` attributes (`HttpOnly Secure SameSite=Lax`) correct ✓.
> - 401 invalid credentials: body matches spec ✓; same response for unregistered email and wrong password ✓.
> - 429 rate-limited: body matches spec ✓; `Retry-After` header correctly set ✓; `retry_after_seconds` in body matches header value ✓.
> - 500 server error: matches spec ✓ (verified by forcing a DB connection failure locally).
>
> New copy: `auth.error.rate_limited` added to `packages/ui/strings/auth.json` ✓; wording matches spec exactly ✓.
>
> Playwright: not applicable for this PR (no UI surface added). When the legacy `login.ts` is removed in the follow-up PR, that PR's Phase 5 will include a Playwright pass on the `/signin` page hitting these new responses.
>
> Ready for Phase 6 (security review).

**WC** spawns. Checks: every spec case actually verified (✓ — UX cited the specific verification method for each), Retry-After header check is real not assumed (✓ — UX ran curl), no "looks fine" without specifics (✓), backend-only task doesn't claim Playwright was used (✓). **Clean.**

---

## Phase 6 — Sec: Security review

Sec spawns. Reads `docs/architecture/01-stack-and-hosting.md` (Vercel + Supabase + Upstash Redis) and `04-decisions.md` (no auth-specific ADRs yet — this PR may produce one for the rate-limit choice). Reads the diff.

Walks the threat-surface checklist; this is auth code so several categories are highly applicable:

- **Authn / authz:** the diff *is* the authn surface. AC2 already requires same-body 401 for unregistered vs wrong password (no side-channel) — Sec verifies the implementation honours this. PE's commit B uses constant-time password comparison — verified.
- **Input validation:** email format and length validated at the request boundary via the existing Zod schema (no string-concat into queries; Supabase client parameterises).
- **Secrets / credentials:** no secrets in the diff. Password is hashed via argon2 (the project standard). Hash is never logged. Session cookie value is opaque (random 32 bytes).
- **Crypto:** constant-time string compare ✓; argon2 used (not bcrypt-rolled-our-own).
- **Session / cookies / CSRF:** cookie attributes `HttpOnly`, `Secure`, `SameSite=Lax` ✓ per UX spec. Session rotates on successful signin (PE's handler issues a fresh ID).
- **CORS / headers:** the API CORS config is unchanged; existing same-origin allow-list stands.
- **Dependencies:** no new deps in this PR.
- **Logging / audit:** Sec checks log output. Found: PE logs the user's email on failed signin (`logger.info("signin failed", { email })`). Flagging — email is PII; should be hashed or omitted. **Medium severity** — not a blocker on its own.
- **Rate limit / abuse:** AC4 requires throttling — implemented and tested. Sec also notes login attempts are per-IP; per-account throttling would close the credential-stuffing loophole — flagging as **Low / Informational** for a follow-up issue.

Sec posts:

> **[Security Engineer]** Phase 6 — Security review complete. **APPROVED.**
>
> Categories walked:
> - Authn / authz: applicable — no side-channel between unregistered and wrong-password 401s; constant-time password check ✓.
> - Input validation: applicable — Zod schema at boundary; no string-concat into Supabase queries.
> - Secrets / credentials: checked — none in diff; argon2 for password hash; session id from `crypto.randomBytes(32)`.
> - Crypto: applicable — argon2 + constant-time compare ✓.
> - Session / cookies / CSRF: applicable — cookie attributes correct; session rotates on signin.
> - CORS / headers: N/A — unchanged.
> - Dependencies: no new deps in this PR.
> - Logging / audit: Medium finding — see below.
> - Rate limit / abuse: applicable — per-IP throttle in place; informational note below.
>
> **Medium (won't block on its own — flagging for PE awareness):**
>
> 1. **`apps/web/api/auth/signin.ts:91`** — `logger.info("signin failed", { email })` logs the email plaintext on failed signin. Email is PII; suggest hashing or omitting. Fix: `{ email_hash: sha256(email) }` or drop the field. Severity: Medium. Not a Critical/High because logs go to a controlled sink with limited access, but it's still PII drift.
>
> **Informational (for follow-up, not this PR):**
>
> - Rate limit is per-IP only. Credential-stuffing across IPs would bypass the throttle. Suggest a per-account counter as a follow-up issue.
>
> Ready for Phase 7 (tests).

**Orchestrator:** Medium does not block. PE is notified; the fix lands as commit `9a1c2f8 fix(security): hash email in failure log per Sec Phase 6` before moving on.

**WC** spawns. Checks: itemised category walk ✓, authz check not skipped ✓, secret-in-diff scan ran ✓, dependency check noted (none) ✓, no silent CORS/header changes (✓ — diff has no header touches outside the cookie attrs from the UX spec). **Clean.**

---

## Phase 7 — TAE: Tests

TAE spawns. Reads the diff. Plans:

- Unit tests for the handler logic (validation, password check, error mapping) — many.
- Integration test against testcontainers Postgres for the happy path + 401 + rate-limit kick-in — three.
- E2E test for the user-visible signin flow (login form → dashboard) — one. *(Note: this E2E uses Playwright since the project already has it set up.)*

TAE writes the tests. Uses `faker.seed(42)`, frozen system clock at `'2026-05-13T10:00:00Z'`, mocked Redis client (in-memory) for unit tests, real Redis via testcontainers for integration. Runs locally — all pass.

Notices: the handler reads `process.env.AUTH_RATE_LIMIT_WINDOW_SECONDS` directly inside the handler function — hard to test cleanly. Flags back to PE: *"please refactor to accept the window as a parameter (default to the env value)."*

**Orchestrator:** This is a TAE-to-PE bounce-back during Phase 7, not a defect from WC. The orchestrator dispatches PE to do the small refactor, then resumes TAE.

PE does the refactor, commits as `refactor(auth): accept rate-limit window as parameter for testability`. TAE resumes; tests now cleaner.

TAE posts:

> **[Test Automation Engineer]** Phase 7 — Tests written.
>
> Added 14 unit tests, 3 integration tests, 1 E2E test (Playwright).
>
> Coverage approach:
> - Unit: validation helpers, password-check (constant-time), rate-limit math, error mapping, request shape parsing, response shape building
> - Integration: signin happy path against testcontainers Postgres; 401 returns same body for unregistered-email vs wrong-password; 429 fires at attempt 6 within 15min window
> - E2E (Playwright): happy-path signin from `/signin` page to `/dashboard` redirect — covers AC1 end-to-end through the actual UI
>
> Test data: 3 user fixtures in `tests/fixtures/users.json` (valid, locked, deleted). Faker seeded with 42, system clock frozen to 2026-05-13T10:00:00Z.
>
> Suite: passes locally (`pnpm test` for unit/integration; `npx playwright test signin` for E2E). 18 new tests, all green.
>
> One PE refactor requested mid-phase (extract rate-limit window as parameter) — done, applied to tests cleanly.
>
> Ready for Phase 8.

**WC** spawns. Checks tests for truthy assertions (none — every test asserts a specific outcome), mock-the-world tests (none — mocks are on collaborators only), `Math.random()` driving outcomes (none), `.skip` without justification (none), E2E for things that should be unit (no — E2E covers the user-visible happy path, all other tests are at the right level). **Clean.**

---

## Phase 8 — QA: Test validation

QA spawns. Walks every test. Builds the AC → Test map:

| AC clause | Test |
|-----------|------|
| AC1: Given valid creds, when POST, then 200 + cookie | `signin.test.ts > authenticates valid email + password` + `signin.integration.test.ts > happy path returns session cookie` + `signin.e2e.spec.ts > sign in and land on dashboard` |
| AC2: Same 401 for unregistered email OR wrong password | `signin.integration.test.ts > unregistered email and wrong password return same body` |
| AC3: p95 ≤ 500ms at 100 req/s | `perf.benchmark.test.ts > signin p95 under steady load` *(runs in nightly perf job, not PR CI)* |
| AC4: 5 failed → 6th 429 for 1h | `signin.integration.test.ts > rate-limits after 5 failed attempts; 1-hour ban` |

Runs the suite. All green. No flake.

Also runs the Playwright suite headed once (`npx playwright test signin --headed --workers=1`) to eyeball the signin flow — confirms the visible behaviour matches the AC verbally. Sanity-check, not a full UX review (that's UX's Phase 5 role).

QA posts:

> **[QA Engineer]** Phase 8 — Test validation complete.
>
> Tests added: 18. Coverage: AC1 ✓ AC2 ✓ AC3 ✓ (nightly perf job) AC4 ✓
>
> | AC | Test |
> |----|------|
> | AC1 | `signin.test.ts > authenticates valid email + password` + integration happy-path + Playwright E2E |
> | AC2 | `signin.integration.test.ts > unregistered email and wrong password return same body` |
> | AC3 | `perf.benchmark.test.ts > signin p95 under steady load` (nightly; not gating this PR) |
> | AC4 | `signin.integration.test.ts > rate-limits after 5 failed attempts; 1-hour ban` |
>
> Test run: all green on first run, no flake observed across 3 consecutive runs.
> Playwright (headed spot-check): signin flow visible end-to-end matches AC1.
>
> Test data: 3 fixtures added (`tests/fixtures/users.json`), factory seeded.
>
> Ready for Phase 9.

**WC** spawns. Checks: every AC has at least one test ✓, AC3 perf test exists but won't gate this PR (acceptable — performance budgets are typically nightly), no skipped tests, no flake silently ignored, Playwright actually run by QA (✓ — referenced specific command). **Clean.**

---

## Phase 9 — PE: Lint + build

PE spawns. Runs `pnpm lint`. 2 warnings — both in the new code (one unused import, one prefer-const). Fixes both.

Runs `pnpm build`. Clean.

Re-runs both. Clean.

Commits as `chore: lint fixes` (commit F). Pushes.

PE posts:

> **[Principal Engineer]** Phase 9 — Lint + build complete.
>
> Lint: ran `pnpm lint`. 2 warnings fixed (1 unused import in signin.ts, 1 prefer-const in rate-limit.ts). Now clean.
>
> Build: ran `pnpm build`. Clean.
>
> Re-ran both after fixes — clean.
>
> Commit: `e91a4b2` chore: lint fixes
>
> Ready for Phase 10 (SRE production-readiness review).

**WC** spawns. Checks: no `// eslint-disable` was added (✓ — lint was actually fixed), no `any` / `# type: ignore` added in this diff, no warning-silencing config changes. **Clean.**

---

## Phase 10 — SRE: Production-readiness review

SRE spawns. Reads `docs/architecture/01-stack-and-hosting.md` (Vercel + Supabase + Upstash) and `04-decisions.md`. Reads the diff.

Walks the production-readiness checklist:

- **Observability:** PE added a counter `auth.signin.attempt` (with `outcome` label: success / invalid_credentials / rate_limited / server_error) and a latency histogram `auth.signin.latency_ms`. Trace span exists via the existing OTel middleware. Log entries reference the existing `request_id` correlation key. (Sec's Phase 6 finding about the plaintext email in the failed-signin log has already been fixed.)
- **Alerting:** the existing dashboard has a "signin error rate > 2% sustained 5min" alert that automatically covers the new endpoint (it scopes on the `auth.signin.*` namespace). A new alert isn't needed; SRE confirms by reading the alert config.
- **Runbook + rollback:** the project's `docs/runbook/auth.md` already has a section "Signin failure mode" that the PE has extended with two paragraphs covering rate-limit-related symptoms and the new metric names. Rollback path is clean — `git revert <PR-merge-sha>` and redeploy; no DB migration or state shape change.
- **Capacity + cost:** new external calls are to the existing Redis instance for the rate-limit counter. At expected steady-state load (~50 req/s baseline, with bursts), this adds ~50 Redis ops/sec — well within the 10k/sec quota on the current plan. Cost delta: zero (using existing tier).
- **Failure modes:** the Redis call has a 200ms timeout configured in `lib/rate-limit.ts`. If Redis is down, the handler **fails open** (allows the signin attempt without throttling) per the project's documented degradation policy — SRE notes this for the PR record. Idempotency: the rate-limit-counter increment is idempotent at the failure-then-retry level (a duplicate increment doesn't bypass the throttle, it just costs one bucket entry — acceptable).
- **Deploy safety:** env var `AUTH_RATE_LIMIT_REDIS_URL` is present in all three env tfvars (verified by re-reading the CA's Phase 2 diff). Code path is safe in canary — the rate-limit util gracefully handles the missing-env case by failing open with a warning log.

SRE posts:

> **[SRE]** Phase 10 — Production-readiness review complete. **APPROVED.**
>
> Categories walked:
> - Observability: counter + histogram + trace span added; log correlation via request_id; no PII in logs (post Sec Phase 6 fix).
> - Alerting: existing `auth.signin.*` alert covers the new endpoint — no new alert needed.
> - Runbook + rollback: `docs/runbook/auth.md` updated; rollback is `git revert + redeploy` (no state changes).
> - Capacity + cost: +50 Redis ops/sec at baseline, well under quota; no cost delta.
> - Failure modes: 200ms timeout on Redis call; fail-open documented as per project policy; idempotent counter increment.
> - Deploy safety: env var in all envs (per CA Phase 2); canary-safe with graceful degradation.
>
> No Blocker or High findings.
>
> **Informational:**
>
> - Fail-open on Redis outage is documented but worth flagging on the PR — the on-call should know that a Redis incident silently disables signin throttling.
>
> Ready for Phase 11 (PrjM process audit).

**WC** spawns. Checks: every category named ✓, observability not skipped on the new code path ✓, no timeout-less external call approved (✓ — 200ms timeout noted), no irreversible migration (✓ — no migration), SLO/alert status checked against the actual alert config (✓ — SRE cited the alert name). **Clean.**

---

## Phase 11 — PrjM: Process-diligence audit

PrjM spawns. Reads issue #42's DoD + AC. Reads all 11 phase comments above (including UX × 2, Sec, SRE). Inspects the diff.

Walks the audit checklist:

- DoD items: 7/7 verified done (including the new "UX spec exists for any user-visible surface" item — covered by Phase 3's API response spec).
- AC → Test map: 4/4 AC clauses have tests (per QA's Phase 8 comment, cross-checked with the diff).
- Lint + build: PrjM runs both themselves. Both green.
- Commits: 8 commits (incl. UX-driven copy commit + Sec-driven PII-log fix), all Conventional Commits, atomic (one logical change each). ✓
- TODO/FIXME: PrjM greps the diff. None added in this PR (the original TODO was replaced with a reference to issue #67 — verified that issue exists).
- Tests: PrjM runs the suite. All green. Playwright passes too.
- CA's human-required checklist: none (CA verified no human-required infra changes needed).
- UX: both phases ran; backend-only nature acknowledged; response-shape spec was followed; new copy string verified added.
- Sec: Phase 6 ran; one Medium finding addressed in commit `9a1c2f8`; informational follow-up (per-account throttle) noted for tracking.
- SRE: Phase 10 ran; production-readiness clean; fail-open behaviour surfaced for PR record.

PrjM posts:

> **[Project Manager]** Phase 11 — Process-diligence audit complete. **APPROVED.**
>
> Checked:
> - DoD checklist: 7/7 items verified done.
> - AC → Test mapping: 4/4 AC clauses have tests; verified against QA's map and the diff.
> - Lint + build: ran `pnpm lint && pnpm build`, both green.
> - Tests: ran `pnpm test && npx playwright test signin`, 18 new tests pass + Playwright green, no flake across 3 runs.
> - Commits: 8 atomic commits, Conventional Commits format, no WIP/typo commits.
> - No TODO/FIXME/debug-prints added in this diff (one original TODO replaced with link to tracking issue #67).
> - UX: response-shape spec from Phase 3 followed (verified by comparing PE's commit B against the spec table); new copy key `auth.error.rate_limited` added with correct wording.
> - Sec: Medium finding (PII email in failure log) fixed in commit `9a1c2f8`; one informational follow-up noted.
> - SRE: observability + alerting + runbook + capacity + failure modes + deploy safety all checked; fail-open behaviour flagged for the PR record.
> - CA: no human-required infra changes; Redis already provisioned in all envs.
>
> Issue ready for PdM Phase 12 (outcome review).

**WC** spawns. Checks: PrjM's claims itemised (✓), PrjM ran the tests themselves (✓ — referenced specific output), missed TODO scans (✓ — caught the issue-#67 link), UX/Sec/SRE phases all acknowledged (✓), no drift into outcome territory (✓ — PrjM stayed on process). **Clean.**

---

## Phase 12 — PdM: Outcome review

PdM spawns. Reads the originating requirements: `docs/requirements/03-functional/auth.md` for FR-AUTH-001 (signin with email+password) and FR-AUTH-002 (rate-limit failed attempts). Rationale on FR-AUTH-001: *"users must be able to authenticate via their primary credential pair and reach the dashboard within one round-trip"*. Fit criterion: *"95% of signin attempts complete in under 500ms p95 under expected load, with a clear path forward for both success and failure cases"*.

Reads the UX Phase 5 review comment (response shapes verified).

Then **actually runs the feature**: starts the local dev server, opens the existing `/signin` page (still pointing at the legacy `login.ts` endpoint for now — the cutover lands in a follow-up PR). Confirms the page behaves as documented: success redirects to `/dashboard`; invalid credentials shows the existing inline error; rate-limit triggers the new `auth.error.rate_limited` copy.

Walks the outcome checklist:

- **Intent:** the implementation honours the rationale (signin within one round-trip) and ships the fit criterion (the perf budget is in place; the rate-limit closes FR-AUTH-002).
- **Experience:** happy path is one click; error path shows actionable copy; rate-limit message includes the `{{minutes}}` wait time so the user knows what to do. No "feature is on but indistinguishable from off" smell.
- **Scope:** the PR ships the endpoint + the new copy key. The cutover (replacing the legacy `login.ts`) is intentionally a follow-up PR — out-of-scope by design, tracked at issue #68. No accidental scope creep noticed (the rate-limit util extraction is the one in-scope refactor and was already justified as preparatory).
- **Trade-offs surfaced:** SRE flagged the fail-open behaviour on Redis outage. PdM endorses the trade-off — "no signin > silent signin loss" is the wrong split for a consumer-facing auth surface. The fail-open with an alert is the right call given the rate-limit is defence-in-depth, not the primary authn boundary.
- **Feedback loop:** the metric `auth.signin.attempt{outcome}` is in place, so post-rollout we can see success vs invalid vs rate-limited ratios. PdM is satisfied this PR ships with enough instrumentation to know if it worked.

PdM posts:

> **[Product Manager]** Phase 12 — Outcome review complete. **APPROVED.**
>
> Walked the feature as a user. The implementation:
> - Honours the originating requirements: FR-AUTH-001 (signin within one round-trip) and FR-AUTH-002 (rate-limit failed attempts). Rationale fit ✓.
> - Meets the fit criterion: p95 budget in place (verified by QA's nightly perf test in Phase 8); user-facing path is clear for success / invalid / rate-limited.
> - Covers the happy path + the error / rate-limited / server-error states (UX Phase 5 verified specifics; this is a holistic re-check).
> - Ships everything the user needs day-1 (the existing `/signin` page already consumes the legacy endpoint, so users continue working through the rollout; cutover follow-up is tracked at #68).
> - Carries no out-of-scope additions (the one refactor — extracting rate-limit util — was justified as preparatory in Phase 4).
>
> Trade-offs endorsed:
> - Fail-open on Redis outage (per SRE Phase 10) — the right call for this surface.
> - Per-IP-only throttle (per Sec Phase 6 informational) — acceptable for now; per-account throttle is a defence-in-depth follow-up.
>
> Feedback-loop note: `auth.signin.attempt{outcome}` metric is wired and will appear on the existing auth dashboard within ~15min of merge. Rollout monitoring covered.
>
> Ready for PE Phase 13 (PR + self-review).

**WC** spawns. Checks: originating requirement actually read (✓ — PdM cited specific rationale + fit criterion), feature actually tried (✓ — PdM cited specific user actions taken on the local dev server), fit-criterion measurability addressed (✓), no taste-pedantry (✓ — PdM endorsed engineering trade-offs without re-quibbling). **Clean.**

---

## Phase 13 — PE: PR + self-review

PE spawns. `gh pr create` with the PR template body. Self-reviews the diff line-by-line in the GitHub UI (mental model — actually via `gh pr diff` and reading carefully). Walks the code-review checklist.

Finds during self-review: the `rate-limit.ts` doc comment is missing a `@param` line for the new `windowSeconds` parameter. Fixes. Commits as `docs: complete jsdoc on rate-limit util`.

Adds the Self-review section to the PR body:

```markdown
## Self-review

I've reviewed this diff myself before requesting human review. The review pass found and fixed:
- Missing `@param` jsdoc on the new `windowSeconds` parameter (commit `f3a8d1c`).
```

PE posts:

> **[Principal Engineer]** Phase 13 — PR + self-review complete.
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

## Phase 14 — Pending

Phase 14 only runs if a human reviewer comments. The orchestrator pauses here. The user re-invokes `/task-implement 42` after human review lands to resume.

---

## Phase 15 — Summary + handoff

Orchestrator posts:

> **[Orchestrator]** Implementation session complete (Phase 0-13). Awaiting human review.
>
> - Branch: `42-add-signin-endpoint`
> - PR: https://github.com/awojtas/example/pull/89
> - Commits: 9 (3 feat, 2 refactor, 3 chore, 1 docs)
> - Tests added: 14 unit / 3 integration / 1 E2E (Playwright)
> - Bounce-backs during session: 1 (PE Phase 4 — debug log + bare TODO)
> - Work Checker findings caught: 2 (the debug log + the bare TODO, both fixed in commit E)
> - Security findings: 1 Medium (PII email in failure log) — fixed in commit `9a1c2f8`; 1 Informational (per-account throttle) — tracked as a follow-up.
> - Production-readiness findings: 0 Blocker/High; 1 Informational (fail-open on Redis outage — surfaced on PR record).
> - Human-required infra checklist items: 0
> - UX spec produced + verified: 1 (API response shapes for backend-only task)
> - Outcome review (PdM): trade-offs endorsed; rollout monitoring confirmed.
> - Self-review found and fixed: 1 (missing jsdoc)
>
> PR is ready for human review and merge.
>
> When review feedback lands, re-invoke `/task-implement 42` to run Phase 14 (address feedback).

Terminal summary to the user matches the above.

---

## What this example demonstrates

1. **The Work Checker earns its keep.** Phase 4 had 2 defects the PE missed (debug log + bare TODO). The WC caught both. Without the WC, those would have either shipped or been caught later in human review.
2. **The UX Designer's role is universal, not UI-only.** A backend task still has UX — the API response shape, the error copy a frontend will render, the cookie attributes. Phase 3 produced a concrete response-shape spec; Phase 5 verified the implementation matches it. Playwright wasn't used because there was no UI surface — Phase 5 was a `curl + jq` review instead. The audit trail is the same regardless of surface type.
3. **The Security pass found a real issue without blocking.** A PII-in-log defect was caught at Medium severity, fixed before the PR shipped. Critical/High would have bounced. Medium documented and addressed without a formal bounce. The threat-surface checklist is itemised — every category gets a "applicable / N/A — reason", not silent skips.
4. **The SRE pass surfaces operational reality before merge.** Observability, fail-open behaviour, capacity sanity — all confirmed on the actual diff before any human reviewer sees it. The fail-open trade-off is a deliberate documented choice, not silent. SRE's per-feature scope complements platform-verify's platform-level scope.
5. **The Project / Product Manager split catches different things.** PrjM checks process (every claim verifiable, every test runs, every box ticked). PdM checks outcome (does the user-facing result match the requirement's intent, and how will we know it worked?). Conflating them would have missed the trade-off endorsement step (fail-open + per-IP-only throttle) — that's a product question, not a process question.
6. **Bounce-backs are normal and named.** 1 bounce-back (Phase 4 WC) + 1 mid-phase TAE→PE refactor handoff + 1 Sec-driven PII fix is healthy. 3+ in the same phase from the same role = orchestrator escalates.
7. **The TAE-to-PE handoff is fluid.** When TAE found the handler was hard to test, the orchestrator dispatched PE for a small refactor mid-phase rather than blocking the entire flow. The Two Hats discipline made this clean.
8. **The audit trail is durable.** Every persona's comment is on the issue. Six months later, anyone can read the issue and reconstruct exactly what happened, who did what, and what the audit findings were — including the UX considerations for a "just a backend" change, the Sec / SRE per-feature scrutiny, and the PdM's outcome endorsement.
9. **The PR has a Self-review section.** That's the visible artefact to the human reviewer that this skill took the work seriously.
