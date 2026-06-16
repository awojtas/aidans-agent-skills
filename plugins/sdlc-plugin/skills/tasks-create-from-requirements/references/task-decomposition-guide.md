# Task Decomposition Guide

How to break a requirement into the small, batched tasks that become GitHub issues. The goal is a set of tasks where each one is a **single PR-able unit of work** — small enough to be completable in a focused session, large enough to be worth opening an issue for.

## The size rule

Each task is ideally:

- **≤ 1 day of focused work** for an AI agent; ≤ 1 day of calendar time for a human (less than that for humans is even better — humans context-switch).
- **One concern.** If a task spans schema + API + UI + tests, split it.
- **One PR.** If it would naturally take multiple PRs to merge cleanly, it's too big.
- **Testable on its own.** Each task has its own acceptance criteria; nothing handwavy like "and other related changes".

If a task feels too small (e.g., "rename a CSS class"), bundle it with the most logically adjacent task rather than creating a 5-minute issue.

## The decomposition recipe

For each requirement (functional or non-functional), apply this checklist in order:

### 1. Schema / data layer

Is there a data shape change?

- New entity / table / column?
- New index?
- Migration with backfill?
- Sample data fixtures for tests?

→ One task per migration. Migrations should never be bundled with feature code unless they're trivial — they need their own deploy window.

### 2. Server / API layer

Is there server-side logic?

- Endpoint(s) to create/modify?
- Validation logic?
- Authorisation check?
- Background job / scheduled task?
- Rate limit / cache?

→ Typically one task per endpoint family (e.g., "POST /users + GET /users/:id" can be one if they share validation; otherwise split).

### 3. Client / UI layer

Is there a user-facing surface?

- New page / route?
- New component(s)?
- Form / input handling?
- Error / loading / empty states?
- Optimistic update logic?

→ One task per discrete UI surface. Form + form-with-states is one task; brand-new page is its own.

**Application shell rule (UI/web projects only — emit once, in the first UI delivery phase):** before decomposing individual feature pages, check whether a shell task already exists. If not, add one. It must cover:

- A real home page at `/` with primary calls-to-action (sign in / sign up, or enter-the-app) — not the scaffold placeholder.
- Global navigation (header/nav) shared via the layout, linking the main sections of the app.
- Authenticated-redirect / routing glue: signed-in users land in the app, not on the marketing page.
- Removal of any scaffold placeholder pages.

A feature route with no link from `/` or the global nav is not "done" — the user has no front door. If decomposing a set of feature pages produces no shell task, one is missing.

**Shell coverage check (after decomposing all UI requirements):** scan the task list. For every new page/route, verify there is either (a) an existing shell task that adds it to the nav, or (b) the feature task's own DoD states how a user navigates to it from `/`. If neither exists, add the nav entry to the shell task or to that feature task's DoD explicitly.

### 4. Integration layer

Does it touch an external service?

- Third-party API call (Stripe, Sentry, OAuth provider)?
- Webhook receiver?
- File / blob storage?
- Email / SMS / push notification?

→ Always its own task. Integrations have their own retry/error semantics and deserve isolation.

### 5. Cross-cutting concerns

For each requirement, check:

- **Telemetry.** Does this need a new metric, log line, or trace span? → Often a sub-task bundled into the layer where the instrumentation lives.
- **Feature flag.** Is this behind a flag for safe rollout? → Bundle the flag setup with the first task that uses it.
- **Documentation.** README update? AGENTS.md update? `docs/` page? → Bundle with the most user-visible task, or its own `type:docs` task if substantial.
- **Tests.** Unit/integration/E2E. Almost never their own task — bundled into the implementation task.

### 6. Acceptance verification

Re-read the requirement's `Acceptance criteria` (Given-When-Then). Map each criterion to a task that covers it. If a criterion has no home, you've missed a task.

## Sequencing within a phase

Within a phase, order tasks so each depends only on already-numbered tasks:

- **Schema first.** Migrations before code that uses them.
- **API before UI.** UI tasks consume API contracts; the API needs to exist (or be mocked) first.
- **Foundation before features.** Routing, auth middleware, test scaffolding before specific endpoints.
- **Happy path before edge cases.** First task implements the core flow; follow-ups add error handling, edge cases.

Cross-task dependencies are captured in each issue's `**Blocked by:** #X` field.

## When NOT to create a task

Skip:

- **"Won't (this release)"** items from `10-prioritisation.md`. They're explicitly out of scope; the milestone for them doesn't exist yet.
- **Pure refactor** of code that doesn't exist yet. Refactor tasks emerge from real code; don't pre-create them.
- **Stakeholder approvals** that aren't actionable work — those belong in `08-open-questions.md`, not as issues.
- **Decisions** that haven't been made yet — those are also open questions, not tasks. Once decided, the implementation becomes a task.

## What a good task title looks like

Pattern: `<phase>.<number> <verb> <object> <qualifier>`

Examples:

- `1.1 Create Vercel project and link to GitHub repo`
- `2.3 Implement /api/auth/signin endpoint with email+password`
- `3.5 Render Code view with line-number gutter`
- `4.2 [HUMAN] Decide on browser support matrix`

Anti-patterns:

- `Auth stuff` — too vague.
- `Implement authentication` — too big; will become multiple tasks.
- `Fix bug` — not until the bug is described enough to be its own issue (and tracked in `09-risks.md` if known in advance).
- `Various improvements` — banned.

## Size signals (when to split)

| Signal                                                              | Action                                  |
|---------------------------------------------------------------------|------------------------------------------|
| Task title has "and" connecting two concerns                        | Split.                                  |
| Acceptance criteria has > 5 checkboxes                              | Split.                                  |
| Task touches > 3 layers (schema/server/UI/integration)              | Split.                                  |
| Task would require > 1 day of focused work                          | Split.                                  |
| You can't write a one-sentence Definition of Done                   | Split or sharpen.                       |
| Two of the same person can work on it simultaneously without merge  | Split (means it was actually two tasks).|
