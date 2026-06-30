# AI-slop catalogue — the named signs to hunt

The telltale patterns AI coding agents leave behind: code that passes tests and linters but signals low quality and high cost-to-change. Each entry below has **what it looks like**, a **detection hint**, and **the legitimate inverse** — the case where the same shape is correct and must be *defended*, not deleted.

Tags: **[aislop]** = the deterministic pre-scan already catches this; don't re-hunt it, just fold its findings in. **[judgment]** = needs a human/agent call; this is where your effort goes.

> The deepest tell is usually in the comments — AI slop shows up there more than anywhere else.

## Comment tells (highest-signal cluster)

- **Restates the name / adds no context** — `# the user id` above `userId`. **[aislop]**
- **Overly verbose** — paragraphs where a line would do; narration of self-evident code. **[aislop partial]**
- **Before/after state narration** — `# this used to do foo, but now does bar`. The comment describes a *change*, not the code. **[judgment]**
- **Self-plan / process references** — `# part of Stage 3 of Use Case X from the requirements doc`; references to TODOs, tasks, prior versions, or the agent's own implementation plan. **[judgment]**
- **Prompt-fact leakage** — a meta instruction from the task entering a comment or identifier (told "ignore negative numbers" → `# ignore negatives because the user asked`). **[judgment]**
- **Inverse to defend (the affirmative standard):** comments should explain **why** — non-obvious rationale, with a source reference (ticket/RFC/link) for a genuinely surprising decision. Those are good; don't strip them.

## DRY & patterns

- **Duplicated helpers / DRY violations** — multiple definitions of the same utility or logic. **[aislop partial + judgment]**
- **Deviation from existing nearby patterns** — *polarity depends on repo posture.* **Brownfield/established:** new code ignoring the settled idiom in adjacent code is the finding. **Greenfield/young:** the existing pattern is *not* authoritative — if it's slop, conformance to it is the finding and fixing it up is right. **[judgment]**

## Naming

- **Enterprise-ese** — `FactoryFactoryAbstraction`, manager-of-managers, ceremony with no payload.
- **Excessively long or overly-technical names** where a plain word works.
- **Banned words** — e.g. "seam", "durable", and similar no-payload jargon.
- **No-value qualifiers** — `SaveGame()` where `Save()` says it; redundant prefixes/suffixes. **[judgment]**

## Tests

- **Asserts implementation, not behaviour** — tests coupled to internals that break on any refactor and prove nothing about correctness.
- **Misleading "coverage"** — e2e that mocks the API and asserts only client-side validation; happy-path-only suites with no negative/authz/cross-tenant cases. **[judgment]**
- **Inverse:** a focused test that pins a genuinely important invariant is good even if it touches an internal — defend it.

## Backwards-compatibility (gated on production posture)

- **Overly backwards-compatible** — compat shims, deprecation guards, dual code paths for a contract that was **never deployed**. *Pre-production:* flag as negative-ETC slop (guarding a ghost). *Production:* legitimate only where a real consumer/contract exists. **[judgment]**
- **Inverse:** a genuinely versioned, externally-consumed contract (published library/JAR, public REST) deserves compatibility care — defend it.

## Public API contracts

- **Changing a public contract without express permission** — only material where there's a *real* contract (library JAR, versioned REST surface). Ties to production posture. **[judgment]**

## Guard code & error handling

- **Unnecessary guard code** — re-guarding what the library already handles (classic: hand-rolled guards instead of relying on the serializer's own error handling). **[aislop partial + judgment]**
- **Defensive fallback where an invariant belongs** — a `?? defaultValue` or `if (!x) return` standing in for a state that should be impossible. Push it to the lowest enforcement layer instead.
- **Handling of now-impossible cases** — error handling for states the type system or a prior check already rules out.
- **null / try-catch papering over unclear ownership** — swallowing instead of deciding who owns the value.
- **Fear of throwing where throwing is correct** — AI is "mortally terrified of exceptions"; in core infra and persisted-data paths, a loud throw beats a silent recovery. **[judgment]**
- **Inverse to defend:** best-effort I/O, `try { setPointerCapture() } catch {}`, external-call boundaries — deliberate, ideally documented. Don't delete these.

## Explicitness (apply firmly — core anti-defensive philosophy, not taste)

- **Null-coalescing / `??` / `||` / default fallbacks** that paper over a missing value — values should be explicitly set; a missing one should fail loudly.
- **Default parameter values in method signatures** — a 3-arg method should require 3 args; defaults hide caller mistakes and cause unexpected behaviour.
- **Swallowed / obfuscated errors** — errors must propagate so problems are discoverable. **[aislop partial + judgment]**
- **Inverse:** a genuine boundary (best-effort I/O, optional config with a *documented* default) may legitimately fall back — as a deliberate choice, never a reflexive `??`.

## Magic values & structure

- **Magic numbers / strings** — extract to named constants; if a value reads like configuration, move it to a config file. **[aislop partial + judgment]**
- **Type/structure conventions (gated on maturity)** — prefer `type` aliases for simple data structures; interfaces + class OOP for complex components. *Brownfield:* defer to the settled idiom, flag only deviation from it. *Greenfield/young:* apply the standard firmly — a fresh slop repo's "idiom" is not authoritative. **[judgment]**

## Abstraction

- **Premature / bad abstraction** — an interface with one implementer that will never get a second; indirection that adds machinery without enabling a real swap (negative ETC). Three similar lines beat a wrong abstraction.
- **Inverse:** an abstraction at a real swap-point (a second provider is plausible, a boundary is genuinely crossed) earns its keep — defend it.
