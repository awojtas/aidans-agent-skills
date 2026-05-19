# Confusion Landmines — Category C Methodology

The "AI confidently thinks it understands the code, verifies its understanding, ships work, and is wrong" failure mode. This category is the highest-leverage part of `/ai-ready-repo` because the failures are *invisible* to humans (humans have implicit context an agent doesn't) and *invisible* to static tools (linters can't catch "this name is misleading").

This document describes:

1. How to sample files for the deep audit.
2. The 10 landmine patterns to scan for.
3. Severity rules and remediation defaults.

## Sample selection

Aim for **~100 files** in a typical mid-size repo (cap at 150 for very large ones). The sample is *not* random — it's weighted to maximise the chance of finding a landmine an AI agent would actually trip on.

### Weighting signals (combine, not exclusive)

**Signal 1 — Well-known core paths.** Files in directories an agent gravitates toward:

- `apps/*/src/`, `apps/*/app/`, `apps/*/pages/`
- `src/handlers/`, `src/routes/`, `src/services/`, `src/controllers/`
- `src/components/`, `src/lib/`, `src/utils/`, `src/helpers/`
- `src/db/`, `src/models/`, `src/repositories/`
- `packages/*/src/`
- Equivalents in other ecosystems (`internal/`, `pkg/` in Go; `lib/` in Ruby; `app/` in Rails; etc.)

Files in these paths are agent-magnets. Prioritise.

**Signal 2 — Recency.** Files modified in the last 90 days:

```bash
git log --since="90 days ago" --name-only --pretty=format: | grep -v '^$' | sort -u
```

Recently-changed files have a higher chance of carrying stale comments (the code moved but the comments didn't) or shadow conventions (a new pattern was introduced but the old one wasn't migrated).

**Signal 3 — Incoming-edge centrality.** Files imported by many others:

```bash
# Rough heuristic — count distinct files that import each path
git ls-files '*.ts' '*.tsx' '*.js' '*.py' | while read f; do
  imports=$(grep -lE "from ['\"][^'\"]*$(basename $f .ts | sed 's/\\./\\\\./g')['\"]" -- $(git ls-files) 2>/dev/null | wc -l)
  echo "$imports $f"
done | sort -rn | head -30
```

(Exact command varies per language; the principle is "count callers".)

High-incoming-edge files are core paths — if they're confusing, the confusion propagates.

**Signal 4 — Name-suggests-purpose.** Files / functions whose names make a *promise* about behaviour:

- `*Service.ts`, `*Repository.ts`, `*Manager.ts`, `*Handler.ts`, `*Util.ts`
- `validate*.ts`, `format*.ts`, `parse*.ts`, `sanitize*.ts`
- `auth*.ts`, `permission*.ts`, `session*.ts`
- `*.middleware.ts`, `*.guard.ts`, `*.interceptor.ts`

Files with promise-shaped names are the ones that *should* be doing what their name suggests. The landmines hide in mismatches.

### Combining signals

For each candidate file, score:

```
score = (in_core_path ? 2 : 0)
      + (modified_in_90d ? 2 : 0)
      + min(incoming_edges, 5)
      + (name_makes_a_promise ? 2 : 0)
```

Sort descending. Take the top 100 (or 150 cap for very large repos).

Print the sample list to the user at the start of Step 3 so they know what's being read. Allow them to add or remove a few entries if they have local knowledge of high-priority files.

## The 10 landmine patterns

Each pattern has:

- **What to look for** — the scanning instruction.
- **Why it traps agents** — the failure mode.
- **Default severity** — assuming a single instance; weight upward if widespread.
- **Auto-fixable** — yes / no / partial.

### Landmine 1 — Stale comments contradicting code

**What to look for:** function-level JSDoc / docstring / leading comment that claims behaviour the function body doesn't match.

- Comment says "returns null if user not found"; function throws.
- Comment says "synchronous"; function returns a Promise.
- Comment says "no side effects"; function writes to a global.
- Comment claims a parameter is optional; function dereferences it without a guard.

**Why it traps:** an agent reads comments first to understand intent. A wrong comment is worse than no comment.

**Default severity:** **major**. (Comments are load-bearing for AI navigation.)

**Auto-fixable:** Partial — the skill can flag the mismatch but shouldn't rewrite the comment without confirming which side (comment or code) is canonical. Default: raise as an issue per finding, or batch into a `docs(ai-readiness): correct stale comments` PR section if many low-stakes ones (typo-level mismatches).

### Landmine 2 — Misleading names

**What to look for:** function / variable / file / class names that promise behaviour the body doesn't deliver.

- `handleSignout` that signs in (real example).
- `validateEmail` that returns the email instead of a boolean.
- `getUserById` that returns the *full account* with related records (the name says `User`, the return type is `Account`).
- `auth-utils.ts` whose only export is a `formatDate` helper.

**Why it traps:** an agent uses names as primary signal for "where to make a change". Misleading names cause edits in the wrong place.

**Default severity:** **major** for promise-shaped names (`Service`, `Manager`, `Util`); **minor** for plain mismatches.

