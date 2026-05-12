# Rework Playbook

How to conduct a rework session — the conversation that decides what changes in `docs/requirements/` and in the open GitHub issues when the team discovers the original plan needs to change.

## When rework is the right tool

Rework is appropriate when:

- **A discovery during Phase 1** (or any phase) changes what's actually needed. The team has started doing the work and learned something that invalidates earlier assumptions.
- **External reality shifted.** A vendor's API changed. A regulation changed. A competitor shipped something. The original plan rests on a now-stale premise.
- **A stakeholder changed their mind** on something material — and the new direction is firm enough to act on (not just an idea floated in passing).

Rework is **not** appropriate when:

- The current plan is fine and the user just wants to add features → `/create-requirements` for new requirements, then `/plan-from-requirements` for new tasks.
- A single requirement is unclear → `/confirm-requirements` will pressure-test it.
- The user wants to start over from scratch → `/create-requirements`, deliberately ignoring the existing docs.
- A bug emerged in shipped code → fix the bug, don't rework the requirement.

## The mindset

This skill is for **course correction**, not memorial. The user said it best: *"We're taking a different route to our destination. There's no point keeping memorabilia for a route we're avoiding."*

- **Default to delete.** Git preserves history. Closed GitHub issues are recoverable. Files in `docs/archive/` are friction.
- **Archive sparingly.** Only when the artefact represents a decision worth remembering even though it's been reversed. See `cleanup-principles.md`.
- **Be assertive.** "Should I keep this just in case?" — almost always, no. The "just in case" cost is real and accumulates.
- **Close issues, don't tag them as wontfix.** A closed issue with a clear closure comment is the same artefact as a tagged one, but the tagged version pollutes filters forever.

## The four-pass model

A rework session has four passes. They're sequenced — don't blend them.

### Pass 1 — Discovery (what changed?)

Ask the user, in plain English, **what triggered the rework**. Don't accept "let me look through the requirements first" — make them name the change in one or two sentences before you read anything.

Question bank:

- What did you discover, and when?
- Is this a scope narrowing (we're doing less), scope broadening (we're doing more), or direction change (different route to the same destination)?
- Whose mind changed — yours, a stakeholder's, a vendor's, the world's?
- What's firm about the new direction? What's still uncertain?

Capture the change as a one-paragraph "rework rationale" — this goes into the session log as the entry's preamble. Without a clear rationale, the rest of the session is theatre.

### Pass 2 — Requirement impact assessment

Walk every requirement in `docs/requirements/`. For each, classify it into one of four bins:

| Bin       | Meaning                                                                                | Action                                                            |
|-----------|----------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| **Keep**  | Untouched. The rework doesn't affect this requirement.                                  | No change.                                                         |
| **Update**| The requirement is still valid in intent, but specific text needs editing.             | Edit in place; record what changed in the session log.            |
| **Delete**| The requirement is no longer relevant under the new direction.                          | Delete the file (or the specific `### FR-…` block within a file).  |
| **Archive**| Rare. Apply only with explicit posterity justification (see `cleanup-principles.md`).  | Move to `docs/archive/<original-name>--archived-YYYY-MM-DD.md`.    |

Also walk `07-assumptions.md` and `08-open-questions.md`:

- Assumptions that the rework reveals as **Falsified** → mark Falsified, record the new fact. These often cascade — every requirement linked to the falsified assumption needs re-inspection.
- Open questions the rework **resolves** → move to Resolved.
- Open questions the rework **opens** → add new entries.

For `01-goals-and-non-goals.md`:

- If a goal is dropped → move to Non-Goals (Never) with rationale, or delete entirely if the original goal is no longer recognised.
- If a non-goal is now a goal → state explicitly with the rework rationale as the source.

Don't bulk-classify. The agent reads each requirement back to the user and asks. This is conversational on purpose.

### Pass 3 — Issue impact assessment

Pull all open issues from the repo (`gh issue list --state open --limit 200 --json number,title,labels,milestone,body`). Also pull recently closed issues (`gh issue list --state closed --limit 50 --json ...`) — sometimes a rework re-opens a previously dismissed need.

For each open issue:

| Bin     | Meaning                                                                              | Action                                                                |
|---------|--------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| **Keep**| Still valid as-written. Implements unchanged requirements.                            | No change.                                                             |
| **Update** | Still needed but task content or acceptance criteria need editing.                | `gh issue edit` with new body / labels / milestone.                    |
| **Close** | No longer needed under the new direction.                                          | `gh issue close --comment "<rework rationale>"`. Default for irrelevant issues. |

For each recently closed issue:

| Bin       | Meaning                                                | Action                                                  |
|-----------|--------------------------------------------------------|----------------------------------------------------------|
| **Leave** | Still correctly closed.                                | No change.                                               |
| **Reopen** | The rework brings back this need.                     | `gh issue reopen` with a comment explaining why.        |

**Watch for issues with linked PRs.** Before closing, check whether the issue has an open PR (`gh pr list --search "linked:<issue-number>"`). If yes, surface it — closing the issue while a PR is in flight needs a deliberate decision (close PR too? merge it first? leave as a dangling reference?).

### Pass 4 — Gap analysis

After the existing-thing assessment, ask: **what's missing?**

- Are there new requirements the new direction needs that weren't previously captured?
- Are there new tasks (GitHub issues) that didn't exist in the old plan?

For new requirements: write them following the templates the `create-requirements` skill uses (`functional-domain.md`, `nfr-section.md`). Add them to the appropriate file in `docs/requirements/`. Don't bulk-elicit — keep this pass tight; if the gap is huge, finish the rework and follow up with a full `/create-requirements` session.

For new tasks: draft them following the issue template (see the `plan-from-requirements` skill's `issue-template.md`). Stage them appropriately — if they're Phase 1 human-required work, label and milestone accordingly.

## After the four passes

You have a **proposed change set** in memory:

- N requirements to delete
- M requirements to update
- K requirements to archive (often 0)
- L new requirements to create
- A issues to close
- B issues to update
- C issues to reopen
- D new issues to create
- Updates to `07-assumptions.md`, `08-open-questions.md`, `01-goals-and-non-goals.md`

**Show this as a single markdown document** to the user. They approve (or edit) before any destructive action.

## Conversational guardrails

- **Don't recommend archive by default.** When a requirement or issue is no longer relevant, the default action is delete/close, not archive. Archive needs explicit justification.
- **Don't try to "soften" the change.** "Should we just mark it deferred?" — no, if it's not coming back, delete it. Deferred items live in `01-goals-and-non-goals.md` "Not yet" or `08-open-questions.md`, not as zombie requirements with `Status: Deferred`.
- **One change set per session.** If the user wants to do two unrelated reworks, surface that and do them as separate sessions. Mixing them makes the session log hard to read later.
- **Stop and confirm before destructive operations.** Even after the user approved the change set, when actually closing 8 issues, say: "About to close issues #12, #14, #15, #16, #17, #19, #20, #22. Final confirm?"
