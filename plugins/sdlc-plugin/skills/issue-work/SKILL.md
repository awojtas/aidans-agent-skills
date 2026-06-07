---
name: issue-work
description: "Lightweight, fast, single-agent implementation of a GitHub issue — reads the issue, explores the codebase, writes code, adds tests, verifies, opens a PR, and closes the issue. The default path for routine work: bug fixes, small features, refactors, doc changes where the quality bar is 'merges cleanly and works'. Use when the user says 'work on issue', 'implement issue #', 'fix issue #', 'pick up this ticket', 'quick fix', 'simple change', 'start on this', or provides a GitHub issue link or number without asking for a thorough or multi-persona pass. Prefer /task-implement when the task is complex, production-critical, or needs audited multi-persona review and audit-trail comments."
---

# Implementing a GitHub Issue

Work a single GitHub issue from understanding through verified implementation. Applies to any language, framework, or build system.

## Prerequisites

Before starting, ask the user for:
1. **GitHub repo** (owner/repo format, e.g. `octocat/hello-world`)
2. **Issue number**

If either is missing, ask before proceeding.

## Workflow

Copy this checklist and track progress:

```text
Issue Progress:
- [ ] Step 1: Read and understand the issue
- [ ] Step 2: Explore the codebase
- [ ] Step 3: Create a working branch
- [ ] Step 4: Implement changes
- [ ] Step 5: Add tests
- [ ] Step 6: Verify (lint, type-check, build, tests)
- [ ] Step 7: Self-check against acceptance criteria
- [ ] Step 8: Open PR and close issue
```

### Concurrency and rate limits

Default agent behaviour fans out 10+ tool calls in a single batch — enough to trip Anthropic's **shared-capacity** rate limit (*"Server is temporarily limiting requests (not your usage limit)"*), which is a transient platform condition distinct from your account's daily quota.

Two knobs:

- **Cap parallel tool calls at 3 at a time.** Sequence further calls in subsequent turns. This is a hard cap — not "try to be modest".
- **Back-off on rate-limited responses.** On a `Rate limited` / `429` / `temporarily limiting requests` response, wait and retry the same call. Three retries with doubling waits: **60s → 120s → 240s**. After the third retry, bounce to the user with the failing call and a "pause for ~10 minutes then re-invoke" note.

The shared-capacity case is the **only** one where retry-the-same-call is correct. Daily / monthly account limits and "running low on context" are different conditions: pause-and-report, never claim done with steps outstanding.

### Step 1: Read and understand the issue

Use the GitHub MCP tool to fetch the full issue from the repo. Identify:

- **Acceptance criteria** — what "done" means
- **Scope boundaries** — what is and isn't included
- **Linked PRs, comments, or related issues** for extra context

If the issue is ambiguous, state assumptions clearly before writing code.

### Step 2: Explore the codebase

Search the codebase to understand:

- Project structure and conventions (check README, CONTRIBUTING, AGENTS.md, CLAUDE.md)
- How to build, lint, and test (look for scripts in package.json, Makefile, .csproj, etc.)
- Existing patterns relevant to the issue (similar features, test helpers, shared utilities)
- The tech stack (language, framework, package manager, test framework)

Do not start coding until you understand the conventions.

### Step 3: Create a working branch

Create and check out a descriptive branch:

```bash
git checkout -b <issue-number>-<short-description>
```

### Step 4: Implement changes

- Make the minimum changes needed to satisfy the acceptance criteria
- Follow existing conventions exactly — match code style, naming, file organization
- No scope creep — if you notice unrelated improvements, note them but don't implement them

### Step 5: Add tests

Add test coverage using the project's existing test patterns:

- **Unit tests** for logic, services, utilities
- **Integration/E2E tests** for user-facing behavior changes
- Use existing test helpers and fixtures — don't reinvent them

Match the test framework already in use (Jest, Playwright, xUnit, pytest, etc.).

### Step 6: Verify

First, read `AGENTS.md` / `CLAUDE.md` for the project's documented verify chain. If none documented, run these in order:

1. **Lint** — fix all warnings and errors
2. **Type-check** — if the project uses static types. Almost never bundled into `test:unit`; run it explicitly.
3. **Build** — confirm it compiles cleanly
4. **Unit tests**
5. **E2E tests** — if the change is user-visible

Hand off to Step 7 only when every command exits clean.

If anything fails:
- Read the full error output
- Fix the root cause, not the symptom
- Re-run to confirm the fix
- Never skip or disable a test to make it pass

### Step 7: Self-check

Re-read the original issue and confirm:

- [ ] Every acceptance criterion is met
- [ ] No edge cases are missed
- [ ] No leftover debug code, console.logs, or TODO comments
- [ ] No regressions in existing functionality
- [ ] No security issues introduced (input validation, auth, secrets)

### Step 8: Open PR and close issue

Create a pull request. The body becomes the review surface and closes the issue on merge:

```bash
gh pr create \
  --title "<type>: <one-line summary> (closes #<issue-number>)" \
  --body "$(cat <<'EOF'
## Summary

<what changed and why — files modified, features added/fixed>

## Tests

<what's covered by the new/changed tests>

## Open questions

<anything unresolved worth discussing in review, or "None">

Closes #<issue-number>
EOF
)"
```

If the repo has CI and auto-merge enabled:
```bash
gh pr merge --auto --squash --delete-branch
```

If CI fails, invoke `/build-fix` or `/test-fix` as appropriate, push the fix on the same branch, then re-watch.
