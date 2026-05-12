# Common Requirements Pitfalls

These are the failure modes that cause requirements docs to become useless or actively harmful. The skill should actively defend against each one during elicitation.

## 1. Ambiguity

**Symptom:** "The system shall be fast / scalable / user-friendly / robust."

**Why it's fatal:** Three people read it three different ways. The team builds against the easiest interpretation, the stakeholder remembered the hardest, conflict ships in production.

**Defence:** Every adjective must reduce to a measurable fit criterion. "Fast" → "p95 response under 500ms for 99% of requests in a steady-state of 100 req/s". If the user can't or won't give a number, write `[ASSUMPTION: we accept latency equivalent to a typical SaaS app at this scale]` in `07-assumptions.md` and move on. The assumption is now visible.

## 2. Scope creep through fuzzy boundaries

**Symptom:** No clear "non-goals" section, or one that's three lines long. Stakeholders months later: "I assumed it would also do X."

**Why it's fatal:** Every undocumented "won't do" item becomes a free option for stakeholders to exercise — and the team has no leverage to refuse.

**Defence:** `01-goals-and-non-goals.md` should be balanced — if Goals is 10 items, Non-Goals should be 10+ items. Specifically enumerate "things a reasonable person might assume are included that we're explicitly not building." Distinguish "not yet" (deferred decision, captured in `08-open-questions.md`) from "never" (architectural choice, captured here with rationale).

## 3. Hidden assumptions

**Symptom:** The doc reads cleanly but a critical assumption — about user behaviour, data shape, regulatory scope, hardware availability — is buried in the implementer's head.

**Why it's fatal:** When the assumption proves wrong, the cost is rework of everything downstream. The team didn't even know to question it.

**Defence:** Every time the agent or stakeholder says "we'll assume X" or "obviously Y" or "everyone knows Z", capture it in `07-assumptions.md` with: assumption, who made it, date, validation status, and what changes if it's wrong. **The single highest-leverage practice in this skill.**

## 4. Missing NFRs

**Symptom:** 200 functional requirements, two NFRs (one of which is "the system must be secure").

**Why it's fatal:** NFRs drive architecture more than functional requirements do. A system with the same features at 100 users and 10M users is two different architectures.

**Defence:** Walk every category in `nfr-catalogue.md`. If a category truly doesn't apply, write a short file recording the decision (not absence) — so the call is reviewable.

## 5. Conflating *what* with *how*

**Symptom:** "The system shall use PostgreSQL with a Redis cache" appears in a functional requirement.

**Why it's fatal:** Technology choices in the requirements doc lock the architecture before the architect has read the requirements. They also conflict with NFR-driven architecture work that comes next.

**Defence:** When you spot a technology mention in a *requirement*, ask "what user-visible behaviour are you really specifying?" Move the tech choice to `06-constraints.md` (if it's mandated by a stakeholder) or defer it to the architecture phase.

## 6. Untestable / no fit criterion

**Symptom:** "The system shall be highly available." No number, no measurement window, no exclusion clauses.

**Why it's fatal:** Cannot be verified. Cannot be designed against. Cannot be argued about when something goes wrong.

**Defence:** Every NFR has a fit criterion line. If the team can't write one, the requirement is incomplete — flag as `Draft` and move it to `08-open-questions.md`.

## 7. Orphan requirements

**Symptom:** A requirement with no rationale, traceable to no stakeholder, no goal, no journey.

**Why it's fatal:** Why is it there? Nobody knows, but everyone's afraid to delete it because "someone must have wanted it." It survives forever, burning estimation budget.

**Defence:** **No requirement without a source line.** If the user can't name who asked for it, delete it or move it to `08-open-questions.md` ("OQ-XXX: do we actually need FR-XXX, no source identified").

## 8. Vocabulary drift

**Symptom:** The stakeholder says "client", the dev writes "user", the spec says "account", the database calls it "tenant", the support team calls them "customers". Same concept, five names.

**Why it's fatal:** Conversations confuse, documents contradict, search misses.

**Defence:** Maintain the glossary in `00-overview.md` from day one. When a new term appears, add it. When a synonym appears, pick one canonical term and note the others.

## 9. Late-arriving stakeholders

**Symptom:** Three months in, "Oh, security/legal/finance/marketing/support also need a say."

**Why it's fatal:** Late stakeholders rewrite finalised requirements, invalidating downstream architecture and code.

**Defence:** During initial discovery, ask the negative-space question: "who would be unhappy if they found out about this project after launch?" Surface all of them in `00-overview.md` stakeholder list.

## 10. Big-bang specs

**Symptom:** A 200-page document that nobody reads after week 1.

**Why it's fatal:** Requirements stop being a living artefact. The wiki diverges from reality. The doc becomes performative.

**Defence:** Short, focused files (the structure this skill produces). Bias to *links* between files over duplication. Treat the doc as a working artefact — every interview session updates it.

## 11. Premature prioritisation

**Symptom:** Everything is "must have" because the conversation hasn't surfaced the cost of each requirement.

**Why it's fatal:** When every item is a Must, MoSCoW degenerates and there's no MVP. The team builds everything to a poor standard rather than the MVP well.

**Defence:** Force-rank within Must — if there were budget for half of the Musts, which half? That sub-set is the real MVP; the rest are actually Shoulds.

## 12. No "waiting room"

**Symptom:** A user mentions a half-formed idea; the agent either implements it as a Should or drops it. Three weeks later, the user asks "what happened to that idea about X?"

**Why it's fatal:** Lost ideas are a trust problem. Implemented hallucinations are a worse problem.

**Defence:** `08-open-questions.md` is the waiting room (Volere's term). Anything not ready for a requirement statement lives there with a date, a description, and a "next step to resolve" line. Nothing is forgotten; nothing is invented.

## Quick reference: pitfall → countermeasure file

| Pitfall                       | Captured in                                  |
|-------------------------------|----------------------------------------------|
| Ambiguity                     | Fit criterion on every requirement           |
| Scope creep                   | `01-goals-and-non-goals.md` (non-goals heavy)|
| Hidden assumptions            | `07-assumptions.md`                          |
| Missing NFRs                  | `04-non-functional/` — file per category     |
| What-vs-how confusion         | `06-constraints.md` for mandated tech        |
| Untestable                    | Fit criterion or → `08-open-questions.md`    |
| Orphan requirements           | Source line mandatory                        |
| Vocabulary drift              | Glossary in `00-overview.md`                 |
| Late stakeholders             | Stakeholder list in `00-overview.md`         |
| Big-bang specs                | Short files; structure of this skill         |
| Premature prioritisation      | `10-prioritisation.md` with force-rank       |
| No waiting room               | `08-open-questions.md`                       |
