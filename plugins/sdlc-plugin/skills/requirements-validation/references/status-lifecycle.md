# Requirement Status Lifecycle

The `Status` field on a requirement moves through four states. Each transition has explicit criteria — don't advance status without them.

```
Draft → Reviewed → Approved → Baselined
                                    │
                                    └─→ (Implemented, in code)
```

## Draft

The default state for a newly written requirement. Means "captured, but not yet pressure-tested".

**Entry criteria:** Statement exists. Source exists.

**Exit criteria (→ Reviewed):**
- Statement is unambiguous (passes hostile re-read).
- Fit criterion is concrete and measurable.
- Rationale ties to ≥1 goal/journey/NFR.
- Acceptance criteria exist for non-trivial requirements (Given-When-Then form).
- All linked assumptions are recorded.
- No linked open question is currently blocking.
- Passes INCOSE single-requirement checks (see `incose-checklist.md`).

A Draft can stay Draft indefinitely while open questions resolve. Don't force-advance.

## Reviewed

The requirement has been confirmed accurate, measurable, and traceable by the elicitation/confirmation process.

**Entry criteria:** all Draft-exit criteria.

**Exit criteria (→ Approved):**
- All stakeholders identified in `00-overview.md` who have a decision interest in this requirement have signed off (explicitly named in `Source` or in a session log).
- No conflicting requirements in the set.
- Priority assigned via MoSCoW.
- For Musts: the force-rank exercise (`10-prioritisation.md`) has been run.

Approved requires explicit stakeholder say-so, not just agent confirmation. The skill should never auto-advance to Approved.

## Approved

Stakeholders have signed off. The requirement is the basis for architecture and implementation work.

**Entry criteria:** all Reviewed-exit criteria + sign-off.

**Exit criteria (→ Baselined):**
- The requirement set as a whole has been baselined — meaning architecture work is starting against this set. Typically the entire `docs/requirements/` folder advances together, not one requirement at a time.

Changes to Approved requirements should trigger a **change-control note** in the session log: who asked for the change, when, why, and which downstream artefacts (architecture, code, tests) need re-inspection.

## Baselined

The frozen-for-this-iteration state. Architecture and implementation are happening against this. Changes from here on are formal change requests, not edits.

In practice, for a solo founder / small team, "Baselined" may just mean "we're not going to keep reopening this without good reason". For an enterprise team, it's a versioned snapshot.

## Session log

Each confirmation session appends an entry to `docs/requirements/session-log.md` (create if missing) capturing:

```markdown
## Session YYYY-MM-DD HH:MM — Confirmation pass

**Scope.** All requirements / `<file>` / `<requirement ID>`.

**Outcomes.**
- **Advanced:** FR-AUTH-003 (Draft → Reviewed), FR-AUTH-005 (Draft → Reviewed)
- **Edited:** FR-AUTH-001 statement clarified; FR-AUTH-002 fit criterion replaced
- **Assumptions resolved:** A-007 validated; A-012 falsified (impacts FR-BILLING-002)
- **Open questions resolved:** OQ-005 (renderer extension list confirmed); OQ-006 (history semantics decided)
- **New open questions:** OQ-014 (auth provider rotation policy)
- **New assumptions:** A-019 (Postgres latency baseline)

**Notes.** Anything worth a future reviewer knowing.
```

The session log is the durable record of how the requirements doc evolved. Useful for:
- Reviewing past decisions ("when did we decide X?")
- Reproducing the audit trail for a compliance review
- Onboarding new team members ("read the last 5 session logs")

## Anti-patterns

- **Stealth advancement.** Don't move Draft → Reviewed inside the same write without an explicit user-confirmed checkpoint. Stealth advancement breaks trust in the process.
- **Premature Approved.** Don't mark Approved until the stakeholder sign-off line is actually recorded. "I think it's fine" is not sign-off.
- **Status fog.** If a requirement has been at Draft for >30 days, it has either (a) unresolved open questions that need owner action, or (b) lost its sponsor. Surface it.
- **Bulk demotion.** If a confirmation pass finds many requirements fail Pass 2 or Pass 5, don't demote them all silently. Stop the session, surface the systemic issue, and have a conversation about the quality bar.
