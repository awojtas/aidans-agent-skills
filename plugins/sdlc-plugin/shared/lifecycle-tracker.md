# SDLC lifecycle tracker — shared spec

The `sdlc-plugin` lifecycle skills maintain a progress tracker at the **very bottom of the acted-on repo's `README.md`**. Each staged skill updates its own line as it runs; `/status-help` rebuilds the whole block from a repo scan. This file is the single source of truth for the stage list, the block format, and the create-or-update algorithm — every skill that touches the tracker reads it from here so the stages never drift apart.

## The stages

The lifecycle stages, in order. The label is exactly what appears in the README; the skill is what advances that stage.

| Stage label | Owning skill |
|---|---|
| Repo bootstrapped | `/repo-bootstrap` |
| Solution designed | `/solution-design` |
| Architecture designed | `/platform-design` |
| Platform provisioned | `/platform-provision` |
| Platform verified | `/platform-verify` |
| Release-ready | `/repo-release-ready` |
| Requirements drafted | `/requirements-create-from-design` |
| Requirements validated | `/requirements-validation` |
| Tasks planned | `/tasks-create-from-requirements` |
| Implementation | `/task-implement` |
| Implementation verified | `/requirements-verify-post-implementation` |

## The emoji legend

- ✅ — done. The stage completed successfully.
- ⏳ — in progress. The owning skill has started but not finished (also covers abandoned and multi-session runs).
- ❓ — not started.

## The block

A find-and-replace-safe block delimited by HTML comments, living at the **very bottom** of `README.md`:

```markdown
<!-- sdlc-lifecycle:start -->
## SDLC progress

- ✅ Repo bootstrapped — `/repo-bootstrap`
- ✅ Solution designed — `/solution-design`
- ⏳ Architecture designed — `/platform-design`
- ❓ Platform provisioned — `/platform-provision`
- ❓ Platform verified — `/platform-verify`
- ❓ Release-ready — `/repo-release-ready`
- ❓ Requirements drafted — `/requirements-create-from-design`
- ❓ Requirements validated — `/requirements-validation`
- ✅ Tasks planned — `/tasks-create-from-requirements` — 56 tasks
- ⏳ Implementation — `/task-implement` — 🟩🟩🟩🟩🟩⬜⬜⬜⬜⬜ 30 of 56 closed
- ❓ Implementation verified — `/requirements-verify-post-implementation`

✅ done · ⏳ in progress · ❓ not started — maintained by the sdlc-plugin skills.
<!-- sdlc-lifecycle:end -->
```

The two `<!-- sdlc-lifecycle:… -->` comment lines are the anchors. Never remove them — they are how every skill finds the block on the next run. Always keep every stage line and the legend line.

## Stage-specific detail

Two stages carry extra inline detail appended after a ` — ` separator. Other stages have no trailing detail.

**Tasks planned** (once `/tasks-create-from-requirements` has run):
```
- ✅ Tasks planned — `/tasks-create-from-requirements` — 56 tasks
```
The number is the total GitHub issue count (open + closed) at the time of the scan. Queried as:
```bash
gh issue list --state all --json number --jq 'length'
```

**Implementation** (once `/tasks-create-from-requirements` has run and there are issues):

Single milestone (or no milestones — all issues in one pool):
```
- ⏳ Implementation — `/task-implement` — 🟩🟩🟩🟩🟩⬜⬜⬜⬜⬜ 30 of 56 closed
```

Multiple milestones — show a per-milestone bar as sub-bullets under the stage line:
```
- ⏳ Implementation — `/task-implement` — 30 of 56 closed
  - 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩 Phase 1 – Core ✅
  - 🟩🟩🟩🟩🟩⬜⬜⬜⬜⬜ Phase 2 – Extended
  - ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ Phase 3 – Polish
```

The progress bar is exactly 10 emoji: `🟩` for each completed tenth (rounded), `⬜` for the rest. Append ` ✅` after the milestone title when that milestone is fully closed. The counts use `gh` queries:
```bash
# Overall totals
total=$(gh issue list --state all --json number --jq 'length')
closed=$(gh issue list --state closed --json number --jq 'length')
# filled = round(closed / total * 10); bar = 🟩×filled + ⬜×(10-filled)

# Per-milestone breakdown (when > 1 milestone exists)
gh api repos/{owner}/{repo}/milestones --jq '.[] | {title: .title, open: .open_issues, closed: .closed_issues}'
```
If `total` is 0 (no issues yet), omit the bar and counts — just the emoji and stage label.
When implementation is ✅ (all closed), the overall bar and every milestone bar are all `🟩`.

## Create-or-update algorithm

Target: `README.md` in the **root of the repo being acted on** (not the plugin repo).

1. **No `README.md`** → create it: an H1 with the repo/project name (from the git remote or the directory name), a blank line, then the block — every stage ❓ except any this run sets otherwise.
2. **`README.md` exists, no `<!-- sdlc-lifecycle:start -->`** → append the block at the very bottom, preceded by one blank line. Every stage ❓ except any this run sets.
3. **Block already present** → replace the content between `<!-- sdlc-lifecycle:start -->` and `<!-- sdlc-lifecycle:end -->` in place; leave the block where it sits.

### A staged skill updates one line

A lifecycle skill touches **only its own stage's line**:

- When it begins its substantive work (after prerequisites pass) → set its line's emoji to ⏳.
- On successful completion → set its line's emoji to ✅.
- Every other line is left exactly as found. Never downgrade or re-evaluate another stage.

Writing the file is the requirement. Committing follows the skill's normal behaviour — if the skill already commits or PRs its other outputs, include `README.md` in that; if it makes no commits, leave the tracker edit as an unstaged working-tree change.

### `/status-help` rebuilds every line

`/status-help` already scans the repo to locate its position, so it has evidence for every stage. It writes **every** stage line from that scan (✅ / ⏳ / ❓ per stage), then stages **only** `README.md`, commits `docs: update SDLC lifecycle tracker`, and pushes. If the block already matches the scan, it skips the commit. This makes `/status-help` the way to reconcile the tracker on a repo whose skills ran before the tracker existed, or out of order.

## Guardrails

- Always preserve the comment anchors, every stage line, and the legend line.
- A staged skill never edits a stage other than its own.
- Use the exact stage labels in the table above — they must match across skills, or per-skill updates and `/status-help` will fight.
- The tracker is best-effort progress signalling, not a gate. Never block skill work on it.
