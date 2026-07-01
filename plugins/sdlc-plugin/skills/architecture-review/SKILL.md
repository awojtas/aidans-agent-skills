---
name: architecture-review
description: 'Thorough, opinionated architecture review of a codebase, organized around ETC (Easy to Change) and "make bad states unrepresentable" rather than a SOLID checklist. Fans out layer/dimension sub-agents plus deterministic probes, confirms load-bearing findings with commands, pushes each fix to the lowest enforcement layer, hunts AI-slop while defending legitimately-defensive code, and ends with a ruthless dependency-ordered action list. Read-only by default; offers issues or a report after. Use when the user says "architecture review", "review the architecture", "is this well designed", "is this maintainable or scalable", "SOLID review", "architecture audit", or "is this over-engineered". Not GitHub issues (issue-architect-review) or creating a design (platform-design).'
---

# Architecture review

Review the **software architecture of a codebase** — opinionated, verified, anti-slop. The output should read as *architecture*, not as a lint report.

The single organizing principle is **ETC — Easy to Change** (Hunt & Thomas, *The Pragmatic Programmer*): every other clean-code principle is a corollary. The operational tool is one question, asked of every layer:

> **"How would I swap this part out for something else — and once I've replaced it, how would I know it still works?"**

SOLID, DRY and the rest are presented as *consequences* of that question, never as the headline. A review organized as "here's where each SOLID letter is violated" reads as a lint report; a review organized around **invariants, swap-points, and how bad states are made impossible** reads as architecture.

This skill is **read-only by default**: it prints a review and a ruthless action list, then *offers* to create issues or a report. The one exception is the repo-posture marker in Step 2 (durable shared context, not a finding).

Distinct from siblings: `issue-architect-review` reviews GitHub *issues*; `platform-design` *creates* architecture docs; `ai-ready-repo` audits *AI-readiness*; `ui-component-review` audits *component reuse*. This reviews the **code**.

## Core stance

- **ETC is the root; make bad states unrepresentable is the method.** Push every fix to the lowest layer where the bad state becomes *impossible*: DB constraint > type system (discriminated unions, partial unique indexes) > service boundary > "remembered" runtime check.
- **Explicit over implicit; errors must propagate.** Silent defaults/fallbacks hide bad states; loud failures expose them.
- **Opinionated and specific over comprehensive and hedged.** Every finding gets severity + `file:line` + the lowest-layer fix. Recommend, don't survey.
- **Hunt AI-slop — but defend legitimately-defensive code.** See `references/ai-slop-catalogue.md`. Don't tell the user to delete every guard.
- **Reward subtraction.** "Delete this", "don't add this abstraction", and "document this as a deliberate exception" are first-class outcomes. A review that only adds machinery has failed.
- **Verify before you assert.** Sub-agents hedge and occasionally state false things. Load-bearing findings are confirmed with a command before they ship.

## Workflow

Copy and track:

```text
Architecture Review Progress
- [ ] Step 1: Scope and read the lay of the land
- [ ] Step 2: Repo-posture gate (production? brownfield/greenfield?) — persist to AGENTS.md
- [ ] Step 3: Deterministic pre-scan (aislop + mechanical probes)
- [ ] Step 4: Fan out sub-agents (layer readers + dimension specialists)
- [ ] Step 5: Synthesis & verification gate
- [ ] Step 6: Output — review + ruthless dependency-ordered action list
- [ ] Step 7: Offer artifacts (issues / report) — only on user say-so
```

### Step 1: Scope and read the lay of the land

Resolve the repo root. Read `docs/architecture/`, `docs/design/`, `README`, and `AGENTS.md` if present — as **context, not gospel**; flag any doc-vs-code drift you notice. Detect the stack and layout.

Let the user narrow scope to a subsystem; otherwise review the whole repo.

### Step 2: Repo-posture gate

Two facts decide the polarity of two whole lenses (backwards-compatibility *and* pattern-deviation). They must be known **before** the sub-agents run.

Check `AGENTS.md` for an existing posture marker. **If present, read it and skip the questions.** If absent, ask the user two questions:

1. *"Is this a production app with real users and real data, or not?"*
2. *"Is this an established/brownfield codebase with its own settled standards, or a greenfield/young codebase (possibly just written by an AI agent)?"*

Persist both, succinctly, into `AGENTS.md` as one HTML-comment-delimited marker (so future runs and other agents inherit it):

```markdown
<!-- repo-posture:start -->
**Repo posture:** Greenfield — young codebase, no settled house standards (may be AI-generated); deviate from and fix up existing patterns freely. Pre-production — no real users or data; no backwards-compat obligations, no deployed contract to break.
<!-- repo-posture:end -->
```

