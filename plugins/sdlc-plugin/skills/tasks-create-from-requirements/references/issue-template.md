# Issue Template

Every issue the skill creates uses this skeleton. The body answers four questions a reader has when they open the issue: **what**, **why is it now**, **how do I know it's done**, and **what's the wider context**.

## Standard template (most tasks)

```markdown
## What

<One paragraph. The "what we're building" statement. Plain English, no jargon.>

## Why now

<One paragraph. Why this task is in this phase, not later or earlier. Tie to a requirement, a constraint, or a dependency.>

## Definition of Done

- [ ] Code implemented per the acceptance criteria below.
- [ ] Tests added (unit and/or integration as appropriate — see project conventions).
- [ ] Documentation updated if user-visible behaviour changed.
- [ ] Pull request opened, reviewed (or self-reviewed for solo work), and merged.
- [ ] Linked requirement(s) in `docs/requirements/` updated if any details changed during implementation.

## Acceptance Criteria

- [ ] Given <precondition>, when <action>, then <observable outcome>.
- [ ] Given <precondition>, when <action>, then <observable outcome>.
- [ ] <Other testable conditions specific to this task.>

## Implements

- FR-<DOMAIN>-NNN — <one-line summary>
- NFR-<CATEGORY>-NNN — <one-line summary> *(if applicable)*

## Context

- **Phase / milestone:** Phase N — <theme>
- **Estimated effort:** <e.g. "half a day" / "1 day" / "2 days">
- **Blocked by:** #<issue number(s)> *(omit if no blockers)*
- **Blocks:** #<issue number(s)> *(omit if blocks nothing)*
- **Requirement source:** [docs/requirements/03-functional/<file>.md](../docs/requirements/03-functional/<file>.md)
```

## Human-required template (overlay)

When `human-required` applies, **prepend** this block before the standard `## What` section:

```markdown
## ⚠️ Human Required

**Why human:** <Specific reason — account creation, secret generation, legal review, etc. See references/human-required-checklist.md for the catalogue.>

**Click-time estimate:** <e.g. "15 min — 2 h" — the time the human is actually doing the task.>

**Elapsed time estimate:** <e.g. "same day" / "1-2 days" / "depends on counsel" — total wall-clock including waits for verification, propagation, etc.>

**What to do:**

1. <Step one — be specific. URL, button name, what to enter.>
2. <Step two.>
3. <Step three.>

**Where to record outputs:**

- <e.g. "Add the generated token to GitHub Actions secrets as `<NAME>`">
- <e.g. "Record the chosen primary brand colour in `docs/design/brand-tokens.md`">

**Agent-verifiable:** <yes — agent confirms via: `<exact command or check, e.g. gh secret list | grep VERCEL_TOKEN>`> | <no — operator self-certifies on close>
```

The DoD for human-required tasks is simpler — typically just "the human-step outputs exist in the place they're supposed to be":

```markdown
## Definition of Done

- [ ] Account / credential / decision / artefact exists.
- [ ] Output recorded in the location specified above ("Where to record outputs").
- [ ] Any dependent AI tasks (listed in "Blocks") can now start.
```

## Bug template (overlay)

When `bug` applies, replace `## What` with:

```markdown
## What — Bug Description

**Symptom:** <what the user sees / what's broken>

**Expected:** <what should happen>

**Reproduction:** <minimum steps>

**Suspected cause:** <if known; otherwise "investigation needed">
```

The rest of the template stays the same. DoD includes a regression test.

## Examples

A standard feature task:

```markdown
## What

Implement the `POST /api/auth/signin` endpoint accepting email + password, returning a session cookie on success or a 401 with a clear error message on failure.

## Why now

Phase 2 starts the auth surface. The sign-in endpoint is the first user-facing entry point; FR-AUTH-001 ("email+password sign-in") is the foundation other auth requirements build on.

## Definition of Done

- [ ] Code implemented per acceptance criteria.
- [ ] Unit tests for valid/invalid credentials, throttling.
- [ ] Integration test that hits the live endpoint end-to-end.
- [ ] Docs: `docs/auth.md` updated with the endpoint shape.
- [ ] PR opened, reviewed, merged.

## Acceptance Criteria

- [ ] Given a registered user with a correct email+password, when they POST to `/api/auth/signin`, then they receive a 200 response with a `Set-Cookie` for the session.
- [ ] Given an unregistered email, when they POST, then they receive a 401 with body `{ "error": "invalid_credentials" }`. (Note: same response as wrong password — avoid leaking which.)
- [ ] After 5 failed attempts in 15 minutes from the same IP, further attempts return 429 for 1 hour.
- [ ] The response time at p95 under steady-state load is < 500 ms (NFR-PERF-001).

## Implements

- FR-AUTH-001 — Email+password sign-in
- FR-AUTH-002 — Rate limiting on auth endpoints
- NFR-SEC-003 — No credential-existence side channel

## Context

- **Phase / milestone:** Phase 2 — Core Auth & Profile
- **Estimated effort:** 1 day
- **Blocked by:** #14 (0.7 Add `AUTH_JWT_SECRET` to GitHub secrets)
- **Blocks:** #18 (2.3 Implement /signin UI), #20 (2.5 Implement password-reset flow)
- **Requirement source:** [docs/requirements/03-functional/auth.md](../docs/requirements/03-functional/auth.md)
```

A human-required task:

```markdown
## ⚠️ Human Required

**Why human:** Vercel account creation requires email verification, Terms of Service acceptance, and a billing card on file (free tier still wants one for proof). The agent cannot complete email verification.

**Click-time estimate:** 20 minutes.

**Elapsed time estimate:** Same day (email verification typically instant).

**What to do:**

1. Go to https://vercel.com/signup
2. Sign up using the project's primary email.
3. Verify email (check inbox).
4. Add the project's GitHub repo as a Vercel project.
5. In Vercel project settings, generate a new API token (scope: Full Access).

**Where to record outputs:**

- Add the API token to GitHub Actions secrets as `VERCEL_TOKEN`.
- Add the Vercel team ID and project ID as `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` (visible in the Vercel project Settings → General).

**Agent-verifiable:** yes — agent confirms via: `gh secret list | grep -E 'VERCEL_TOKEN|VERCEL_ORG_ID|VERCEL_PROJECT_ID'` (all three names should appear).

## Why now

Phase 0 — everything in Phase 1+ that deploys depends on these secrets being in place.

## Definition of Done

- [ ] Vercel project exists, linked to the GitHub repo.
- [ ] `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` set in GitHub Actions secrets.
- [ ] Any dependent AI tasks (listed in "Blocks") can now start.

## Context

- **Phase / milestone:** Phase 0 — Operator Setup
- **Estimated effort:** 20 min click-time
- **Blocks:** #5 (1.1 Configure Vercel preview deploys in CI), #12 (2.1 Implement Edge middleware)
- **Requirement source:** [docs/requirements/06-constraints.md](../docs/requirements/06-constraints.md) (C-T-001 mandates Vercel hosting)
```
