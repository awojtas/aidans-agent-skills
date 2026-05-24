# SDLC Pitfalls — what to defend against during implementation

A reference list the Work Checker, Project Manager (process), and Product Manager (outcome) use to spot under-delivery. Drawn from Fowler, Knuth, Pike, McConnell, Kernighan, the refactoring catalogue, and recent research on LLM coding failure modes.

## 15 pitfalls — by name

1. **Premature optimisation.** Knuth/Hoare via Pike: optimise after measurement only. ([Notes on Programming in C](https://users.ece.utexas.edu/~adnan/pike.html).)
2. **Golden hammer.** Reaching for the familiar tool regardless of fit (McConnell, *Code Complete*).
3. **Primitive obsession.** Strings for money/phone/email; fix with [Replace Primitive with Object](https://refactoring.guru/smells/primitive-obsession).
4. **Shotgun surgery.** One logical change scattered across many classes ([catalogue](https://refactoring.guru/smells/shotgun-surgery)).
5. **Feature envy.** A method uses another class's data more than its own ([catalogue](https://refactoring.guru/smells/feature-envy)).
6. **Comment instead of refactor.** Explanatory comments papering over bad names — rename instead.
7. **"We'll add tests later".** Violates self-testing code. The TDD red-green-refactor loop ([Fowler/TDD](https://martinfowler.com/bliki/TestDrivenDevelopment.html)) is the antidote.
8. **Test-after-the-fact.** Tests written against the implementation rather than the spec — they pass even when the spec is unmet.
9. **Refactor-while-feature-coding.** Violates Beck/Fowler's **Two Hats** rule — you wear the refactor hat or the feature hat, never both at once. Mix and the diff is unreviewable.
10. **Leaky abstraction.** Adapter exposes underlying DB error types upward; consumer code now depends on the adapter's internals.
11. **Mixing concerns in one commit.** Review blindness — reviewer can't separate the two changes; a bug in either is hard to bisect.
12. **Swallowing exceptions.** `catch {}` or `catch (e) { log(e) }` with no recovery — silent failures that propagate corrupted state.
13. **Dead code / commented-out blocks.** Git is the history. Delete it.
14. **Speculative generality.** Abstractions for needs that may never arrive — adds present cost for hypothetical future benefit.
15. **Big-bang merge.** Long-lived branch produces days of conflict resolution. CI fixes this; see `solid-applied.md`'s notes on small atomic changes.

Kernighan: *"The most important single aspect of software development is to be clear about what you are trying to build."* (Kernighan & Pike, *The Practice of Programming*.)

## Lazy-AI-coder failure modes

LLM-specific patterns the Work Checker, Project Manager (process), and Product Manager (outcome) watch for:

- **Truthy assertions.** Tests that call the function and assert truthy/non-null without behavioural coverage.
- **Skipped edge cases.** Empty, null, boundary, unicode, timezone, concurrency.
- **TODO/FIXME in place of implementation.** "We'll handle this later" in a comment instead of handling it.
- **Swallowed exceptions.** `try { ... } catch { /* ignore */ }`.
- **Debug remnants.** `console.log` / `print` / `debugger` left in.
- **Placeholder returns.** `return null`, `return []`, `return "ok"` that satisfy types but not semantics.
- **"Done" with a broken build.** Claim of completion while lint/build/tests fail locally.
- **Renamed-but-unused parameters.** Dead arguments added "for safety."
- **Mocking the system under test.** Mocking the thing being tested instead of its collaborators — the test verifies the mocks.
- **Tests pinned to the wrong implementation.** Asserting the current (incorrect) behaviour rather than the spec.
- **Dependencies added without lockfile update or licence check.** New imports that don't appear in `package.json` / `requirements.txt` lockfiles.
- **Migrations without rollback.** Schema change with no `down` migration.
- **AC bullets ticked without corresponding tests.** Definition of Done's "tests added" box checked when the tests don't actually map to the AC.
- **Limit-citing shortcuts.** "Hit the daily usage limit, marking remaining phases done", "running low on context, skipping the Work Checker", "compressing Phase 7 and Phase 8 to save tokens", "calling it done so the user can finish later." Capacity pressure is never an excuse to skip work, collapse phases, downgrade a persona brief, or claim completion without doing the work. The only legitimate response is to **pause and report** — post an `[Orchestrator]` comment naming the in-flight phase and what's outstanding, then stop. The session is resumable from the issue's comment trail; declaring done to avoid pausing is a defect, not a pragmatism.
- **Lying about completion.** A persona posting `[Role] Done` without having actually run its checks — e.g. Sec posting "no issues found" without walking the threat-surface checklist, TAE posting "tests added" without writing them, PE posting "lint+build green" without running them. Work Checker treats any "done" claim that doesn't name the categories/commands walked as a bounce.

## The Two Hats rule (Beck via Fowler)

From [Preparatory Refactoring Example](https://martinfowler.com/articles/preparatory-refactoring-example.html), citing Kent Beck:

> *You can operate in one of two modes: refactoring and adding function. You may swap frequently between hats, perhaps every couple of minutes, but you can only wear one hat at a time.*

The practical rule for the Principal Engineer: a single commit either changes behaviour OR refactors. If a feature needs a refactor to land cleanly, the refactor goes in its own commit first. The reviewer can verify "no behaviour change" on the refactor commit and "behaviour change is the intended one" on the feature commit.

Beck's *"make the change easy, then make the easy change"* is the rule of thumb: figure out what refactor would make the new code drop in cleanly, do that refactor first as its own commit, then add the new code.

## What "done" actually means (Definition of Done)

From [Scrum.org's DoD guidance](https://www.scrum.org/resources/what-definition-done):

> *The Definition of Done is a formal description of the state of the Increment when it meets the quality measures required for the product… If a Product Backlog item does not meet the Definition of Done, it cannot be released or even presented at the Sprint Review.*

Task-level DoD for this skill:

- AC met (every clause has a test that asserts it).
- Unit + integration tests added and green.
- Lint clean (no warnings the project flags as warnings).
- Build clean.
- PR small and self-reviewed (Self-review section in the PR body).
- No secrets / debug / TODO added in this diff.
- Docs updated if user-visible behaviour changed.
- Human-required infra steps (from CA) surfaced in the PR or issue.
- Feature flag wired (if applicable).
- Observability added (logs / metrics / traces) for new code paths.

The Project Manager checks this list literally for execution; the Product Manager re-checks the user-facing items (docs, observability, feature flag, AC met) from an outcome lens. If any item is unchecked, the task isn't done.

## Sources

- Fowler, *Continuous Integration* — https://martinfowler.com/articles/continuousIntegration.html
- Fowler, *Feature Branch* — https://martinfowler.com/bliki/FeatureBranch.html
- Fowler, *Branching Patterns* — https://martinfowler.com/articles/branching-patterns.html
- Fowler, *Feature Toggles* — https://martinfowler.com/articles/feature-toggles.html
- Fowler, *Test Driven Development* — https://martinfowler.com/bliki/TestDrivenDevelopment.html
- Fowler, *Definition Of Refactoring* — https://martinfowler.com/bliki/DefinitionOfRefactoring.html
- Fowler, *Preparatory Refactoring Example* — https://martinfowler.com/articles/preparatory-refactoring-example.html
- Fowler, *Code Smell* — https://martinfowler.com/bliki/CodeSmell.html
- Refactoring Catalogue — https://refactoring.guru/refactoring/smells
- Pike, *Notes on Programming in C* — https://users.ece.utexas.edu/~adnan/pike.html
- Scrum.org, *What is a Definition of Done?* — https://www.scrum.org/resources/what-definition-done
- McConnell, *Code Complete, 2nd Ed.* (no canonical online URL)
- Kernighan & Pike, *The Practice of Programming* (no canonical online URL)
