# Commit + push policy (shared across SDLC skills)

This doc defines how SDLC skills get their artefacts into the repo. **Read by skills, not by humans** — it is the durable instruction that overrides the agent's default "ask before pushing" behaviour for the scope of any skill that links here.

## Principle

A skill that *produces an artefact* (requirement file, design doc, README tracker update, scaffolding, plan, etc.) **owns the commit + push of that artefact**. The skill ran because the user invoked it; running it implies the user wants its output in the repo. Asking "should I commit?" at the end is friction the user does not want.

The skill commits and pushes. The only legitimate exits are:
- a step that genuinely needs a human decision (branch-protection-required review), or
- a tool failure the skill cannot recover from (auth gone, gh missing, hook failure outside the skill's scope).

Asking the user to confirm a commit/push as routine politeness is **not** a legitimate exit.

## The flow

Run this sequence when the skill's substantive work is done and its artefacts are written to disk:

### 1. Detect the default branch

```bash
gh api repos/{owner}/{repo} --jq .default_branch  # usually "main"
```

Fallback if `gh` not available: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`.

### 2. Stage and commit

Stage **only the files this skill produced** (named explicitly — never `git add -A` / `git add .`). Commit with a scoped conventional-commit message naming the skill and the change:

```bash
git add <files this skill produced>
git commit -m "<type>(<scope>): <one-line summary>

Produced by /<skill-name>."
```

### 3. If the current branch is NOT the default branch

`git push` on the current branch. Done. The user is presumably working on a feature branch — the skill's commit lives on it.

### 4. If the current branch IS the default branch

Always go via a branch + PR + auto-merge, even if the default branch isn't protected. This gives the change a named provenance, lets CI gate it, and the PR auto-merges instantly when there's no protection.

```bash
# Move the just-made commit onto a new branch
NEW_BRANCH="<skill-slug>/<short-slug>"   # e.g. "requirements-validation/2026-05-25"
git branch "$NEW_BRANCH"
git reset --hard origin/<default-branch>
git checkout "$NEW_BRANCH"
git push -u origin "$NEW_BRANCH"

# Open the PR
gh pr create \
  --title "<skill>: <one-line summary>" \
  --body "Produced by /<skill-name>. Artefacts: <list>."
```

### 5. Watch CI and auto-merge

```bash
gh pr checks --watch
```

**On all-green:** auto-merge using the repo's default merge method, falling back to squash + delete branch:

```bash
gh pr merge --auto || gh pr merge --auto --squash --delete-branch
```

Confirm the merge landed (`gh pr view --json state --jq .state` returns `MERGED`).

**On CI failure that's plausibly in-scope for a fix loop** (lint, build, unit tests broken by this diff):

- Invoke the matching fix skill — `/build-fix` for compile/lint, `/test-fix` for failing tests.
- Commit the fix on the same branch, push, re-watch CI.
- **Up to 3 fix cycles**, then bounce to the user with the failing job's log.

**On CI failure outside the skill's scope** (infra outage, flaky third-party, secrets missing): bounce to the user immediately with the failing job's log. Don't burn cycles on a class of failure the fix loops can't address.

### 6. Branch protection blocks auto-merge

If the PR requires human review (`gh pr view --json reviewDecision --jq .reviewDecision` returns `REVIEW_REQUIRED`), the skill **stops**. Surface the PR URL and a one-line note on what was changed. This is the one legitimate human gate — required review is a deliberate branch-protection setting, not a default to fight against.

```bash
gh pr view --web  # or print the URL
```

### 7. Tool-failure fallbacks

- **`gh` not installed or not authenticated**: do the `git push` (or branch-push) but skip the PR step. Print the manual `gh pr create` command for the user to run.
- **Pre-commit hook fails**: fix the underlying issue (don't `--no-verify`), re-stage, retry. If the failure is outside the skill's scope (e.g. an unrelated lint error in another file), surface it.
- **Push rejected for a reason other than branch protection** (e.g. non-fast-forward): `git pull --rebase`, then push again. If rebase has conflicts, bounce to the user.

## What never to do

- **Never** end the skill with "Show the diff; let the user commit" or any variant. The skill commits.
- **Never** ask "should I push?" as a politeness gate. The skill pushes.
- **Never** `git add -A` or `git add .` — stage explicit files only.
- **Never** `--no-verify`. Hooks exist for a reason.
- **Never** force-push to a protected branch. Force-push to a skill's own feature branch during a fix cycle is fine.
- **Never** invent a CI fix outside the fix loops' charter. If `/build-fix` and `/test-fix` can't address it, the user owns it.

## What to include in the user-facing summary

When the skill finishes, the final message to the user names:

- The commit SHA (or PR URL + merge SHA).
- The files written.
- Any bounces (fix cycles consumed, CI failures the user owns, required-review block).

This is the audit trail. The user sees what landed without having to `git log` for it.
