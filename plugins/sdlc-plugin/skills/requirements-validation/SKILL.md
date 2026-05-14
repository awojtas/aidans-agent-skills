---
name: requirements-validation
description: Interactively validates and refines the requirements already documented in docs/requirements/. Starts by inventorying every file and showing the user a directory-style listing with status counts (Drafts vs Reviewed, open vs resolved questions, validated vs unvalidated assumptions), then asks "All requirements" or "Specific requirement(s)" to scope the session. For each requirement in scope, runs a five-pass confirmation (still-accurate / measurable / assumptions-still-hold / open-questions-resolved / INCOSE-quality), echoing the requirement back to the user, capturing edits, advancing status (Draft → Reviewed → Approved) only with explicit confirmation, and updating linked assumption and open-question entries. Appends a session log to docs/requirements/session-log.md. Companion to /requirements-create-from-design — that one elicits, this one refines. Use when the user says "confirm requirements", "review requirements", "validate requirements", "pressure-test what we have", "walk through the requirements", "go through each requirement", or wants to advance requirements from Draft to Reviewed.
---

# Confirming an existing requirements specification

This skill validates requirements that have already been written (by `/requirements-create-from-design` or by hand) and helps them advance through the status lifecycle. It is **highly interactive** and **edits files in place**. Every change requires user confirmation; nothing auto-advances silently.

## Why this skill exists

A requirement that was right when it was written may not be right now. Assumptions may have been validated or falsified. Open questions may have been answered. New edge cases may have surfaced. Stakeholders may have changed their minds. Without a periodic confirmation pass, the requirements doc rots — the team builds against a stale spec, and trust in the doc collapses.

## Operating mode

Same operating principles as `/requirements-create-from-design`:

- Small focused question batches.
- Echo each requirement back before discussing it.
- Capture every change in the right file (the requirement, `07-assumptions.md`, `08-open-questions.md`, `session-log.md`).
- Treat hesitation as signal — flag for further investigation rather than guessing.
- **Never auto-advance status.** Always ask before flipping Draft → Reviewed or Reviewed → Approved.

## Reference material the agent should consult

| File                                            | When to consult                                                      |
|-------------------------------------------------|-----------------------------------------------------------------------|
| `references/confirmation-playbook.md`           | The five-pass model. Question banks for each pass.                    |
| `references/status-lifecycle.md`                | Entry/exit criteria for each status. Session-log format.              |
| `references/incose-checklist.md`                | Per-requirement and set-level quality checks. Smell list.             |
| `references/example-confirmation-session.md`    | Worked before/after example of confirming FR-FILEVIEW-004.            |

The sibling `create-requirements` skill (same plugin) carries `example-worked-requirement.md` showing the full multi-file requirement set this confirmation example builds on — use as additional context: `../requirements-create-from-design/references/example-worked-requirement.md`.

## Prerequisites

1. **`docs/requirements/` exists** in the working directory. If it doesn't, stop and tell the user to run `/requirements-create-from-design` first.
2. **The doc has at least some content.** If `docs/requirements/` exists but every file is just the template stub, the user should keep eliciting before confirming — stop and suggest `/requirements-create-from-design` to continue.
3. **The user has time for the session.** Set expectation: 5–10 minutes per requirement walked carefully. A full pass on a 30-requirement project is 2–5 hours. Most sessions cover one file or a handful of requirements.

## Workflow

```text
Confirmation progress:
- [ ] Step 1: Inventory docs/requirements/
- [ ] Step 2: Show dashboard listing + status summary
- [ ] Step 3: Ask "All" or "Specific" + capture scope
- [ ] Step 4: For each in-scope requirement, run the five-pass model
- [ ] Step 5: Process side effects (assumption / open-question state changes)
- [ ] Step 6: Write the session log entry
- [ ] Step 7: Summary + handoff
```

### Step 1: Inventory `docs/requirements/` (and check `docs/architecture/`)

**First, if `docs/architecture/` exists, read it.** The architectural design is the context against which requirements are confirmed. If the architecture has changed since requirements were written (newer dates in `docs/architecture/04-decisions.md`, or open questions resolved/added in `docs/architecture/05-open-questions.md`), some requirements may now drift from the architecture — surface those during Pass 1 (still-accurate) of the confirmation.

If `docs/architecture/` doesn't exist, **flag it** — *"Confirmation pass running without an architectural reference. Consider running `/platform-design` after this session to capture the technical shape; many of the assumptions in this requirements set are likely architectural-shape assumptions."*

Then walk `docs/requirements/`. For each file, compute:

