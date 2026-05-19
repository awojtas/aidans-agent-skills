---
name: ai-ready-repo
description: Audits an existing mature codebase for AI-readiness — can an AI agent (Claude Code, Copilot, Cursor) actually be effective in this repo, or will it stumble on layout / convention / landmine issues that aren't obvious to humans? Walks three categories — (A) agent-instruction hygiene (AGENTS.md / CLAUDE.md / `@AGENTS.md` import, dev commands documented), (B) layout + stack legibility (root README signposting, monorepo structure, type info, tech-stack red flags AI struggles with), (C) confusion landmines via deep file sampling (stale comments contradicting code, misleading names, hidden re-exports, shadow conventions, lint config that disables type safety, test names that don't match assertions). Reports findings tiered by severity (blocker / major / minor / nit), prompts the user to pick what to fix, applies the approved fixes in a single PR (split if very different areas), and offers to raise GitHub issues for the things it can't auto-fix (renames, convention consolidations). For mature / pre-existing repos that never went through `/repo-bootstrap`. Use when the user says "is this repo AI-ready", "AI readiness check", "make this repo AI-friendly", "agent-readiness audit", "AI tooling audit", "can Claude work in this repo", "agent-onboarding", "AI confusion check", or wants a focused assessment of an existing codebase's friction for AI agents. Companion to `/repo-bootstrap` (greenfield day-0 scaffolding) and `/repo-release-ready` (release-readiness scaffolding) — `/ai-ready-repo` is the *retrofit* for repos that already exist.
---

# AI-readiness audit for an existing repo

Take an existing, working codebase and answer: **can an AI agent be effective in here, or will it stumble on things that aren't obvious to humans?** Walks three categories, reports findings, asks the user what to fix, and applies the fixes in one PR.

## When to use this vs the alternatives

- **`/repo-bootstrap`** — greenfield day-0 scaffolding. Creates a new repo from scratch with AGENTS.md, CLAUDE.md, and friends already in place. Use this for *new* repos.
- **`/repo-release-ready`** — day-0 → day-1 hardening. Adds release branches, secret scanning, branch protection, promotion workflows. Use this for *newly-bootstrapped* repos.
- **`/ai-ready-repo`** (this skill) — *retrofit* an existing, mature repo to be AI-friendly. Use when the repo never went through the bootstrap chain and you want AI agents to work productively in it.

This skill is read-and-recommend by default. It surfaces findings and lets the user decide what to fix.

## Prerequisites

1. **Working directory is inside a git repo** with a clean working tree (no uncommitted changes).
2. **`gh` CLI authenticated** with `repo` scope, for the slim AI-specific GitHub-side checks and for opening the remediation PR.
3. **The user has time.** The deep landmine sample (Category C) reads ~100 files. Allow 5-15 minutes for a typical mid-size repo.

## Workflow

Copy this checklist and track progress:

```text
ai-ready-repo progress:
- [ ] Step 0: Stack + size + age detection (cheap sniff)
- [ ] Step 1: Audit A — agent-instruction hygiene
- [ ] Step 2: Audit B — layout + stack legibility
- [ ] Step 3: Audit C — confusion-landmine sample (deep, ~100 files)
- [ ] Step 4: Slim GitHub-side AI-specific checks
- [ ] Step 5: Present findings tiered (blocker / major / minor / nit)
- [ ] Step 6: User picks remediation scope (all / selected / none)
- [ ] Step 7: Apply approved fixes; offer GitHub issues for the rest; produce summary
```

### Step 0 — Stack + size + age detection

Cheap, fast. Sets expectations for the rest of the audit.

