# Release-Readiness Checklist (per-feature)

The operational checklist the SRE persona walks in `/task-implement` Phase 10, applied here as a standalone skill. Covers everything that makes a change *safe to run in production*, distinct from making the cloud platform *exist and be wired right* (that's `/platform-verify`).

Walk in order. For inapplicable categories, say so explicitly with a one-line reason — silence is not proof.

## Observability — can we see what this is doing?

- [ ] **Logs**: the new code path emits structured logs at the right levels. Errors are logged with enough context (request ID, user ID, the operation attempted) to debug without re-running. No PII / secrets in the entries themselves.
- [ ] **Metrics**: any new business-meaningful counter / latency / error-rate is exposed. (E.g. a new endpoint exposes request count + p50/p95/p99 latency + error rate.)
- [ ] **Traces**: if the project uses distributed tracing, the new code path is in the trace. Cross-service calls add spans.
- [ ] **Correlation**: log entries can be tied to traces (trace ID in log MDC / context).
- [ ] **Log level discipline**: errors are `error`, warnings are `warn`, normal flow is `info` or `debug`. No `error`-spam on benign conditions.

**Common gaps:**

- New endpoint with no request counter / no latency histogram.
- New background job with no success / failure counters.
- New external call with no log entry on failure.
- A "successfully did the thing" log at `error` level (alert noise).
- PII (email, full name, raw token) in log fields.

## Alerting — will we know if it breaks?

- [ ] If the change adds a new failure mode (a new external dependency, a new background job, a new endpoint with an SLO), is there an alert for it?
- [ ] Alert thresholds are based on the **SLO**, not arbitrary. If the project has no SLOs, surface that to the user — adding alerts in a vacuum is busywork.
- [ ] Alerts route to the right on-call channel.
- [ ] Alerts are actionable — the alert text or runbook tells the on-call what to do.
- [ ] **Existing alerts cover the new code path** — if the new endpoint sits under an existing namespace (`auth.*`, `api.*`), check that the existing `<namespace>.error_rate` alert auto-includes it.

**Common gaps:**

- New external dependency with no "X is unhealthy" alert.
- New background job with no "X hasn't run in N minutes" alert.
- Alert with no runbook link — the on-call is reading the alert text trying to invent the response in the moment.

## Runbook + rollback

- [ ] **Runbook entry**: lightweight is fine — five bullets beat zero bullets. Should answer: "what does this look like when it breaks, and what do I do?"
- [ ] **Rollback path**: `git revert <PR-merge-sha>` and redeploy is usually the answer. Confirm there's no migration / state change that prevents a clean revert.
- [ ] **Migration is backward-compatible** (additive, reversible). Old and new code can coexist during the rollout window.
- [ ] **Feature flag is the rollout mechanism**: kill-switch documented; flag is removable once the rollout is stable.
- [ ] **Dependencies on the new code**: anything else that hard-depends on this change being in production? If yes, the rollback isn't simple — flag it.

**Common gaps:**

- Migration that drops a column the previous code still reads.
- Migration with no `down` migration.
- Feature flag without documentation of how to flip it / who can flip it.
- New code that consumes a new message format with no version-bump / no backward-compat handling.

## Capacity + cost

- [ ] **External-call rate**: new calls to a downstream API — under the dependency's quota at expected load? Estimate calls/minute steady-state.
- [ ] **DB queries**: new queries are **indexed**. EXPLAIN sanity check counts; full performance testing is a separate concern.
- [ ] **Background job depth**: new background job has observable queue depth and guards against unbounded growth.
- [ ] **Cost sanity**: new managed service / new SaaS call / new always-on container — does the cost shape match the value? If unclear, surface it.
- [ ] **Memory / CPU**: new code path doesn't introduce a memory leak (e.g. an unbounded in-process cache) or a CPU hotspot (e.g. O(n²) on an unbounded input).

**Common gaps:**

- New endpoint that does a full-table scan because the new query field isn't indexed.
- New in-process cache that grows without bound.
- New external API call inside a hot loop (per-row instead of batched).
- New always-on managed service for a low-frequency use case (cost ≠ value).

## Failure modes

- [ ] **Timeouts**: external calls have explicit, bounded timeouts. No "wait forever" defaults.
- [ ] **Retries**: idempotent operations have a retry strategy with jitter. Non-idempotent operations do not retry blindly.
- [ ] **Circuit breakers / bulkheads**: if the change calls a fragile downstream, is there isolation so its failure doesn't cascade?
- [ ] **Graceful degradation**: if the new dependency is down, what does the user see? A clear error, a fallback, or a confusing 500?
- [ ] **Fail-open vs fail-closed policy**: if the system has a documented policy (e.g. rate limiting fails open; authn fails closed), the new code honours it.

**Common gaps:**

- HTTP client with no timeout configured (defaults to "forever").
- Retry loop on a non-idempotent operation (sends payment twice on flaky network).
- New dependency that, if down, causes the whole request to 500 with no fallback.
- Authn check that fails open on dependency error (huge security risk).

## Deploy safety

- [ ] **Env vars added in all environments** (dev, UAT, prod) before the merge. Echoes the CA's check; re-verify.
- [ ] **Secrets** in the secret manager, not in the diff.
- [ ] **Canary compatibility**: if the project uses progressive rollout, the new code path is safe in a subset (no shared state assumptions that require 100% adoption).
- [ ] **Backward compatibility**: old and new code can coexist during the rollout window.
- [ ] **CI is green** at the time of review (the readiness review doesn't gate on this, but red CI is a separate blocker).

**Common gaps:**

- Env var added to `prod.tfvars` but missed in `dev.tfvars` / `staging.tfvars`.
- New code path that assumes a config value that doesn't exist in dev.
- Hard-coded URL that only works in one environment.
- Migration that runs at startup and fails idempotently the second time, breaking canary.

## Data safety (if applicable — skip if the diff has no migrations / no schema changes)

- [ ] **Migration is reversible.** There's a `down` migration; if irreversible, surface it explicitly.
- [ ] **Migration is backward-compatible.** Old code can read new schema; new code can read old data.
- [ ] **Expand-then-contract.** If renaming / restructuring, two migrations: one adds, one removes (after the new code is live).
- [ ] **Backfill plan**: if new column has a NOT NULL constraint, there's a backfill that doesn't lock the table.
- [ ] **No data loss path**: deleting a column with data has a "snapshot first" step.

**Common gaps:**

- Adding a NOT NULL column to a large table without a backfill step.
- Renaming a column in a single migration — old code reads the old name and crashes during deploy.
- DROP TABLE in a migration with no archive step.

## Web app ↔ API integration (skip if there is no separate API Vercel project, or if the diff doesn't touch the BFF proxy, Trusted Sources config, or API-call path)

Uses the **BFF + Vercel Trusted Sources** pattern. Browsers never call the API directly.

- [ ] **BFF proxy route handlers present and complete**: the web app has server-side proxy handlers that (a) authenticate the user, (b) call `getVercelOidcToken()` from `@vercel/oidc`, (c) forward requests to the API with `x-vercel-trusted-oidc-idp-token` + user JWT.
- [ ] **Trusted Sources configured on the API project**: the web app's Vercel project is listed as a trusted source (API project → Settings → Deployment Protection → Trusted Sources).
- [ ] **API Deployment Protection is ON**: the API is not directly reachable from the public internet. A direct unauthenticated request to the API URL returns a Vercel authentication challenge.
- [ ] **`API_URL` server-side env var set in all environments**: the web app's Vercel project env store has the API's URL as a server-side variable (not `NEXT_PUBLIC_`). Confirmed in the deploy project — not just `.env.local`.
- [ ] **A real end-to-end call verified in the target environment**: browser → BFF → API through real user auth — not a mocked or server-only test.

**Common gaps:**

- BFF handlers exist but `getVercelOidcToken()` call is missing — OIDC token not added, API rejects all BFF calls.
- Trusted Sources not configured on the API project — BFF calls blocked even with the OIDC token present.
- `API_URL` set locally but not in the Vercel web app env store — BFF calls hit `undefined` in production.
- Integration tested only at the unit or API level — BFF wiring failures invisible until a full stack is deployed.

## What "ready" looks like at the end

After walking every category, you can say:

> *"This change has X new code path(s) that emit Y new log line(s), Z new metrics, and consume / produce N new external calls. The rollback path is clean (`git revert + redeploy`). The new failure modes are covered by alerts <list>. The capacity delta is <one-line>. No Blocker or High findings."*

If you can't say something like this in plain language, the readiness check isn't complete — keep walking.

## Sources

- Beyer et al., *Site Reliability Engineering* (Google) — https://sre.google/sre-book/table-of-contents/
- Google SRE, *Service Reliability Hierarchy* (the "production readiness review" practice) — https://sre.google/sre-book/part-III-practices/
- OWASP, *Logging Cheat Sheet* (the "don't log PII" guidance) — https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
