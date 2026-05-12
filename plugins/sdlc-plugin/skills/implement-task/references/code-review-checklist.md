# Code Review Checklist (PE Self-Review + Reviewer Reference)

The Principal Engineer's self-review pass in Phase 10 walks this checklist. The same checklist is what a human reviewer applies when they pick up the PR. Drawn from Google's eng-practices, Fowler's writing on small commits, and the Conventional Commits standard.

## Why self-review

Google's eng-practices: *"The right size for a CL is one self-contained change… 100 lines is usually a reasonable size for a CL, and 1000 lines is usually too large… reviewers have discretion to reject your change outright for the sole reason of it being too large."* ([Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html).)

The PE's self-review is the first review the PR gets. It exists to catch the obvious before the reviewer's time is consumed. Documented value: Microsoft's internal AI-reviewer rollout *"reported 10–20% median PR completion time improvements"* alongside earlier defect detection. ([Microsoft Engineering blog](https://devblogs.microsoft.com/engineering-at-microsoft/enhancing-code-quality-at-scale-with-ai-powered-code-reviews/).)

## The checklist

### Size and scope

- [ ] **PR is small.** Under ~400 lines of *meaningful* diff (excluding generated files, lockfiles, test fixtures). If over, can it be split into stacked PRs?
- [ ] **One logical change.** No "while I was in there" tangents. If a refactor was needed for the feature, it's in its own commit (Two Hats).
- [ ] **No mixed concerns.** A bug fix and a feature in the same PR is two PRs.

### Description quality

- [ ] **PR title** uses Conventional Commits format: `<type>(<optional scope>): <subject>` — e.g., `feat(auth): add rate limit to signin endpoint`. ([conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/).)
- [ ] **PR body** follows the template (What / Why / How / Tests / Manual verification / Out of scope / Self-review).
- [ ] **`Closes #N`** appears in the body for automatic issue closure.
- [ ] **Screenshots / videos** for UI changes.
- [ ] **Risk and rollback** stated if the change is non-trivial.
- [ ] **Self-review section** lists what the self-review pass found and fixed.

### Commits

- [ ] **Atomic commits.** Each commit is a meaningful unit. Squashing happens only if the project policy says so.
- [ ] **Commit messages** in Conventional Commits format, imperative mood, subject ≤ 72 chars, body explains *why*.
- [ ] **No `WIP` / `fix typo` / `oops` commits.** Squash these out before requesting review.
- [ ] **No `--no-verify` skips.** Pre-commit hooks ran on every commit.

### Code quality

- [ ] **No TODO / FIXME / XXX added in this diff.** Existing ones unchanged unless deliberately addressed.
- [ ] **No commented-out code.** Git has the history.
- [ ] **No `console.log` / `print` / `debugger`.** Pure debug statements removed.
- [ ] **No magic strings / numbers.** Named constants where the value carries meaning.
- [ ] **No hardcoded secrets / API keys / URLs.** All through config / env / secret manager.
- [ ] **Error handling exists** for I/O and external calls. No silent swallowing (`catch {}`).
- [ ] **Function size reasonable.** A function over ~50 lines in this diff should have a comment justifying it, or be a sign a refactor was skipped.
- [ ] **Naming is descriptive.** No `x`, `y`, `tmp`, `data`, `result` for non-trivial variables.

### Tests

- [ ] **AC clauses covered.** Every Acceptance Criterion from the issue maps to at least one test (QA produced the AC → Test map in Phase 7).
- [ ] **No `.skip` / `xit` / `pytest.mark.skip` added.** Or, if added, there's a comment explaining why and a tracking issue.
- [ ] **No flaky tests.** Tests use seeded factories and frozen clocks; no `Math.random()` / `Date.now()` driving outcomes.
- [ ] **Tests pass locally.** PE ran the full suite after Phase 6-8 (TAE tests → QA test validation → PE lint+build).
- [ ] **No test mocks the system under test.** Mocks are for collaborators (DB, network); not for the code being tested.
- [ ] **Coverage shape is right.** Pyramid: more unit than integration than E2E.

### Architecture

- [ ] **No new SOLID violations.** New `switch` on type tag? Domain code importing infra? Inheritance hierarchy that breaks LSP? Either fix or document.
- [ ] **No new dependencies without justification.** Each new `package.json` / `requirements.txt` entry has a one-sentence rationale in the PR body or a commit message.
- [ ] **Backwards compatibility maintained** (unless deliberately breaking, in which case `BREAKING CHANGE:` footer on the commit).

### Build, lint, CI

- [ ] **Lint runs clean.** No warnings ignored or `// eslint-disable` added without justification.
- [ ] **Type-check passes.** No `any` / `# type: ignore` added without justification.
- [ ] **Build succeeds.** Local and (after push) CI.
- [ ] **CI is green** when the PR is opened — wait for the first run before requesting review.

### Infrastructure / IaC

- [ ] **IaC changes scoped correctly.** Either in this PR (small), or in a stacked PR (large), or flagged as a follow-up (out of scope).
- [ ] **Env vars added to all environments** — local, dev, staging, prod. Not just one.
- [ ] **Secrets in the secret manager**, not committed.
- [ ] **Migrations have rollbacks.**

### Documentation

- [ ] **README / runbook / AGENTS.md updated** if user-facing or developer-facing behaviour changed.
- [ ] **ADR added** if a non-trivial architectural decision was made.
- [ ] **API docs regenerated** if endpoints / shapes changed.

### Out of scope / follow-ups

- [ ] **Anything found but deliberately deferred** is listed in the PR body with a link to a tracking issue.
- [ ] **No silent deferral.** Every "we should fix this later" is captured.

## How the PE conducts self-review

1. Open the PR in GitHub.
2. Click "Files changed".
3. Read every diff hunk line-by-line. *Read it, don't skim it.*
4. For each hunk: ask "would I approve this if a colleague wrote it?"
5. For anything that earns a "hmm" — fix it. Commit. Push.
6. Repeat until the diff reads clean.
7. Apply the checklist above. Anything failing? Fix it.
8. Add the **Self-review** section to the PR body, listing what the pass found and fixed (or "Self-review clean — no pre-emptive fixes needed" if genuinely so).
9. Mark the PR ready for review.

The Self-review section is visible to the reviewer. It signals: *"I took this seriously. Here's what I caught myself."*

## Sources

- Google Engineering Practices, *Small CLs* — https://google.github.io/eng-practices/review/developer/small-cls.html
- Conventional Commits — https://www.conventionalcommits.org/en/v1.0.0/
- Microsoft Engineering, *Enhancing Code Quality at Scale with AI-Powered Code Reviews* — https://devblogs.microsoft.com/engineering-at-microsoft/enhancing-code-quality-at-scale-with-ai-powered-code-reviews/
- Madaan et al., *Self-Refine* — https://arxiv.org/abs/2303.17651 *(the empirical basis for the Work Checker's "~20% improvement on second-pass critique" pattern)*
