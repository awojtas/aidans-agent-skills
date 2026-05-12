# Requirements for {{PROJECT_NAME}}

This folder contains the requirements specification for **{{PROJECT_NAME}}**. It is a *living* document — each elicitation session adds or refines content. **Do not** treat it as a one-time deliverable.

## How to read this

Start at `00-overview.md` for context. The numbered files are designed to be read in order on a first pass, but you can jump straight to any file once the project is familiar.

| File / Folder                          | What's in it                                                          |
|----------------------------------------|------------------------------------------------------------------------|
| `00-overview.md`                       | Purpose, stakeholders, glossary.                                       |
| `01-goals-and-non-goals.md`            | What we *are* building. What we are *explicitly not* building.         |
| `02-personas-and-journeys.md`          | User personas + top user journeys.                                     |
| `03-functional/`                       | One file per functional domain (auth, billing, ...).                   |
| `04-non-functional/`                   | One file per quality attribute (performance, security, ...).           |
| `05-data-and-integrations.md`          | Data entities, sensitivity, retention. External systems.               |
| `06-constraints.md`                    | Technical, legal, budget, timeline constraints.                        |
| `07-assumptions.md`                    | Every assumption, dated, with a "what changes if wrong" note.          |
| `08-open-questions.md`                 | The "waiting room" — unresolved items, with a next-step.               |
| `09-risks.md`                          | Known risks, probability × impact, mitigation owner.                   |
| `10-prioritisation.md`                 | MoSCoW table. MVP definition derives from the Musts.                   |

## Conventions

- **RFC 2119 keywords** (MUST, SHALL, SHOULD, MAY) are used **in ALL-CAPS** to signal a normative statement. Lower-case is informal prose.
- Every requirement has a unique ID of the form `FR-<DOMAIN>-NNN` or `NFR-<CATEGORY>-NNN`.
- Every requirement has a **fit criterion** — how we'd verify it. Without one, the requirement is `Draft`, not `Reviewed`.
- Every assumption goes in `07-assumptions.md`. Every deferred decision goes in `08-open-questions.md`. Nothing implicit.

## Status

This specification is at: **DRAFT** *(updated {{TODAY}})*.

Move to **REVIEWED** when every requirement has a fit criterion and a source. Move to **APPROVED** when stakeholders have signed off. Move to **BASELINED** when architecture work begins against it.

## Next step

Once this folder reaches `REVIEWED`, the next phase is **architecture design** — translating these requirements into a system design. The architecture document should trace every architectural decision back to a requirement ID here.
