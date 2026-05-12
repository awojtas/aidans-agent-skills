# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that give it new tricks for common dev work.

## Getting started

Open Claude Code and run:

```
/plugin marketplace add awojtas/aidans-agent-skills
```

After that, open `/marketplace` again, navigate to "Aidan's Agent Skills", and pick which plugins you want to install.

Then close and re-open Claude Code - skills don't hot-reload, so you need a fresh session for them to show up.

## How to contribute

Want to add a skill? Point your AI coding agent at this repo and tell it what you want to build. The [AGENTS.md](AGENTS.md) file has the full walkthrough for adding a new plugin and skill, so the agent can handle the scaffolding, file structure, and marketplace registration on its own.

## Skills

### Build Fixer (`/build-fixer`)

Runs your build, reads the errors, fixes them, runs it again. Keeps going until it compiles or it's clear something needs human attention.

Works with .NET, Node.js (npm/pnpm/yarn/bun), Rust, Go, Java (gradle/maven), Make, and others.

What it does:

- Figures out your build command from project files
- Classifies errors as fixable code problems vs. environment issues it can't solve
- Loops through fixes until the build passes or it stops making progress
- Tells you what's left if anything still fails

Ask Claude to fix build errors, clean up lint warnings, or just paste your build output.

---

### Design System Aurora (`/design-system-aurora`)

A full design system built around glassmorphism, aurora gradients, neon glows, and a purple-cyan palette. Think frosted glass cards with glowing edges.

What it does:

- Gives you design tokens for colors, typography, spacing, and shadows
- Walks you through glassmorphic styling - backdrop blur, translucent borders, neon glow effects
- Includes aurora gradient animations and gradient text patterns
- Covers responsive design, dark mode, accessibility, and animation
- Comes with reference docs for tokens, glass patterns, and component examples

Use it when you're building or tweaking UI components and want them to match the Aurora look.

---

### E2E Test Runner and Fixer (`/e2e-test-runner-fixer`)

Your E2E tests are failing. This skill figures out why and fixes them.

Works with Playwright, Cypress, and WebDriver.

What it does:

- Finds your runner config, test specs, helpers, and seed scripts
- Reproduces failures in isolation before touching anything
- Sorts failures into categories: real bug, flaky test, environment-dependent, platform-specific
- Digs into root causes like data setup mismatches, race conditions, stale locators, or auth leakage
- Makes the smallest fix that actually solves the problem, then re-runs to confirm

Use it when E2E tests break, specs are flaky, or your CI test job is red.

---

### Issue Closer (`/issue-closer`)

Goes through your open GitHub issues and closes the ones where the work is already done.

What it does:

- Pulls up all open issues in the current repo
- Checks for evidence that they're finished - merged PRs, commits, code that matches the request
- Closes anything that's clearly done, with a comment explaining why
- Gives you a summary of what got closed and what's still open

Good for cleaning up a backlog that's gotten stale, or after a sprint where tickets didn't get closed along the way.

---

### Issue Prioritiser (`/issue-prioritiser`)

Looks at your open GitHub issues and helps you figure out what to work on next.

What it does:

- Pulls issues matching a filter (milestone, label, or everything)
- Checks whether each issue is still relevant and well-defined enough to act on
- Rates priority based on impact, how often people hit the problem, and effort to fix
- Labels them: highest, high, medium, low, nice to have
- Flags issues that might already be done or too stale to matter
- Recommends a ranked list of what to tackle first

Use it when the backlog feels like a mess and you need a starting point.

---

### Issue Worker (`/issue-worker`)

Give it a GitHub issue and it does the whole thing - reads the ticket, understands the codebase, writes code, adds tests, and makes sure everything passes.

What it does:

- Reads the issue and pulls out acceptance criteria and scope
- Explores the repo to understand conventions, build system, and stack
- Creates a branch and writes the minimum changes needed
- Adds unit and integration tests using whatever patterns already exist
- Runs lint, type-check, build, and tests, fixing anything that fails
- Double-checks against the acceptance criteria before reporting back

Say "work on issue #123" or drop in a GitHub issue link.

---

