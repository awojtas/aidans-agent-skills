---
name: sentry-recent-issues
description: Investigate recent or specific Sentry issues for any project. Fetches issues via the Sentry MCP, determines frequency and recurrence, researches root cause in the codebase, and recommends fixes with regression tests. Use when the user mentions Sentry issues, production errors, error monitoring, or asks to triage recent exceptions.
---

# Investigating Sentry Issues

Before starting, ask the user for any values not already provided:

- **Organisation** — Sentry organisation slug
- **Project** — Sentry project slug
- **Environment** — e.g. `production`, `staging`
- **Time window** — how far back to look (e.g. `12 hours`, `24 hours`)
- **Specific issue ID** — if investigating a single issue (e.g. `PROJECT-42`)

## Workflow A: Scan recent issues

Use when the user wants an overview of what went wrong recently.

```
Task Progress:
- [ ] Step 1: Fetch recent issues from Sentry
- [ ] Step 2: Assess frequency and recurrence
- [ ] Step 3: Summarise findings
- [ ] Step 4: Research root cause in codebase
- [ ] Step 5: Recommend fix and regression test
```

**Step 1 — Fetch recent issues**

Use the Sentry MCP to list issues raised within the requested time window for the given organisation, project, and environment.

**Step 2 — Assess frequency and recurrence**

For each issue, check Sentry for previous occurrences. Classify as:
- **Recurring** — seen before across multiple time periods
- **Regression** — previously resolved, now reappeared
- **New** — first occurrence

**Step 3 — Summarise findings**

Provide a concise summary per issue: title, frequency classification, affected users/transactions, and first/last seen timestamps.

**Step 4 — Research root cause in codebase**

Search the workspace for code referenced in the stack trace. Identify the likely root cause.

**Step 5 — Recommend fix and regression test**

Suggest a root-cause fix so the issue does not reoccur. Recommend an appropriate test (unit, integration, or e2e) to prevent re-release.

## Workflow B: Investigate a specific issue

Use when the user provides a specific Sentry issue ID.

```
Task Progress:
- [ ] Step 1: Fetch the specific issue from Sentry
- [ ] Step 2: Check for prior occurrences
- [ ] Step 3: Summarise the issue
- [ ] Step 4: Research root cause in codebase
- [ ] Step 5: Recommend fix and regression test
```

**Step 1 — Fetch the specific issue**

Use the Sentry MCP to retrieve the issue by ID for the given organisation, project, and environment.

**Step 2 — Check for prior occurrences**

Look up Sentry history for the same error. Classify as recurring, regression, or new.

**Step 3 — Summarise the issue**

Provide: title, stack trace summary, frequency classification, affected users/transactions, first/last seen.

**Step 4 — Research root cause in codebase**

Search the workspace for code referenced in the stack trace. Identify the likely root cause.

**Step 5 — Recommend fix and regression test**

Suggest a root-cause fix so the issue does not reoccur. Recommend an appropriate test (unit, integration, or e2e) to prevent re-release.