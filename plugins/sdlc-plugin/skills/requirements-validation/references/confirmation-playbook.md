# Confirmation Playbook

How to interactively pressure-test an existing requirement. Different from elicitation: the requirement already has a draft; the job is to confirm it still holds, surface what's changed, and decide whether status can advance.

## The five-pass model

For each requirement, run the agent through these five passes — **in order**. If a pass fails, log the issue and either fix in place or capture in `08-open-questions.md`. Don't advance status until all five passes succeed.

### Pass 1 — Still accurate?

Read the **Statement** verbatim back to the user. Ask:

- Does this still describe what the system should do?
- Has anything changed in the world (user needs, business goals, regulatory environment) that would change the statement?
- **Has the architecture changed?** If `docs/architecture/` exists, cross-check whether the requirement still fits the recorded architectural shape (hosting, components, integrations, stack). A requirement that assumed a serverless API may need an update if the project pivoted to a real-time hub, and vice versa.
- If the requirement were deleted today, what would break?

If the user pauses or says "actually, we should..." — capture the edit and re-read the new version.

If the architecture has drifted away from what the requirement assumed, this is a cascade signal — surface it. The requirement may need an Update, or a previously-accepted architectural decision may have invalidated a downstream requirement, and that needs a `/requirements-rework` rather than just a confirmation tweak.

### Pass 2 — Fit criterion is measurable?

Read the **Fit criterion**. Ask:

- Walk me through how we would actually measure this. What's the tool, the dataset, the threshold?
- Could two reasonable engineers disagree on whether this passes?
- For numeric criteria: where does the number come from? (Customer pain threshold, competitor benchmark, infrastructure limit?)

If the answer is vague — "it'll feel fast", "users will know" — the fit criterion is broken. Either replace it with a concrete metric, or downgrade the status to Draft and log an open question.

### Pass 3 — Assumptions still hold?

For every assumption ID linked from this requirement (search `07-assumptions.md` for the matching `A-NNN` entries):

- Read the assumption.
- Ask: has anything validated or falsified this since `<date raised>`?
- If validated: update `Validation status` to `Validated` and record the validation method that worked.
- If falsified: update to `Falsified`, add the new fact, and **trigger a re-read of the requirements that depend on it** — they may need to change.

If the requirement has no linked assumptions but the statement contains hedge words ("assuming users have...", "given typical traffic"), there's a buried assumption. Extract it as a new `A-NNN` entry.

### Pass 4 — Open questions resolved?

For every open-question ID linked from this requirement (search `08-open-questions.md` for the matching `OQ-NNN`):

- Read the question.
- Ask: has this been answered? What's the answer?
- If resolved: move the entry to the **Resolved questions** section of `08-open-questions.md`, recording resolution date and resolution. Update the requirement to remove the link and incorporate the resolution.
- If still open: ask what's blocking it and update the "Next step" or "Target resolve date".
- If the answer arrived but wasn't recorded: thank the user for catching it; record it now.

### Pass 5 — Quality (INCOSE) and smell check

Apply the INCOSE characteristics from `incose-checklist.md`:

| # | Test                  | Trigger to fix                                                   |
|---|------------------------|------------------------------------------------------------------|
| 1 | Necessary              | If removing the requirement would break nothing → delete it.     |
| 2 | Unambiguous            | Re-read pretending to be hostile. Can it be misread?             |
| 3 | Complete               | "...and other things", "etc.", "where appropriate" → enumerate.   |
| 4 | Singular               | "and" / "or" / commas hiding two requirements → split.            |
| 5 | Feasible               | Buildable within known constraints? If not — downgrade priority. |
| 6 | Verifiable             | Goes back to Pass 2.                                              |
| 7 | Traceable              | Link to ≥1 goal/journey/NFR/constraint? If orphan — investigate. |

Run the **smell list**:

- "user-friendly", "intuitive", "modern", "robust", "scalable" → fix
- "fast", "quickly", "soon" → replace with number
- "if possible", "when applicable", "where appropriate" → either required or not
- "and/or", "such as" → enumerate
- "the system" with no subject → who/what specifically?

## Conversational patterns

### The "still" question

After Pass 1, ask: *"What's changed for you since this was written?"* — often surfaces context the user wouldn't volunteer otherwise.

### The hostile re-read

For Pass 2: read the statement aloud (or echo it back in chat) and say *"Here's how someone could implement this to technically pass and still annoy users..."* — describe the worst-case minimum bar. If the user says "no, I meant..." — that "meant" is the missing fit criterion.

### The dependency trace

For Pass 3: *"This requirement assumes X. If X turned out to be wrong, what's the next thing that would have to change?"* — walks the user through the cost-of-being-wrong line in the assumption.

### The promotion question

After Pass 5 passes: *"Are you ready to move this from Draft to Reviewed?"* Don't auto-promote; the user has to say yes. Reviewed → Approved is even more deliberate — typically batched across a whole file or release.

## Where to record findings

Every confirmation session produces some combination of:

- **Edits** to the requirement file (statement refined, fit criterion added, AC expanded, status advanced).
- **Updates** to `07-assumptions.md` (validation status flipped, new assumptions extracted).
- **Updates** to `08-open-questions.md` (resolved → moved within file; new questions added).
- **A session summary** appended to a session log (see `status-lifecycle.md` for format).

Do **not** delete content. Falsified assumptions stay (as learning record). Resolved open questions move within the file (as decision history). Reworked requirements have prior text in git history — don't try to preserve "before" text inside the file.

## Sources

- INCOSE, *Guide for Writing Requirements*
- ISO/IEC/IEEE 29148:2018
- Volere atomic requirement shell — https://www.volere.org/
- RFC 2119 / RFC 8174
