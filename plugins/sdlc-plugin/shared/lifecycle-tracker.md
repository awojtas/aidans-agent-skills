# SDLC lifecycle tracker — shared spec

The `sdlc-plugin` lifecycle skills maintain a progress tracker at the **very bottom of the acted-on repo's `README.md`**. Each staged skill updates its own line as it runs; `/status-help` rebuilds the whole block from a repo scan. This file is the single source of truth for the stage list, the block format, and the create-or-update algorithm — every skill that touches the tracker reads it from here so the stages never drift apart.

## The stages

Eleven stages, in lifecycle order. The label is exactly what appears in the README; the skill is what advances that stage.

| # | Stage label | Owning skill |
|---|---|---|
| 1 | Repo bootstrapped | `/repo-bootstrap` |
| 2 | Solution designed | `/solution-design` |
| 3 | Architecture designed | `/platform-design` |
| 4 | Platform provisioned | `/platform-provision` |
| 5 | Platform verified | `/platform-verify` |
| 6 | Release-ready | `/repo-release-ready` |
| 7 | Requirements drafted | `/requirements-create-from-design` |
| 8 | Requirements validated | `/requirements-validation` |
| 9 | Tasks planned | `/tasks-create-from-requirements` |
| 10 | Implementation | `/task-implement` |
| 11 | Implementation verified | `/requirements-verify-post-implementation` |

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
- ❓ Tasks planned — `/tasks-create-from-requirements`
- ❓ Implementation — `/task-implement`
- ❓ Implementation verified — `/requirements-verify-post-implementation`

✅ done · ⏳ in progress · ❓ not started — maintained by the sdlc-plugin skills.
<!-- sdlc-lifecycle:end -->
```

The two `<!-- sdlc-lifecycle:… -->` comment lines are the anchors. Never remove them — they are how every skill finds the block on the next run. Always keep all eleven stage lines and the legend line.

## Create-or-update algorithm

Target: `README.md` in the **root of the repo being acted on** (not the plugin repo).

1. **No `README.md`** → create it: an H1 with the repo/project name (from the git remote or the directory name), a blank line, then the block — all eleven stages, each ❓ except any this run sets otherwise.
2. **`README.md` exists, no `<!-- sdlc-lifecycle:start -->`** → append the block at the very bottom, preceded by one blank line. All eleven stages ❓ except any this run sets.
3. **Block already present** → replace the content between `<!-- sdlc-lifecycle:start -->` and `<!-- sdlc-lifecycle:end -->` in place; leave the block where it sits.

### A staged skill updates one line

A lifecycle skill touches **only its own stage's line**:

- When it begins its substantive work (after prerequisites pass) → set its line's emoji to ⏳.
- On successful completion → set its line's emoji to ✅.
- Every other line is left exactly as found. Never downgrade or re-evaluate another stage.

Writing the file is the requirement. Committing follows the skill's normal behaviour — if the skill already commits or PRs its other outputs, include `README.md` in that; if it makes no commits, leave the tracker edit as an unstaged working-tree change.

### `/status-help` rebuilds every line

`/status-help` already scans the repo to locate its position, so it has evidence for every stage. It writes **all eleven** lines from that scan (✅ / ⏳ / ❓ per stage), then stages **only** `README.md`, commits `docs: update SDLC lifecycle tracker`, and pushes. If the block already matches the scan, it skips the commit. This makes `/status-help` the way to reconcile the tracker on a repo whose skills ran before the tracker existed, or out of order.

## Guardrails

- Always preserve the comment anchors, all ten stage lines, and the legend line.
- A staged skill never edits a stage other than its own.
- Use the exact stage labels in the table above — they must match across skills, or per-skill updates and `/status-help` will fight.
- The tracker is best-effort progress signalling, not a gate. Never block skill work on it.