**Auto-fixable:** No. Renames touch every caller — too judgment-heavy. Raise as a GitHub issue per finding.

### Landmine 3 — Hidden re-exports / aliases

**What to look for:** `import { x } from './lib'` where the actual implementation of `x` is 3+ layers deep through re-exports. Walk the chain:

```
./lib/index.ts → re-exports from ./lib/auth.ts → re-exports from ./lib/auth/session.ts → actual impl in ./lib/auth/session/handler.ts
```

**Why it traps:** the agent does `grep -r "function x"` and finds nothing — the function is named something else internally. Or the agent edits `./lib/auth.ts` thinking it's the source; it's actually a thin re-export and the real change needs to happen 3 levels down.

**Default severity:** **major** if re-export chain is ≥ 3 layers; **minor** if 2 layers.

**Auto-fixable:** No. Flattening re-exports changes the public API. Raise as an issue with the chain documented; suggest documenting the *real* implementation path in a comment at the top of the re-export file.

### Landmine 4 — Generated files without "Generated" headers

**What to look for:** files emitted by a code generator (Prisma client, protoc output, OpenAPI codegen, gRPC stubs, GraphQL codegen, type-from-schema tools) that don't start with a `// This file was generated...` / `# AUTO-GENERATED` style header.

Detection heuristics:

- Path matches `*generated*`, `*.gen.*`, `__generated__/`, `node_modules/.prisma/`, `*.pb.go`, `dist/`, etc.
- File has uniform formatting (no whitespace variation, no human comments, programmatic naming).
- File is referenced from `.gitignore` but committed anyway, or vice versa.
- `package.json` has a `generate` / `codegen` script that produces files with this shape.

**Why it traps:** an agent edits a generated file. Edit is overwritten on the next generation. Looks like a flaky agent; actually the file was always going to be regenerated.

**Default severity:** **major** if a generated file in a path agents might touch (`src/`, `lib/`) doesn't have a header. **Minor** if it's in an obviously generator-owned dir (`__generated__/`, `dist/`).

**Auto-fixable:** Yes. Prepend a header:

```
// AUTO-GENERATED by <tool>. Do not edit by hand.
// Regenerate via: <command>
```

Use the detected generator + the package.json script as the regenerate command.

### Landmine 5 — Env var sprawl

**What to look for:** `process.env.X` (Node), `os.environ.get('X')` (Python), `env::var("X")` (Rust), `os.Getenv("X")` (Go), etc. scattered across files with no central registry.

Detection:

```bash
# Node example
grep -rnE 'process\.env\.[A-Z_]+' src/ | wc -l
grep -rnE 'process\.env\.[A-Z_]+' src/ | awk -F: '{print $1}' | sort -u | wc -l
```

If `(env-usages / unique-files) < 2` and there's no `lib/env.ts` / `config.ts` / equivalent that exports the validated set: **landmine**.

**Why it traps:** the agent sees one branch of code that reads `process.env.STAGE === 'production'` and assumes that's the whole behaviour. There may be 14 other env-var branches scattered across the codebase that the agent never saw.

**Default severity:** **major** if env vars are read in >10 distinct files; **minor** if 5-10; **nit** if <5.

**Auto-fixable:** Partial. The skill can:

- Generate a central `lib/env.ts` (or stack equivalent) exporting all detected env vars as typed constants.
- *Cannot* safely migrate all callers without testing — that's a per-call-site change. Default: scaffold the registry; raise an issue to migrate callers.

### Landmine 6 — Shadow conventions

**What to look for:** two distinct patterns for the same concept in one codebase.

Common shadow-pairs:

- Two state management libraries (Redux + Zustand; Vuex + Pinia).
- Two HTTP client wrappers (`fetch` + `axios`; custom `httpClient` + `fetch`).
- Two date libraries (`date-fns` + `moment`; `Temporal` + `Date`).
- Two test runners (`jest` + `vitest`).
- Two router paradigms in one app (Next.js Pages + App Router).
- Two component styles (class components + hooks).
- Two API styles (REST + GraphQL handlers in the same backend).

Detection: look for the imports across the sample. If two distinct libraries-for-the-same-job are imported in different files, that's a shadow convention.

**Why it traps:** the agent adds a new feature using whichever pattern it noticed first. The team might have been actively migrating *away* from that pattern. Now there's another file using the wrong convention.

**Default severity:** **major**. Shadow conventions are one of the biggest sources of agent-induced inconsistency.

**Auto-fixable:** No. Choosing the right pattern is a team decision. Auto-fix would be migrating one to the other — too big. Raise as an issue with a recommended canonical choice and a count of files using each.

### Landmine 7 — Lint config disables human-relied checks

**What to look for:** `eslintrc` / `pyproject.toml [tool.ruff]` / `mypy.ini` / etc. rules that disable safety nets.

ESLint examples:

- `@typescript-eslint/no-explicit-any: off`
- `@typescript-eslint/no-floating-promises: off`
- `no-unused-vars: off`
- `@typescript-eslint/no-non-null-assertion: off`
- `prefer-const: off`

Python equivalents:

