# AI-Ready Checklist — Categories A and B

The auditable items in Categories A (agent-instruction hygiene) and B (layout + stack legibility). Category C (confusion landmines) has its own document — `confusion-landmines.md` — because the methodology is different (sampling + pattern-matching, not file-presence).

## Severity definitions used throughout

| Severity | Meaning | Default action |
|----------|---------|----------------|
| **Blocker** | An AI agent will materially fail or produce wrong output without this. | Auto-fix or stop the audit until user confirms. |
| **Major** | A real friction that significantly degrades agent effectiveness; agents work around it but at a cost. | Default to auto-fix where possible; otherwise raise as a high-priority issue. |
| **Minor** | A friction worth fixing but agents cope. | Auto-fix if cheap; recommend if not. |
| **Nit** | A small papercut. | Mention in the report; don't auto-fix. |

Severity is per-finding, not per-category — a missing `AGENTS.md` is **major** but a missing `.github/copilot-instructions.md` is only **minor** because most agents work from `AGENTS.md` / `CLAUDE.md`.

## Category A — Agent-instruction hygiene

The files an AI agent reads on entering the repo, and their cross-referencing.

### A1 — Root agent files exist

| File | Severity if missing | Auto-fixable? |
|------|---------------------|---------------|
| `AGENTS.md` (root) | Major | Yes — scaffold from `references/agent-file-templates.md` with stack-aware sections (use Step 0 detection). |
| `CLAUDE.md` (root) | Major | Yes — scaffold with `@AGENTS.md` import + project-specific notes section. |
| `.github/copilot-instructions.md` | Minor | Yes — scaffold with `@../AGENTS.md` import. |

Bias: scaffold the file, don't write detailed content. The user fills it in. Auto-generated content beyond structure invites stale lore.

### A2 — `@<path>` imports wired correctly

This is the highest-leverage finding in Category A. Claude Code's `@<path>` syntax inlines the imported file's content into the loaded context. A prose reference doesn't.

- `CLAUDE.md` contains `@AGENTS.md` (or `@./AGENTS.md`) on its own line — **major** if missing.
- `.github/copilot-instructions.md` contains `@../AGENTS.md` — **minor** if missing (Copilot is more lenient about prose links).

How to check: read the file. Look for a line matching `^@[\.\/]*AGENTS\.md\s*$` — exact match. Don't accept `Please see @AGENTS.md for...` — that's a prose mention, not an import directive (the agent may or may not treat embedded `@` inside a sentence as an import; the unambiguous form is a standalone line).

Auto-fix: prepend the import directive at the top of the file (after any frontmatter / title heading), with a blank line below for readability.

### A3 — Dev commands documented somewhere agent-loaded

The commands an agent needs to verify its work. The canonical list (rename per language):

- `build` — `pnpm build` / `make build` / `cargo build` / `dotnet build` / etc.
- `lint` — `pnpm lint` / `ruff check` / `golangci-lint run` / etc.
- `test` — full suite umbrella.
- `test:unit` — unit tests only.
- `test:e2e` — end-to-end.
- `type-check` — `tsc --noEmit` / `mypy` / `pyright` / etc.
- `dev` — local dev server / hot-reload.
- `migrate` / `seed` — database lifecycle if applicable.

Walk: `AGENTS.md`, `CLAUDE.md`, `README.md`, `package.json#scripts`, `Makefile`, `justfile`.

- **Major** if `lint`, `test`, or `type-check` aren't documented anywhere agent-readable.
- **Minor** if `dev` / `migrate` / `seed` are missing from docs but present in package scripts.
- **Nit** if package scripts have non-obvious names (`pnpm verify` as the umbrella — agent might guess) and no docs explain them.

Auto-fix: infer commands from `package.json scripts` (or stack equivalent), append a `## Dev commands` section to `AGENTS.md`.

### A4 — `type-check` is not silently absent from CI / `test:unit`

Common rot pattern: `test:unit` runs only Jest/Vitest, not `tsc --noEmit`. CI runs `test:unit` on PRs, not on `push` to default branch. Result: TypeScript errors accumulate on `main` invisibly.

Check:

