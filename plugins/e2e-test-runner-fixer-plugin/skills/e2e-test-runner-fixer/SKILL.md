---
name: e2e-test-runner-fixer
description: Diagnoses and fixes end-to-end test failures with deterministic setup, isolation, and iterative reruns. Use when users mention E2E failures, flaky specs, Playwright/Cypress/Webdriver tests, test data seeding, headed mode, or failing CI test jobs.
---

# E2E Tests

You are a specialist for running, debugging, and fixing Playwright E2E tests.
Use this skill for diagnosis and repair, not for authoring brand-new test suites.


## Core Rules

1. Deterministic over convenient: fix root causes, not flakes via retries.
2. Fix flaky tests immediately when first seen — flakiness is technical debt that compounds quickly. If a fix isn't possible right away, create a tracked ticket and quarantine the test.
3. Never dismiss a flake without investigation — a "flaky" test can be a canary for a real intermittent production bug. Prove it's a test problem before labeling it as one.
4. Seed data and verify state via APIs/test-data generators/seed data scripts, not the UI — minimize UI surface area. Use the browser only for what must be validated visually.
5. Isolate each spec and reseed when tests mutate shared state.
6. Keep tests short and focused — fewer steps per test means fewer chances for flakiness. Prefer multiple small tests over one long multi-step journey.
7. Prefer stable user-facing locators over brittle CSS selectors.
8. Keep fixes minimal and reversible.

## Workflow

Copy this checklist and keep it updated while working:

```text
E2E Fix Progress
- [ ] Step 1: Discover runner commands and config
- [ ] Step 2: Reproduce failing test in isolation
- [ ] Step 3: Identify root cause (data, timing, auth, locator, environment)
- [ ] Step 4: Apply smallest safe fix
- [ ] Step 5: Re-run failing test
- [ ] Step 6: Re-run related tests
- [ ] Step 7: Verify stability with repeated runs
```

### Step 1: Discover commands and layout

Find:
- Runner config (`playwright.config.*`, `cypress.config.*`, `wdio.conf.*`, etc.)
- Test specs
- Test helpers/fixtures
- Seed scripts and test-data sources

Use existing project scripts first. Avoid inventing new command names.

### Step 2: Reproduce in isolation

Run in this order:
1. List tests (if supported)
2. Run one failing spec
3. Run one failing test by title/pattern
4. Run headed/debug mode only if needed

Run full suite only after isolated failures are fixed.

## Setup Patterns

Map these concepts to project-specific helper names:
- **Empty-state setup**: clear storage and sign in; use when test creates its own data.
- **Seeded-state setup**: preload data + sign in; use when test needs existing records.
- **No-auth setup**: clear storage only; use for sign-in/public/auth-redirect tests.
- **Re-auth setup**: refresh authentication with minimal setup overhead.
- **Cleanup workflow**: reset or delete test-created data in `afterEach`/`afterAll`
  to prevent state leakage to subsequent tests.
- **Failed-state recovery**: setup code should detect and reset corrupted state
  from a previous failed run (where `afterEach` may not have fired). Before
  creating data, check if stale data exists and clean it. This ensures a re-run
  after a mid-test crash doesn't immediately fail again.
- **Disposable accounts**: prefer creating one-time-use test identities over
  reusing shared accounts that accumulate state.

## Classify the Failure

Before diving into root cause analysis, determine the failure type:

| Signal | Classification | Action |
|--------|---------------|--------|
| Fails consistently on every run | **Real bug** | Debug the application or test code |
| Passes on retry with no changes | **Flaky** | Investigate environment, timing, or data |
| Fails only in CI, passes locally | **Environment-dependent** | Compare CI vs. local config, network, resources |
| Fails only on specific browser/OS | **Platform-specific** | Check browser/OS-specific behavior or polyfills |

## Failure Triage Order

1. Error output + artifacts (`test-results/`, traces, screenshots, videos)
2. Data/setup mismatch
3. Non-determinism (race conditions, fixed sleeps, missing wait conditions,
   date/time dependencies, random values, volatile external service responses)
4. Locator drift after UI changes
5. Auth/session leakage (local storage, session storage, IndexedDB/cookies)
6. Environment instability (rate limits, slow backend, unavailable dependencies)

## Detect Flakiness Patterns

When investigating failures, look for:
- **Retry history**: tests that required retries to pass in recent CI runs.
- **Platform correlation**: failures only on specific browsers, OS, or CI agents.
- **Time-of-day correlation**: failures during peak load or scheduled jobs.
- **Run-order dependence**: tests that fail when run after a specific other test
  but pass in isolation.

Use `--last-failed`, CI dashboards, or test report history to surface these signals.

## Environment Stabilization

- **Mock or stub unreliable external services** (APIs, third-party integrations)
  rather than hitting live endpoints in E2E tests.
- **Run smoke tests before the full suite** to verify environment readiness
  (backend healthy, database seeded, services reachable).
- **Standardize the test environment** using containers or VMs to reduce
  inconsistency between local and CI runs.
- **Use a dedicated test environment** — never share a deployment target with
  other teams or manual testers. Unexpected deploys, API changes, or data
  mutations by others are a top source of false failures.
- **Monitor for network/server instability** — add health-check assertions
  at the start of test setup to fail fast with a clear message.
- **Increase logging verbosity** when investigating flakes — set framework or
  app-level debug flags (e.g., `DEBUG=*`, `--verbose`, `--trace on`) to capture
  state at the moment of failure. Persist logs as CI artifacts alongside
  screenshots and traces.

### Structured Multi-Level Logging

