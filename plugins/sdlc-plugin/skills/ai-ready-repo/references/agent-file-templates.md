# Agent-File Templates

Scaffolds for the agent-instruction files Category A and B scaffold when they're missing. Keep these minimal — the user fills in real content. Auto-generated content beyond structure invites stale lore.

The templates here cover:

- **Root `AGENTS.md`** — repo-wide canonical instructions.
- **Root `CLAUDE.md`** — minimal form (just `@AGENTS.md`) is the recommended shape.
- **Root `.github/copilot-instructions.md`** — Copilot-side import of AGENTS.md.
- **Per-package `AGENTS.md` in monorepos** — progressive disclosure pattern (see B2-progressive in the checklist).

## `AGENTS.md` skeleton

Use this when scaffolding a missing `AGENTS.md`. Fill the stack-specific blanks from Step 0 detection.

```markdown
# AGENTS.md

This document is for AI coding agents working in this repository. Humans should
read `README.md` first; this file assumes that context.

## What this project is

<One paragraph. Inferred from README.md if present; otherwise leave for the user.>

## Stack

- **Language(s):** <detected — e.g. TypeScript 5.x>
- **Framework(s):** <detected — e.g. Next.js 14 App Router>
- **Package manager:** <detected — e.g. pnpm>
- **Database:** <detected if obvious — e.g. PostgreSQL via Prisma>
- **Hosting:** <leave blank for user>

## Structure

<inferred from `ls -d */`, one line per top-level directory; leave one-line
descriptions blank where unclear>

## Dev commands

Run these from the repo root:

| Command | What it does |
|---------|--------------|
| `<pm> install` | Install dependencies. |
| `<pm> dev` | Start the local dev server. |
| `<pm> build` | Build for production. |
| `<pm> lint` | Run the linter. |
| `<pm> test` | Run all tests. |
| `<pm> test:unit` | Run unit tests only. |
| `<pm> type-check` | Run the type checker. |

<commands inferred from package.json scripts; remove rows that don't exist;
fill <pm> with the detected package manager>

## Conventions

<leave blank — user fills in>

- Commit messages: <e.g. Conventional Commits>
- Branch naming: <e.g. `<issue-number>-<slug>`>
- File organisation: <e.g. tests live alongside source as `*.test.ts`>

## Areas to avoid

<auto-populated from detection — vendored dirs, generated dirs, legacy paths>

## Sources of truth

<leave blank — user fills in: the canonical place to look for design decisions,
e.g. docs/architecture/, an ADR folder, a Notion workspace>
```

## `CLAUDE.md` skeleton — minimal form (recommended)

The recommended shape, once `AGENTS.md` exists, is **as short as possible**:

```markdown
@AGENTS.md
```

That's it. One line. Anthropic's Claude Code best-practices documentation recommends keeping CLAUDE.md under 200 lines and notes that a shorter CLAUDE.md produces better adherence than a longer one. Putting generic project rules in AGENTS.md and importing them into CLAUDE.md is the documented best practice.

## `CLAUDE.md` skeleton — extended form (use only if Claude-Code-specific guidance is genuinely needed)

```markdown
@AGENTS.md

## Claude-specific notes

- <one bullet per genuinely Claude-Code-specific instruction>
- <e.g. "Always use `gh pr view` rather than fetching the PR via WebFetch — auth is wired through `gh`">
```

**What does NOT belong in CLAUDE.md:**

- Generic dev commands (build / test / lint) — those go in AGENTS.md.
- Project conventions (commit format, branch naming, file organisation) — AGENTS.md.
- Stack description, architecture overview, "what is this project" — AGENTS.md.
- "Read this first" guides for new contributors — AGENTS.md.
- Anything that another AI tool (Copilot, Cursor) would equally benefit from — AGENTS.md.

**What does belong in CLAUDE.md (when applicable):**

- Specific instructions tied to Claude Code features (using a particular slash-command or sub-agent).
- Notes that only apply because the user is in Claude Code (e.g. "the `gh` MCP is configured here, prefer it over WebFetch for GitHub data").
- Project-specific workflow preferences that Claude Code uniquely supports.

If you find yourself writing more than ~5–10 lines of Claude-specific notes, ask whether they're actually Claude-specific or just generic guidance you should move into AGENTS.md.

## `.github/copilot-instructions.md` skeleton

```markdown
@../AGENTS.md

# Copilot Instructions

<This file is loaded by GitHub Copilot. The line above imports AGENTS.md from
the repo root.>

## Copilot-specific notes

<leave blank — user fills in if needed>
```

## Per-package `AGENTS.md` skeleton (progressive disclosure)

