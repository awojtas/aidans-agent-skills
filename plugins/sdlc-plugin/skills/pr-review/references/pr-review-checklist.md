# PR Review Checklist (Reviewer Reference)

The same checklist the Principal Engineer self-reviews against in `/task-implement` Phase 13, applied here from the *reviewer* side. Drawn from Google's eng-practices, Fowler's writing on small commits, and the Conventional Commits standard.

## Reviewer mindset

Three lenses, held simultaneously:

1. **Correctness** — does this code do what the PR body says it does?
2. **Quality** — does this meet the project's bar?
3. **Risk** — what could go wrong in production?

The reviewer is **not the author's adversary** — they're the author's safety net. Direct, specific, neutral. Don't pile on. Don't be wishy-washy. Don't bikeshed.

## The checklist

### Size and scope

- [ ] **PR is small.** Under ~400 lines of *meaningful* diff (excluding generated files, lockfiles, test fixtures). If over, can it be split into stacked PRs?
- [ ] **One logical change.** No "while I was in there" tangents. If a refactor was needed for the feature, it's in its own commit (Two Hats).
- [ ] **No mixed concerns.** A bug fix and a feature in the same PR is two PRs.

### Description quality

- [ ] **PR title** uses Conventional Commits format: `<type>(<optional scope>): <subject>` — e.g., `feat(auth): add rate limit to signin endpoint`.
- [ ] **PR body** follows the template (What / Why / How / Tests / Manual verification / Out of scope / Self-review).
- [ ] **`Closes #N`** appears in the body for automatic issue closure.
- [ ] **Screenshots / videos** for UI changes.
- [ ] **Risk and rollback** stated if the change is non-trivial.
- [ ] **Self-review section** present and honest (lists what the author found in their own pre-review, not "self-review clean" when the author obviously didn't pass).

### Commits

- [ ] **Atomic commits.** Each commit is a meaningful unit. Squashing happens only if the project policy says so.
- [ ] **Commit messages** in Conventional Commits format, imperative mood, subject ≤ 72 chars, body explains *why*.
- [ ] **No `WIP` / `fix typo` / `oops` commits.** These should have been squashed before review.
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

- [ ] **AC clauses covered.** Every Acceptance Criterion from the linked issue maps to at least one test. Cross-check by reading the diff's tests and matching each AC clause to a test name.
- [ ] **No `.skip` / `xit` / `pytest.mark.skip` added.** Or, if added, there's a comment explaining why and a tracking issue.
- [ ] **No flaky tests.** Tests use seeded factories and frozen clocks; no `Math.random()` / `Date.now()` driving outcomes.
- [ ] **No test mocks the system under test.** Mocks are for collaborators (DB, network); not for the code being tested.
- [ ] **Coverage shape is right.** Pyramid: more unit than integration than E2E.

### Architecture

- [ ] **No new SOLID violations.** New `switch` on type tag? Domain code importing infra? Inheritance hierarchy that breaks LSP? Either fix or document.
- [ ] **No new dependencies without justification.** Each new `package.json` / `requirements.txt` entry has a one-sentence rationale in the PR body or a commit message.
- [ ] **Backwards compatibility maintained** (unless deliberately breaking, in which case `BREAKING CHANGE:` footer on the commit).

### Build, lint, CI

- [ ] **Lint runs clean.** No warnings ignored or `// eslint-disable` added without justification.
- [ ] **Type-check passes.** No `any` / `# type: ignore` added without justification.
- [ ] **CI is green** at the time of review.

### Infrastructure / IaC

- [ ] **IaC changes scoped correctly.** Either in this PR (small), or in a stacked PR (large), or flagged as a follow-up (out of scope).
- [ ] **Env vars added to all environments** — local, dev, staging, prod. Not just one.
- [ ] **Secrets in the secret manager**, not committed.
- [ ] **Migrations have rollbacks.**

### Cross-origin integration (skip if client and API are on the same origin, or if the diff doesn't touch the API surface or client API-call configuration)

- [ ] **CORS configured on the API**: the client origin(s) are allow-listed, including the `Authorization` header. No wildcard (`*`) for credentialed requests.
- [ ] **Production API not behind a platform SSO / deployment-protection wall**: access is gated by the application's own JWT/session auth + CORS, not by a platform gate that blocks end-user browsers before the app runs.
- [ ] **Client's API-URL env var set in all environments**: `.env.example` updated; var confirmed in the deploy project's env store — not just locally.
- [ ] **Integration tested with a real cross-origin call through auth**, not only mocked or server-side tests — a test that doesn't cross origins can't catch a CORS misconfiguration.

### Security (reviewer's quick sniff)

- [ ] **No secrets in the diff.** API keys, tokens, passwords, connection strings, private keys.
- [ ] **User input validated** at trust boundaries (schema, length, type, allow-list).
- [ ] **No new SQL with string concatenation** of user input.
- [ ] **No PII in logs** (emails, IDs, tokens — should be hashed or omitted).
- [ ] **New endpoints have authentication** where appropriate; authorisation enforced server-side.

### Documentation

- [ ] **README / runbook / AGENTS.md updated** if user-facing or developer-facing behaviour changed.
- [ ] **ADR added** if a non-trivial architectural decision was made.
- [ ] **API docs regenerated** if endpoints / shapes changed.

### Out of scope / follow-ups

- [ ] **Anything found but deliberately deferred** is listed in the PR body with a link to a tracking issue.
- [ ] **No silent deferral.** Every "we should fix this later" is captured.

## How the reviewer conducts the review

1. **Open the PR** (`gh pr view <number>` + `gh pr diff <number>`).
2. **Read the description and linked issue** before reading the code.
3. **Read every diff hunk line-by-line.** *Read it, don't skim it.*
4. **For each finding**, leave a line-anchored inline comment with the specific location and a concrete suggestion.
5. **Walk the checklist** to surface anything the line-by-line read didn't naturally catch.
6. **Write the summary review** with the verdict (Approve / Comment / Request changes) and the rationale.

## What a Request-changes is for

- A correctness bug — the code doesn't do what the PR body claims.
- A missing test for a stated AC.
- A security issue (PII in logs, missing authz, secret in the diff).
- A broken contract (backwards-compatibility break not flagged).
- A description so thin the PR can't be understood without reading the code.

## What an Approve doesn't mean

- "I read every line." (You did.) ✓
- "This is the optimal implementation." (Maybe; doesn't have to be.) ✗
- "I'd write it the same way." (Doesn't matter.) ✗
- "There are no improvements possible." (There always are.) ✗

An Approve means "I checked, this meets the bar, ship it." Nothing more.

## Sources

- Google Engineering Practices, *Small CLs* — https://google.github.io/eng-practices/review/developer/small-cls.html
- Google Engineering Practices, *Reviewer guidance* — https://google.github.io/eng-practices/review/reviewer/
- Conventional Commits — https://www.conventionalcommits.org/en/v1.0.0/