```bash
# Does test:unit invoke type-check?
grep -E "tsc|mypy|pyright" package.json

# Does CI run on push to default?
grep -lE "on:\s*$|push:" .github/workflows/*.yml | xargs grep -lE "branches:.*main|branches:.*master"

# Are recent CI runs on default branch failing?
gh run list --workflow ci.yml --branch main --limit 10 2>/dev/null | head
```

- **Major** finding if type-check is missing from both `test:unit` and the CI run on default branch.
- **Recommendation, not auto-fix.** Cannot safely modify CI workflows or package scripts in a way that's correct for the project — too much variability. Raise as a GitHub issue with a suggested fix.

### A5 — Skip-list / ignore-list patterns are documented

If the project's `AGENTS.md` mentions things like *"don't touch `/legacy/`"* or *"don't run migrations locally"*, fine. If there are clearly legacy or ignore-worthy paths (deprecated subtrees, vendored code, generated outputs) and they're *not* mentioned, agents will treat them as fair game.

- **Minor** if there's an obvious `legacy/` / `vendor/` / `generated/` tree and no doc telling agents to leave it alone.
- Auto-fix: add an "Areas to avoid" subsection to `AGENTS.md` listing the detected paths.

## Category B — Layout + stack legibility

How the repo presents itself to an agent that has just `git clone`d it and is trying to figure out where to start.

### B1 — Root `README.md` exists and explains layout

- **Major** if no `README.md` at root.
- **Minor** if `README.md` exists but has no section explaining what's where.

Auto-fix (minor case): add a `## Structure` section listing top-level directories with a one-line description per:

```markdown
## Structure

- `apps/web/` — the user-facing Next.js app
- `apps/admin/` — the internal admin dashboard
- `packages/ui/` — shared UI components
- `packages/db/` — Prisma client + migrations
- `infra/` — Terraform for AWS resources
- `docs/` — design docs and runbooks
```

Inferred from `ls -d */` + commit-history file paths. If the skill can't infer a one-line description, leave the description blank for the user to fill in — don't invent.

### B2 — Multi-app / monorepo structure is signposted

If `apps/` / `packages/` / `services/` / `cmd/` has multiple children:

- **Minor** if no `apps/README.md` (or equivalent) explaining which child is which.
- Auto-fix: scaffold a `README.md` in each detected parent directory listing the children. Don't go deeper than one level — the user can add per-child READMEs if they want.

### B3 — Type information is present

- TypeScript: `tsconfig.json` with `"strict": true`.
- Python: `mypy.ini` / `[tool.mypy]` / `pyrightconfig.json` configured.
- Go: type-checking is built-in; check for `go vet` in CI.
- Other: language-appropriate.

Severity if missing / loose:

- **Minor.** Don't auto-fix. Flipping `strict: true` on a mature TypeScript codebase is a real refactor. Raise as a recommendation; offer to open an issue if the user wants.

### B4 — Tech-stack red flags

Apply the catalogue in `tech-stack-redflags.md`. Severity per pattern (the catalogue is the authoritative source). Common cases:

- **Mixed lockfiles** (`package-lock.json` + `pnpm-lock.yaml` + `yarn.lock` in one project) → **major**, auto-fixable (keep the active one, delete the others after confirming with the user which is canonical).
- **Multiple framework paradigms in one app** (Next.js Pages + App Router) → **major**, not auto-fixable (raise as issue + recommend a migration plan).
- **Heavy metaprogramming** without docs → **major** to **informational** depending on extent. Don't auto-fix.
- **Generated code without "Generated" headers** → **minor**, auto-fixable (add the header).

### B5 — `.gitignore` covers the obvious

- **Nit** if `.gitignore` is missing entries for the detected stack (`node_modules`, `__pycache__`, `target/`, `.env`, `.DS_Store`, IDE folders).
- Auto-fix: append the missing standard entries for the detected stack.

### B6 — README has a "Getting Started" section

A one-shot for a new contributor (or new agent) to get the project running locally.

- **Minor** if no Getting Started section in `README.md`.
- Auto-fix: scaffold a section pulling the dev commands inferred in A3. Stop short of saying "run `pnpm install`" if a different package manager was detected; use the right one.

## Output of Category A + B

A list of findings, each with:

- ID (`A1`, `A2-1`, `B4-3`, etc.).
- Severity.
- Where (file path, or "missing").
- What (one-line description).
- Suggested fix (one-line).
- Auto-fixable (yes / no).

This list feeds into the Step 5 report.