- **Functional requirement files** (`03-functional/*.md`): count requirements (`grep -c '^### FR-' <file>`), break down by status.
- **NFR files** (`04-non-functional/*.md`): count requirements (`grep -c '^### NFR-' <file>`), break down by status. Note any "Applies? No" files.
- **`01-goals-and-non-goals.md`**: count goals and non-goals.
- **`02-personas-and-journeys.md`**: count personas and journeys.
- **`07-assumptions.md`**: count entries (`grep -c '^### A-' <file>`) and break down by `Validation status:` (Unvalidated / In progress / Validated / Falsified).
- **`08-open-questions.md`**: count entries in the main section vs the "Resolved questions" section.
- **`09-risks.md`**: count entries by Status (Open / Mitigated / Realised / Closed).
- **`10-prioritisation.md`**: tally MoSCoW counts if the table is populated.

For each requirement, also identify "stale Drafts" — Draft requirements with no Status update in over 30 days (use `git log -1 --format=%at` per line or accept that this is best-effort).

### Step 2: Show the dashboard listing

Render an annotated tree to the user. Example:

```text
docs/requirements/
├── README.md
├── 00-overview.md
├── 01-goals-and-non-goals.md         [7 goals, 6 non-goals (4 Never, 2 Not-yet), 3 grey-area]
├── 02-personas-and-journeys.md       [3 personas, 5 journeys]
├── 03-functional/
│   ├── auth.md                       [8 reqs:  Reviewed=6  Draft=2 (stale: 1)]
│   ├── billing.md                    [12 reqs: Reviewed=10 Draft=2]
│   └── admin.md                      [5 reqs:  Reviewed=5]
├── 04-non-functional/
│   ├── performance.md                [4 reqs:  Reviewed=3  Draft=1]
│   ├── security.md                   [6 reqs:  Reviewed=6]
│   ├── reliability-availability.md   [Applies? No — recorded]
│   └── ... (other NFR files)
├── 05-data-and-integrations.md       [2 entities, 3 integrations]
├── 06-constraints.md                 [5 constraints: 2 tech, 1 legal, 2 budget]
├── 07-assumptions.md                 [12 assumptions: Unvalidated=8 Validated=3 Falsified=1]
├── 08-open-questions.md              [11 questions: Open=7 Resolved=4]
├── 09-risks.md                       [5 risks: Open=4 Mitigated=1]
└── 10-prioritisation.md              [MoSCoW: Must=8 Should=12 Could=5 Won't=4]
```

Highlight items worth attention (use plain prose under the tree, not the tree itself):

- "Stale Drafts (no update >30d): FR-AUTH-007. Worth a look."
- "Unvalidated assumptions: 8 of 12. High proportion — confirmation will spend time on these."
- "Open questions older than 14 days: OQ-003 (raised 2026-04-01)."

### Step 3: Ask "All requirements" or "Specific requirement(s)"

Use AskUserQuestion. The options should be:

1. **All requirements** — walk every requirement systematically, file by file, in numerical order. Fast-path Reviewed/Approved items ("Anything changed?" with a yes/no — only deep-dive on yes).
2. **Specific file** — drill into one file (e.g. `03-functional/auth.md`, or `04-non-functional/security.md`).
3. **Specific requirement(s)** — one or several requirement IDs (`FR-AUTH-003`, or `FR-AUTH-003, FR-AUTH-005`).
4. **Just the stale Drafts / open questions / unvalidated assumptions** — a triage-style sweep over only the items flagged in Step 2.

Capture the user's choice. If "Specific", ask for the file path or requirement ID(s) and read them back to confirm before proceeding.

If the user changes their mind mid-session ("can we also do billing while we're at it?"), accept and add to scope — don't make them restart.

### Step 4: Run the five-pass model

For each in-scope requirement, follow `references/confirmation-playbook.md`:

1. **Pass 1 — Still accurate?** Echo the Statement back. Ask if anything has changed.
2. **Pass 2 — Fit criterion measurable?** Ask how we would actually verify it.
3. **Pass 3 — Assumptions still hold?** For each linked `A-NNN`, ask if it's been validated/falsified since.
4. **Pass 4 — Open questions resolved?** For each linked `OQ-NNN`, ask if it's been answered.
5. **Pass 5 — Quality (INCOSE + smells)?** Apply the checklist from `references/incose-checklist.md`. Do a **hostile re-read** of the statement.

For **already-Reviewed** requirements in an "All" pass: short-circuit. Ask once: *"FR-AUTH-005 is at Reviewed. Anything changed since? Quick yes/no."* If yes — full five passes. If no — record "confirmed unchanged" in the session log and move on.

**Edits during a pass:**