```bash
# Repo size
git ls-files | wc -l                              # tracked-file count
git log --oneline | wc -l                         # commit count
git log -1 --format="%cs" $(git rev-list --max-parents=0 HEAD)  # first commit date
git log -1 --format="%cs"                         # most recent commit

# Stack detection (sample — extend per language)
ls package.json pnpm-lock.yaml yarn.lock package-lock.json 2>/dev/null
ls pyproject.toml requirements.txt Pipfile poetry.lock 2>/dev/null
ls Cargo.toml go.mod pom.xml build.gradle 2>/dev/null
ls *.csproj *.sln 2>/dev/null

# Framework sniff (sample — extend per ecosystem)
grep -l "next" package.json 2>/dev/null && echo "Next.js"
grep -l "react-native" package.json 2>/dev/null && echo "React Native"
grep -l "vite" package.json 2>/dev/null && echo "Vite"
grep -l "django" requirements.txt pyproject.toml 2>/dev/null && echo "Django"
grep -l "fastapi" requirements.txt pyproject.toml 2>/dev/null && echo "FastAPI"
grep -l "spring-boot" pom.xml build.gradle 2>/dev/null && echo "Spring Boot"
grep -l "rails" Gemfile 2>/dev/null && echo "Rails"
```

Record: stack, age, size (file count), recency. Use these to:

- Pick the right tech-stack red-flag patterns to look for (from `references/tech-stack-redflags.md`).
- Time-bound the landmine sample (very small repo → fewer files; very large repo → cap at 100 files but weight selection).

Print a one-liner so the user knows what's being audited.

### Step 1 — Audit A: agent-instruction hygiene

Walk `references/ai-ready-checklist.md` — section A. The substance:

**A1. Root agent files exist.**

```bash
ls AGENTS.md CLAUDE.md .github/copilot-instructions.md 2>/dev/null
```

- Missing `AGENTS.md` → **major** finding (auto-fixable: scaffold from the `/repo-bootstrap` template with stack-aware content).
- Missing `CLAUDE.md` → **major** (auto-fixable: scaffold with `@AGENTS.md` import).
- Missing `.github/copilot-instructions.md` → **minor** (auto-fixable: scaffold with `@../AGENTS.md` import).

**A2. CLAUDE.md uses `@AGENTS.md` import — not just a prose reference.**

Claude Code's documented `@<path>` import syntax inlines another file's content into context. A prose link ("see AGENTS.md") is just words; `@AGENTS.md` loads the file. Read `CLAUDE.md`. Check it contains `@AGENTS.md` (or `@./AGENTS.md`) on its own line as an import directive.

- CLAUDE.md exists but doesn't import AGENTS.md → **major** finding (auto-fixable: add `@AGENTS.md` line at the top).
- CLAUDE.md only mentions AGENTS.md in prose → **major** finding (auto-fixable: add the import directive in addition to the prose).
- Same check for `.github/copilot-instructions.md` importing `@../AGENTS.md` if both exist.

**A3. Dev commands are documented somewhere a CLAUDE.md-loaded agent can find them.**

The commands matter: `build`, `lint`, `test`, `test:unit`, `test:e2e`, `type-check`, `dev`, `migrate`, `seed`. Walk:

- `AGENTS.md` — does it list these commands?
- `README.md` — does it have a "Development" / "Getting Started" section that names them?
- `package.json` `scripts` — are the script names self-explanatory?

A repo where the agent has to guess that `pnpm verify` is the umbrella command (vs `pnpm test && pnpm lint && pnpm type-check`) is a stumble.

- Critical commands missing from any agent-accessible doc → **major** finding (auto-fixable: add a "Dev commands" section to AGENTS.md inferred from `package.json scripts` / `Makefile` targets / etc.).

**A4. `type-check` is not silently absent from `test:unit`.**

Common trap: repos accumulate TypeScript errors on `main` because `pnpm test:unit` doesn't run `tsc --noEmit`. Check:

- Does `test:unit` (or equivalent) script invoke `tsc --noEmit` / `mypy` / etc.?
- Does CI run type-check on `push` to `main`, not just on PRs?

If type-check is missing from both: **major** finding (cannot auto-fix without project-specific scripts; raise as a recommendation + offer to open an issue).

### Step 2 — Audit B: layout + stack legibility