Use this when scaffolding a missing `AGENTS.md` inside a monorepo subdirectory (e.g. `apps/web/AGENTS.md`, `packages/db/AGENTS.md`). The file is loaded **on demand** when the agent reads code inside that directory, layered on top of the root AGENTS.md.

```markdown
# AGENTS.md — `<package-name>`

This file gives agents working in this directory package-specific context. The
[root AGENTS.md](../../AGENTS.md) carries the repo-wide conventions; this file
adds the parts that only apply to `<package-name>`.

## What this package is

<One sentence. Inferred from `package.json` `description` / `pyproject.toml`
[project] description / similar; leave blank if not detectable.>

## Stack (package-specific)

<Only what differs from the repo-wide stack in the root AGENTS.md. E.g.:>

- Framework: <Next.js 14 App Router>
- Database client: <Prisma>
- Test framework: <Vitest>

(If the stack matches the repo-wide AGENTS.md exactly, omit this section.)

## Dev commands (package-specific)

<Only commands that differ from or extend the root AGENTS.md's commands. E.g.:>

| Command | What it does |
|---------|--------------|
| `<pm> --filter <package-name> dev` | Run only this package's dev server. |
| `<pm> --filter <package-name> test` | Run only this package's tests. |

(If commands match the root exactly, omit this section.)

## Conventions (package-specific)

<Only what differs from or extends the root AGENTS.md's conventions. E.g.:>

- Components live in `src/components/`, organised by feature not type.
- Server-only modules end in `.server.ts`; client-only modules end in `.client.tsx`.

## Areas to avoid (in this package)

<Only if there are package-specific avoid-paths. E.g.:>

- `src/__generated__/` — emitted by `pnpm codegen`; do not edit.
```

### How agents load this file

Per Claude Code's documented behaviour, agents see this file when they read code inside the directory it lives in. The root `AGENTS.md` is always loaded; this file is loaded *in addition*, when relevant. The agent sees both, with more-specific (this file) winning over less-specific (the root) where they conflict.

### What NOT to put in per-package AGENTS.md

- Anything that's true repo-wide — that belongs in the root AGENTS.md.
- Stack basics the package shares with the rest of the repo — root.
- Boilerplate that just repeats `package.json scripts` verbatim — the agent can read those.
- Speculative future-work notes — they decay.

If a per-package AGENTS.md is shorter than ~10 lines after you've filled it in, that's a signal you may not need it yet. The root AGENTS.md plus the actual code is probably enough until package-specific divergence emerges.

## Section: dev-commands inference

The Step 7 auto-fixer infers the Dev commands table from:

1. **`package.json` `scripts`** (Node) — keys are command names; values include what they invoke. The skill maps common script names:

   - `dev` / `start` → "Start the local dev server"
   - `build` → "Build for production"
   - `lint` / `lint:fix` → "Run the linter"
   - `test` → "Run all tests"
   - `test:unit` / `test:integration` / `test:e2e` → corresponding
   - `type-check` / `typecheck` / `tsc` → "Run the type checker"
   - `migrate` / `db:migrate` / `prisma migrate` → database migrations
   - `seed` / `db:seed` → seed data

2. **`Makefile` / `justfile`** — top-level targets.

3. **`pyproject.toml` `[tool.poetry.scripts]`** / `[project.scripts]` — Python equivalents.

4. **`Cargo.toml`** — `cargo` is the entrypoint; document common subcommands (`cargo build`, `cargo test`, `cargo clippy`).

5. **`Dockerfile` / `docker-compose.yml`** — if Docker is the dev surface, document `docker compose up` / equivalents.

If multiple are present, prefer the most-recent one (highest commit recency on the file).

## Areas-to-avoid inference

Auto-populated from detection. Add to the "Areas to avoid" section of `AGENTS.md`:

- `vendor/` if exists and committed (Go vendoring).
- `node_modules/` (always — but it's gitignored, so usually not necessary to mention).
- `dist/` / `build/` / `out/` if committed.
- `__generated__/` / `*generated*` paths.
- `legacy/` / `deprecated/` / `old/` if obvious.
- Any path matching the project's `.gitignore` that's *still* tracked (suggests it was committed by accident).

Keep the list short. If the auto-detector finds more than 5 paths to list, surface to the user — that's a signal the project has more cleanup than this skill can do automatically.

## What this file is NOT

- Not a prompt to ship as-is. The skill scaffolds these; the user (or a follow-up `/issue-work`) fleshes them out.
- Not a substitute for the work `/repo-bootstrap` does on a greenfield repo. `/repo-bootstrap` generates richer initial content with project-specific framing; this skill scaffolds minimal structure because it's being applied to a repo with existing context.
- Not opinionated about content — the skill scaffolds the *shape*; the user's content is the *substance*.
