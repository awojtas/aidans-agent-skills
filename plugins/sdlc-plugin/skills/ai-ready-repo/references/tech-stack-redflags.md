# Tech-Stack Red Flags AI Agents Struggle With

A catalogue of stack patterns that introduce friction for AI agents. Used by Category B (layout + stack legibility) and partly by Category C (confusion landmines). Each entry: what to detect, why it traps agents, severity, remediation default.

This catalogue is **not exhaustive**. Add new patterns as new ones surface in real-world audits.

## Cross-cutting (any stack)

### Mixed package managers

**Detect:** more than one of `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` exists in one project root (not different workspaces — same root).

**Why traps:** the agent runs `npm install` because it sees `package-lock.json`; the team uses `pnpm`. The next `pnpm install` rewrites the world.

**Severity:** **major**.

**Auto-fix:** Yes. Detect which lockfile is recent (`git log -1 --format=%ct -- <lockfile>`) and matches `packageManager` in `package.json` if set. Keep that one; delete the others. Confirm with the user before deleting.

### Multiple framework paradigms in one app

**Detect (Next.js example):** both `pages/` and `app/` directories exist at the Next.js root. Both have route files.

**Detect (React example):** mix of class components (`extends Component`) and function components in the same codebase, both actively maintained (commits in the last 90 days on both).

**Detect (Vue example):** both Options API and Composition API in use without a documented migration plan.

**Detect (Python web example):** both Flask Blueprints and FastAPI routers mounted in the same process.

**Why traps:** the agent picks the pattern it noticed first. The team may be actively migrating *away* from that pattern.

**Severity:** **major**.

**Auto-fix:** No. Migration is a project decision. Raise as a GitHub issue with the file counts per paradigm and a recommendation to either migrate or document the canonical choice in `AGENTS.md`.

### Mixed test runner / framework

**Detect:** `jest.config.*` + `vitest.config.*`; `pytest.ini` + `nose.cfg`; multiple test-runner invocations in `package.json scripts`.

**Why traps:** the agent uses one runner; CI uses the other. Tests pass locally; fail in CI (or vice versa).

**Severity:** **major** if both are actively run; **minor** if one is clearly legacy (no recent commits on its tests).

**Auto-fix:** No. Consolidation is a project decision. Raise as an issue.

### Mixed module systems

**Detect (Node):** `.cjs` + `.mjs` + `.js` files with `"type": "module"` ambiguity; CommonJS `require` calls in `.mjs` files; ESM imports in `.cjs` files.

**Why traps:** the agent writes ESM; the file is interpreted as CommonJS. Confusing runtime errors that look like the agent's bug but are actually the project's module config.

**Severity:** **major**.

**Auto-fix:** No. Settling on one module system is a project decision.

## JavaScript / TypeScript specific

### `tsconfig.json` with `strict: false`

**Detect:** root or app `tsconfig.json` doesn't have `"strict": true` (or has individual strict-family options disabled: `strictNullChecks: false`, `noImplicitAny: false`).

**Why traps:** the agent writes code assuming the type system catches null-undefined. The type system actually accepts `null`/`undefined` everywhere. Runtime null-deref ships.

**Severity:** **minor**. (Not major because flipping `strict: true` on a mature codebase is a real refactor — too project-specific to push.)

**Auto-fix:** No. Raise as a recommendation.

### `any` / `unknown` overuse

**Detect:** `grep -rn ": any" --include='*.ts' --include='*.tsx' | wc -l` divided by total TS line count. If high (>0.5%), flag.

**Why traps:** agent reads `any` and assumes free-form data; downstream code expects a specific shape.

**Severity:** **minor**.

**Auto-fix:** No. Typing the `any`s is a per-call-site change.

### Implicit `process.env` typing

**Detect:** `process.env.X` used widely without a `globalThis` augmentation or a runtime validator (Zod, T3 env, `envalid`).

**Why traps:** agent reads `process.env.STAGE` and treats it as `string`; it can be `undefined`.

**Severity:** **minor** (related to the env-sprawl landmine in Category C).

**Auto-fix:** Partial. The skill can scaffold a typed env module; cannot migrate call sites.

### Heavy Webpack / build-tool customisation

**Detect:** `webpack.config.*` / `next.config.*` / `rollup.config.*` with > 100 lines of customisation; custom loaders / plugins inline.

**Why traps:** the agent doesn't know which transforms apply where; behaviour seems magical.

**Severity:** **informational** (a fact about the stack, not a defect to fix).

**Auto-fix:** No.

## Python specific

### Mixed Python versions in one project

**Detect:** `pyproject.toml` declares `python = "^3.11"`; CI runs `3.9`; `setup.py` says `python_requires=">=3.7"`.

**Why traps:** agent writes 3.11-specific syntax; CI fails on 3.9.

**Severity:** **major**.

**Auto-fix:** No. Aligning versions is a project decision.

### Heavy metaprogramming

**Detect:**

- `__getattr__` / `__getattribute__` defined widely.
- Heavy use of `getattr(obj, ...)` / `setattr(obj, ...)`.
- Pydantic / dataclass / attrs models with extensive `__init_subclass__`, validators that mutate.
- Django models with custom `Meta` doing real lifting.

**Why traps:** the agent reads the class definition; runtime behaviour is shaped by metaclass / descriptor magic the agent never sees.

**Severity:** **major** if widespread; **informational** if isolated.

**Auto-fix:** No. Removing metaprogramming is a real refactor.

