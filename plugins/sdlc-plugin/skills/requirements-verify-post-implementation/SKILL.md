---
name: requirements-verify-post-implementation
description: Post-implementation verification — checks the actually-shipped code and tests against every requirement in docs/requirements/, producing a traceability report where each FR and NFR is marked Met / Partial / Not met / No evidence. The whole-system closing QA sweep of the SDLC chain — distinct from /requirements-validation (which pressure-tests the requirements documents before build) and from the per-issue outcome check inside /task-implement (which only covers one ticket). Catches requirements that were never turned into an issue, NFRs that no single ticket fully delivered, and drift between spec and build. Raises GitHub issues for the gaps; never silently fixes them. Use when the user says "verify the requirements are implemented", "did we build everything", "requirements traceability", "post-implementation verification", "requirements coverage check", "acceptance verification", "V&V pass", or wants to confirm the delivered system matches the documented spec.
---

# Post-implementation requirements verification

Takes the requirements in `docs/requirements/` as given and answers one question for each: **does the shipped system actually satisfy this?** Produces a traceability report and raises issues for the gaps. It does not fix gaps, and it does not re-litigate whether the requirements themselves are good — that is `/requirements-validation`'s job.

## When to use this vs the alternatives

- **`/requirements-validation`** — pressure-tests the requirements *documents* (clear, measurable, still accurate?). Runs *before* implementation.
- **The Product Manager persona inside `/task-implement`** — checks one issue's outcome against its originating requirement. Per-ticket scope.
- **`/requirements-verify-post-implementation`** (this skill) — the *whole-system, post-build* sweep. Every requirement, against the actual code and tests, whether or not it ever became an issue.

## Prerequisites

1. **`docs/requirements/` exists** with FR / NFR files. If not, there is nothing to verify against — stop and point the user at `/requirements-create-from-design`.
2. **Implementation has happened** — there is application code to inspect. If the repo is still scaffolding-only, say so and stop.
3. **`gh` CLI authenticated** (`repo` scope) if the user wants gaps raised as issues. Without it the report is still produced; issue creation is skipped.
4. **The user has time.** A thorough sweep reads the whole requirements set and samples the codebase and test suite.

## Workflow

Copy this checklist and track progress:

```text
verify progress:
- [ ] Step 1: Inventory every requirement in docs/requirements/
- [ ] Step 2: Gather implementation + test evidence per requirement
- [ ] Step 3: Classify each — Met / Partial / Not met / No evidence
- [ ] Step 4: Write the traceability report
- [ ] Step 5: Offer to raise issues for the gaps
- [ ] Step 6: Update the lifecycle tracker + summarise
- [ ] Step 7: Commit + push the report
```

### Step 1 — Inventory the requirements

Read every file in `docs/requirements/`. Build the working list of verifiable requirements: each FR and NFR with its **ID**, **statement**, and **fit criterion** (the measurable bar). Note the `traces-to` chain and any linked GitHub issues — those are evidence shortcuts. Read `07-assumptions.md` and `08-open-questions.md` too: an unresolved open question against a requirement caps its best-possible verdict at *Partial*.

### Step 2 — Gather evidence

For each requirement, search the codebase for what implements it and what tests exercise it:

- **Code** — the modules, routes, handlers, components, jobs that deliver the behaviour the requirement describes.
- **Tests** — unit / integration / E2E tests whose assertions match the requirement's fit criterion.
- **History** — closed issues and merged PRs that `traces-to` the requirement (`gh issue list`, `gh pr list --search`).

Use the **fit criterion** as the target. "The feature exists" is not verification — "a test demonstrates the fit criterion is met" is.

**NFRs need NFR-shaped evidence.** A performance NFR wants a benchmark or load test, not a code reading. A security NFR wants the control actually present (auth check, input validation, rate limit). A reliability NFR wants retries / timeouts / monitoring in the code path. If that evidence does not exist, the verdict is *No evidence* — do not infer an NFR is met from the absence of a problem.

### Step 3 — Classify each requirement

| Verdict | Meaning |
|---|---|
| **Met** | Implementation present *and* a test (or other concrete evidence) demonstrates the fit criterion is satisfied. |
| **Partial** | Implemented but under-tested, or only part of the fit criterion is satisfied, or a linked open question is unresolved. |
| **Not met** | No implementation found for the requirement. |
| **No evidence** | Cannot be determined from available artefacts — fit criterion not testable as written, or an NFR with no measurable evidence either way. |

Be honest. "No evidence" is a legitimate, useful verdict — never round it up to "Met".

### Step 4 — Write the traceability report

Write `docs/requirements/verification-report.md` — a current-state snapshot (overwrite on re-run; git keeps the history). Stamp it with the date and the commit SHA verified.

```markdown
# Requirements verification report

**Verified:** <date> · **Commit:** <short SHA>

## Summary

| Verdict | Count |
|---|---|
| Met | N |
| Partial | N |
| Not met | N |
| No evidence | N |

## Traceability matrix

| Req ID | Statement (short) | Verdict | Evidence | Gap notes |
|--------|-------------------|---------|----------|-----------|
| FR-1 | ... | Met | `src/...`, `tests/...` | — |
| FR-7 | ... | Not met | — | No handler found |
| NFR-2 | ... | No evidence | — | No load test; cannot confirm |
```

Every requirement gets a row. Evidence cites `file:line`, test names, or PR / issue numbers.

### Step 5 — Offer to raise issues for the gaps

For each **Not met** and **Partial**, offer to raise a GitHub issue:

```bash
gh issue create --title "<Req ID>: <gap>" --body "<requirement statement + fit criterion + what's missing + report link>" --label "verification-gap"
```

Ask once whether to create the `verification-gap` label if it does not exist. Batch the user-approved issues. List the **No evidence** items separately for the user to decide — some are untestable-as-written (a requirements problem, route to `/requirements-validation`) rather than a build gap.

### Step 6 — Update the tracker + summarise

Update the lifecycle tracker (see below), then print a short summary: the four counts, the issue numbers raised, and a one-line verdict — e.g. *"38 of 44 requirements Met; 4 Partial and 2 Not met raised as issues."*

### Step 7 — Commit and push

Stage `docs/requirements/verification-report.md` and `README.md` (lifecycle tracker), commit with `docs(requirements): verification report YYYY-MM-DD`, then follow [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). The `verification-gap` issues raised in Step 5 are already pushed via `gh issue create` — no further git action needed for them.

## Guardrails

- **Don't fix gaps.** Report and raise issues. Closing a gap is implementation work — `/task-implement` or `/issue-work`, not this skill.
- **Don't re-validate the requirements.** If a requirement is vague or wrong, that is `/requirements-validation`'s job — note it and move on.
- **Don't fabricate evidence.** No test, no measurement → *No evidence* or *Partial*, never *Met*.
- **Whole-system scope.** Verify every requirement, including the ones that never became an issue — those are exactly what this skill exists to catch.
- **Grounded in** ISO/IEC/IEEE 29148 (requirements engineering), the requirements traceability matrix practice, IEEE 1012 (verification & validation), and ISO/IEC 25010 quality attributes for NFR evidence.

## Lifecycle tracker

This skill owns the **Implementation verified** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Implementation verified` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Implementation verified` line to ✅ (done).

Touch only the `Implementation verified` line — leave every other stage exactly as found.
