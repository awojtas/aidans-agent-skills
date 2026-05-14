---
name: requirements-add
description: Adds a single new requirement to an existing docs/requirements/ tree. Checks for duplicates and conflicts against the requirements already on disk, decides interactively with the user whether the new requirement extends an existing file or stands as a new one, and elaborates the requirement in depth (statement, fit criterion, rationale, traces-to, assumptions, open questions) using the same disciplines as /requirements-create-from-design but at single-requirement granularity. For when one new requirement surfaces *after* the initial bulk elicitation — not for the whole-tree case (that's /requirements-create-from-design). Trigger phrases include "add a requirement", "add this requirement", "we need a new requirement for X", "document this new requirement", "capture this as a requirement", "I forgot a requirement".
---

Adds **one** new requirement to an established `docs/requirements/` tree, with a duplicate/conflict pre-check and proper elaboration.

## When to use this skill vs others

- **No requirements tree yet?** Use `/requirements-create-from-design` instead.
- **Tree exists, single new requirement to add?** This skill.
- **A discovery is invalidating the existing plan?** Use `/requirements-rework`.
- **Re-validating existing requirements?** Use `/requirements-validation`.

## Workflow

1. **Read `docs/requirements/`.** If it doesn't exist, stop and tell the user to run `/requirements-create-from-design` first. Read `docs/architecture/` too if it's present — the new requirement must respect the recorded architecture.

2. **Capture the new requirement in one or two lines from the user.** The raw ask, not the polished form. You'll elaborate it later.

3. **Duplicate check.** Search every existing `FR-` and `NFR-` statement (and fit criterion) for overlap with the proposed addition. Show the user any candidate near-matches before continuing. Three outcomes:
   - **Exact duplicate** — stop, point at the existing requirement, ask the user if they meant to edit it.
   - **Partial overlap** — propose extending the existing requirement instead of adding a new one. Let the user decide.
   - **No overlap** — proceed.

4. **Conflict check.** Look for requirements (or assumptions, or goals/non-goals) that the new requirement would contradict. Surface anything plausible. If the conflict is real, the user has to resolve it before adding — propose options (drop the new requirement, supersede the conflicting one, or add as an explicit exception).

5. **Placement decision.** Interactively work out where the new requirement lives:
   - Functional → which `03-functional/<domain>.md`? Append to an existing domain file or create a new domain file. The boundary should mirror how the existing tree is organised.
   - Non-functional → which quality attribute file in `04-non-functional/`?
   - Edge case: the new requirement spans multiple domains. Propose splitting it.

6. **Elaboration interview.** Use the same disciplines as `/requirements-create-from-design`, scoped to one requirement:
   - **Statement** — RFC 2119 verb (SHALL / SHOULD / MAY).
   - **Fit criterion** — observable, measurable, verifiable.
   - **Rationale** — why this requirement exists.
   - **Traces-to** — linked goals, NFRs, assumptions, open questions.
   - **Constraints / dependencies** — anything it depends on or is blocked by.
   - **New assumptions** — capture into `07-assumptions.md` if any surface.
   - **New open questions** — capture into `08-open-questions.md` if any surface.
   - **MoSCoW** — Must / Should / Could / Won't. Pressure-test Musts honestly.
   - **Status** — default `Draft`; user can promote later via `/requirements-validation`.

7. **INCOSE sanity check.** Quick pass against necessary / unambiguous / singular / verifiable / traceable. Push back if any fail.

8. **Assign the ID.** Infer the next-available `FR-<DOMAIN>-NNN` or `NFR-<ATTR>-NNN` from the existing tree's convention. Don't invent a new scheme.

9. **Write to disk.** Append the requirement to the chosen file, in the same format the file already uses. Add any new assumptions / open questions to their registers. Update `traces-to` lines on related existing requirements if the new one is a dependency.

10. **Session-log entry.** Append a structured entry to `docs/requirements/session-log.md`: date, the new ID + statement, placement decision (why this file), any conflicts resolved, any new assumptions/OQs added.

## Guardrails

- **One requirement per invocation.** If the user has five new ones, run the skill five times. Bulk additions belong in `/requirements-create-from-design`.
- **Don't auto-promote status.** New requirements start `Draft`. Status changes are `/requirements-validation`'s job.
- **Don't bypass the duplicate check** — it's the whole reason this skill exists rather than the user just editing a file by hand.
- **Don't restructure the tree.** If the new requirement doesn't fit the existing organisation, ask the user before reorganising — don't silently move files.
- **Respect the architecture.** If `docs/architecture/` is present and the new requirement is impossible under the recorded architecture, surface that before writing anything.

## Output

- One requirement appended to the appropriate file with a fresh ID.
- Any new assumptions / open questions appended to their registers.
- Any updated traces-to lines on related requirements.
- A session-log entry.
- A short summary to the user: ID assigned, where it lives, status (`Draft`), what to do next (typically: `/requirements-validation` later to advance the status).
