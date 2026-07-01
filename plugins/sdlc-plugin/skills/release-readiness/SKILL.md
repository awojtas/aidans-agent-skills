---
name: release-readiness
description: 'Per-feature production-readiness check before a change merges or deploys. Reads the diff (or a PR) and walks the operational checklist — observability, alerting, runbook + rollback, capacity + cost, failure modes (timeouts/retries/degradation), deploy safety (env vars, canary) — and produces a green/red verdict with specific gaps. Per-feature scope, distinct from /platform-verify (platform-level) and /pr-review (code quality). Use when the user says "ready to ship", "release readiness", "is this ready for prod", "production readiness check", "pre-launch check", "operability review", or "SRE pass on this".'
---

# Release-readiness review

Take a specific change (current branch, an open PR, or a recently merged change) and answer: **is this safe to run in production?** Walks the per-feature production-readiness checklist and produces a clear green / red verdict.

## When to use this vs the alternatives

- **`/release-readiness`** (this skill) — per-feature ops gate. "Is this change safe to ship?"
- **`/platform-verify`** — platform-level smoke test. "Is the cloud wired right?" (Different scope.)
- **`/repo-release-ready`** — repo-level scaffolding. "Does this repo have release branches, secret scanning, branch protection?" (Different scope.)
- **`/task-implement` Phase 10 (SRE production-readiness review)** — the SRE persona inside the orchestration. Same checklist as this skill; just integrated into the heavyweight workflow rather than invoked standalone.

This skill is the **standalone version** of the Phase 10 SRE pass. Use it when:

- The change wasn't built via `/task-implement` (so Phase 10 didn't run).
- The change is at the PR or pre-deploy stage and you want a focused ops pass.
- You want a second opinion on a `/task-implement`-produced PR's ops-readiness.

## Prerequisites

1. **Working directory is inside a git repo.**
2. **`gh` CLI authenticated** if reviewing a PR (read access; no write needed unless `--post-comment` is used).
3. **The diff is identifiable** — current branch (default), a passed PR number, or a commit range.

## Inputs the skill accepts

- `release-readiness` — defaults to the current branch's diff vs `main`.
- `release-readiness <PR-number>` — pulls the PR's diff via `gh`.
- `release-readiness <commit-range>` — e.g. `release-readiness main..HEAD` or `release-readiness <sha1>..<sha2>`.
- `release-readiness --post-comment <PR-number>` — review the PR and post the findings as a PR comment (default is terminal-only).

## Workflow

Copy this checklist and track progress:

```text
release-readiness progress:
- [ ] Step 1: Resolve the change
- [ ] Step 2: Read docs/architecture/ for context
- [ ] Step 3: Read the diff
- [ ] Step 4: Walk the readiness checklist
- [ ] Step 5: Classify findings (Blocker / High / Medium / Low / Informational)
- [ ] Step 6: Produce the verdict
- [ ] Step 7: (Optional) Post the comment on the PR
```

### Step 1: Resolve the change

If the user passed a PR number:

```bash
gh pr view <number> --json number,title,headRefName,baseRefName,additions,deletions,changedFiles,statusCheckRollup
```

If the user passed a commit range, validate it resolves:

```bash
git log --oneline <range>
```

If neither, default to the current branch's diff vs `origin/main` (or vs `main` if no remote):

```bash
git fetch origin main 2>/dev/null
git diff origin/main...HEAD --stat
```

Confirm with the user what's being reviewed before proceeding.

### Step 2: Read `docs/architecture/` for context

The readiness checklist is grounded in the project's recorded architecture. Read:

- `docs/architecture/00-system-overview.md` — system type and criticality.
- `docs/architecture/01-stack-and-hosting.md` — runtime topology.
- `docs/architecture/04-decisions.md` — any operational ADRs (SLOs, error budgets, fail-open vs fail-closed policy).

If `docs/architecture/` doesn't exist, that's not a blocker for *this* skill — but note it as Informational. The readiness check is less load-bearing without the project's recorded operational expectations.

### Step 3: Read the diff

```bash
gh pr diff <PR-number>    # if PR
git diff <range>          # if commit range
git diff origin/main...HEAD  # if current branch
```

Read for **operational surface**: new endpoints, new background jobs, new external dependencies, new migrations, new env vars / secrets, new log lines, new metric emissions, new feature flags.

You're not reading the diff for code-quality issues (that's `/pr-review`'s job). You're reading for *what will happen when this runs in production*.

### Step 4: Walk the readiness checklist

Apply `references/release-readiness-checklist.md`. Cover every category. For inapplicable categories, say so explicitly — silence is not proof.

**Categories:**

1. **Observability** — logs, metrics, traces on new code paths.
2. **Alerting** — new failure modes covered; thresholds tied to SLOs.
3. **Runbook + rollback** — operability documentation; clean revert path.
4. **Capacity + cost** — new traffic shape vs quotas; cost delta.
5. **Failure modes** — timeouts, retries, circuit breakers, graceful degradation.
6. **Deploy safety** — env vars in all environments; canary compatibility.
7. **Data safety** (if applicable) — migrations reversible; backward-compatible schema.
8. **Web app ↔ API integration** (if the change touches the BFF proxy, Trusted Sources config, or API-call path) — BFF proxy handlers complete with OIDC token, Trusted Sources configured on the API project, API Deployment Protection ON, `API_URL` server-side env var set, end-to-end call verified.

