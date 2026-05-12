---
name: check-work
description: Standalone "check your work carefully" audit pass. Inspects a slice of recent work — by default the uncommitted plus unpushed changes on the current branch — and reports defects with file:line references. Applies the universal Work-Checker checklist (TODO/FIXME left behind, swallowed exceptions, magic numbers, commented-out code, debug prints, hardcoded values, secrets, atomic-commit hygiene, --no-verify, accurate commit messages, silent config relaxations) plus a role-specific layer chosen from what the diff actually contains (implementation, tests, IaC, UX/design, project-management claims). Defaults to a critical, specific, named-defect output — not pedantry, not feature requests. Hard limit at two passes; if the same work bounces twice, surfaces the deeper problem. Same pattern as the Work Checker persona inside /implement-task, but invocable on its own slice of work — uncommitted diff, a branch, a commit range, a PR, or a path. Use when the user says "check my work", "audit this", "did I miss anything", "review this before I push", "self-review this PR", "look over the diff", "spot-check this branch", or asks for a critical pre-commit / pre-PR sweep. Empirically catches defects ~80% of the time. Companion to /implement-task — that one runs this audit after every persona phase; this skill lets you run the same audit on demand, outside the orchestration.
---

# Standalone "check your work" audit

This skill runs the same audit pass the Work Checker persona runs inside `/implement-task`, but on a user-chosen slice of work rather than after a persona phase. Empirically a "please just check your work carefully on this" pass surfaces defects the original work missed about 80% of the time (Madaan et al., *Self-Refine* — ~20pp absolute quality lift on a second-pass critique: https://arxiv.org/abs/2303.17651). The job is to make that audit deliberate and specific.

## What this skill does and doesn't do

**Does:**
- Audits a defined slice of work (default: uncommitted + unpushed changes on the current branch).
- Applies the universal Work-Checker checklist.
- Picks a role-specific checklist layer based on what's in the diff (code → PE; tests → TAE; IaC → CA; UX/UI → UX; etc.).
- Returns a structured **Clean** or **Defects** report with file:line references.
- Stops at two passes — if the same scope still has defects on the second look, surfaces the deeper problem.

**Doesn't:**
- **Doesn't redo the work.** It names defects; the human (or follow-up agent) fixes them. If the user asks you to fix what you found, that's a separate request — fine to do, but be explicit about switching modes.
- **Doesn't second-guess the requirement.** It checks delivery against the stated intent, not whether the intent was right.
- **Doesn't run the full test suite from scratch every time.** It spot-checks claims (e.g. "tests pass") only when relevant.
- **Doesn't pedant on typos in comments or stylistic taste.** The bar is *"would this materially harm the PR or the running system?"* If yes, flag. If no, let it go.
- **Doesn't post to GitHub by default.** The persona version inside `/implement-task` posts a `[Work Checker]` comment because that's the audit trail of the orchestration. The standalone skill returns its report to the user. Posting to a PR is a follow-up the user can ask for.

## Reference material

This skill is the standalone face of the same audit logic that `/implement-task`'s Work Checker uses. Read these sibling docs:

| File | Purpose |
|------|---------|
| `../implement-task/references/role-work-checker.md` | The full Work Checker charter, universal checklist, role-specific checklists, "check your work" prompt, and defect-comment templates. Read this first. |
| `../implement-task/references/code-review-checklist.md` | The PE's self-review checklist — useful additional surface when the diff is mostly production code. |
| `../implement-task/references/sdlc-pitfalls.md` | Named SDLC pitfalls + lazy-AI failure modes — broader context when something feels off but isn't on the universal list. |
| `../implement-task/references/role-principal-engineer.md` | "Lazy-PE failure modes" — apply when the diff is mostly implementation code. |
| `../implement-task/references/role-qa-engineer.md` | "Lazy-QA failure modes" — apply when AC has been edited or when test validation is in scope. |
| `../implement-task/references/role-cloud-architect.md` | "Lazy-CA failure modes" — apply when IaC, pipelines, or infrastructure files are in the diff. |
| `../implement-task/references/role-test-automation-engineer.md` | "Lazy-TAE failure modes" — apply when test files are in the diff. |
| `../implement-task/references/role-ux-designer.md` | "Lazy-UX failure modes" — apply when UI components, design tokens, or visual surfaces changed. |
| `../implement-task/references/role-project-manager.md` | "Lazy-PM failure modes" — apply when a PR/issue body has been edited or someone has claimed work is "done". |

If the user is running this skill outside the SDLC bundle (e.g. they installed only this skill) and the referenced files don't resolve, fall back to the universal checklist in the **Universal checklist** section below — it's a compact restatement of the universal section of `role-work-checker.md` and is enough to do a useful pass on its own.

## Prerequisites

1. **Working directory is inside a git repo.** Otherwise the default scope (uncommitted + unpushed work) doesn't make sense — ask the user to point you at something specific instead.
2. **Some scope to audit.** If the working tree is clean and the branch is up to date with origin and no scope was given, ask the user what they want audited.
3. **`gh` CLI available** if the user gave a PR number. If not installed, fall back to reading the PR locally via `git fetch origin pull/<N>/head:pr-<N>` and diffing against base.

## Workflow

```text
check-work progress:
- [ ] Step 1: Resolve scope — what exactly is being audited?
- [ ] Step 2: Gather the artefacts (diff, commits, file list, any claimed status)
- [ ] Step 3: Classify the work (code / tests / IaC / UX / docs / mixed)
- [ ] Step 4: Apply the universal checklist
- [ ] Step 5: Apply the role-specific checklist(s) for the classified work
- [ ] Step 6: Run the "check your work" prompt one more time
- [ ] Step 7: Produce the report (Clean or Defects)
- [ ] Step 8: If user asks for a second pass after fixes — re-run, but stop after the second pass
```

### Step 1: Resolve scope

Figure out what's being audited. In priority order:

1. **The user gave an explicit scope** (a PR number, a commit range like `HEAD~3..HEAD`, a branch name, a file path). Use it.
2. **There are uncommitted changes** in the working tree. Default scope = uncommitted changes (`git status` + `git diff` + `git diff --staged`).
3. **The current branch is ahead of `origin/<branch>` or `origin/main`**. Default scope = the unpushed/unmerged commits (`git log origin/main..HEAD` or `git log @{u}..HEAD`).
4. **None of the above** — working tree clean, branch up to date, no explicit scope. Ask the user what they want audited (single AskUserQuestion).

State the chosen scope back to the user in one line before proceeding, so they can correct if you picked wrong: e.g. *"Auditing the 4 unpushed commits on `feat/add-rate-limit` (vs `origin/main`)."*

### Step 2: Gather the artefacts

For the chosen scope, collect:

- **Diff.** `git diff <range>` for commit ranges; `git diff` + `git diff --staged` for uncommitted; `gh pr diff <N>` for PRs.
- **Commit list.** `git log --oneline <range>` so you can spot-check messages.
- **File list.** `git diff --name-only <range>` — quick way to classify the work.
- **Any "done" claims.** If the user said *"I just finished X — check my work"*, that sentence IS the claim. Audit against it. If you're auditing a PR, the PR description is the claim.

### Step 3: Classify the work

From the file list, classify the work — one or more categories. This drives which role-specific checklist applies in Step 5.

| Signal in diff | Apply role-specific checklist | From file |
|----------------|-------------------------------|-----------|
| Production source files (`src/`, `app/`, `lib/`, equivalents) | **PE / lazy-PE failure modes** | `role-principal-engineer.md` |
| Test files (`*_test.*`, `*.test.*`, `spec/`, `tests/`, `__tests__/`) | **TAE / lazy-TAE failure modes** | `role-test-automation-engineer.md` |
| IaC / pipelines (`*.tf`, `*.bicep`, `*.yaml` under `.github/workflows/`, `serverless.yml`, `Dockerfile`, `k8s/`, `infra/`) | **CA / lazy-CA failure modes** | `role-cloud-architect.md` |
| UI components, design tokens, styles (`*.tsx`/`*.vue` under `components/`, `*.css`, `tokens.*`) | **UX / lazy-UX failure modes** | `role-ux-designer.md` |
| Issue body / PR description edits, "done" claims | **PM / lazy-PM failure modes** | `role-project-manager.md` |
| AC edits, fixture files, test plans | **QA / lazy-QA failure modes** | `role-qa-engineer.md` |
| Docs only (`*.md`, `README`) | Apply universal only; lazy-role checklists rarely add value for docs |

Mixed diffs (almost always the case) apply more than one. Don't make this a giant matrix though — pick the **one or two layers** that look most relevant. If you'd be applying five, the scope is too big and you should ask the user to narrow it.

### Step 4: Apply the universal checklist

For every audit, regardless of classification, walk these items. They come straight from `role-work-checker.md`'s universal section.

- [ ] **Claim vs reality.** Did the work actually do what was claimed? Read any "I did X" sentence (commit message, PR description, the user's prompt) against the diff. Mismatch = defect.
- [ ] **Right artefacts for the scope.** If the scope is "implementation", a diff that's only tests is a mismatch. If the scope is "fix bug Y", a diff that touches unrelated files is a smell.
- [ ] **TODO / FIXME / XXX additions.** `git diff <range> | grep -E '^\+.*(TODO|FIXME|XXX|HACK)'`. Any newly-added one is a defect unless deliberately scoped (with an issue reference inline).
- [ ] **Skipped tests / lints.** Did any test get `.skip` / `xfail` / `it.only` / `describe.only` added? Was a lint rule disabled or a `// eslint-disable` / `// @ts-ignore` / `# noqa` / `# type: ignore` added? Was any test file deleted? Each is a defect unless justified in the diff itself.
- [ ] **Silent config relaxations.** `.eslintrc`, `tsconfig.json` strict flags, `pyproject.toml` ruff/mypy config, `.prettierrc`, CI config — any rule loosened to make a build pass is a defect, even if the build is green now.
- [ ] **Files that shouldn't be committed.** `.DS_Store`, `node_modules/`, `dist/`, `*.log`, `.env`, `.env.local`, anything under a `secrets/` directory, JSON files with API keys / tokens / passwords. Check `git diff --name-only` and the actual content.
- [ ] **Large binary blobs.** Anything > 1MB added to the repo. Almost always a smell.
- [ ] **`--no-verify` commits.** `git log <range> --format='%H %s %G?'` won't show it directly; check for commits that skip the project's pre-commit hooks by looking at whether hook-managed files (formatting, generated barrels) match the rest of the diff.
- [ ] **Commit-message honesty.** `git log <range>`. Does each subject line describe what the commit actually changes? `fix: typo` on a 200-line refactor is a defect. `feat: ...` on a pure-test commit is a defect.

If you find issues that aren't on this list but feel material, flag them — the list is a floor, not a ceiling.

### Step 5: Apply the role-specific checklist(s)

For each role category you classified in Step 3, open the relevant `role-<role>.md` file (paths in the reference table above) and find its **"Lazy-X failure modes the Work Checker watches for"** section. Walk it against the diff.

A few high-frequency hits across roles:

- **PE**: swallowed exceptions (`catch { }`), magic numbers, commented-out code blocks, debug prints (`console.log`, `print(`, `dbg!`), hardcoded values that should be config, an atomic-commit boundary that mixes refactor + behaviour change.
- **TAE**: truthy assertions (`expect(x).toBeTruthy()` instead of asserting the actual value), mocked-the-world tests that don't exercise real behaviour, flaky timing (`setTimeout`, real clocks), hardcoded test data without seeded factories, `.skip` without a linked reason.
- **CA**: env vars added in one deploy target but not the others, hardcoded secrets in IaC, oversized infra additions ("created a Kafka cluster for a button label change"), claimed "no infra changes needed" without actually opening the IaC files.
- **UX**: visual states missing (only happy path covered — no loading / empty / error / focus / disabled), copy not specified, new colours / fonts / spacing values introduced instead of reusing existing design tokens, no accessibility consideration.
- **PM**: "looks good to me" without specifics, "done" claim without evidence (no test pass, no build green, no DoD walked).
- **QA**: AC clauses left vague after edit ("the system should handle errors gracefully" — define "gracefully"), no AC → Test map, non-deterministic fixtures approved.

The lists in the referenced files are deeper — consult them for any role that's in scope.

### Step 6: The "check your work" prompt — apply once more

Before producing the report, re-run this prompt against the work in your head:

> *Please just check your work carefully on this. The work claims to be done. Verify that claim against the artefacts. Look for: [role-specific failure modes you just walked]. Look for: [universal failure modes]. Be specific about what you find. Don't be polite — the user wants real defects flagged. If you'd ship this as-is, say so. If you'd push back at code review, say what you'd push back on.*

This is the prompt with the documented ~80% find rate. Apply it deliberately, even when the first eight items felt clean. The second-pass critique catches things the first didn't.

### Step 7: Produce the report

Two formats, depending on outcome.

**When clean:**

```markdown
**Work Checker — clean**

Scope: <one-line statement of what was audited>

Checked:
- Universal: TODO/FIXME, swallowed exceptions, magic numbers, debug prints, file-shouldn't-be-committed, atomic commits, commit-message honesty, silent config changes, --no-verify
- Role-specific: <PE / TAE / CA / UX / PM / QA — list the ones applied>
- Cross-checked: <any specific high-risk thing you verified, e.g. "ran the changed test once locally to confirm pass"; if you didn't run anything, say so>

No defects found. Notable observations (optional, 0–3 bullets): <e.g. "Commit message hygiene is unusually tight on this branch" — leave out if there's nothing>.
```

**When defects found:**

```markdown
**Work Checker — defects**

Scope: <one-line statement of what was audited>

Found <N> defect(s):

1. **<short defect name>** — <file:line> — <one-sentence specifics, including what's wrong and what the right shape would look like>
2. **<short defect name>** — <file:line> — <specifics>
...

Recommendation: <one of>
- Address the defects and re-run `/check-work` for a second pass.
- Address the defects yourself (no second pass needed if they're obvious).
- If you disagree with a finding, say which one and why — I may be wrong; the bar is "would this materially harm the PR or running system?"

(Empirical note: ~80% of audits surface at least one defect. Finding things is the value, not a failure of the underlying work.)
```

Each defect line must be **specific**. Not *"clean up the error handling"* — *"src/api/client.ts:142 — the `catch (err)` block swallows the exception silently; expected the same propagate-to-caller pattern the rest of this file uses"*. A reader of the report should be able to act on each item without asking a follow-up question.

### Step 8: Second-pass cap

If the user fixes the defects and asks for a re-audit, run the workflow again on the post-fix scope. **Stop after the second pass.** If defects remain after pass 2:

- Three or fewer remaining defects → list them and tell the user: *"I've audited this twice. Remaining items are listed; recommend you address them yourself or get a human review — a third audit pass here would be optimisation, not value."*
- More than three remaining defects → tell the user: *"This work has bounced twice with material defects remaining. That's a signal the underlying task may be bigger or less clear than it seemed. Recommend: step back, reconsider scope or approach, rather than iterate on audits."*

This mirrors the bounce-back cap in `/implement-task`'s Work Checker pattern. It's there because three passes is a signal of stuckness, not of high standards.

## Examples of useful invocations

- *"Check my work before I push."* → scope = uncommitted + staged changes; audit; report.
- *"I just finished implementing the rate-limit feature, check the branch."* → scope = unpushed commits on the current branch vs origin/main; audit with PE + TAE layers (likely both).
- *"Audit PR #142 before I request review."* → scope = `gh pr diff 142`; audit with the layers the diff calls for.
- *"Did I miss anything in this commit?"* → scope = `HEAD`; audit with universal + relevant role layers.
- *"Spot-check the IaC changes on this branch."* → scope = files matching the IaC pattern on the current branch; audit with CA layer + universal.

## Edge cases

- **Working tree is clean and no scope given.** Ask the user what to audit. Don't pick something arbitrary.
- **Scope is huge** (e.g. branch is 50 commits ahead with 10K lines of diff). Tell the user up front — the audit will be partial: *"This scope is large enough that I'll spot-check rather than walk every line. If you want exhaustive, narrow the scope (a specific commit, a specific subset of files)."* Then do a stratified sample: every commit's message gets read; a sample of files (highest-risk-looking) gets full review; the rest gets a scan for the universal red flags only.
- **Diff contains generated files** (package lock, generated TypeScript types, formatter output). Note them in the scope statement and largely skip them — don't waste audit budget on regenerable noise.
- **No actual code, just docs.** Apply the universal checklist only. Skip the role-specific layers. The bar is honesty + accuracy, not the lazy-role lists.
- **User asks the skill to fix what it found.** Switch mode explicitly: *"Switching from auditor to fixer."* Then fix the defects (smallest commit per defect, conventional commits messages). After fixing, **do not** re-run the audit on yourself — that's a different problem (self-review of fixes), and the user can re-invoke `/check-work` if they want it. State clearly that you've stopped at the fixes.
- **User wants the audit posted to a GitHub PR.** Format the defect report as a single comment and post with `gh pr comment <N>` after explicit confirmation. Use the `[Work Checker]` prefix the orchestrated skill uses, so it shows the same audit-trail pattern.
- **The skill is run inside `/implement-task`'s session by accident.** That's fine but redundant — `/implement-task` already runs this audit after every persona phase. Tell the user and let them decide.

## Strict non-goals

- **No fixing without explicit user permission.** Auditor mode is the default; fixer mode is an explicit switch.
- **No third audit pass.** Stop after two.
- **No pedantry.** Typos in comments aren't defects. Stylistic taste isn't a defect. The bar is *"materially harms the PR or running system"*.
- **No feature requests.** *"Could be faster"* isn't a Work Checker finding. *"Could throw an unhandled exception on line 42"* is.
- **No requirement second-guessing.** The skill audits delivery against the stated intent, not whether the intent is right. If the intent looks wrong, say so as an observation — but don't refuse to audit.

## The 80% number

About 80% of audits surface at least one defect. That's the empirical reason this skill exists as a separate, dedicated step rather than "just be more careful when you write the code". A focused second pass catches things the first pass missed — backed by Madaan et al.'s *Self-Refine* (https://arxiv.org/abs/2303.17651), which measured ~20pp absolute quality lift on a second-pass critique across multiple task types. Make the audit deliberate, and the find rate stays high.