Write the Brownfield / Production variants analogously. If `AGENTS.md` doesn't exist (common on a greenfield repo — exactly the case here), create it and add the marker. This is the only repo write made outside Step 7, because it is durable shared context.

**How posture drives the review:**

- **Production posture → the backwards-compat lens.** *Pre-production:* backwards-compat machinery, deprecation shims, and contract-guarding for never-deployed code are themselves **slop to flag** (negative ETC — guarding a ghost). *Production:* contract changes to a library/JAR or versioned REST surface are real risks; flag any public-contract change made without express permission. The lens is "is there a *real* consumer/contract here?", not reflexive compatibility.
- **Codebase maturity → the pattern-deviation lens.** *Greenfield/young:* existing patterns are **not authoritative**; if the idiom is itself slop (likely, if a cheap agent wrote it yesterday), **fix it up to the standards** — apply the type/structure, magic-number, and naming standards firmly. *Brownfield/established:* match the settled house idiom; *deviation from an established good pattern* is the finding, and universal style rules yield to a deliberate house style (flag + document, don't impose).

### Step 3: Deterministic pre-scan (aislop + mechanical probes)

Some dimensions are answered faster and more reliably by a command than by reading. Run these **early, every time**, so the tooling-shaped dimensions are never skipped just because they don't surface from reading business logic — and so the deep-read agents spend their budget on judgment, not counting.

**aislop (optional, graceful):** if `npx`/node is available and the language is supported (TS/JS, Python, Go, Rust, Ruby, PHP, React Native):

```bash
npx aislop@latest scan --json
```

It's deterministic (no LLM, sub-second) and catches the *mechanical* slop — trivial/narrative comments, swallowed exceptions, hidden fallbacks, `as any`, hallucinated imports, duplicated helpers, dead code, TODO stubs. Feed its findings into synthesis as **pre-verified** (no command re-verification needed). If `npx` is unavailable or the language unsupported, skip and **note it in the output** (no silent gap). Never just parrot aislop — it owns the mechanical layer so the sub-agents can do judgment.

**Targeted probes (always, regardless of aislop):**

```bash
grep -rn --exclude-dir=node_modules "biome-ignore\|eslint-disable\|@ts-ignore\|@ts-expect-error\|# noqa\|nolint" . | wc -l   # suppression count
cat tsconfig*.json 2>/dev/null | grep -i 'strict\|noUncheckedIndexedAccess\|noImplicitAny'   # type strictness
grep -rn --exclude-dir=node_modules "TODO\|FIXME\|HACK\|XXX" . | wc -l
grep -rn --exclude-dir=node_modules "process\.env\." . | wc -l                 # env spread: count + which files
git ls-files '*.test.*' '*.spec.*' | wc -l                                     # test inventory
```

(Adapt to the repo's language. See `references/coverage-rubric.md` for the probe-per-dimension mapping and a hardcoded-secret scan.)

**Test inventory is evidence, not inference.** Never infer coverage from file presence. Record counts per layer, what's tested vs bare, presence of *negative / authz / cross-tenant* tests (not just happy-path), and whether e2e exercises the **real stack or fakes it** — open the e2e specs: a suite that mocks the API and asserts only client-side validation is not e2e. Flag the highest-value missing tests, especially any gating a proposed refactor.

### Step 4: Fan out sub-agents (layer readers + dimension specialists)

Launch sub-agents in parallel (Task tool, `Explore` or general-purpose). Use **two kinds**, because a review built by reading source naturally over-weights what *lives in the code* (SOLID, patterns, abstractions) and under-weights what *surrounds it* (tests, config, tooling, docs, build). Correct for that bias deliberately.

- **Layer readers** — one per architectural layer present: data/persistence & migrations; API/service boundaries & tenancy/authz; domain/core logic & state modelling; frontend/UI state topology; cross-cutting/infra (config, concurrency, error handling).
- **Dimension specialists** — explicitly owned, because they get silently skipped otherwise: **Testing & testability**; **Security breadth** (authz, tenancy, injection, secrets, CSRF, SSRF, rate-limit); **Global state, side-effects & config**. Feed these the Step 3 probe output.

Hand every sub-agent `references/review-lens.md` **verbatim** and point it at `references/ai-slop-catalogue.md`. Each must return:

- **Strengths** — idioms the codebase already does right (mandatory; the synthesis needs them).
- **Findings** — each with severity + `file:line` + the **lowest-enforcement-layer fix**.
- **Defended code** — any legitimately-defensive code it chose *not* to flag, with why.

Scale the agent count to repo size. Name in the output which layers/dimensions were and weren't covered — **no silent caps.**

### Step 5: Synthesis & verification gate

You are now the reviewer-in-chief. Work the checklist in `references/synthesis-checklist.md`, in order:

1. **Dimension-coverage gate (mandatory).** Walk the full rubric in `references/coverage-rubric.md` and assign every dimension a status: **covered (findings) / checked, nothing to fix / gap / n/a**. "We didn't look at testing" must be impossible to ship. A clean "checked, nothing to fix" is a first-class, valuable outcome — but it must be *stated*, never omitted.
2. **Verify load-bearing claims** with actual commands — a required gate for every Critical/High finding (e.g. `grep -rc "check (" migrations/`, confirm RLS/constraints exist). **Cross-confirmation** by two independent sub-agents = strong signal; call it out.
3. **Push every fix to the lowest layer** where the bad state becomes impossible. Challenge any "add validation in the service" finding — can a CHECK constraint / discriminated union / partial unique index make it unrepresentable instead?
4. **Couple every refactor to its safety net.** For each *split / extract / replace / move* recommendation, answer: "What test proves this behaves the same after the change — and does that test exist today?" If the safety net is missing, emit the **characterization/coverage test as a prerequisite finding, sequenced before the refactor and linked blocker → blocked.** Never recommend refactoring untested code without first recommending the test that protects it.
5. **Strengths + through-line.** A mandatory "what's genuinely well-designed" section, and where one exists, the **"they already know how to do this here, just not there"** reframing — which turns a gap into a consistency problem, not a knowledge problem, and lands recommendations in the codebase's own idiom.
6. **Anti-overcomplication pass on the review itself.** Ask: "Which of these recommendations is itself over-engineering?" Reward subtraction and "document as a deliberate exception" (e.g. don't add a repository abstraction over an ORM for a swap that will never happen — that's negative ETC).
7. **Calibrate to size.** Distinguish god-module (mixed responsibilities → split) from large-but-cohesive (leave it; extract only when next touched). A high LOC count is a prompt to investigate, **never itself a finding**.

### Step 6: Output — review + ruthless, dependency-ordered action list

Print, in this order:

1. **Coverage rubric status table** — every dimension with its status.
2. **Strengths** — and the through-line, if one exists.
3. **Findings** — grouped by severity, each `file:line` + lowest-layer fix.
4. **What I'd actually do** — a short, ruthless list ordered by **safety-per-effort *and* prerequisite**. Findings have dependencies (test-before-refactor, constraint-before-authz-move) — encode that ordering and mark blockers (blocker → blocked), so the user can execute top-to-bottom without discovering mid-refactor that the safety net is missing. Lead with the one or two biggest "an AI agent will break this" footguns. Deliberately **stop short of everything** — the user should be able to read only this section and start work.

Severity vocabulary: **Critical / High / Medium / Low.** Surface the `aislop ci` persisted-guard recommendation if the repo lacks one (wiring `aislop ci` into the pipeline makes mechanical slop harder to write in the first place — a real ETC win).

### Step 7: Offer artifacts (only on user say-so)

After printing, *offer* to turn findings into GitHub issues or a dated report doc. Don't impose. If the user accepts:

- **Read existing labels, milestones, and issue templates first.** Reuse the repo's own vocabulary and `file:line` framing.
- **Never invent labels or milestones.** Surface gaps ("no milestone fits this") instead of filling them. Don't force a finding into a milestone that doesn't fit.
- Preserve the blocker → blocked links when issuifying (the prerequisite test issue blocks its refactor issue).

## Edge cases

- **Not a code repo / wrong directory:** report and stop.
- **No `git` / not a git checkout:** the test-inventory and `--changes` probes won't work; note it and fall back to `find`.
- **aislop unsupported language or no `npx`:** skip it, run the manual probes, and state in the output that the deterministic mechanical pass was skipped.
- **Huge monorepo:** scope to one package/app per run (ask which); don't silently sample.
- **Posture marker already in `AGENTS.md`:** trust it; don't re-ask. If the user says it's stale, update it.
- **Tiny / throwaway repo:** say so. A 200-line script doesn't need a layered review — give the two things that matter and stop.

## Reference docs

- `references/review-lens.md` — the verbatim "how to think" lens handed to every sub-agent.
- `references/ai-slop-catalogue.md` — the named AI-slop signs to hunt, each with its legitimate inverse.
- `references/coverage-rubric.md` — the mandatory dimension rubric + the mechanical probe per dimension.
- `references/synthesis-checklist.md` — the synthesis / verification / prioritisation gate.
- Corollary reading (don't duplicate): `../task-implement/references/solid-applied.md` (SOLID per principle, applied non-dogmatically) and `../task-implement/references/sdlc-pitfalls.md` (defensive-coding pitfalls, the Two Hats rule, lazy-AI-coder failure modes).
