# GitHub Issue Management for Rework

The `gh` CLI patterns the rework skill uses to close, update, reopen, and create issues. Each operation has a recommended form that produces a clean audit trail.

## Inventorying issues

Before any change, list open and recently closed issues:

```bash
# Open issues, with labels, milestone, and full body
gh issue list --state open --limit 200 \
  --json number,title,labels,milestone,body,assignees \
  > /tmp/rework-open.json

# Recently closed, in case the rework reopens something
gh issue list --state closed --limit 50 \
  --json number,title,labels,milestone,closedAt,stateReason \
  > /tmp/rework-closed.json

# Find issues with linked PRs — closing these needs extra care
gh search prs --state open --json number,title,body --jq '
  .[] | {pr: .number, title, linked_issues: (.body | scan("(?:closes|fixes|resolves)\\s+#(\\d+)") | .[0])}'
```

## Closing an issue

The closure comment is **mandatory** — it's the durable record of why the issue is no longer in flight. The skill must always include it.

```bash
gh issue close <number> --comment "$(cat <<'EOF'
Closed during rework session YYYY-MM-DD.

<One-sentence reason linking to the rework rationale.>

<Optional: replaced by #<new-issue>, or "requirement deleted; see session log entry YYYY-MM-DD".>
EOF
)"
```

If the issue has an open linked PR, **don't auto-close**. Stop and ask the user:

> "Issue #X has an open PR #Y linked to it. Closing this issue while the PR is in flight will leave the PR with a dangling reference. Options:
> - Close the PR first (`gh pr close Y`), then close this issue.
> - Merge the PR first, then close (only if the work is wanted).
> - Leave the issue open until the PR is resolved, then close after.
> Which?"

## Updating an issue

For requirement changes that don't invalidate the task entirely but change its scope or acceptance criteria:

```bash
# Edit the title (rare — usually the task title still describes the work)
gh issue edit <number> --title "<new title>"

# Edit the body (common — when AC or DoD shifts)
gh issue edit <number> --body-file /tmp/issue-N-new-body.md

# Edit labels — for priority shifts due to rework
gh issue edit <number> --add-label "priority:medium" --remove-label "priority:high"

# Change milestone — if the rework reshuffles phases
gh issue edit <number> --milestone "Phase 2: Core"
```

**When editing the body**, preserve the cross-references format (`Implements:`, `Blocked by:`, `Blocks:`) — they're the dependency graph. If the rework changes what the task implements, update the `Implements:` line; don't strip it.

After editing, **add a comment** explaining what changed and why:

```bash
gh issue comment <number> --body "$(cat <<'EOF'
Updated during rework session YYYY-MM-DD.

**Changed:** <One-line summary — "acceptance criterion AC3 was tightened to require pathname-based URLs after assumption A-004 was validated">

**Why:** <Link to rework rationale.>
EOF
)"
```

The comment is the audit trail; the edit is the new state. Both matter.

## Reopening an issue

If the rework reverses a previous closure decision:

```bash
gh issue reopen <number> --comment "$(cat <<'EOF'
Reopened during rework session YYYY-MM-DD.

<Why the original closure decision is being reversed.>
EOF
)"
```

Update labels and milestone afterward if the rework places the task in a new phase. Don't expect labels/milestone to be correct from the original — they may have been removed or stale.

## Creating new issues

New issues from rework follow the same template as `/tasks-from-requirements` (see the `tasks-from-requirements` skill's `references/issue-template.md`). The only difference is the **`Context` section** — the new issue should cite the rework session as its origin:

```markdown
## Context

- **Phase / milestone:** Phase N — <theme>
- **Estimated effort:** <e.g. half a day>
- **Blocked by:** #<num>
- **Blocks:** #<num>
- **Requirement source:** [docs/requirements/<file>](../docs/requirements/<file>)
- **Origin:** Rework session YYYY-MM-DD — see session log.
```

The `Origin: Rework session ...` line is what distinguishes a rework-born task from a `/tasks-from-requirements`-born task in the audit trail.

```bash
gh issue create \
  --title "<phase>.<num> <title>" \
  --body-file /tmp/new-issue-body.md \
  --label "<labels>" \
  --milestone "<phase milestone>"
```

## Batch operations

Two patterns for batched changes that keep the audit trail readable:

### Batched close

When multiple issues are closing for the same rework reason (common — a feature is dropped and 6 tasks die with it):

```bash
for n in 12 14 15 16 17 19; do
  gh issue close "$n" --comment "Closed during rework session 2026-05-13. The 'X feature' is no longer being built (see session log entry 2026-05-13). Replaced by simpler approach — see #34."
done
```

The closure comments are identical on each, so a reader scanning the closed-issue list sees the pattern.

### Batched milestone reassignment

When the rework reshuffles phases (e.g. work that was Phase 3 is now Phase 2 because the upstream blocker disappeared):

```bash
for n in 21 22 23 24; do
  gh issue edit "$n" --milestone "Phase 2: Core Auth & Profile"
done
gh issue comment 21 --body "Promoted to Phase 2 along with #22, #23, #24 during rework session 2026-05-13 — upstream blocker (Phase 1 task X) was eliminated."
```

One comment on the lowest-numbered issue is enough; cross-referencing the others. Don't comment on all four — that's noise.

## Two-pass create-then-link

If a rework creates multiple new issues that block each other, create them in topological order (no blockers first), then in a second pass edit each body to insert the now-known issue numbers in `Blocked by:` and `Blocks:` fields:

```bash
# Pass 1: create all issues in dependency order
url1=$(gh issue create --title "5.1 Foo" --body-file /tmp/5.1.md ...)
url2=$(gh issue create --title "5.2 Bar (blocked by 5.1)" --body-file /tmp/5.2.md ...)
url3=$(gh issue create --title "5.3 Baz (blocked by 5.1)" --body-file /tmp/5.3.md ...)

# Pass 2: extract numbers and patch bodies
n1="${url1##*/}"; n2="${url2##*/}"; n3="${url3##*/}"
gh issue edit "$n2" --body-file <(sed "s/BLOCKER_PLACEHOLDER/#$n1/g" /tmp/5.2.md)
gh issue edit "$n3" --body-file <(sed "s/BLOCKER_PLACEHOLDER/#$n1/g" /tmp/5.3.md)
gh issue edit "$n1" --body-file <(sed "s/BLOCKS_PLACEHOLDER/#$n2, #$n3/g" /tmp/5.1.md)
```

Same pattern `/tasks-from-requirements` uses; reused here verbatim.

## What never to do

- **Never `gh issue delete`.** Deletion destroys the audit trail. Close instead.
- **Never edit a closed issue's body.** It's an archived state. If you need to add context, comment.
- **Never auto-bulk-close without surfacing the list first.** Always show the user what's about to be closed.
- **Never close an issue without a comment.** Even if the reason is "subsumed by #N", that link is the audit trail.
- **Never strip the `Implements:` line during an edit.** If the requirement it implements is itself being deleted, decide whether the task is also being closed (most likely) — don't leave a dangling task with no requirement link.
