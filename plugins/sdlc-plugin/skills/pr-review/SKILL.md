---
name: pr-review
description: Reviews a GitHub pull request end-to-end as a thoughtful peer reviewer. Reads the PR description + linked issue + diff, walks the code-review checklist, leaves specific inline comments where things are wrong (file:line + concrete suggestion), and posts a summary review verdict — Approve / Comment / Request changes. Distinct from the Work Checker which audits work *inside* `/task-implement`; this skill reviews work that's *already been raised as a PR* by someone (or something) else. Use when the user says "review this PR", "review PR #X", "look at PR #X", "do a code review on this PR", "peer review", "review someone else's PR", or provides a GitHub PR URL or number to review. Lighter-weight than `/task-implement` Phase 13 (the self-review) — this is a *reviewer* role, not a *self-reviewer* role. Companion to `/release-readiness` (which checks production-readiness of a change) — `/pr-review` checks code-quality.
---

# Reviewing a pull request

Take an open GitHub PR and review it as a thoughtful peer would: read the diff carefully, walk the standard checklist, leave specific inline comments where things are wrong, and post a clear verdict (Approve / Comment / Request changes) at the end.

## When to use this vs the alternatives

- **`/pr-review`** (this skill) — review a PR raised by someone else. The reviewer perspective.
- **`/task-implement` Phase 13 (self-review)** — the PE reviewing *their own* diff before requesting human review.
- **Work Checker (inside `/task-implement`)** — the per-phase audit gate. Internal to the orchestration; never invoked standalone.

This skill is the **external reviewer**. Not a defect when used on a `/task-implement`-produced PR — that PR has been through 16 phases of internal checks, but it's still appropriate for a human reviewer (or this skill standing in) to apply an independent pass.

## Prerequisites

1. **Working directory is inside a git repo** with a GitHub remote (so `gh pr view` resolves the PR locally).
2. **`gh` CLI authenticated** with `repo` scope (read + comment + review).
3. **The PR exists and is open.** The user passes a PR number or URL. If they didn't, ask.

## Inputs the skill accepts

- `pr-review 89` — PR number in the current repo.
- `pr-review https://github.com/owner/repo/pull/89` — full URL (the skill extracts owner/repo/number).
- `pr-review owner/repo#89` — qualified shorthand.

If the PR is closed or already merged, report that and stop — don't review a closed PR.

## Workflow

Copy this checklist and track progress:

```text
pr-review progress:
- [ ] Step 1: Resolve the PR + read its description
- [ ] Step 2: Read the linked issue(s) and any prior review comments
- [ ] Step 3: Read the diff
- [ ] Step 4: Walk the code-review checklist
- [ ] Step 5: Post inline comments for specific findings
- [ ] Step 6: Post the summary review (Approve / Comment / Request changes)
```

### Step 1: Resolve the PR and read its description

```bash
gh pr view <number> --json number,title,body,state,headRefName,baseRefName,additions,deletions,changedFiles,reviewDecision,statusCheckRollup,mergeable
```

Parse out: title, body, branch, base, sizes, CI state, current review status. If `state != "OPEN"`, stop and report.

Read the PR body. The PR template (see `references/pr-review-checklist.md`) expects: **What / Why / How / Tests / Manual verification / Out of scope / Self-review.** Note which sections are missing or thin — that's a finding worth raising at the summary level.

### Step 2: Read the linked issue(s) and any prior review comments

```bash
gh pr view <number> --json closingIssuesReferences   # the "Closes #N" linkage
gh pr view <number> --comments                       # PR-level discussion comments
gh api repos/<owner>/<repo>/pulls/<number>/comments  # inline review comments from prior reviewers
```

For each issue this PR closes, read its body — that's the Definition of Done and Acceptance Criteria the reviewer is checking *against*. Without this, the review is "is this code OK in isolation" rather than "does this code solve the problem the issue stated".

If the PR has prior review comments, read them. Don't repeat findings someone else already raised. Don't contradict prior approvals without explicit reasoning.

### Step 3: Read the diff

```bash
gh pr diff <number>
```

Read the **whole** diff line-by-line. Don't skim. For large PRs (more than ~500 meaningful lines): note size as a finding (Google's eng-practices guidance), but still read all of it — you can't review what you haven't read.

While reading, hold three lenses simultaneously:

1. **Correctness** — does this code do what the PR body says it does?
2. **Quality** — does this code meet the project's bar (per `references/pr-review-checklist.md`)?
3. **Risk** — what could go wrong in production with this change?

### Step 4: Walk the code-review checklist

Apply `references/pr-review-checklist.md`. Cover every category that's applicable:

- Size + scope
- Description quality
- Commits
- Code quality (TODOs, magic numbers, error handling, naming)
- Tests (AC coverage, determinism, pyramid shape)
- Architecture (SOLID, dependencies, backwards compat)
- Build / lint / CI
- Infrastructure / IaC
- Documentation
- Out of scope / follow-ups

For each finding, note: file:line, what's wrong, what would be better. **Specificity is the value.** A finding without a location and a concrete suggestion is not actionable.

### Step 5: Post inline comments for specific findings

For each location-specific finding, post an inline review comment via `gh`:

```bash
# Start a pending review
gh pr review <number> --comment --body "<summary>" 
```

`gh` doesn't directly expose line-anchored review comments — use the GitHub API for those:

