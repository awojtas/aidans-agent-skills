---
name: requirements-delete
description: Removes or demotes a single requirement from an existing docs/requirements/ tree, with a full cascade-impact scan first. Asks whether the intent is full deletion or just demotion (lower MoSCoW priority, or moving to Won't). Scans every requirement, assumption, open question, fit criterion, and traces-to chain for references to the target so nothing else silently breaks. Surfaces any open or recently-closed GitHub issues that implement the requirement. Presents the full proposed change set for explicit approval before doing anything destructive. For when one requirement is no longer needed — not for plan-wide pivots (use /rework for those). Trigger phrases include "delete this requirement", "remove FR-X", "we don't need this requirement anymore", "drop this requirement", "demote this requirement", "lower the priority of this requirement".
---

Removes or demotes **one** requirement from an established `docs/requirements/` tree, after checking that nothing downstream silently breaks.

## When to use this skill vs others

- **One requirement no longer needed?** This skill.
- **A discovery invalidating the broader plan, with multiple requirements to revisit?** Use `/rework` — it cascades across the whole tree.
- **Just lowering confidence in a requirement (Approved → Draft)?** That's `/confirm-requirements`'s job, not this one.

## Workflow

1. **Read `docs/requirements/` and identify the target requirement.** The user typically names it by ID (`FR-AUTH-003`) or by paraphrase. Echo the full statement back so you're both pointing at the same thing.

2. **Ask: delete or demote?**
   - **Delete** — the requirement is removed from its file. Git preserves history; we don't need a `docs/archive/` entry unless the user explicitly wants posterity beyond git.
   - **Demote** — the requirement stays but its priority drops. Two flavours: lower the MoSCoW band (Must → Should → Could → Won't), or move from an Approved/Reviewed status back to Draft. Ask which.

3. **Cascade scan.** Search the whole `docs/requirements/` tree (and `docs/architecture/` if present) for **every** reference to the target. Don't restrict to a fixed list of fields — search broadly:
   - Other requirements' `traces-to` / `depends-on` / `blocked-by` / `related` lines.
   - Fit criteria that name the target requirement or rely on its behaviour.
   - Body text and rationales that mention the target by ID or by name.
   - Assumptions (`A-NNN`) whose justification rests on the target.
   - Open questions (`OQ-NNN`) that resolve against the target.
   - Goals / non-goals that the target was traceable to.
   - ADRs in `docs/architecture/04-decisions.md` (or equivalent) that cite the target.

   Show every hit to the user. Group by file.

4. **Functional impact judgement.** For each cascade hit, judge: would removing/demoting the target *break* this thing, or just leave a dangling reference?
   - **Breaks** — propose the fix-up (rewrite the dependent requirement, surface a new open question, mark the dependent for re-confirmation, etc.).
   - **Dangling reference only** — propose the edit to remove the now-stale reference.

5. **GitHub issues check.** Run `gh issue list --search "<target-id>"` (and check recently-closed too). Any issue that names the target in body, title, or as `Implements: <target-id>` is in scope. Show them. For each:
   - **Open + delete chosen** — propose closing with a comment explaining why.
   - **Open + demote chosen** — propose a comment updating the AC if priority change implies scope change.
   - **Recently closed** — likely no action; flag for awareness only.

6. **Proposed change set.** Show a single markdown doc covering:
   - Target ID + statement + chosen action (delete / demote).
   - Every cascade hit + the proposed fix.
   - Every GH issue + the proposed action.
   - Whether to archive (default: no — git preserves history; archive only with stated posterity reason).

   **Ask for explicit approval before executing.** Destructive actions don't happen on hunches.

7. **Execute on approval.**
   - **Delete** — remove the requirement block from its file. If the file becomes empty, ask before deleting the file itself.
   - **Demote** — edit the MoSCoW or Status field in place.
   - **Cascade fixes** — apply each approved edit. Mark any downstream requirement that now needs re-confirmation by adjusting its Status (e.g., Reviewed → Draft) and noting in its body that it was touched by this rework.
   - **GH issues** — `gh issue close`, `gh issue comment`, or `gh issue edit` per the approved plan.

8. **Session-log entry.** Append to `docs/requirements/session-log.md`:
   - Date, target ID + statement, action taken (delete / demote).
   - Every cascade fix applied.
   - Every GH issue closed / commented on.
   - Anything still outstanding (e.g., requirements that need user input later).

## Guardrails

- **One requirement per invocation.** If multiple are stale, either run the skill multiple times or use `/rework` if they're all part of a single direction-change.
- **No silent deletes.** The proposed change set in Step 6 is the gate — never skip straight to execution.
- **Don't delete a requirement that has open PRs implementing it.** Surface this before doing anything; ask the user how to handle (cancel the PR, complete it then close the issue, etc.).
- **Don't archive by default.** Git preserves history. Use `docs/archive/` only when the user gives a specific posterity reason (e.g., "we may revisit this in 12 months").
- **Demotion isn't free either.** If demoting a Must to a Should/Could affects whether downstream Musts are still achievable, flag it — sometimes the right answer is to demote multiple in step.

## Output

- The target requirement deleted or demoted.
- Cascade fixes applied across the tree.
- GH issues closed / commented as approved.
- `docs/requirements/session-log.md` updated.
- A short report to the user: what changed, what's now outstanding, anything they need to chase up (e.g., open PRs, dependent requirements that need re-confirmation).
