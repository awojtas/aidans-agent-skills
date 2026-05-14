# Initial Architecture for {{PROJECT_NAME}}

This folder contains the **initial architectural design** for **{{PROJECT_NAME}}** — what kind of system we're building, what the major pieces are, where it runs, and what early decisions shaped it.

**Status: INITIAL.** This is a first stab. It is not 100% baked, and it is not meant to be. The purpose is to capture enough about the technical shape that:

- Requirements work (in `docs/requirements/`) isn't done in an architectural vacuum.
- The team can spot early when a requirement implies an architectural change.
- Future implementation work has a target to build to.

Expect this to evolve as requirements get tighter and as implementation surfaces real constraints. When that happens, update the relevant file *and* add a new entry to `04-decisions.md` explaining what changed.

## How to read this

| File                                 | What's in it                                                              |
|--------------------------------------|---------------------------------------------------------------------------|
| `00-system-overview.md`              | What this system is, who uses it, what it talks to, the major moving parts (C4-style context + containers). |
| `01-stack-and-hosting.md`            | Language(s), framework(s), libraries, hosting platform, runtime model.   |
| `02-data-and-storage.md`             | Where data lives, its shape, sensitivity, retention.                     |
| `03-external-integrations.md`        | Third-party APIs, services, and partners this system depends on.         |
| `04-decisions.md`                    | The architectural decisions made so far (lightweight ADR style).          |
| `05-open-questions.md`               | What we deliberately punted on — needs more thought / more requirements / more research. |

## Conventions

- **Diagrams in Mermaid** where possible — they render natively on GitHub and stay version-controlled. ASCII art is fine as a fallback.
- **Decisions are recorded in `04-decisions.md`** using a lightweight ADR format (1-2 paragraphs each). Every meaningful technical choice that constrains future work gets an entry.
- **What's not decided yet goes in `05-open-questions.md`**, not buried in prose elsewhere.
- **Cross-link to requirements.** When a section here is shaped by a goal or constraint in `docs/requirements/`, link it.

## Status of decisions

Generated: {{TODAY}}. Last updated: {{TODAY}}.

Major open questions outstanding: see `05-open-questions.md`.

## Next steps

Once this folder has enough content that requirements work isn't blocked by architectural ambiguity:

1. Run `/requirements-create-from-design` to elicit functional + non-functional requirements (which will reference this folder).
2. As requirements firm up, revisit this folder — some open questions will resolve, some new ones will emerge.
3. When implementation starts (`/task-implement`), the Principal Engineer, Cloud Architect, and UX Designer all read this folder.