- Refined statements, expanded fit criteria, added acceptance criteria, updated traces-to lines → edit the requirement file in place.
- Validated/falsified assumptions → edit `07-assumptions.md`. For Falsified, also re-read every requirement linked from the assumption and flag if any of them need to change.
- Resolved open questions → move the entry from the main section of `08-open-questions.md` to the **Resolved questions** section. Add resolution date, resolution text, resulting changes.
- New open questions → append to `08-open-questions.md` with a fresh `OQ-NNN` ID.
- New assumptions surfaced → append to `07-assumptions.md` with a fresh `A-NNN` ID.

**Status advancement:**

After all five passes succeed, ask explicitly: *"All passes clean. Ready to advance from Draft to Reviewed?"* — wait for an affirmative answer before changing the Status line. For Reviewed → Approved, the threshold is higher (see `status-lifecycle.md`); never auto-advance from a confirmation session.

### Step 5: Process cascade effects

Some changes ripple. After each requirement:

- If an assumption was **Falsified**, scan its `Linked requirements:` list. For each linked requirement: read it, ask if the falsification breaks anything. If yes, downgrade Status to Draft and queue for re-confirmation.
- If an open question was **Resolved** in a way that contradicts an existing requirement, flag for the user.
- If a requirement's priority changed, update `10-prioritisation.md`.

Don't fix cascade effects silently — surface them, let the user direct.

### Step 6: Write the session log

Create `docs/requirements/session-log.md` if it doesn't exist. Append an entry following the format in `references/status-lifecycle.md`:

```markdown
## Session YYYY-MM-DD HH:MM — Confirmation pass

**Scope.** All requirements | <file> | <requirement ID(s)>.

**Outcomes.**
- **Advanced:** FR-XXX (Draft → Reviewed), ...
- **Edited:** FR-YYY statement clarified; FR-ZZZ fit criterion replaced
- **Assumptions resolved:** A-NNN validated; A-MMM falsified (impacts FR-AAA, FR-BBB)
- **Open questions resolved:** OQ-NNN (...)
- **New open questions:** OQ-PPP (...)
- **New assumptions:** A-QQQ (...)
- **Confirmed unchanged (Reviewed already, no edits):** FR-RRR, FR-SSS

**Notes.** Anything worth a future reviewer knowing.
```

The session log is the audit trail. Do not skip this step.

### Step 7: Summary + handoff

Print a tight summary:

- Requirements walked, advanced, edited, confirmed-unchanged (counts).
- Assumptions resolved.
- Open questions resolved.
- New items added (open questions, assumptions).
- Cascade effects flagged.
- **Next-step pointer.** Three options to mention:
  - More confirmation in another session (good for spreading the load).
  - If the set is mostly Reviewed with stakeholder sign-off, the user might want to **baseline** — see `status-lifecycle.md`.
  - If the set is mostly Reviewed, the user can move to **architecture design** — the requirements set is the input.

Show the diff (`git status` + a summary of what changed) and let the user commit. Do not auto-commit.

## Strict non-goals for this skill

- **No new feature elicitation.** If the user wants to add features, point them at `/requirements-create-from-design`. This skill confirms what exists; eliciting is the other skill's job.
- **No silent edits.** Every requirement change is echoed back to the user; every status advancement is explicitly confirmed.
- **No auto-commit.** Show the diff; let the user commit.
- **No deletion of content.** Falsified assumptions stay (as learning record). Resolved open questions move within the file. Reworked requirement text is preserved in git history.
- **No bulk auto-promotion.** A confirmation pass surfaces *candidates* for promotion; the user advances them.

## Edge cases

- **`docs/requirements/` doesn't exist.** Stop and suggest `/requirements-create-from-design`.
- **`docs/requirements/` exists but is empty / all template stubs.** Stop and suggest `/requirements-create-from-design` to populate before confirming.
- **User asks to confirm a single requirement that doesn't exist.** Search for it case-insensitively (`grep -ri "FR-AUTH-003" docs/requirements/`). If found in a non-obvious file, surface the location and confirm. If not found, list close matches.
- **A confirmation surfaces a needed change that's bigger than a single requirement** ("this whole NFR category needs revisiting"). Stop the per-requirement pass, surface the systemic issue, and propose either continuing one-by-one or pausing the session and starting a fresh elicitation pass for that area.
- **Falsified assumption with many downstream requirements** (10+). Don't try to fix all of them in one session. Mark each linked requirement back to Draft, log the cascade in the session log, and propose a follow-up session focused on those Drafts.
- **Stale Drafts older than 90 days.** Surface them but don't auto-archive. Ask the user: "still relevant, or should we mark them Out-of-scope and move to `01-goals-and-non-goals.md`?"
- **User pushes back on a quality issue Pass 5 surfaces** ("that's a nit, leave it"). Respect it — but log the unresolved smell in the session log so the next reviewer sees it. The session log is the place for "we knew about this and decided to leave it".
- **No session-log.md yet.** Create it. First entry is the first session.
