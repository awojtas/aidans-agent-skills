---
name: rework
description: Course-corrects both the requirements (docs/requirements/) and the open GitHub issues when something discovered during early implementation invalidates the original plan. Conducts a discovery interview ("what triggered the rework?"), walks every requirement and every open issue to classify them (Keep / Update / Delete / Archive for docs; Keep / Update / Close / Reopen for issues), identifies new requirements or tasks that the new direction needs, shows the proposed change set as a single markdown document for explicit user approval, then executes — deleting docs that no longer apply (git history preserves them), closing irrelevant issues with clear closure comments (closed issues are recoverable), updating in place where the intent still holds, and creating new artefacts where there are gaps. Default behaviour is assertive cleanup — no document sprawl, no zombie issues, no memorabilia for routes not taken. docs/archive/ exists for genuine posterity value only, with a documented rationale. Appends a rework entry to docs/requirements/session-log.md as the durable audit trail. Use when the user says "rework this", "we need to change direction", "pivot", "course-correct", "this isn't going to work anymore", "redo the plan", "scrap that and...", or describes any kind of mid-implementation discovery that invalidates earlier requirements or tasks.
---

# Rework: course-correcting requirements and tasks

This skill is for the moment when the work begins, a discovery is made, and the original requirements or plan no longer fits. It updates both the requirements docs and the GitHub issues so the team is working from one truth again.

## Why this skill exists

Plans go stale. The most expensive failure mode isn't "the plan was wrong"; it's "the plan was wrong and we kept going anyway because no one synchronised the docs and the issues". That produces:

- Documents that disagree with the issues they spawned.
- Issues that implement assumptions the team has since abandoned.
- Stakeholders reading the requirements doc and getting a story that no longer matches reality.
- A backlog full of zombies — work that's not relevant but nobody dares close.

Rework is the explicit "everyone catches up to reality" step. It's interactive, assertive about cleanup, and produces a durable audit trail.

## Operating mode

- **Conversational.** The four-pass model (discovery → requirements → issues → gaps) is run as a conversation, not a generator.
- **Approval-gated.** No destructive operation runs without the user seeing and approving the proposed change set as a single markdown document.
- **Assertively clean.** Default is delete (docs) and close (issues). Archive only when there's specific posterity value. See `references/cleanup-principles.md`.
- **Cascade-aware.** A falsified assumption ripples through linked requirements; a closed issue may strand a linked PR; a deleted requirement may orphan tasks. The skill walks the cascade.
- **One change set per session.** If the user wants two unrelated reworks, surface that and ask them to do separate sessions.

## Reference material the agent should consult

| File                                            | When to consult                                                                |
|-------------------------------------------------|---------------------------------------------------------------------------------|
| `references/requirements-rework-playbook.md`                 | The four-pass model. When rework is the right tool vs. one of the other skills. |
| `references/cleanup-principles.md`              | Delete vs. archive vs. keep decision tree. Issue closure principles.            |
| `references/github-issue-management.md`         | `gh` CLI patterns for close/update/reopen/create with audit-trail comments.    |
| `references/example-rework-session.md`          | Worked example: narrow rework (dynamic-manifest discovery) — full session.     |

## Prerequisites

1. **`docs/requirements/` exists and has content.** If not, this is the wrong skill — point at `/requirements-create-from-design` to elicit requirements first.
2. **`gh` CLI authenticated with write access** to the repo. The skill closes/edits issues; without write access, only the doc side can run.
3. **Working directory is inside the target git repo.**
4. **The user can name the rework rationale in one or two sentences.** If they can't, push back — *"What did you discover? Be specific. We're not doing a rework on vague feeling."* Vague rationale produces vague rework.

## Workflow

```text
Rework progress:
- [ ] Step 1: Read current state (docs/requirements/ + open + recently closed issues)
- [ ] Step 2: Pass 1 — Discovery interview, capture rework rationale
- [ ] Step 3: Pass 2 — Walk every requirement, classify (Keep/Update/Delete/Archive)
- [ ] Step 4: Pass 2 (cont.) — Walk assumptions and open questions for cascade effects
- [ ] Step 5: Pass 3 — Walk every open issue, classify (Keep/Update/Close)
- [ ] Step 6: Pass 3 (cont.) — Check recently closed issues for any to Reopen
- [ ] Step 7: Pass 4 — Gap analysis (new requirements? new tasks?)
- [ ] Step 8: Show proposed change set; get explicit user approval
- [ ] Step 9: Execute requirement changes (in-place edits, deletions, archives)
- [ ] Step 10: Execute issue changes (close/update/reopen/create with audit comments)
- [ ] Step 11: Append session-log entry
- [ ] Step 12: Summary + handoff
```

### Step 1: Read current state

```bash
# All requirements files
find docs/requirements -type f -name "*.md"

# Open issues
gh issue list --state open --limit 200 --json number,title,labels,milestone,body,assignees

# Recently closed issues (in case rework reopens one)
gh issue list --state closed --limit 50 --json number,title,labels,milestone,closedAt,stateReason

# Issues with linked PRs — closing these needs care
gh search prs --state open --json number,title,body
```

