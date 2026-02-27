---
name: issue-worker
description: Implements a GitHub issue end-to-end in any codebase — reads the issue, explores the project, writes code, adds tests, and verifies everything passes. Use when the user says "work on issue", "implement issue #", "pick up issue", "fix issue", "start on this ticket", or provides a GitHub issue link or number to implement.
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
- [ ] Step 8: Summarize changes
```

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

Run the project's full verification suite. Discover commands from Step 2, then run them:

1. **Lint** — fix all warnings and errors
2. **Type-check** — if the project uses static types
3. **Build** — confirm it compiles cleanly
4. **Tests** — run both unit and E2E suites

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

### Step 8: Summarize

Provide a concise summary:

- **What changed** — files modified, features added/fixed
- **Tests added** — what's covered
- **Open questions** — anything unresolved or worth discussing in PR review