### Untyped or partially-typed Python

**Detect:** `mypy.ini` / `[tool.mypy]` not configured; or configured with `ignore_missing_imports = true` globally; or `disallow_untyped_defs = false`.

**Severity:** **minor**. Same reasoning as TypeScript strict — too project-specific to push.

**Auto-fix:** No.

### Implicit Django magic without docs

**Detect:** Django project with custom managers, signals, middleware doing significant work, and no `AGENTS.md` section explaining the architecture.

**Why traps:** the agent edits a model; a signal fires; downstream side-effects propagate. Agent doesn't see the signal.

**Severity:** **major**.

**Auto-fix:** Partial. Scaffold an "Architecture overview" section in `AGENTS.md` listing detected signals and middleware.

## Ruby specific

### Heavy Rails magic

**Detect:** Rails app. Always informational — Rails is convention-over-configuration by design.

**Why traps:** the agent edits a model; the controller behaviour changes through associations the agent doesn't trace.

**Severity:** **informational**.

**Auto-fix:** No.

### `method_missing` / `respond_to_missing?` usage

**Detect:** `grep -rn "method_missing" app/ lib/`.

**Severity:** **major** if used in core paths.

**Auto-fix:** No.

## Go specific

### Vendored dependencies look like first-party code

**Detect:** `vendor/` exists alongside `go.mod` and `vendor/` is committed.

**Why traps:** the agent edits a `vendor/` file thinking it's the project's; edit is lost on next `go mod vendor`.

**Severity:** **major** unless `vendor/` has a top-level note + path in `AGENTS.md` saying "don't edit".

**Auto-fix:** Yes. Add an "Areas to avoid" section to `AGENTS.md` naming `vendor/`.

### Heavy interface / generics usage with confusing signatures

**Detect:** Go 1.18+ generics used in core paths with type parameters per function call.

**Severity:** **informational** (this is just modern Go).

**Auto-fix:** No.

## Rust specific

### Heavy macro usage

**Detect:** `macro_rules!` / `proc_macro` widely used in domain code (not test fixtures).

**Why traps:** the agent reads a macro invocation; the expansion is non-obvious. The compiler error refers to expanded code the agent never sees.

**Severity:** **major** if widespread; **informational** if isolated to derive macros.

**Auto-fix:** No.

## Java / Kotlin specific

### Heavy annotation-driven configuration

**Detect:** Spring Boot, Quarkus, Micronaut projects. Annotations doing core lifting (`@Transactional`, `@Async`, `@Cacheable`, `@PreAuthorize`).

**Why traps:** the agent edits a method; the annotations change behaviour invisibly.

**Severity:** **informational**.

**Auto-fix:** Scaffold an "Annotations to watch" section in `AGENTS.md`.

### XML configuration alongside annotations

**Detect:** `applicationContext.xml` + `@Component` / `@Service` in the same project.

**Why traps:** the agent reads annotations; configuration is partly in XML.

**Severity:** **major**.

**Auto-fix:** No.

## .NET specific

### Reflection-heavy code without comments

**Detect:** widespread `Activator.CreateInstance` / `Type.GetMethod(...).Invoke(...)`.

**Severity:** **major** in core paths.

**Auto-fix:** No.

### Implicit DI registration

**Detect:** assembly-scanning DI (`services.Scan(...).FromAssemblyOf<...>()`).

**Why traps:** the agent reads the DI setup; specific bindings are implicit.

**Severity:** **informational**.

**Auto-fix:** Add a section listing DI conventions.

## Frontend specific (any framework)

### Generated CSS in repo

**Detect:** `dist/styles.css` or similar committed alongside `src/styles.scss`.

**Why traps:** the agent edits the generated file; edit is overwritten on build.

**Severity:** **major** if no header marks the generated file.

**Auto-fix:** Yes. Add a generated-header to the file; add it to `.gitignore` if the build always regenerates.

### Styling: multiple paradigms

**Detect:** CSS-in-JS (styled-components, emotion) + CSS modules + utility classes (Tailwind) + plain CSS, all in active use.

**Severity:** **major** (shadow-convention specialisation).

**Auto-fix:** No.

## Infrastructure / IaC

### Terraform + CloudFormation + manual cloud resources

**Detect:** `terraform/` + `cloudformation/` + manual-provision notes in docs.

**Why traps:** the agent updates Terraform; the resource is actually managed by CloudFormation; drift.

**Severity:** **major**.

**Auto-fix:** No.

### Mixed deployment targets without documentation

**Detect:** `Dockerfile` + serverless config (`serverless.yml` / `vercel.json` / `netlify.toml`) + traditional VM setup hints, all in one repo.

**Severity:** **major**.

**Auto-fix:** Scaffold a "Deployment targets" section in `AGENTS.md`.

## How this catalogue is used

Each detected red flag becomes a finding with the severity above. Findings flow into the main report (Step 5 of the skill). The user picks which to address; auto-fixable ones become commits in the remediation PR, non-auto-fixable ones become GitHub issues.

## Extending the catalogue

When a new stack pattern surfaces in real audits as an agent confusion source:

1. Add a section to the appropriate language / cross-cutting block.
2. Describe **detection** (the grep / file presence / config-check).
3. Describe **why traps** (the failure mode).
4. Pick **severity** (start with the closest existing pattern).
5. Specify **auto-fix** (usually no for big patterns; yes for scaffolding-shaped fixes).