Don't read everything into the conversation. Build an index — files, issue numbers, titles — and pull full content only when classifying a specific item.

### Step 2: Pass 1 — Discovery

**Open with a single, focused question:** *"What triggered the rework? One or two sentences."*

Do not read any files first. The user names the change in their own words. The agent then echoes it back as a captured rework rationale:

> *Captured rationale:* `<rework rationale paragraph>`
>
> *Is this firm? Anything still uncertain?*

If the user hedges ("maybe", "I think", "we might want to..."), stop. *"This sounds exploratory. Rework is for firm changes. Would you rather talk through it first without doing the rework?"*

If the rationale is firm, proceed.

### Step 3: Pass 2 — Requirement walk

For every requirement file under `docs/requirements/`, walk in numeric order:

1. **Goals + non-goals** (`01-goals-and-non-goals.md`) — does the new direction change any goal? Move any non-goal in or out? This rarely changes; surface what does.
2. **Personas + journeys** (`02-personas-and-journeys.md`) — sometimes a rework removes a user type entirely. Check.
3. **Functional requirements** (`03-functional/*.md`) — walk each `### FR-…` block. For each, classify into Keep / Update / Delete / Archive (the four bins in `rework-playbook.md`).
4. **Non-functional requirements** (`04-non-functional/*.md`) — same drill.
5. **Data + integrations** (`05-data-and-integrations.md`) — if an integration is dropped, the related entries go.
6. **Constraints** (`06-constraints.md`) — rare for rework to change these; surface what does.

For each requirement classified **Update** or **Delete**, capture *what specifically*. Don't generalise — "AC3 is now wrong" beats "this needs updating".

For each requirement classified **Archive**, demand explicit posterity justification per `cleanup-principles.md`. The default answer is no.

### Step 4: Pass 2 (cont.) — Assumptions and open questions

These are where the cascade lives.

**Assumptions** (`07-assumptions.md`): For every assumption, ask:

- Did the rework validate this assumption?
- Did the rework falsify it?
- For each falsified assumption, scan its `Linked requirements:` field — every linked requirement needs re-inspection (it may have already been caught in Step 3, but verify).

**Open questions** (`08-open-questions.md`): For every open question, ask:

- Did the rework resolve it? (Move to Resolved section with resolution.)
- Did the rework create new open questions? (Add them.)

### Step 5: Pass 3 — Open issue walk

