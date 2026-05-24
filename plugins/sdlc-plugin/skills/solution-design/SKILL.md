---
name: solution-design
description: Creates a high-level solution design document at docs/design/solution-design.md — a combined business + technical first-stab at how the system might work. Walks 15 sections in a short focused interview (10-15 minutes target) — purpose & problem, users & personas, value & success criteria, key features, high-level user flows, major screens/surfaces (thinking-level), system context (C4-context Mermaid), major components (C4-container), solution strategy, data approach, external integrations, NFR drivers, constraints, risks & open questions, and a prominent first-stab disclaimer. Explicitly first-thinking fidelity — will be wrong in places later; supersede notes accumulate rather than rewriting. Bridges README ("what is this") and docs/architecture/ ("how is this engineered"). Trigger phrases include "solution design", "create a solution design", "draft an HLD", "high-level design", "sketch the solution", "design overview", "vision doc".
---

Writes a single high-level solution design markdown document covering **business and technical** framing for an early-stage project. Designed for the 10-15 minute "first-thinking" window — *not* the 30-90 minute architecture slog that `/platform-design` runs.

## When to use this skill vs others

- **Brand-new project, README exists, want a first-stab solution view?** This skill.
- **Ready to flesh out the technical architecture in detail?** Use `/platform-design` next.
- **Need to elicit functional + non-functional requirements?** Use `/requirements-create-from-design` after this.

## Workflow

1. **Read `README.md`.** It's the seed. If missing, stop and ask the user for a brief description of what the project is.

2. **Check whether `docs/design/solution-design.md` already exists.**
   - If **yes** — switch to *evolve mode*: walk only the sections the user wants to revisit; add **Superseded YYYY-MM-DD** entries below the live content rather than overwriting. Old framings stay as history.
   - If **no** — proceed to fresh-write mode.

3. **Walk the 15 sections** via a short focused interview. 3-5 questions per section max. Target 10-15 minutes end-to-end — breadth over depth on purpose.

   | # | Section | What goes here |
   |---|---|---|
   | 1 | Purpose & problem | What this system does; the job it gets hired for (Jobs-to-be-Done framing) |
   | 2 | Users & personas | Short list, lightweight |
   | 3 | Value & success criteria | Why this matters; how we'd know it's working |
   | 4 | Key features / capabilities | "User can do X" — capability-level, not requirement-level |
   | 5 | High-level user flows | 3-5 key journeys as short narrative paragraphs |
   | 6 | Major screens / surfaces | The main surfaces the user touches — pages, dashboards, CLI commands, API endpoints. Explicitly *thinking-level*, not specs |
   | 7 | System context | One C4-context Mermaid diagram; inside/outside the boundary |
   | 8 | Major components | C4-container level, 5-9 boxes |
   | 9 | Solution strategy | 3-5 bullets on biggest design choices (web/mobile/CLI, sync/async, monolith/services, hosted/self-hosted) |
   | 10 | Data approach | Where data lives — not modelling |
   | 11 | External integrations | List, not specs |
   | 12 | NFR drivers | 3-5 bullets across the AWS Well-Architected pillars (security, reliability, performance, cost, ops) |
   | 13 | Constraints | Tech mandates, compliance, budget |
   | 14 | Risks & open questions | Known unknowns |
   | 15 | First-stab disclaimer | **Prominent** — this will be wrong in places; supersede notes accumulate |

4. **Push back on premature precision.** If the user starts naming specific tech ("Postgres on RDS"), gently redirect: *that's the `/platform-design` conversation; here just say "a relational DB hosted on a managed PaaS"*. Same for product detail — capability-level, not requirement-level.

5. **Write `docs/design/solution-design.md`.** Use the 15 sections as headings. Include any Mermaid diagrams inline. Stamp the doc with creation date.

6. **Final read-back.** Echo the doc structure to the user, ask if anything is missing, then close.

## Grounding sources

- **Business / product**: Lean Canvas (Ash Maurya), Jobs-to-be-Done (Clayton Christensen), lightweight customer journey mapping, low-fidelity sketching ("Crazy 8s").
- **Technical**: C4 model — Context + Container levels (Simon Brown); Arc42 sections 1-5; TOGAF Architecture Vision (Phase A).
- **Cross-cutting**: AWS Well-Architected Framework pillars for the NFR-drivers section; IEEE/ISO/IEC 42010 for architecture-description framing.

## Guardrails

- **Don't slip into platform-design depth.** This is breadth-over-depth on purpose. If a section starts running long (more than ~5 minutes), park it and note it as an open question.
- **Don't paint over.** If the doc already exists and the user wants to change something, append a *Superseded YYYY-MM-DD* entry; don't quietly overwrite the old framing. The history is part of the value.
- **Don't ship without the disclaimer.** Section 15 is non-negotiable — every reader needs to understand the doc is consciously first-stab and will be revised.
- **Sketches, not wireframes.** Section 6 captures screens *at the level you'd describe them in a napkin sketch*. If the user pushes for visual fidelity, redirect to a UX skill or a real wireframing tool.
- **Don't invent details.** If the user genuinely doesn't know something, capture it in section 14 (Risks & open questions). Better an honest gap than a fabricated answer.

## Output

- `docs/design/solution-design.md` — created (or appended with Superseded entries).
- A short report to the user: what got captured, what went into open questions, what's next (typically: `/platform-design`).

## Commit and push

Stage `docs/design/solution-design.md` and `README.md` (lifecycle tracker), commit with `docs(design): create solution design` (or `docs(design): evolve solution design` in evolve mode), then follow [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md).

## Lifecycle tracker

This skill owns the **Solution designed** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Solution designed` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Solution designed` line to ✅ (done).

Touch only the `Solution designed` line — leave every other stage exactly as found.