## SDLC bundle — `/sdlc-plugin`

The next ten skills are bundled together under the **`sdlc-plugin`** marketplace entry. Install once, get the full workflow: bootstrap a fresh repo → level it up to release-ready → sketch the initial architecture → provision the cloud platforms the architecture names → elicit requirements → confirm them → plan the implementation as GitHub issues → implement one issue end-to-end with audited handoffs → check your work whenever you want a focused critical audit → rework when a discovery during implementation changes direction. They're designed to be used in sequence but each is useful on its own.

| Order | Skill                                    | What it produces                                           |
|-------|------------------------------------------|------------------------------------------------------------|
| 1     | [`/repo-bootstrap`](#repo-bootstrap-repo-bootstrap)             | A new private GitHub repo, cloned to `~/src/<name>`, with starter files. |
| 2     | [`/repo-level-up`](#repo-level-up-repo-level-up)               | Release branches, promotion workflows, secret scanning, branch protections. |
| 3     | [`/initial-design`](#initial-design-initial-design)             | `docs/architecture/` — first-stab architectural sketch (system type, components, hosting, stack, data, integrations, lightweight ADRs, open questions). |
| 4     | [`/provision-platform`](#provision-platform-provision-platform)        | The cloud/SaaS platforms named in `docs/architecture/` actually provisioned — hosting, observability, DBs, auth, etc. Secrets wired into GH Actions; results logged to `docs/architecture/provisioning-log.md`. |
| 5     | [`/create-requirements`](#create-requirements-create-requirements)        | `docs/requirements/` — interactively elicited functional + non-functional requirements (reads `docs/architecture/` first). |
| 6     | [`/confirm-requirements`](#confirm-requirements-confirm-requirements)     | Same folder, requirements validated and advanced through `Draft → Reviewed → Approved`. |
| 7     | [`/tasks-from-requirements`](#tasks-from-requirements-tasks-from-requirements)   | GitHub issues + milestones + labels — small-batch tasks, human-required work front-loaded. |
| 8     | [`/implement-task`](#implement-task-implement-task)                 | One GitHub issue taken from picked-up to PR-ready, via a seven-persona orchestration (incl. UX/UI Designer) with audit-trail comments. |
| —     | [`/check-work`](#check-work-check-work)                         | A generic "please just check your work carefully" second-pass skill. Works on anything — code, plans, writing, analysis. Saves typing the phrase. |
| —     | [`/rework`](#rework-rework)                                 | Assertively course-corrects both the requirements docs *and* the open GitHub issues when an implementation-time discovery invalidates the plan. |

---

### Repo Bootstrap (`/repo-bootstrap`)

Stands up a brand-new GitHub repo from nothing. Asks for a project name and a one-line intro, then does the rest.

What it does:

- Creates a private GitHub repo under your account
- Clones it to `~/src/<repo-name>`
- Scaffolds `.gitignore`, `.gitattributes`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `LICENSE` (proprietary), `.github/copilot-instructions.md`, `.github/pull_request_template.md`, and a `check-root-docs` workflow that enforces only `README/AGENTS/CLAUDE.md` in the repo root
- Makes the initial commit and pushes to `origin/main`

Day-0 only — branching, CI, deploys, dependabot, observability, etc. are out of scope and belong to the companion `/repo-level-up` skill below.

Say "new project", "bootstrap a repo", or "spin up a project".

---

### Repo Level-Up (`/repo-level-up`)

Takes a freshly bootstrapped repo to release-ready maturity. The companion to `/repo-bootstrap`.

What it does:

- Adds `release/uat` and `release/prod` branches off `main`
- Scaffolds promotion workflows: `main → release/uat` and `main → release/prod`, with a Vercel deployment-status gate and a `force_deploy` escape hatch on production
- Adds GitGuardian secret scanning, Claude On-Demand (`@claude` mentions), vibe-guard SARIF, a Copilot setup stub, and Dependabot (`github-actions` ecosystem)
- Replaces the minimal PR template with a version-label-aware one (`version:major/minor/patch/skip`)
- Installs three branch-protection rulesets via `gh api`: `Main <Repo>`, `UAT <Repo>`, `Production <Repo>` — all requiring PRs and blocking force-push / deletion
- Appends a "Deployment & Branching Strategy" section to `AGENTS.md`
- Opens a **"Checklist for Human Admin"** GitHub issue listing every manual step that's left (secrets to add, Vercel project to wire up, GitHub Security toggles to flip, version labels to create, etc.)

Run it after `/repo-bootstrap` when you're ready to lock down branches and start shipping. Say "level up this repo", "make this release-ready", "add UAT and prod branches", or "harden this repo".

---

### Initial Design (`/initial-design`)

The bridge between *"the repo exists"* and *"we know what we're building in detail"*. Captures a **first stab** at the architecture so the requirements skill isn't elicited in a vacuum (a "messaging app" looks very different over serial cable vs cloud — the architecture decides which).

What it does:

- Reads `README.md` and any existing context.
- Walks **7 topics** in order — system type, hosting/runtime, major components, stack, data, external integrations, architecture pattern fit. 3-5 questions per topic; 30-90 minutes total.
- Writes `docs/architecture/` as a small set of focused markdown files:
  - `00-system-overview.md` — system context + container view (with Mermaid diagram)
  - `01-stack-and-hosting.md` — languages, frameworks, hosting platform, runtime model
  - `02-data-and-storage.md` — stores, sensitivity, retention, single/multi-region
  - `03-external-integrations.md` — third-party APIs and partners with sub-processor list
  - `04-decisions.md` — lightweight **ADRs** (Michael Nygard's format, 1-2 paragraphs each) covering every architectural choice that constrains future work, with a *Re-decide when* trigger where applicable
  - `05-open-questions.md` — what was deliberately punted, with revisit triggers
- **Pushes back on premature complexity** — proposes modular monolith before microservices, managed PaaS before Kubernetes, single-region before multi-region. Captures the alternatives as open questions for later.
- Treats this as a **first stab** — not exhaustive, not finished. The expectation is the folder evolves as requirements firm up. Each evolution is recorded (ADRs are Superseded, not deleted).
- **Re-design mode** for when `docs/architecture/` already exists: walks only the topics that changed; supersedes old ADRs rather than deleting them.

Grounded in [Simon Brown's C4 model](https://c4model.com/), [Michael Nygard's ADR format](https://github.com/joelparkerhenderson/architecture-decision-record), Fowler's [`MonolithFirst`](https://martinfowler.com/bliki/MonolithFirst.html), and [The Twelve-Factor App](https://12factor.net/).

Use it right after `/repo-bootstrap` (and before `/create-requirements`). Say "initial design", "design the architecture", "what's the technical shape", or "sketch the architecture".

---

### Provision Platform (`/provision-platform`)

Stands up the cloud platforms and SaaS services the architecture names — and then wires the resulting secrets into GitHub Actions so the deployed system can actually run.

What it does:

- Reads `docs/architecture/` to inventory every external thing the system depends on (hosting, observability, DBs, auth, email, queues, AI providers, analytics, ...) — not restricted to a fixed catalogue
- For each one, **tries every channel it has** — connected MCP servers, locally installed CLIs, HTTP APIs via WebFetch — until something works. Open-ended on purpose: anything Claude can reach is fair game
- Provisions what it can autonomously and captures the outputs (project IDs, regions, DSNs, URLs, tokens)
- Batches the bits **only a human can do** (account signups, billing decisions, OAuth, copying secrets out of dashboards) into a **single checklist** rather than dripping prompts one at a time
- Wires secrets into GitHub Actions (`gh secret set`) and the platforms' env stores; updates `.env.example` with the names (never the values)
- Records everything in `docs/architecture/provisioning-log.md` — the bridge between the architecture doc and the actual state of the cloud

Run it after `/initial-design` and before you really start building. Say "provision the platform", "stand up the stack", "set up the infrastructure", "wire up the cloud services", or "spin up the runtime".

---

### Create Requirements (`/create-requirements`)

Interactively elicits software requirements (both functional and non-functional) from you and writes them up as a structured set of short markdown files in `docs/requirements/`.

What it does:

- Reads your `README.md` (default grounding source) and any existing context, then runs a stakeholder + goals + scope discovery interview. If no `README.md` exists, asks you to supply an alternative source — describe the project in chat, or point at a local file, URL, PDF, or doc-server page
- Captures **goals AND non-goals** explicitly — the non-goals section is treated as more important than the goals one (most project blow-outs come from under-documented "won't do" items)
- Walks each functional domain (auth, billing, admin, ...) one at a time with question banks adapted from BABOK
- Walks every ISO 25010 quality attribute (performance, security, reliability, usability, maintainability, compatibility, portability) plus modern additions (observability, privacy/compliance, accessibility, i18n, cost) — won't let you skip a category
- Captures every assumption in `07-assumptions.md` and every deferred decision in `08-open-questions.md`, so nothing implicit survives
- Force-ranks Musts in a MoSCoW pass to surface the real MVP
- Runs an INCOSE quality-checklist sweep at the end (necessary / unambiguous / singular / verifiable / traceable, etc.)
- Designed as a multi-session skill — re-invoke to pick up where the last session stopped

Grounded in [Volere](https://www.volere.org/), [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), [ISO/IEC 25010](https://en.wikipedia.org/wiki/ISO/IEC_25010), the INCOSE Guide for Writing Requirements, [BABOK](https://www.iiba.org/standards-and-resources/babok/), and [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119). The output feeds a downstream architecture-design phase.

Highly interactive — set aside 30–90 minutes for a first useful pass. Pause and resume any time. Say "create requirements", "elicit requirements", "document requirements", "what should this project do", or "scope this out".

---

### Confirm Requirements (`/confirm-requirements`)

The refining companion to `/create-requirements`. Where the eliciter produces requirements from interview, this one validates the ones already on disk and advances them through the status lifecycle.

What it does:

- Inventories `docs/requirements/` and shows you an annotated directory listing with status counts (Drafts vs Reviewed, open vs resolved questions, unvalidated vs validated assumptions, stale items)
- Prompts you up front — "All requirements" or "Specific requirement(s)" — and tailors the session accordingly (one file, one requirement, just the Drafts, etc.)
- For each requirement in scope, runs a **five-pass model**:
  1. **Still accurate?** Echoes the statement back and asks what's changed
  2. **Fit criterion measurable?** Pressure-tests how you'd actually verify it
  3. **Assumptions still hold?** Walks every linked `A-NNN` — validate, falsify, or extract new ones
  4. **Open questions resolved?** Walks every linked `OQ-NNN` — resolve and update
  5. **INCOSE quality + smell list** — hostile re-read catches the worst-case-minimum-bar implementations
- Advances `Status: Draft → Reviewed` only with explicit user confirmation. Never auto-promotes.
- Updates the requirement file in place; moves resolved open questions to their "Resolved" section (keeps as decision history); updates assumption validation states.
- Cascades: when an assumption is **Falsified**, scans every linked requirement and flags downstream impacts.
- Appends a structured **session log** entry to `docs/requirements/session-log.md` — the audit trail of every confirmation pass.
- Includes a worked before/after example (`example-confirmation-session.md`) showing a Draft requirement → Reviewed across one session.

Use it periodically (after stakeholder conversations, after market changes, after assumptions get tested). Say "confirm requirements", "review requirements", "validate requirements", "walk through the requirements", or "pressure-test what we have".

---

### Tasks from Requirements (`/tasks-from-requirements`)

Turns the requirements you've already documented (via `/create-requirements` and refined via `/confirm-requirements`) into a concrete plan of GitHub issues. Pure planning — no code generation.

What it does:

- Reads every `FR-` and `NFR-` requirement, the MoSCoW prioritisation, the constraints, the integrations, and the assumptions/open-questions registers
- Decomposes each requirement into **small-batch tasks** (≤1 day each) — schema → API → UI → integration → tests, with each layer as its own task
- Identifies which tasks need a **human** (account creation, API keys, design decisions, legal review, sign-off — full catalogue in the reference docs) and **front-loads them into Phase 1**, because humans are slower than AI and the AI shouldn't sit idle waiting
- Orders the rest into 3–7 phases with dependencies tracked via each issue's `Blocked by:` field
- Names tasks with **staged numbering** — `1.1`, `1.2`, `2.1`, `2.2`... — so the title alone tells you where in the plan you are
- Writes each issue with a **clear Definition of Done** + Given-When-Then **acceptance criteria** + an `Implements:` line tracing back to the requirement IDs
- Applies a **minimal 8-label set**: `priority:high/medium/low`, `bug`, `chore`, `docs`, `human-required`, `blocked`. **Never** uses labels for phases — phases are GitHub milestones
- Creates one milestone per phase (`Phase 1: Foundation`, `Phase 2: Core Auth`, ...) and links every issue to its milestone
- **Shows you the full plan as a markdown document first** (`docs/implementation-plan.md`) so you can edit it before any GitHub issue is created. Nothing is created without your explicit approval.
- Detects existing labels, milestones, and issues by title — never duplicates on re-run

Companion to `/create-requirements` and `/confirm-requirements`. Run it once the requirements are mostly Reviewed and you're ready to start work.

Say "plan the implementation", "create issues from requirements", "break this into tasks", "what do we build first", or "make me a backlog".

---

### Implement Task (`/implement-task`)

The heavyweight implementation skill. Takes a single GitHub issue from picked-up through to PR-ready via a seven-persona orchestration. Designed for long-running runs (hours) on important tasks. The lighter `/issue-worker` is the right tool for small tasks; `/implement-task` is for tasks worth the audit gates.

What it does:

- **Spawns seven personas as focused sub-agents**, each with their own mandate and audit-trail comment on the GitHub issue:
  - **Principal Engineer** — branch setup, implementation, lint+build, PR + self-review, review-feedback handling
  - **QA Engineer** — validates the AC is testable, validates the tests prove the AC, builds the AC → Test map. Can use Playwright for AC oversight
  - **Cloud Architect** — identifies IaC / pipeline / DevOps changes, applies what they can, surfaces human-required ones
  - **UX/UI Designer** — establishes the design spec before implementation (Phase 3), verifies the rendered output after (Phase 5). Uses the project's design system if one exists; defines initial principles (typographic scale, palette, spacing, radius, shadows) if not. Uses Playwright + `axe-core` to verify states, responsive behaviour, and accessibility. For backend-only tasks the spec covers response shape, error messages, and observability semantics — UX still applies, just to a different surface
  - **Test Automation Engineer** — writes unit + integration + E2E tests at the right level of the test pyramid
  - **Project Manager** — diligence audit; bounces work back to any prior role if the audit finds gaps. Diligent — defaults to "prove it"
  - **Work Checker** — runs after **every** other persona. Asks *"please just check your work carefully on this"*. Empirically catches defects ~80% of the time (backed by Madaan et al.'s Self-Refine research)
- **13 phases** in sequence: branch setup → ticket validation → cloud arch → UX design spec → implementation → UX design review → tests → test validation → lint+build → PM diligence audit → PR + self-review → review feedback → summary
- **Every persona posts a `[Role Name]` comment** on the GitHub issue, creating a durable audit trail
- **Two Hats discipline** — refactors get their own commits, separate from feature commits
- **Conventional Commits** for commit messages; small atomic PRs per Google's eng practices; PR body includes a **Self-review** section showing what the PE caught themselves
- **Bounce-back limit:** if a role gets bounced 3 times by the WC or the PM, the skill escalates to the user — something deeper is wrong
- **Pauses naturally between Phase 10 and Phase 11** so the human reviewer can comment; re-invoke to address review feedback

Grounded in Fowler (continuous integration, refactoring, Two Hats, test pyramid), Robert C. Martin (SOLID), Google eng-practices (small CLs), Conventional Commits, Scrum.org Definition of Done, Refactoring UI (Wathan & Schoger), Nielsen's usability heuristics, and WCAG 2.2 AA.

Use it when quality matters more than speed. Say "implement task #X", "do issue #X properly", "fully implement issue #X", "take this through to PR", "comprehensive implementation".

---

### Check Work (`/check-work`)

A generic "please just check your work carefully on this" second-pass skill. The whole point is to save you typing that phrase out every time. Works on anything — code, plans, writing, analysis, designs, calculations, summaries.

What it does:

- Re-examines whatever was just produced with the *"would I ship this as-is?"* lens
- Reports findings specifically — what's wrong, where — so they're actionable, not vague
- Doesn't redo the work; doesn't pedant on stylistic taste; doesn't request features
- Stops after two passes — if issues remain on a second audit, the underlying work needs rethinking, not a third audit

Empirically a focused second-pass critique surfaces something worth changing about 80% of the time (Madaan et al., *Self-Refine*).

Say "check your work", "double-check this", "look this over", "did I miss anything", "review what you just did", "go over this again", "self-review".

---

### Rework (`/rework`)

Course-corrects both the requirements (`docs/requirements/`) *and* the open GitHub issues when something discovered during early implementation invalidates the original plan. The one in the SDLC bundle that hopefully doesn't get called often — but when you need it, you really need it.

What it does:

- **Asks for the rework rationale first.** One or two sentences. Won't proceed without it.
- **Walks every requirement** — classifies each as Keep / Update / Delete / Archive
- **Walks every open issue** — classifies each as Keep / Update / Close, plus checks recently closed issues for any to Reopen
- **Cascades through assumptions and open questions** — falsified assumption → every linked requirement re-inspected; resolved question → entry moves to Resolved with the answer
- **Gap analysis** — identifies new requirements / new tasks the new direction needs (kept narrow; if the gap is huge, suggests a fresh `/create-requirements` session instead)
- **Shows the proposed change set as a single markdown document** for explicit approval before any destructive action
- **Default behaviour is assertive cleanup.** Git preserves deleted files; closed GitHub issues are recoverable. `docs/archive/` exists only for artefacts with specific posterity value, and only with a documented rationale. No `wontfix` label sprawl on issues.
- Appends a structured **rework entry to `docs/requirements/session-log.md`** as the durable audit trail
- Watches for issues with linked PRs — surfaces before closing rather than dangling references

Use it sparingly. When you need it, run `/rework`. Say "rework this", "we need to change direction", "pivot", "course-correct", "this isn't going to work anymore", or "scrap that and...".

---

### Sentry Recent Issues (`/sentry-recent-issues`)

Pulls recent Sentry issues, figures out what's going on in the code, and tells you how to fix them.

What it does:

- Fetches issues from Sentry for a given org, project, and environment
- Classifies each one as recurring, regression, or new
- Summarizes affected users, frequency, and timing
- Traces stack traces back to actual code in your repo
- Suggests a root-cause fix and a regression test

Use it when production errors pile up or you get a Sentry alert you need to triage.

---

### Teams to Confluence (`/teams-to-confluence`)

Takes a Microsoft Teams chat and turns it into a proper Confluence page. Requires the "claude.ai Atlassian" and "claude.ai Microsoft 365" MCP servers.

What it does:

- Asks what chat, what to extract, and what date range
- Finds and confirms the right Teams chat before pulling anything
- Pulls messages and organizes them into a real page with decisions, action items, and technical details
- Shows you the proposed title, space, parent page, and content before creating anything
- Creates the page and confirms it published correctly

Ask it to save a Teams chat to Confluence or create a wiki page from a discussion.

---

### Write Like a Human (`/write-like-a-human`)

Makes your text sound like a person wrote it, not a language model.

What it does:

- Strips out the AI vocabulary that gives the game away (words like "delve," "tapestry," "underscore")
- Swaps em dashes and curly quotes for the plain punctuation people actually type
- Mixes up sentence length and structure so it doesn't read like a template
- Breaks the formulaic patterns AI falls into - the rule of three, the "not just X but Y" construction, the tidy intro-body-conclusion
- Cuts promotional language, fake hedging, and vague claims about significance
- Runs a voice checklist on everything before handing it over

Use it for blog posts, articles, essays, emails, creative writing, marketing copy - anything that should sound like you wrote it.