```bash
# Get the latest commit SHA on the PR
LATEST_SHA=$(gh pr view <number> --json commits --jq '.commits[-1].oid')

# Post a line-anchored review comment
gh api -X POST repos/<owner>/<repo>/pulls/<number>/comments \
  -f body="<one-line finding + concrete suggestion>" \
  -f commit_id="$LATEST_SHA" \
  -f path="<file>" \
  -F line=<line-number> \
  -f side="RIGHT"
```

**Discipline:**

- One finding per comment — don't pile multiple unrelated things into one thread.
- Lead with the *what's wrong*, then the *suggestion*. Reviewers who read top-to-bottom should learn the issue without scrolling.
- Use GitHub's suggestion syntax for trivial code-change proposals:
  ````
  Suggest hashing the email before logging:
  ```suggestion
      logger.info("signin failed", { email_hash: sha256(email) });
  ```
  ````
- Tone: **direct + neutral**. *"This logs PII; suggest hashing"* is right. *"You forgot to hash this, fix it"* is not. *"Maybe consider possibly thinking about hashing"* is also not — wishy-washy is wasted words.
- **Don't pile on style preferences** that aren't in the project's lint config. If the project's tooling didn't flag it, leave it.

### Step 6: Post the summary review

After all inline comments are in, post the summary review with a verdict:

```bash
gh pr review <number> --approve --body "<summary>"
# OR
gh pr review <number> --request-changes --body "<summary>"
# OR
gh pr review <number> --comment --body "<summary>"
```

Choose the verdict by the **severity of the findings**:

| Findings | Verdict | When |
|----------|---------|------|
| None worth raising, or only nits | **Approve** | The PR meets the bar; minor things are fine to merge with or not. |
| Mix of minor + things-to-discuss; no blockers | **Comment** | Worth raising for discussion / future-PR awareness but doesn't gate this merge. |
| One or more genuine blockers (correctness, security, missing tests for AC) | **Request changes** | This shouldn't merge until the blockers are addressed. |

The summary body follows this skeleton:

```markdown
## Summary

<One paragraph. What this PR does, observed from the diff — not just restated from the PR body.>

## What I checked

- Issue alignment: <verified against the linked issue's AC + DoD — list which AC clauses I checked tests for>
- Size + scope: <N lines of meaningful diff; one logical change ✓ / mixed>
- Code quality: <walked checklist, key categories: code, tests, build, IaC>
- Tests: <AC coverage map ✓ / gaps>
- Risk / rollback: <any concerns about production safety, deploy ordering, migration reversibility>

## Findings

**Blockers (must address before merge):**
- <inline comment ref / brief>: <what + why>

**Worth discussing (won't block on their own):**
- <inline comment ref / brief>

**Nits (take or leave):**
- <inline comment ref / brief>

## Verdict

**<Approve / Comment / Request changes>**

<One sentence. The "why" of the verdict.>
```

## Strict non-goals

- **Doesn't merge.** This skill never merges the PR. Even if all checks pass and the verdict is Approve, merging is a human decision (or a follow-up automation).
- **Doesn't push commits** to the PR's branch. The reviewer's job is to surface; the author's job is to fix.
- **Doesn't request a specific approver or assign reviewers.** Out of scope.
- **Doesn't run the project's tests locally** unless the PR's CI is red and the reviewer needs to verify whether it's a flake or a real failure. If CI is green, trust it.
- **Doesn't review draft PRs.** Drafts are work-in-progress; skip and tell the user to mark Ready for Review first.
- **Doesn't review your own PR.** If the PR's author matches the authenticated user, stop and recommend `/task-implement` Phase 13 (self-review) instead — that's a different discipline.

## Edge cases

- **PR is huge** (>1000 meaningful lines). Read it anyway, but flag the size as a Worth-discussing finding — large PRs are review-hostile, and the project policy may push for splitting.
- **PR body is empty or one sentence.** Surface as a blocker on the PR description quality criterion — reviewers can't review what isn't explained. Verdict: Request changes (with the empty body as the change request).
- **CI is red.** Read the failure. If it's a real failure, it's a blocker. If it's a known flake (the author's prior comment says "flake on this job"), note it as Worth-discussing and don't auto-fail the review.
- **PR has merge conflicts.** Not a blocker for *this* review — the author resolves conflicts before merge. Note in the summary.
- **PR is a revert.** Different review shape — confirm it cleanly reverts the original commit, no extra changes piggybacked, the original PR is linked. Light review pass.
- **PR is a dependency bump (Dependabot, Renovate).** Light review pass — verify lockfile is the only meaningful change, CI is green, changelog/release notes link is in the PR body. Approve unless the bump introduces a major-version migration that the codebase hasn't adapted to.
- **PR closes an issue that doesn't exist.** Surface — the audit trail is broken. Worth-discussing.
- **PR has zero tests for a non-trivial change.** Almost always a blocker unless the project genuinely has no test infrastructure (and even then, surface the gap).
- **PR has tests but all of them mock the system under test.** Blocker — the tests verify the mocks, not the code. Cite the specific tests.

## When the reviewer pushes back on the PR's premise

If the PR appears to be addressing the *wrong problem* — e.g. it tightens a rate limit when the linked issue actually says "increase the rate limit" — surface that as a blocker at the top of the summary. Don't dive into code-quality findings if the *direction* is wrong; that's the bigger gap.

If the PR's direction is right but the requirement itself is wrong (you discover during review that the requirement is outdated): note it as a Worth-discussing item and recommend the author runs `/requirements-rework` before merging. Don't block on this — it's a process recommendation, not a code defect.
