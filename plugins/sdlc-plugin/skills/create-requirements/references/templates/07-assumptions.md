# 07 — Assumptions

> Highest-leverage file in this folder. The cost of a buried assumption that turns out wrong is rework of every downstream artefact (architecture, code, tests, docs, customer comms). Capture **every** assumption made during requirements work.

## How to use this file

Add an entry whenever:

- An interview answer rests on a belief about users, the market, the law, the data, or the tech.
- The agent makes a default choice the user didn't explicitly approve.
- A requirement is written conditional on something not yet verified.
- A stakeholder says "obviously", "everyone knows", "we can assume", "let's say".

Tag the assumption in the source requirement with `[ASSUMPTION: A-NNN]` and the assumption here links back.

## Assumptions

### A-001: {{Short statement of the assumption}}

- **Made by.** {{Who — stakeholder name or "the elicitation agent"}}
- **Date.** {{YYYY-MM-DD}}
- **Validation status.** Unvalidated | In progress | Validated | Falsified
- **Validation method.** {{How will / did we test this? Interview, data analysis, prototype, expert review.}}
- **Linked requirements.** {{FR-XXX-NNN, NFR-YYY-NNN}}
- **What changes if wrong.** {{Plain-English description of the downstream cost. This is what makes the assumption tracking earn its keep.}}

---

### A-002: ...

*(Continue.)*

## Recently falsified assumptions

When an assumption is **Falsified**, keep it in the list and add:

- **Falsified on.** {{date}}
- **What we learned instead.** {{the new fact}}
- **Action taken.** {{links to requirement updates, PRs, open questions raised}}

Falsified assumptions stay in the doc — they're a learning record, not noise.
