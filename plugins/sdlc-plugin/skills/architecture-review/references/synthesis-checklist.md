# Synthesis checklist — the reviewer-in-chief gate

You have the sub-agents' returns (strengths, findings, defended code) and the Step 3 deterministic pre-scan. Your job is to turn raw findings into a verified, opinionated, executable review. Sub-agents hedge and occasionally assert things that aren't true — you are the gate that stops false or low-value findings from shipping. Work this in order.

## 1. Walk the coverage rubric — assign every dimension a status

Open `coverage-rubric.md`. For all 12 dimensions, record **covered / checked, nothing to fix / gap / n/a**. Do not skip one silently. If a dimension specialist returned nothing, that's either "checked, nothing to fix" (state it) or "gap" (say so) — never an omission. This table is the first thing printed in the report.

## 2. Verify load-bearing claims with commands

For **every Critical/High finding**, confirm it with a real command before it ships. Examples:

```bash
grep -rc "check (" migrations/                 # does the CHECK constraint actually exist?
grep -rn "enableRLS\|ROW LEVEL SECURITY" .       # is RLS actually on?
grep -rn "<the exact symbol the agent claimed>"  # does the thing they cited exist where they said?
```

- A finding that fails verification is **dropped or downgraded** — note it as "claimed but unconfirmed."
- **Cross-confirmation is a strong signal:** when two independent sub-agents flag the same thing (e.g. the API reader and the data reader both flag the same tenancy gap), say so — it raises confidence.
- **aislop / mechanical-probe findings are pre-verified** (deterministic — same input, same output). Fold them in without re-running a command, but still subject them to the "defend legitimate defensiveness" and lowest-layer lenses.

## 3. Push every fix to the lowest enforcement layer

For each finding, ask: is the proposed fix at the lowest layer where the bad state becomes *impossible*? Rewrite "add validation in the service" to "add a CHECK constraint / discriminated union / partial unique index" wherever that's achievable. **DB constraint > type system > service boundary > runtime check.**

## 4. Couple every refactor to its safety net

For each **split / extract / replace / move** recommendation:

- Name the test that proves same-behaviour-after.
- Does it **exist today**? Verify with the test inventory, don't assume.
- If missing: emit the **characterization/coverage test as a separate, prerequisite finding**, sequenced *before* the refactor, and link them **blocker → blocked**.

Never let a refactor recommendation ship without its protecting test accounted for. (The canonical failure: filing three refactor issues whose prerequisite tests don't exist.)

## 5. Strengths + the through-line

Assemble the mandatory **"what's genuinely well-designed"** section from the sub-agents' strengths. Then look for the **"they already know how to do this here, just not there"** through-line: where the codebase uses the right technique in one place (deterministic PKs, `nullsNotDistinct`, a clean projection, RLS on one table) but not in an analogous place. When it exists, reframe the matching gaps as **consistency problems, not knowledge problems** — recommendations land harder when they're in the codebase's own idiom.

## 6. Anti-overcomplication pass on your own review

Before finalizing, turn the lens on the recommendations themselves:

> "Which of these is itself over-engineering?"

Cut or downgrade any recommendation that adds machinery for a swap that will never happen (e.g. a repository abstraction over an ORM you'll never replace — that's negative ETC). **Reward subtraction.** "Delete this", "leave this as-is", and "document this as a deliberate exception" are valid, valuable outcomes. A review that only adds is failing the user's actual standard.

## 7. Calibrate to size

God-module (mixed responsibilities → split) vs large-but-cohesive (one responsibility, just big → leave; extract when next touched). High LOC is a prompt to investigate, never itself a finding.

## 8. Emit the dependency-ordered action list

The final "what I'd actually do" is ordered by **safety-per-effort AND prerequisite**:

- Encode dependencies (test-before-refactor, constraint-before-authz-move). Mark blockers so the list executes top-to-bottom.
- Lead with the one or two biggest "an AI agent will break this" footguns.
- Stop short of everything — the user should be able to read only this section and start.
- If the repo has no slop CI guard, recommend wiring `aislop ci` into the pipeline (makes mechanical slop unrepresentable at PR time — a real ETC win, not just another finding).

## Tone

Opinionated and specific over comprehensive and hedged. Every finding: **severity + `file:line` + lowest-layer fix.** Recommend, don't survey.
