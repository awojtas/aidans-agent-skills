---
name: issue-closer
description: Reviews open GitHub issues in the current repo and closes any where the work has been fully completed and checked in. Use when the user mentions closing stale issues, cleaning up done issues, "close completed issues", "review open issues", tidying the backlog, or when issues may have been implemented but not closed.
---

# Closing Completed GitHub Issues

Review all open GitHub issues in the current repo. Close issues where the work is fully implemented and checked in. Leave issues open when uncertain.

## Core Rules

1. **Default to leaving open.** Only close an issue when evidence clearly shows full completion.
2. **Never close without a comment** explaining what evidence confirmed the work is done.
3. **One issue at a time.** Fully evaluate before moving to the next.
4. **Partial work is not done.** If only some acceptance criteria are met, leave it open.

## Workflow

Copy this checklist and keep it updated while working:

```text
Issue Cleanup Progress
- [ ] Step 1: List all open issues
- [ ] Step 2: For each issue, gather evidence of completion
- [ ] Step 3: Close confirmed-done issues with comment
- [ ] Step 4: Report summary
```

### Step 1: List all open issues

Fetch all open issues in the repo. Note each issue number, title, and labels.

### Step 2: Evaluate each issue

For each open issue, determine whether the work has been fully completed:

**Evidence sources** (check in this order):
1. **Issue description / acceptance criteria** — understand what "done" means for this issue
2. **Linked PRs or branch references** — check if a merged PR references the issue
3. **Commit history** — search for commits mentioning the issue number (`#123`, `fixes #123`, etc.)
4. **Codebase search** — look for the feature/fix described in the issue in the current code

**Classification:**

| Evidence | Verdict | Action |
|----------|---------|--------|
| Merged PR that references the issue + code confirms implementation | **Done** | Close with comment |
| Commits reference the issue + feature is clearly present in code | **Done** | Close with comment |
| Feature exists in code but no explicit link to the issue | **Likely done** | Close with comment noting the assumption |
| Partial implementation or only some criteria met | **Not done** | Leave open |
| No evidence of work | **Not done** | Leave open |
| Ambiguous — can't confidently determine | **Uncertain** | Leave open |

### Step 3: Close confirmed issues

For each issue classified as done, add a comment and close it:

**Comment format:**
> Closing — this issue appears to have been completed. [brief evidence summary, e.g. "Implemented in PR #45" or "Feature is present in `src/auth/login.ts` matching the described requirements."]
>
> If this was closed in error, please reopen.

### Step 4: Report summary

After processing all issues, provide a summary:

```text
Issues reviewed: X
Issues closed:   Y
Issues left open: Z

Closed:
- #12 — [title] — [reason]
- #34 — [title] — [reason]

Left open (uncertain or incomplete):
- #56 — [title] — [reason left open]
```

## Edge Cases

- **Issues with no clear acceptance criteria**: Check if the issue title/description implies a specific change, search for that change. If still ambiguous, leave open.
- **Issues that reference external dependencies or infrastructure**: Leave open unless you can verify from the codebase alone.
- **Bug reports**: Look for the fix described or the regression test. If the buggy behavior is no longer reproducible from reading the code, treat as likely done.