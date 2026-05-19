---
name: branch-prune
description: Prunes stale local and remote branches whose patches are already on the default branch (squash-merge ghosts). Uses `git cherry` to distinguish ghosts from branches with genuinely unmerged work, presents the proposed deletions for explicit user approval, and only deletes on confirmation. Handles dependabot/copilot/feature/fix/docs branches that accumulate forever in squash-merge workflows. Trigger phrases include "clean up branches", "prune branches", "delete merged branches", "stale branches", "remove squash-merged branches", "branch cleanup", "tidy git branches".
---

# Branch prune

Classifies every local + remote working branch into **Delete** (patches already on `main`) or **Keep** (has unmerged commits), presents the proposal, and deletes the Delete set after explicit user approval.

## Why this exists

Squash-merge workflows leave behind branches whose changes are on `main` but whose tip commits look "unmerged" to `git branch --merged` (different SHAs). They pile up — dependabot, copilot, and old feature branches especially. `git cherry main <branch>` is the right primitive: it lists commits in `<branch>` with no equivalent patch on `main`. No `+` lines means the branch is safe to delete.

## Workflow

### Step 1: Inventory

```bash
git fetch --prune
git for-each-ref --format='%(refname:short)' refs/heads/ refs/remotes/origin/
```

Filter to candidate prefixes — defaults: `feature/*`, `fix/*`, `chore/*`, `docs/*`, `copilot/*`, `dependabot/*`. Exclude `main`, `release/uat`, `release/prod`, and anything covered by branch protection.

### Step 2: Classify

For each candidate, run:

```bash
git cherry main <branch>
```

- **No output, or only `-` lines** → all patches already on `main`. **Delete.**
- **Any `+` lines** → unmerged commits. **Keep.** Capture `git diff --stat main..<branch>` for the user.
- **Branch deleted on remote, local has only `-` lines** → ghost local. **Delete (local only).**

### Step 3: Present the proposal

Output one block per category. **Do not delete yet.**

```
Delete (squash-merge ghosts, no unmerged work):
  - feature/foo-thing       (local + remote)
  - dependabot/npm/bar-1.2  (remote only)
  - copilot/baz-789         (local only)
  ...

Keep (has unmerged commits — recommend re-review):
  - feature/in-flight-x     (3 commits, 28 LOC changed)
  - fix/half-finished       (1 commit, 4 LOC changed)

Proposal: delete N branches, keep M. Confirm to proceed.
```

### Step 4: Delete on approval

Only after explicit "yes" / "go" / equivalent. For each Delete entry:

```bash
git branch -D <local-branch>              # local
git push origin --delete <remote-branch>  # remote
```

Report final counts and any failures.

## Guardrails

- **Never delete `main`, `release/uat`, `release/prod`, or any protected branch.** Filter them out in Step 1.
- **Never delete without explicit user confirmation.** A general "clean up branches" request is not consent to delete — only the user's "yes" after seeing the Delete list is.
- **`git cherry` is authoritative.** Don't trust `git branch --merged` for squash-merge workflows.
- **If `main` isn't the default branch**, ask the user which base to compare against before classifying.
- **A branch with `+` lines and > 90 days old** stays in Keep but gets a "very stale — consider closing manually" flag.

## Output

```
Pruned N branches (X local-only, Y remote-only, Z both). Kept M with unmerged work.
```