When adding logging for diagnosis, use tiered output:
- **Level 1 (basic)**: test name, start/end timestamps, pass/fail status.
- **Level 2 (detailed)**: all data created, API calls made, requests/responses,
  key step transitions.
- **Level 3 (verbose)**: full error stacks, DOM snapshots, network traces,
  environment variables.

Separate levels into distinct log files or CI artifact streams so basic runs
stay readable while detailed data is available when needed.

## Validate Assumptions

Tests that assume preconditions (data loaded, service available, specific time)
fail when those assumptions break silently:
- **Check preconditions explicitly** at the start of setup — assert that
  required data exists, APIs respond, and the environment is correct.
- **Never assume execution order** provides the right state — always seed or
  verify independently.

## Feedback Loop

Use this loop until green:
1. Reproduce
2. Fix one root cause
3. Re-run the same test
4. If still failing, reclassify cause and repeat
5. When passing, run related specs to check regressions

If 5+ iterations do not converge, stop and report blockers with next actions.

### Step 7: Verify stability

Run the fixed test multiple times (e.g., `--repeat-each=5` or equivalent)
to confirm it passes consistently, not just once. Only then mark it resolved.

## Quarantine Flaky Tests

When a test is confirmed flaky (intermittent pass/fail with no code change):
1. Tag or skip the test so it no longer blocks CI/CD pipelines.
2. Move it to a dedicated quarantine suite or marker (e.g., `@flaky`, `test.skip`).
3. Fix the root cause in isolation.
4. Verify stability by running the test repeatedly (e.g., `--repeat-each=5`).
5. Only re-integrate into the main suite once it passes consistently.

This prevents flaky tests from eroding trust in automation reports or delaying releases.

## Common Fix Strategies

- Replace fixed timeouts with condition-based waits.
- Normalize setup in `beforeEach` and keep seed/reset logic explicit.
- Remove cross-test coupling by unique deterministic identifiers.
- Update locators to resilient semantic selectors.
- Centralize locators in page-object models or fixture helpers so a UI change
  requires updating one file, not every test that touches that element.
- Reduce hidden shared state (storage, cache, leaked auth sessions).

### Async Handling: Polling vs. Callbacks

When replacing fixed sleeps, choose the right async strategy:
- **Polling (condition-based waits)**: repeatedly check whether an element or
  condition is satisfied at short intervals. Preferred in most E2E frameworks
  (e.g., `waitForSelector`, `toBeVisible()`, Playwright auto-waiting).
- **Event / callback-driven**: chain test assertions onto completion signals
  (e.g., `waitForResponse`, `waitForEvent`, network idle). Preferred when the
  app emits reliable events and polling would be wasteful or too slow.

Never fall back to bare `sleep` / `setTimeout` — always tie waits to a real
condition or event.

### Non-Deterministic Inputs

Code that depends on unpredictable values produces flaky tests. Control them:
- **Dates / times**: mock or freeze the clock (e.g., `page.clock`, `sinon.useFakeTimers`)
  so tests don't depend on wall-clock time.
- **Random values**: seed random generators or inject deterministic values in
  test fixtures.
- **External service responses**: stub or mock volatile APIs; never depend on
  live third-party data in E2E tests.

### Concurrency and Shared Resources

Parallel test execution can cause deadlocks or race conditions when tests share
mutable resources (database rows, files, global state):
- **Isolate resources per worker**: give each parallel worker its own test data
  or namespace (e.g., unique user per worker, prefixed DB records).
- **Avoid cross-test locks**: if tests lock shared resources, a second parallel
  test needing the same lock can deadlock. Replace shared resources with mocks
  or per-test copies.
- **Reproduce locally**: lower parallelism (`--workers=1`) to rule out
  concurrency, then increase to confirm the fix under parallel load.

### Order Dependency

Tests that depend on execution order are fragile:
- **Make every test self-contained**: each test sets up its own preconditions
  in `beforeEach` and cleans up in `afterEach`.
- **Randomize test order** periodically (e.g., `--shard`, shuffled configs) to
  surface hidden coupling early.
- **Watch for shared mutable state**: global variables, files on disk, database
  rows, and browser storage can all leak between tests.

## Runner Config Details

Inspect runner config and verify:
- **Workers / parallelism**: lower when debugging flaky behavior.
- **Retries**: keep low; retries are diagnostic, not the fix.
- **Timeouts**: align with real app behavior.
- **Base URL / environment**: correct target and port.
- **Project matrix**: browsers/devices are intentional.
- **Artifacts**: traces/screenshots/videos available for debugging.

Avoid masking instability with broad timeouts or high retries.

## Test Identities

Use canonical test identities from fixtures/helpers/seed data.

When missing:
- Add identities to the project’s canonical test-data source.
- Keep names unique and deterministic.
- Ensure reset/reseed prevents collisions.
- Document where identities live and how tests reference them.

## Reporting Blockers

When reporting unresolved flaky tests, include:
- Number of CI runs affected and retry frequency.
- Whether the flaky test is blocking a release or PR merge.
- Recommended quarantine action if a fix isn't immediate.
- Estimated effort and risk of the proposed fix.
- **Domain owner**: route the fix to the developer or SDET with the most
  expertise in the failing test's domain — they have the context to fix it
  fastest.

## Prevention: Stress-Test New Tests Before Merging

Don't wait for flakiness to appear in the main suite:
- Run new or modified tests repeatedly before merging (e.g., `--repeat-each=10`
  or run in parallel against themselves in CI).
- If a test can't pass 100% of repeated runs, it's not ready to merge.
- This catches timing issues, data races, and hidden dependencies before they
  infect the main suite.