For each open issue (from the inventory in Step 1), classify into Keep / Update / Close. The default for *"this no longer reflects what we're doing"* is **Close**, not Archive (issues don't archive) and not a `wontfix` label.

For each issue classified **Update**, capture the diff: which field changes (title / body / AC / labels / milestone / Blocked-by), and what to.

For each issue classified **Close**, capture the closure comment. It must include:
- *"Closed during rework session YYYY-MM-DD."*
- One-sentence reason linking to the rework rationale.
- Replacement, if any (`Replaced by #<new>` or `Requirement deleted; see session log`).

**Linked PRs.** Before approving an issue close, check whether the issue has open PRs linked. If yes, surface this to the user — closing while a PR is in flight needs a deliberate decision.

### Step 6: Pass 3 (cont.) — Reopen candidates

Walk recently closed issues. Did the rework's new direction bring any previously-dismissed need back? If yes, mark for Reopen with a comment explaining why.

This is usually a short list, often empty. Don't over-fish.

### Step 7: Pass 4 — Gap analysis

Now the existing-stuff assessment is complete. Ask: *what's missing?*

- **New requirements** the new direction needs that weren't captured? Draft them following the templates the `create-requirements` skill uses. If the gap is huge (>5 new requirements), stop and suggest a separate `/requirements-create-from-design` session — rework is for narrow corrections, not re-scoping.
- **New tasks (GitHub issues)** that didn't exist in the old plan? Draft them following the standard issue template, citing the rework session as the origin in their `Context` section.

### Step 8: Proposed change set + approval

Render the entire change set as one markdown document and show the user. Structure:

```markdown
# Rework session YYYY-MM-DD — proposed change set

## Rationale
<paragraph captured in Step 2>

## Requirements
- **Update:** <list with one-line summary each>
- **Delete:** <list>
- **Archive:** <list with posterity rationale each>
- **Create:** <list>

## Assumptions
- **Validated:** <IDs>
- **Falsified:** <IDs + new fact>

## Open questions
- **Resolved:** <IDs + resolution>
- **Created:** <IDs + question>

## GitHub issues
- **Close:** <number + reason>
- **Update:** <number + summary of diff>
- **Reopen:** <number + reason>
- **Create:** <title + phase + labels for each>

## Session log
A single entry will be appended summarising the above.

---

**Approve to execute?**
```

Wait for explicit affirmative (`yes`, `approved`, `do it`). Don't proceed on `sounds good` if the user hasn't said yes explicitly. Push back: *"Just to confirm — execute this exact change set?"*

If the user wants edits, accept and re-render. Iterate until approval.

### Step 9: Execute requirement changes

In this order:

1. **Update** existing files — in-place edits.
2. **Delete** files — `rm <path>` (or `git rm <path>` if the user prefers staging for commit). Git history preserves the content.
3. **Archive** files (rare) — `mkdir -p docs/archive/<dir>` then move + prepend the archive header per `cleanup-principles.md`.
4. **Create** new files — write following the templates.

Update `07-assumptions.md` and `08-open-questions.md` per Step 4.

### Step 10: Execute issue changes

Per `references/github-issue-management.md`:

1. **Close** issues — `gh issue close <num> --comment "..."` for each. If multiple share a closure reason (common), batch them with a `for` loop but use the same comment template.
2. **Update** issues — `gh issue edit <num> --body-file ...` and/or `--add-label` / `--remove-label` / `--milestone`. Add a comment per update explaining the change.
3. **Reopen** issues — `gh issue reopen <num> --comment "..."`. Update labels/milestone after.
4. **Create** new issues — `gh issue create ...`. Use the standard template; in the `Context` section include `Origin: Rework session YYYY-MM-DD` so future readers can trace it.

For dependency graphs in newly-created issues (Blocked-by / Blocks fields), do the two-pass create-then-link pattern from `github-issue-management.md`.

Before each batch of closes, surface the list one more time: *"About to close issues #<list>. Final confirm?"*

### Step 11: Session log entry

Append a single entry to `docs/requirements/session-log.md`:

```markdown
## Session YYYY-MM-DD HH:MM — Rework

**Rationale.** <one-paragraph rationale captured in Step 2>

**Outcomes.**
- **Requirements updated:** <IDs>
- **Requirements deleted:** <IDs>
- **Requirements archived:** <IDs + path each>
- **Requirements created:** <IDs>
- **Assumptions:** <ID → Validated/Falsified each>
- **Open questions:** <ID → Resolved/Created each>
- **Issues closed:** <number + one-line reason>
- **Issues updated:** <number + one-line diff>
- **Issues reopened:** <number + reason>
- **Issues created:** <number + title>

**Notes.** <Any context worth preserving — cascades caught, surprises, things to revisit.>
```

The session log is the durable audit trail. Future readers reconstructing "why does the doc say X when issue Y says Z" should find their answer here.

### Step 12: Summary + handoff

Print a tight summary to the user:

- Counts (requirements changed, issues changed) with deltas.
- Any items that need follow-up — for example, *"Falsified assumption A-003 was caught; one downstream requirement (FR-…) was updated to match. If you find more downstream effects later, a fresh `/requirements-validation` pass on the affected file will catch them."*
- Pointer to next step:
  - Resume implementation if the plan is now consistent.
  - `/tasks-create-from-requirements` if the rework created new requirements that need staging into issues (only if Pass 4 added many new requirements — typically not needed).
  - `/requirements-validation` if the rework left several requirements still Draft.

Show the diff (`git status`, `git diff`). Don't auto-commit — let the user review and commit.

## Strict non-goals

- **No silent destructive operations.** Every delete and every issue-close is named in the change set and approved before execution.
- **No archive-by-default.** Archive needs explicit posterity justification per `cleanup-principles.md`. The default for "no longer relevant" is delete.
- **No `wontfix` labels** on issues. Close them with a clear closure comment instead.
- **No new requirement elicitation from scratch.** If the rework triggers a need for wholesale new requirements, finish the rework narrowly and point the user at `/requirements-create-from-design` for the bigger conversation.
- **No code changes.** Rework is about docs and issues. Code changes are a downstream consequence — they happen in implementation sessions against the updated issues.
- **No `gh issue delete`.** Closure is the destructive operation; delete loses the audit trail.
- **No partial commits during execution.** Run the full execution batch; let the user commit the whole rework as one logical change in git.

## Edge cases

- **`docs/requirements/` is missing.** Stop and point at `/requirements-create-from-design`.
- **`gh` not authenticated.** Can do the doc side of the rework but not the issue side. Warn clearly; ask the user to authenticate and re-run if both are needed.
- **No open issues yet.** The rework is doc-only. Skip Pass 3; the workflow still works.
- **Issue has linked open PR.** Surface explicitly before closing — *"#X has an open PR #Y. Close PR first / merge PR first / leave issue open until PR resolved — which?"*
- **Rework rationale changes mid-session.** Stop. Resync. The rationale is the anchor for everything else; if it shifts, prior passes' classifications may be wrong.
- **User wants to bulk-classify everything as Delete** (e.g. *"just close all Phase 4 issues"*). Push back. Each issue gets a deliberate classification, with the reason captured. Bulk close is for the script-driven step 10, not for the assessment.
- **The change set is enormous** (rework touches > 50% of requirements). This is a smell — the requirements doc may have been wrong, not just stale. Surface to the user: *"This rework is touching more than half the doc. Are we sure rework is the right tool, or is this a re-scoping that needs `/requirements-create-from-design`?"*
- **The user wants to delete `07-assumptions.md` entries for falsified assumptions.** Don't. Falsified assumptions stay (as learning record). The Falsified status is the signal.
- **The user wants to delete `08-open-questions.md` Resolved entries.** Don't. Resolved questions are decision history.