### Step 5: Classify findings

Use this severity ladder:

| Severity | What it means | Effect on verdict |
|----------|---------------|-------------------|
| **Blocker** | Meaningfully unsafe: missing rollback, unbounded retry against a third-party API, missing timeout on a critical call, irreversible migration. | **Red.** Don't ship. |
| **High** | Real ops gap: new endpoint with no observability, missing alert for a new failure mode, known capacity cliff. | **Red.** Don't ship without fixing. |
| **Medium** | Hardening gap (no explicit alert threshold, runbook entry missing, log level wrong). | **Yellow.** Ship if low-criticality change; document and follow up. |
| **Low** | Informational (potential cost concern, slight observability gap). | **Green.** Note and move on. |
| **Informational** | Observation worth recording — not a defect. | **Green.** |

### Step 6: Produce the verdict

Verdict map:

- **Green** (no Blocker / High, no concerning Medium) — Ready to ship.
- **Yellow** (Mediums only, change is low-criticality) — Ship with documented follow-ups.
- **Red** (any Blocker / High, or Medium on a high-criticality change) — Not ready. Specific gaps listed.

Output to the terminal in this shape:

```markdown
# Release-readiness review: <PR title or branch name>

**Verdict: <Green / Yellow / Red>**

## What was reviewed

- Source: <PR #N / branch X / commits A..B>
- Files changed: <N>
- Lines: +<N> / -<N>
- Architecture context: <docs/architecture/ read / not present>

## Categories walked

| Category | Status | Notes |
|----------|--------|-------|
| Observability | <✓ / gap> | <one-liner> |
| Alerting | <✓ / gap / N/A> | <one-liner> |
| Runbook + rollback | <✓ / gap> | <one-liner> |
| Capacity + cost | <✓ / gap / N/A> | <one-liner> |
| Failure modes | <✓ / gap> | <one-liner> |
| Deploy safety | <✓ / gap> | <one-liner> |
| Data safety | <✓ / gap / N/A> | <one-liner> |

## Findings

**Blockers / High (must address before shipping):**

1. **<Specific gap>.** Severity: <Blocker / High>. Where: <file:line or "missing — should be at <path>">. Impact: <what could go wrong in prod>. Fix: <one-line remediation>. Owner: <PE / SRE setup / Infra>.

**Medium (won't block low-criticality ship; follow-up required):**

- <note>

**Low / Informational:**

- <note>

## Recommendation

<One paragraph. The "why" of the verdict. If Red, what the smallest path to Green looks like.>
```

### Step 7: (Optional) Post the comment on the PR

If invoked with `--post-comment <PR-number>`, post the verdict and findings as a PR comment:

```bash
gh pr comment <number> --body "$(cat <<'EOF'
**[Release-readiness review]**

<verdict block from Step 6, condensed>
EOF
)"
```

Default behaviour is terminal-only — the user reads it and decides whether to post. Don't post by default; that's a write operation.

## Strict non-goals

- **Doesn't run smoke tests against the live platform.** That's `/platform-verify`.
- **Doesn't review code quality.** That's `/pr-review`.
- **Doesn't load-test or performance-test.** Different discipline.
- **Doesn't add observability or alerting itself.** Reports gaps; the author or SRE adds the missing instrumentation.
- **Doesn't approve / request changes on the PR.** The verdict is informational; the human merges (or runs `/pr-review` for an actual approval decision).
- **Doesn't review changes already in production.** If the change has merged, this skill becomes a *post-mortem hygiene check* — still useful, but the time to fix is shorter than the time to ship.

## Edge cases

- **`docs/architecture/` missing.** Note as Informational. Continue with the checklist using best-effort defaults (assume the system is a typical web service unless the diff suggests otherwise).
- **Diff is purely refactor / docs / test changes.** Verdict is Green; the readiness surface is unchanged. Note this in the verdict explicitly.
- **Diff is huge** (>1000 lines). Read it anyway. Note size as Informational — a large change carries more ops risk by surface area alone.
- **PR is closed / merged.** Continue the review but frame the output as a post-merge hygiene check.
- **CI is red.** Note as Informational. The readiness review is independent of CI state; a red CI is a separate blocker that this skill doesn't own.
- **Project has no SLOs / observability stack.** Surface as Informational. The readiness review degrades but doesn't fail — surface the gaps that exist *given the project's level of operational maturity*.
- **Project has no `docs/runbook/`.** Note as Informational. Recommend adding a runbook entry as part of this change.
- **New external dependency in the diff.** Trigger explicit checks: rate-limit / quota awareness, timeout configured, retry strategy, graceful degradation on dependency failure.
- **Migration in the diff.** Trigger explicit checks: reversible, backward-compatible with the previous code, expand-then-contract pattern if schema is shared.
- **Feature flag wired but not documented.** Note as Medium — flags without docs become operational landmines.

## When the skill recommends deeper work

- **No observability at all on the new code path** + this is a critical-path feature → recommend `/task-implement` for the next iteration to enforce the full SRE Phase 10 pass.
- **Missing runbook for an entirely new subsystem** → recommend a dedicated docs task before the next feature builds on top.
- **The diff implies an architectural change** (new managed service, new auth boundary) that doesn't have an ADR → recommend `/platform-design` or an ADR-specific session before shipping.