Walk `references/ai-ready-checklist.md` — section B.

**B1. Root README explains the layout.**

```bash
grep -iE "^##? .*(structure|layout|directories|monorepo|apps|packages)" README.md
```

- README missing → **major** (auto-fixable: scaffold a skeleton with stack-detected sections).
- README present but no structure section → **minor** (auto-fixable: add a `## Structure` section listing the top-level dirs inferred from `ls -d */`).

**B2. Monorepo / multi-app structure is signposted.**

If the repo has `apps/`, `packages/`, `services/`, `cmd/`, or similar at root:

```bash
ls -d apps/* packages/* services/* 2>/dev/null
```

- Multiple apps but no `apps/README.md` explaining which is which → **minor** (auto-fixable: scaffold a per-directory README listing what each subdirectory contains).

**B3. Type information is present.**

- TypeScript: `tsconfig.json` with `strict: true`. Not strict → **minor** (don't auto-fix; raise as recommendation, since flipping strict on a mature codebase is a real refactor).
- Python: `pyproject.toml` / `mypy.ini` with type-checking configured. None → **minor** (recommendation only).
- Other: language-appropriate equivalent.

**B4. Tech-stack red flags.**

Apply the catalogue in `references/tech-stack-redflags.md`. The skill walks the patterns relevant to the detected stack. Each flag is reported with severity per the catalogue:

- Heavy metaprogramming / reflection (`__getattr__` chains, `method_missing`, Rust macros doing structural work) → **major** flag if widespread; **informational** if isolated.
- Implicit-everything framework usage (Rails magic, Spring annotations doing core lifting) → **informational** (a fact about the stack, not a defect).
- Mixed package managers in tree (multiple lockfiles) → **major** (auto-fixable: delete the stale lockfiles after confirming the active one).
- Mixed test-file conventions (some `*.test.ts` alongside source, some in `tests/`) → **minor** (recommendation only — consolidation is a project decision).
- Multiple framework-version paradigms (Next.js Pages + App Router; class + hook React components) → **major** flag in the report; user-decision how to handle.

The catalogue is the authoritative list; this section is the calling convention.

### Step 3 — Audit C: confusion-landmine sample (deep)

This is the most expensive category and the highest-leverage. Apply the methodology in `references/confusion-landmines.md`.

**Sample selection.** Weight toward files an AI agent is likely to *touch* and likely to be *confidently wrong about*:

1. Files in well-known paths (handlers, routes, services, components, models, lib, utils).
2. Files modified in the last 90 days (recency signal — actively being changed, more chance of stale state).
3. Files imported by many others (`grep -r "from '<path>'"` count; high incoming-edge files are core paths).
4. Files with name-suggests-purpose (e.g. `auth-utils.ts`, `userService.ts`, `apiClient.ts`).

Aim for **~100 files** (cap at 150 for very large repos; allow more time). Read them carefully.

**For each file in the sample**, scan for the landmines documented in `references/confusion-landmines.md`:

1. **Stale comments contradicting code.** JSDoc / docstring claims behaviour the function doesn't actually exhibit.
2. **Misleading names.** Function / variable / file name suggests one thing; body does another. (E.g. `handleSignout` that signs in.)
3. **Hidden re-exports / aliases.** `import { x } from './lib'` where the actual implementation is 3+ layers deep through re-exports.
4. **Generated files without headers.** Files that *look* hand-written but are emitted from a generator. Or hand-written files that look generated (auto-format, no human comments).
5. **Env var sprawl.** Code branches on `process.env.X` / `os.environ.get('X')` scattered across files with no central registry. Agent sees one branch and assumes that's the full behaviour.
6. **Shadow conventions.** Two distinct patterns for the same concept in one codebase. (Two state-management libs; two HTTP client wrappers; two date utilities.)
7. **Lint config disables human-relied checks.** `@typescript-eslint/no-explicit-any: off`, `no-floating-promises: off`, ESLint's `no-unused-vars: off`. The team relies on social pressure; the agent reads the config and trusts what isn't flagged.
8. **Test names mismatch assertions.** `test("rejects invalid email")` that actually asserts `expect(result).toBeDefined()`.
9. **Magic numbers / strings used as if they were config.** Constants embedded in 5 places that should be a single named export.
10. **Conditional code that looks dead.** Branch guarded by a flag that's always true (or always false) at runtime — agent reads the code and assumes both paths matter.

**Output of Step 3:** a list of landmine findings, each with:

- File:line.
- Landmine category (1-10 above).
- One-line description of the trap.
- Severity (blocker / major / minor / nit per `references/confusion-landmines.md`).
- Suggested remediation: *rename* / *add comment* / *consolidate* / *flag for human decision*.

### Step 4 — Slim GitHub-side AI-specific checks

Only AI-specific concerns. Branch protection / secret scanning / dependabot belong to `/repo-release-ready`, not here. The narrow scope here:

```bash
# Is there a @claude-mention workflow installed?
ls .github/workflows/claude*.yml 2>/dev/null

# Is there a CI gate that exercises the AI agent's flow?
gh api repos/{owner}/{repo} --jq '.default_branch' 2>/dev/null

# Are there branch-protection rules that *prevent* an AI agent from doing
# something unsafe (e.g. force-pushing to main)?
gh api repos/{owner}/{repo}/branches/{default}/protection 2>/dev/null
```

The questions:

- **Is there a `claude-on-demand.yml` / `@claude`-mention workflow?** Missing → **minor** finding (auto-fixable: scaffold the workflow from `/repo-release-ready`'s template).
- **Are agents required to PR rather than push to default?** Missing branch protection on default → **major** for AI-specific concerns (it means an agent could force-push main and lose work). Don't auto-fix — recommend running `/repo-release-ready`.
- **Anything else AI-specific?** Skip.

### Step 5 — Present findings

Produce a tiered markdown report. Show to the user.

```markdown
# AI-readiness audit — <repo name>

**Stack:** <detected>. **Age:** <N months>, ~<N> commits. **Files audited:** ~<N>.

## Summary

- Blockers: <N>
- Major: <N>
- Minor: <N>
- Nits: <N>

## Findings

### Blockers (AI agents will materially stumble here)

1. <Finding>. Where: <file:line or path>. Why it matters: <one-line>. Suggested fix: <one-line>. Auto-fixable: yes/no.

### Major

<as above>

### Minor

<as above>

### Nits

<as above>

## Auto-fixable findings

<count> of <total>. These can be applied immediately in a single PR.

## Findings that need human decision (can be raised as GitHub issues)

<count>. Listed below. Pick any to convert to issues at the next step.

---

What would you like to do?
- **Fix all auto-fixable + open issues for the rest.**
- **Fix selected auto-fixable + open issues for selected non-auto.**
- **Just produce the report — don't fix or open anything yet.**
```

The user replies with one of the three choices, plus (if "selected") which findings.

### Step 6 — User picks remediation scope

The skill waits for the user's reply. Three branches:

- **All auto-fixable + issues for the rest** → proceed to Step 7 with all auto-fix findings + all non-auto findings flagged for issue creation.
- **Selected** → user lists finding numbers; proceed with that subset.
- **Just report** → stop. The report is the artefact.

Confirm the scope back to the user before any writes.

### Step 7 — Apply approved fixes; offer GitHub issues; summarise

**A. Create a branch.**

```bash
git checkout -b ai-readiness-pass
```

**B. Apply the auto-fixable findings.**

By category:

- **A1 (missing root agent files):** scaffold `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` per the templates in `references/agent-file-templates.md`. Use the stack detected in Step 0 to fill stack-specific sections.
- **A2 (missing `@AGENTS.md` import):** prepend `@AGENTS.md` (or `@../AGENTS.md` for the copilot-instructions case) to the top of the file.
- **A3 (missing dev-commands section):** infer commands from `package.json scripts` / `Makefile` / `pyproject.toml [tool.poetry.scripts]` / etc., add a "Dev commands" section to `AGENTS.md`.
- **B1/B2 (missing structure section / multi-app signposting):** scaffold from `ls -d */` output.
- **B4 (mixed package managers / mixed lockfiles):** confirm the *active* package manager (look at which lockfile is recent + matches `packageManager` field), then delete the stale ones.
- **Category C (confusion landmines):** apply the auto-fixable subset — adding "// Generated — do not edit" headers, consolidating env-var usage into a `lib/env.ts` central registry if minor, adding clarifying comments where stale comments contradicted code. Heavier C findings (renames, convention consolidation) skip auto-fix and become issues.

Group commits by category for review clarity:

```
feat(ai-readiness): scaffold AGENTS.md and CLAUDE.md
chore(ai-readiness): add @AGENTS.md import to agent files
docs(ai-readiness): document dev commands
chore(ai-readiness): consolidate env-var usage into lib/env.ts
docs(ai-readiness): label generated files
```

**C. Offer GitHub issues for the rest.**

For each non-auto-fixable finding, the skill prompts:

> *"Finding C-7 (`apps/web/auth.ts:42` — function `handleSignout` actually signs the user *in*). This needs a rename + caller migration, which is too judgment-heavy to auto-fix. Raise as a GitHub issue?"*

User says yes / no per finding. The skill batches the approved ones:

```bash
gh issue create --title "<title>" --body "<body with file:line + suggested fix + ai-readiness label>" --label "ai-readiness"
```

Use a single label `ai-readiness` for grouping. Don't create a label that doesn't exist; ask the user once if they want the label created.

**D. Open the PR.**

```bash
git push -u origin ai-readiness-pass
gh pr create --title "chore(ai-readiness): apply audit fixes" --body "$(cat <<'EOF'
## Summary

Output of /ai-ready-repo audit and remediation. Applies the auto-fixable
findings; the non-auto-fixable findings have been raised as separate issues
labelled `ai-readiness`.

## Findings applied in this PR

- A1 — scaffolded AGENTS.md / CLAUDE.md / copilot-instructions.md
- A2 — added @AGENTS.md import directives so the files load into agent context
- A3 — documented dev commands in AGENTS.md
- B1/B2 — added structure section to README; per-app READMEs
- B4 — removed stale lockfiles (kept pnpm-lock.yaml as the active one)
- C — added "Generated" headers to <N> files; consolidated env-var usage

## Findings raised as issues (not in this PR)

- <issue numbers and one-line descriptions>

## Why one PR

Per the /ai-ready-repo skill default — auto-fixable findings ship as one PR for
review clarity. Splitting was considered but the changes are all
documentation/scaffolding/cleanup; no logic changes.

## Test plan

- [ ] Verify the new agent files load (open Claude Code in the repo and confirm).
- [ ] Verify the README structure section matches the actual directory layout.
- [ ] Verify the stale lockfile removal didn't break CI.
- [ ] Verify the env-var consolidation kept behaviour identical.

🤖 Generated with /ai-ready-repo (Claude Code)
EOF
)"
```

**E. Decide on splitting (rare).**

The default is one PR. Split into multiple only if the auto-fix surface covers genuinely different areas:

- Splitting trigger: more than ~15 files in two distinct subtrees (e.g. agent-files at root + code-quality fixes in `apps/web/`).
- Splitting trigger: a fix that's an opinionated change (e.g. consolidating shadow conventions in `lib/state/`) where the user might want to review independently of the docs scaffolding.

If splitting, name branches `ai-readiness-pass-<category>` (`docs`, `cleanup`, etc.) and reference each from the parent PR description.

**F. Terminal summary.**

Print to the user:

```markdown
# AI-readiness audit — done

- Audit findings: <N> total (<B> blockers / <M> major / <m> minor / <n> nits)
- Applied this PR: <N> findings
- Raised as issues: <N> findings (<issue links>)
- PR: <URL>
- Skipped (user opted not to fix or raise): <N>

Next: review the PR, merge when happy. The labelled issues (`ai-readiness`)
are a backlog of judgement-heavy refactors AI agents would benefit from.
Consider running `/issue-prioritise` on them.
```

## Strict non-goals

- **Doesn't set up MCP servers.** Out of scope; user-controlled.
- **Doesn't install Claude Code skills / plugins.** That's a user choice; this skill prepares the repo, not the agent.
- **Doesn't change runtime behaviour.** All Category A and B fixes are documentation / scaffolding. Most Category C fixes are documentation (Generated headers) or small refactors (env-var consolidation) that preserve behaviour. Bigger changes go to issues, not auto-fix.
- **Doesn't refactor away from a tech-stack red flag.** If the repo uses heavy Rails magic, this skill doesn't migrate it. It reports the friction and lets the user decide.
- **Doesn't audit the *quality* of the existing AGENTS.md / CLAUDE.md content.** If those files exist and the right imports are wired, the skill takes the content as-is. Improving the content is `/repo-bootstrap`'s scaffolding job, not this skill's.
- **Doesn't run for greenfield repos.** If the repo is fewer than ~30 commits old or fewer than ~50 tracked files, suggest `/repo-bootstrap` or `/repo-release-ready` first and ask the user to confirm before proceeding.

## Edge cases

- **Working tree is dirty.** Stop. Ask the user to commit or stash before proceeding — the skill creates a branch and commits changes; dirty state risks losing work.
- **Repo has no remote / no GitHub.** Apply local fixes and skip the PR / issue creation steps. Tell the user the audit is complete; they can push when they're ready.
- **`gh` CLI not authenticated.** Apply local fixes; skip the GitHub-side steps; tell the user to run `gh auth login` to enable the GitHub-side work.
- **Repo is huge** (>10k tracked files). Cap the Category C sample at 150 files but heavily bias the selection toward the recently-changed core paths. Note the cap in the report so the user knows the audit isn't exhaustive.
- **Repo has zero TypeScript / no type info anywhere.** B3 reports as a finding but doesn't push aggressively — typed languages exist; "use a type system" isn't a sensible auto-fix.
- **AGENTS.md exists but is generic boilerplate** that doesn't say anything about *this* project. Treat as if it has only the structural items (commands, references) — flag missing items normally.
- **CLAUDE.md already imports a different file** (e.g. `@.aiderc`) instead of AGENTS.md. Note the existing import and recommend adding `@AGENTS.md` as well rather than replacing; some teams maintain multiple agent files.
- **The repo is a fork of another repo.** Note this in the Step 0 detection. The upstream may have the agent files; the fork should keep them in sync or override consciously.
- **The repo has `.aider*`, `.cursor*`, `.continue*`, or other AI-tool-specific config.** Note their presence but don't audit them — `/ai-ready-repo` is agnostic to which agent the user runs.
- **A finding's auto-fix would conflict with an open PR.** Detect open PRs touching the affected files (`gh pr list --state open`). If conflict likely, skip the auto-fix and raise as an issue instead with a note about the conflicting PR.

## Why `@AGENTS.md` matters (the import-syntax citation)

Claude Code supports an `@<path>` import directive inside `CLAUDE.md` (and other markdown files in the project context). When the agent loads `CLAUDE.md`, any `@<path>` line is replaced with the content of `<path>` — the imported file becomes part of the active context window, not a "go look at this file" hint the agent might or might not follow.

Reference: Anthropic's Claude Code documentation describes this import behaviour. The practical implication for AI-readiness: a prose link ("see AGENTS.md") leaves the agent guessing whether to look; `@AGENTS.md` ensures the content is loaded.

This is why `/ai-ready-repo` flags a CLAUDE.md that mentions AGENTS.md only in prose, even if the prose is otherwise complete. The structural difference is real, not stylistic.
