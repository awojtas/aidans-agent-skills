# AGENTS.md — `sdlc-plugin`

Plugin-specific context for agents working in `plugins/sdlc-plugin/`. The [root AGENTS.md](../../AGENTS.md) carries the repo-wide conventions for adding plugins and skills; this file covers what is distinctive about *this* plugin.

## What this plugin is

A bundle of skills for the full Software Development Lifecycle — plan, build, ship, operate, maintain. Workflow chain from repo bootstrap through task implementation, plus helpers for status, audit, course-correction, backlog triage, production-error triage, peer PR review, per-feature release-readiness, AI-readiness audit of existing mature repos, and dev-loop fixes.

## Anchor skill: `task-implement`

`/task-implement` is the heaviest skill in the bundle and the one that touches the most ground when edits land here. When extending or modifying it:

- It orchestrates **10 personas** across **16 phases**. Personas are spawned as focused sub-agents and post `[Role Name]`-prefixed comments on the GitHub issue.
- Every persona has a dedicated reference doc in `skills/task-implement/references/role-<name>.md`.
- The Work Checker runs after every other persona's phase. The empirical defect-find rate is ~80% on first pass.
- Phase numbers drift across edits — when adding / removing / reordering phases, update them consistently across `SKILL.md`, every role doc, `code-review-checklist.md`, `test-strategy.md`, and `example-implementation-session.md`. Past edits have left stale numbers in subtle places; grep before claiming done.

## Cross-skill conventions

The skills in this plugin form chains, not islands:

- **Design / requirements chain:** `solution-design` → `platform-design` → `requirements-create-from-design` → `requirements-validation` → `tasks-create-from-requirements` → `task-implement`.
- **Surgical requirement edits:** `requirements-add`, `requirements-delete`, `requirements-rework` for one-off changes to an existing tree.
- **Issue lifecycle:** `issue-prioritise` → `issue-architect-review` (optional pre-implementation quality pass) → `issue-work` (lightweight) or `task-implement` (heavyweight) → `pr-review` → `release-readiness` → `issue-close`.
- **Maturity / audit:** `repo-bootstrap` → `repo-release-ready`; `ai-ready-repo` is the retrofit for repos that didn't go through that chain.

Skills that consume `docs/architecture/`, `docs/requirements/`, or `docs/design/` should fail gracefully when those folders are absent. Most fall back to README.md or to asking the user — match that pattern when adding new consumers.

## Versioning

This plugin is at v5.x and bumps often. **Always bump the version in the same change as any skill edit** — the marketplace update check compares only the `version` field in `plugin.json`, not file contents. Forgetting the bump means users running `/plugin marketplace update` are told they're up to date when they're not.

Use semver per the root `AGENTS.md`: minor for new skills / new reference docs / meaningful behaviour changes; patch for typos / small wording; major only for removing or renaming a skill (a breaking change to how users invoke things).

## Skill anatomy and authoring patterns

- **`SKILL.md` is the always-loaded prompt.** Keep the workflow lean — push detailed checklists, templates, catalogues, and worked examples into `references/*.md` files and reference them from `SKILL.md`.
- **`references/*.md` are loaded on demand** when the skill is invoked. This is the on-demand half of progressive disclosure — analogous to per-package AGENTS.md, but scoped to a skill.
- **Trigger phrases in the SKILL.md frontmatter `description` field are how Claude Code decides when to auto-invoke a skill.** Be specific. Listing every plausible user phrasing pays off — the description is the prompt that determines triggering.

## Areas of attention

- **Phase-number drift in `task-implement`** — see the anchor-skill note above.
- **Cross-skill references** — `/ai-ready-repo` mentions `/repo-bootstrap` and `/repo-release-ready` by name; `/release-readiness` distinguishes itself from `/platform-verify`. When renaming a skill, grep across the plugin for stale references.
- **`description` field length** — some skills (e.g. `task-implement`, `ai-ready-repo`) have long descriptions intentionally; the trigger-phrase coverage is the value. Trim only if redundant, not on principle.
