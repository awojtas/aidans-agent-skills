# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that extend its capabilities for common development tasks.

## Using with Claude Code

1. Open Claude Code
2. Run:
   ```
   /plugin marketplace add awojtas/aidans-agent-skills
   ```

## Skills

### Build Fixer (`/build-fixer`)

Iteratively fixes build errors and lint warnings until your project compiles cleanly.

**Supported ecosystems:** .NET, Node.js (npm/pnpm/yarn/bun), Rust, Go, Java (gradle/maven), Make, and more.

**What it does:**

- Auto-detects your build command from project files
- Runs the build, classifies errors as fixable vs. environment-level
- Fixes code errors in a loop (type errors, syntax issues, unused variables, etc.)
- Stops when the build passes or no more progress can be made
- Reports results with troubleshooting suggestions for any remaining issues

**Trigger it** by asking Claude to fix build errors, resolve compilation failures, or clean up lint warnings — or just paste your build output.

---

### Design System Aurora (`/design-system-aurora`)

Glass Aurora design system — ethereal glassmorphism, aurora gradients, neon glows, and a purple-cyan color scheme.

**What it does:**

- Provides comprehensive design tokens (colors, typography, spacing, shadows)
- Guides glassmorphic component styling with backdrop blur, translucent borders, and neon glow
- Includes aurora gradient animation patterns and gradient text for emphasis
- Covers responsive design, dark mode, accessibility, and animation best practices
- Ships with reference docs for design tokens, glassmorphism patterns, and component examples

**Trigger it** when creating or modifying UI components to ensure consistency with the Glass Aurora aesthetic.

---

### E2E Test Runner & Fixer (`/e2e-test-runner-fixer`)

Diagnoses and fixes end-to-end test failures with deterministic setup, isolation, and iterative reruns.

**Supported frameworks:** Playwright, Cypress, WebDriver.

**What it does:**

- Discovers runner config, test specs, helpers, and seed scripts
- Reproduces failures in isolation before attempting fixes
- Classifies failures (real bug, flaky, environment-dependent, platform-specific)
- Triages root causes: data/setup mismatch, race conditions, locator drift, auth leakage, environment instability
- Applies smallest safe fix, then re-runs to verify stability

**Trigger it** when E2E tests fail, specs are flaky, or CI test jobs break.

---

### Issue Closer (`/issue-closer`)

Reviews open GitHub issues and closes any where the work has been fully completed and checked in.

**What it does:**

- Lists all open issues in the current repo
- Gathers evidence of completion (merged PRs, commits, codebase search)
- Closes confirmed-done issues with an explanatory comment
- Reports a summary of issues closed and issues left open

**Trigger it** when you want to clean up done issues, close stale tickets, or tidy the backlog.

---

### Issue Prioritiser (`/issue-prioritiser`)

Reviews open GitHub issues, applies priority labels, checks relevance, and recommends the next issues to work on.

**What it does:**

- Fetches all open issues matching a filter (milestone, label, or all)
- Assesses relevance (still needed?), clarity (well-defined?), and priority (impact, frequency, effort)
- Applies priority labels: highest, high, medium, low, nice to have
- Flags potentially done or stale issues
- Ranks and recommends the top issues to work on next

**Trigger it** when you want to triage the backlog, rank issues, or decide what to work on next.

---

### Issue Worker (`/issue-worker`)

Implements a GitHub issue end-to-end — reads the issue, explores the project, writes code, adds tests, and verifies everything passes.

**What it does:**

- Reads the issue and identifies acceptance criteria and scope
- Explores the codebase to understand conventions, build system, and tech stack
- Creates a working branch and implements the minimum changes needed
- Adds unit and integration/E2E tests using existing test patterns
- Runs lint, type-check, build, and tests — fixes anything that fails
- Self-checks against acceptance criteria before reporting

**Trigger it** by saying "work on issue #123", "implement this ticket", or providing a GitHub issue link.

---

### Sentry Recent Issues (`/sentry-recent-issues`)

Investigates recent or specific Sentry issues, determines frequency and recurrence, researches root cause in the codebase, and recommends fixes.

**What it does:**

- Fetches recent issues from Sentry for a given org, project, and environment
- Classifies each issue as recurring, regression, or new
- Summarises affected users/transactions, frequency, and timestamps
- Searches the codebase for code referenced in stack traces
- Recommends a root-cause fix and an appropriate regression test

**Trigger it** when you want to triage production errors, investigate Sentry alerts, or review recent exceptions.
