---
name: issue-prioritiser
description: Reviews open GitHub issues in the current repo, applies priority labels, checks relevance, and recommends the next issues to work on. Use when the user mentions prioritising issues, triaging the backlog, "what should I work on next", ranking issues, labelling priorities, or reviewing open issues for importance.
---

# Prioritising GitHub Issues

Review open issues in the current repo, apply priority labels, assess relevance, and recommend the top issues to work on next.

## Core Rules

1. **Label every issue** in the filter — not just the top ones.
2. **Ask before closing.** If an issue looks stale or done, flag it but don't close it (use the `closing-issues` skill for that).
3. **Ask clarifying questions** on unclear issues rather than guessing their intent.
4. **Consider the current state of the codebase** when judging relevance and priority.

## Workflow

Copy this checklist and keep it updated while working:

```text
Issue Prioritisation Progress
- [ ] Step 1: Determine scope (repo, filter, label set)
- [ ] Step 2: Fetch matching issues
- [ ] Step 3: Assess and label each issue
- [ ] Step 4: Rank top recommendations
- [ ] Step 5: Report summary
```

### Step 1: Determine scope

Ask the user (if not already provided):

1. **Which issues to review** — a milestone filter, label filter, or just all open issues.
   Default: `is:issue state:open` (all open issues in the current repo).
2. **Priority labels available** — use the repo's existing priority labels if they exist.
   Default set (create if missing): `priority: highest`, `priority: high`, `priority: medium`, `priority: low`, `priority: nice to have`.
3. **How many to recommend** — how many top issues to surface.
   Default: 5.

### Step 2: Fetch matching issues

List all issues matching the filter. Note each issue's number, title, current labels, and age.

### Step 3: Assess and label each issue

For each issue, evaluate three things:

**A. Relevance** — Is this still needed?

| Signal | Verdict |
|--------|---------|
| Feature/fix is already in the codebase | Flag as potentially done |
| Requirement is obsolete (superseded, no longer applies) | Flag as potentially stale |
| Still clearly needed | Relevant |

**B. Clarity** — Is the issue well-defined enough to act on?

If the description is vague, missing acceptance criteria, or ambiguous, post a comment asking for clarification. Don't guess at priority for unclear issues — label them `priority: medium` as a placeholder and note the question in the summary.

**C. Priority** — Apply a label based on:

| Factor | Raises priority | Lowers priority |
|--------|----------------|-----------------|
| User-facing impact | Blocks users, data loss, broken core flow | Cosmetic, edge case, nice-to-have |
| Frequency | Affects many/all users | Affects rare scenarios |
| Dependencies | Unblocks other issues | Standalone |
| Complexity vs value | High value, low effort | High effort, low value |
| Urgency | Security, compliance, outage | No deadline |

Apply exactly one priority label to each issue.

### Step 4: Rank top recommendations

From the labelled issues, pick the top N (default 5) to recommend working on next. Order by priority label first, then by effort-to-value ratio. Briefly explain why each is recommended.

### Step 5: Report summary

```text
Issues reviewed: X
Labels applied:  Y

Priority breakdown:
  highest:     N
  high:        N
  medium:      N
  low:         N
  nice to have: N

Flagged for review:
- #12 — [title] — Possibly already done
- #34 — [title] — Needs clarification (question posted)

Recommended next 5:
1. #56 — [title] — [reason]
2. #78 — [title] — [reason]
3. #90 — [title] — [reason]
4. #11 — [title] — [reason]
5. #22 — [title] — [reason]
```

## Edge Cases

- **No priority labels exist in the repo**: Create them. Use the default set above with appropriate colours.
- **Issue already has a priority label**: Re-evaluate it. Update if your assessment differs, and note the change in the summary.
- **Too many issues to review in one pass**: Process in batches. Tell the user how many remain and ask whether to continue.