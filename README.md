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

### Repo Requirements (`/repo-requirements`)

Interactively elicits software requirements (both functional and non-functional) from you and writes them up as a structured set of short markdown files in `docs/requirements/`.

What it does:

- Reads your `README.md` and any existing context, then runs a stakeholder + goals + scope discovery interview
- Captures **goals AND non-goals** explicitly — the non-goals section is treated as more important than the goals one (most project blow-outs come from under-documented "won't do" items)
- Walks each functional domain (auth, billing, admin, ...) one at a time with question banks adapted from BABOK
- Walks every ISO 25010 quality attribute (performance, security, reliability, usability, maintainability, compatibility, portability) plus modern additions (observability, privacy/compliance, accessibility, i18n, cost) — won't let you skip a category
- Captures every assumption in `07-assumptions.md` and every deferred decision in `08-open-questions.md`, so nothing implicit survives
- Force-ranks Musts in a MoSCoW pass to surface the real MVP
- Runs an INCOSE quality-checklist sweep at the end (necessary / unambiguous / singular / verifiable / traceable, etc.)
- Designed as a multi-session skill — re-invoke to pick up where the last session stopped

Grounded in [Volere](https://www.volere.org/), [ISO/IEC/IEEE 29148:2018](https://www.iso.org/standard/72089.html), [ISO/IEC 25010](https://en.wikipedia.org/wiki/ISO/IEC_25010), the INCOSE Guide for Writing Requirements, [BABOK](https://www.iiba.org/standards-and-resources/babok/), and [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119). The output feeds a downstream architecture-design phase.

Highly interactive — set aside 30–90 minutes for a first useful pass. Pause and resume any time. Say "elicit requirements", "document requirements", "what should this project do", or "scope this out".

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