- `mypy: ignore_missing_imports = true` everywhere
- `ruff` with `select = ["E"]` only (most safety rules disabled)
- `# type: ignore` comments scattered without justification

**Why it traps:** the agent reads the lint config and concludes "we don't enforce X, so X is fine here". The team's actual rule is "we don't enforce X because we trust each other not to do it"; the agent doesn't have that social context.

**Default severity:** **major** for safety-critical disables (`no-floating-promises`, `no-explicit-any`, `no-non-null-assertion`). **Minor** for style-only disables.

**Auto-fixable:** No. Re-enabling a lint rule on a mature codebase produces hundreds of new errors that need real fixes. Raise as an issue per rule with a count of how many lines would need attention.

### Landmine 8 — Test names mismatch assertions

**What to look for:** test names that promise specific behaviour, but the assertions are weak or test something else.

Examples:

- `test("rejects invalid email")` that asserts `expect(result).toBeDefined()` — the function returning *anything* passes, including the wrong outcome.
- `test("calculates p95 correctly")` that asserts `expect(p95).toBeGreaterThan(0)` — passes for `1`, passes for `9999`, doesn't test correctness.
- `test("isolates tenants")` that doesn't actually test cross-tenant access.

Detection: in each sampled test file, look at each `test(...)` / `it(...)` block. The string name promises something; the body should assert it. Mismatches are the landmines.

(Scoring heuristic for scale: count assertions that are `toBeDefined`, `toBeTruthy`, `not.toBeNull`, `toEqual(expect.anything())` — these are *almost always* weak.)

**Why it traps:** the agent reads the test name and assumes coverage. Adds a change. Tests pass. Bug ships.

**Default severity:** **major** for weak assertions on critical paths (auth, payment, permission). **Minor** elsewhere.

**Auto-fixable:** No. Strengthening assertions requires understanding what *should* be asserted. Raise as an issue per finding, batched into a `tests(ai-readiness): strengthen weak assertions` issue if many.

### Landmine 9 — Magic numbers / strings used as config

**What to look for:** the same literal value appearing in 3+ places where it's clearly a configuration knob, not a coincidence.

- `5 * 60 * 1000` (a 5-minute rate-limit window) in `signin.ts`, `rate-limit.ts`, `signin.test.ts`.
- `'paid'`, `'trial'`, `'cancelled'` subscription-status strings hardcoded across services.
- API base URLs hardcoded in multiple clients.

Detection: simple grep for non-trivial literals across the sample. Count occurrences. Anything > 3 with semantic meaning is a candidate.

**Why it traps:** the agent changes the rate-limit in one place; behaviour drifts in the others.

**Default severity:** **major** for safety-relevant magic (rate limits, retry counts, timeouts). **Minor** for cosmetic (label strings).

**Auto-fixable:** Partial — the skill can scaffold a `constants.ts` / `config.ts` with the detected magic values exported as named constants. *Cannot* safely migrate all call sites without testing. Default: scaffold the constants file; raise an issue to migrate callers.

### Landmine 10 — Conditional code that looks dead

**What to look for:** branches guarded by flags / env vars / config values that are always (or never) true at runtime.

- `if (FEATURE_FLAG_X) { ... }` where `FEATURE_FLAG_X` is `true` in every env config.
- `if (process.env.LEGACY_MODE === '1') { ... }` where `LEGACY_MODE` was retired in 2023.
- Feature-flag references to flags that no longer exist in the flag service.

Detection: walk the env-var registry (or feature-flag config). Cross-reference flag/env values across env files. Branches where the guard is always one way at runtime are landmines.

**Why it traps:** the agent reads the conditional and assumes both branches matter. Adds a change to the unreachable branch. The change ships but is dead code.

**Default severity:** **major** for retired feature flags / env vars; **minor** for "the branch is theoretical but might be revived".

**Auto-fixable:** No. Removing dead branches changes behaviour subtly (what if the flag *is* used somewhere we missed?). Raise as an issue per finding with a recommendation to either remove the branch or document why it's intentionally preserved.

## Output of Category C

Each landmine finding has:

- ID (`C1-3`, `C7-1`, etc.).
- Landmine number (1-10).
- File:line(s).
- One-line description.
- Severity.
- Auto-fixable? (yes / no / partial).
- Suggested remediation.

Group findings by landmine number in the report for readability — easier for the user to decide "fix all the Generated headers, raise issues for all the rename ones" than to walk file-by-file.

## What this category does NOT do

- **Does not run the test suite** to verify weak assertions. The pattern-match is on the assertion code, not the runtime behaviour. (Running the suite is a separate `/test-fix` skill's job.)
- **Does not refactor.** Auto-fixes are limited to headers + scaffolding new registry files. Renames, consolidations, and assertion strengthening are issues.
- **Does not chase every minor inconsistency.** The audit is for *traps*, not style preference. Two-spaces vs four-spaces indent is not a landmine; the formatter handles it.
- **Does not audit code the agent is unlikely to read.** Vendored libraries, generator output in `node_modules/`-equivalents, build outputs are skipped by sample selection.
