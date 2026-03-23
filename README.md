# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that give it new tricks for common dev work.

## Getting started

Open Claude Code and run:

```
/plugin marketplace add awojtas/aidans-agent-skills
```

After that, open `/marketplace` again, navigate to "Aidan's Agent Skills", and pick which plugins you want to install.

Then close and re-open Claude Code - skills don't hot-reload, so you need a fresh session for them to show up.

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
- Runs a 17-point checklist on everything before handing it over

Use it for blog posts, articles, essays, emails, creative writing, marketing copy - anything that should sound like you wrote it.
