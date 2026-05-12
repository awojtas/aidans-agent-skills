# Test Strategy

The shape of tests the Test Automation Engineer writes, and the Quality Assurance Engineer validates. Drawn from Fowler's TestPyramid, Cohn's original pyramid, Kent C. Dodds' Testing Trophy, and Fowler's TestCoverage.

## The pyramid

Fowler's rule: *"You should have many more low-level UnitTests than high level BroadStackTests running through a GUI."* E2E tests are *"brittle, expensive to write, and time consuming to run"* and *"more prone to non-determinism."* The corollary: *"before fixing a bug exposed by a high level test, you should replicate the bug with a unit test."* Avoid the inverted "ice-cream cone." ([martinfowler.com/bliki/TestPyramid.html](https://martinfowler.com/bliki/TestPyramid.html).)

Default ratios for a typical web application:

| Level         | Share of tests | What it covers                                                | Speed       |
|---------------|----------------|----------------------------------------------------------------|-------------|
| **Static**    | (underneath)   | Lint, type-check, security scan                                | Instant     |
| **Unit**      | ~70%           | Pure functions, single classes, mocked collaborators           | Fast (ms)   |
| **Integration** | ~20%         | Multiple modules together; real DB / queue via testcontainers  | Medium (s)  |
| **E2E**       | ~10%           | Full stack through the UI / API surface                        | Slow (10+s) |

For component-driven frontends, Kent C. Dodds' [Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications) shifts weight toward integration tests because *"the more your tests resemble the way your software is used, the more confidence they can give you."* Apply the trophy on the frontend; apply the pyramid on the backend.

## Coverage — not a target

Fowler: *"If you make a certain level of coverage a target, people will try to attain it. The trouble is that high coverage numbers are too easy to reach with low quality testing."* The actual test of test quality is:

> *You rarely get bugs that escape into production, and you are rarely hesitant to change some code for fear it will cause production bugs.*

Expect coverage in the upper 80s or 90s as a **side-effect** of testing the right things, not a goal in itself. **100% line coverage is a red flag** — it usually means tests are pinned to implementation details, making the code brittle to refactor. ([martinfowler.com/bliki/TestCoverage.html](https://martinfowler.com/bliki/TestCoverage.html).)

The TAE's actual coverage standard:

- Every AC clause has at least one test asserting its outcome.
- Every error path the PE wrote has a test exercising it.
- Every external boundary (network, DB, queue) has a test stubbing or sandboxing it.
- The "happy path" runs end-to-end as one integration test or one E2E test.

If those four boxes are checked, coverage is the right shape — even at 60% line coverage.

## Determinism — non-negotiable

A flaky test is worse than no test. Rules:

- **Seeded factories.** `faker.seed(42)` at the top of every test file using faker. Same seed = same data, every run.
- **Fixed clocks.** `vi.setSystemTime(new Date('2026-05-13'))` / `freezegun` / `MockDate`. If the code under test uses `Date.now()`, it's a parameter the test mocks.
- **Mocked UUIDs.** When IDs appear in assertions, generate them deterministically (`new ObjectId('000000000000000000000001')`).
- **No real network in unit/integration.** Stub with `nock`, `msw`, `responses`, or in-memory queues.
- **No shared mutable state across tests.** Each test sets up its own state and tears down.

The QA enforces this in Phase 5 — any test with `Math.random()` or `Date.now()` driving outcomes is rejected.

## Test structure

Every test:

- **Reads as a sentence.** `it("rejects sign-in with an invalid email format")`, not `it("test signin 2")`.
- **Arrange / Act / Assert** layout, with visual separators (`// Arrange`, blank line, `// Act`, blank line, `// Assert`).
- **One concept per test.** Multiple assertions on the same concept are fine; multiple unrelated concepts is two tests.
- **No conditional logic.** `if (foo) expect(bar)` is a smell — tests don't branch.
- **No `sleep` / `setTimeout`.** Await the actual completion signal of async code.

## When NOT to write a test

- **Trivial getters/setters.** No.
- **Generated code** (ORM scaffolding, OpenAPI clients). Mock at the boundary.
- **Third-party library wrappers** that add no logic. Test the boundary, not the library.
- **Configuration loading** (unless there's parsing logic).
- **Pure type guards** in TypeScript / Python — the type system is the test.

## E2E discipline — keep them thin

E2E tests are valuable for **the critical user-visible path**. They're not valuable for **every branch of logic**.

Per task: 0-2 E2E tests, typically 0. If the task adds a user-visible feature, one E2E test on the happy path is appropriate. Anything more belongs at integration or unit level.

E2E test requirements:

- Run in CI on every PR (not just nightly — feedback must be fast).
- Use a dedicated test environment with deterministic data.
- Clean up after themselves (no test pollutes the database for the next test).
- Mark as `skip` if running in an environment that doesn't have the deps available (testcontainers, browser, etc.) — don't fail the whole CI for missing deps.

## What a green build means

The TAE's claim of "tests pass" must be verifiable. The PE in Phase 6 re-runs:

- Static analysis (lint, type-check, format-check).
- Unit tests.
- Integration tests.
- E2E tests (or at least the relevant ones — full E2E may run on CI only).
- Build (compile / bundle).

If any of these fails after the TAE claimed green, that's a defect the Work Checker catches.

## Sources

- Fowler, *Test Pyramid* — https://martinfowler.com/bliki/TestPyramid.html
- Fowler, *Test Coverage* — https://martinfowler.com/bliki/TestCoverage.html
- Cohn, *Succeeding with Agile* (origin of the pyramid; no canonical URL)
- Dodds, *The Testing Trophy and Testing Classifications* — https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications
