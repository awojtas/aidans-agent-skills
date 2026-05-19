# Agent-File Templates

Scaffolds for the agent-instruction files Category A scaffolds when they're missing. Keep these minimal — the user fills in real content. Auto-generated content beyond structure invites stale lore.

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

## `CLAUDE.md` skeleton

```markdown
@AGENTS.md

# CLAUDE.md

<Any Claude Code-specific instructions go here. The line above imports
AGENTS.md's content into the loaded context.>

## Claude-specific conventions

<leave blank — user fills in if needed. Examples:>

- Prefer `pnpm` over `npm` (the project uses pnpm).
- Use `gh pr create` rather than the web UI for PRs.
- When making changes, always run `pnpm verify` before claiming done.
```

The `@AGENTS.md` line at the top is the key thing. Claude Code's import syntax loads the imported file's content. Without it, AGENTS.md is just a file the agent might or might not read.

## `.github/copilot-instructions.md` skeleton

```markdown
@../AGENTS.md

# Copilot Instructions

<This file is loaded by GitHub Copilot. The line above imports AGENTS.md from
the repo root.>

## Copilot-specific notes

<leave blank — user fills in if needed>
```

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
