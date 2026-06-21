---
name: feedback-work
description: "Receives a batch of short feedback items from the user, builds a structured todo list, then either (A) implements every fix immediately — reading relevant code, committing, and merging to main — or (B) creates one GitHub issue per item under a shared milestone for another agent to action. Enters a silent listening mode by default until the user signals 'go'. Asks which mode to use (implement now vs. create issues) unless the user's opening prompt already specifies it. Also surfaces any documentation updates implied by the feedback. Trigger phrases: 'I have some feedback', 'collate my feedback', 'create issues from feedback', 'fix this feedback', 'I want to give you feedback about', 'keep listening until I say go'."
---

# Feedback work

Turns a batch of user feedback into action — either shipping fixes directly or creating a milestone of GitHub issues, whichever the user needs.

## The two modes

**Mode A — Implement now.** Work through every todo item sequentially: read the relevant code, implement the fix, commit, merge. Best for small/medium batches where the fixes are clear enough to act on immediately.

**Mode B — Create issues.** Create a GitHub milestone and one issue per todo item. Best when the fixes need deeper thought, involve other people, or should be handed to another agent.

Both modes share the same first three steps: listen → todo list → confirm. Only the action step differs.

---

## Workflow

### Step 1 — Enter listening mode

On invocation, read the user's opening prompt for two signals:

**Mode signal** (determines Step 4):
- "create GH issues" / "create issues" / "make tickets" → Mode B
- "implement" / "fix now" / "fix these" / "do it" → Mode A
- No signal → ask in Step 2

**Listen signal** (determines whether to wait):
- "wait for go" / "keep listening" / "don't do anything until" / "I'm going to keep giving you" → silent listening mode
- No listen signal → collect feedback inline as the user types

If **listening mode** is active: acknowledge in one line and nothing else.

> *"Ready — give me all the feedback. I'll wait for your go."*

Stay silent until the user signals done. Common done signals: "go", "that's it", "done", "that's all my feedback", "ok go ahead". Do not ask questions, prompt for more, or summarise while waiting — it breaks the user's flow.

---

### Step 2 — Confirm mode (if not already known)

After all feedback is received, if the mode was not clear from the opening prompt, ask once:

> **Mode A — Implement immediately:** I'll work through each item, implement the fixes, and commit and merge.
> **Mode B — Create GitHub issues:** I'll create a milestone and one issue per item, ready for another agent or a later session.
>
> Which do you prefer? (A or B)

Accept any clear signal: A, B, "implement", "issues", "do it now", "create them", etc.

---

### Step 3 — Build and confirm the todo list

Parse all feedback into a numbered, flat list:

- Group sub-items under a parent where the feedback naturally bundles them (e.g., multiple complaints about the same screen → one parent item with lettered sub-items).
- Write each item as a clear action, not a restatement of the complaint (e.g., "Replace em/en dash with hyphen on the home screen" not "user doesn't like the dash").
- Flag any item that implies a **documentation update** (new page, renamed feature, changed flow).

Show the full list and ask:

> *"Here's what I've got — anything missing or mis-read? Say go to proceed."*

Do not begin implementing or creating issues until the user confirms.

---

### Step 4A — Mode A: Implement immediately

Work through each item in order:

1. **Read context.** Read the relevant source files. If `docs/architecture/` exists, check it for any relevant decisions. If the item involves a UI/UX change and the `/frontend-design` skill is available, invoke it for that item.
2. **Implement.** Make the fix.
3. **Commit.** Use a conventional commit message that references the item number: e.g., `fix(home): replace em/en dash with hyphen [feedback 1]`. Use `[feedback N]` notation, not `#N` — GitHub interprets `#N` as an issue/PR reference and would create a spurious link.
4. **Merge to main.** Check whether the project uses branch protection before assuming a direct push is allowed — if branch protection is on, open a PR per item (or batch related items into one PR).
5. **Check off and continue.** If an item fails (file not found, ambiguous spec), note it and move on — don't stall the batch.

When all items are done, report:
- Items completed
- Items skipped and why
- Any follow-up needed

---

### Step 4B — Mode B: Create GitHub issues

**1. Create a milestone**

```bash
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  --field title="Feedback: <short topic from user context>" \
  --field description="<one-line summary of what this batch covers>"
```

**2. Create one issue per todo item**

For each item:
- **Title:** concise, imperative ("Add icons to Microsoft and Google sign-in buttons")
- **Body:** the original feedback verbatim, then a one-line interpreted acceptance criterion
- **Milestone:** the number returned from step 1
- **Labels:** apply existing repo labels that fit (`bug`, `enhancement`, `ux`, etc.) — do not invent new labels

Group lettered sub-items from the same parent into one issue with a checklist body, not separate issues.

**3. Report**

Show the milestone URL and the full list of created issues with their numbers. The milestone is the handoff — pass it to another agent or open it in the browser to work through later.

---

### Step 5 — Documentation updates

For every item flagged in Step 3 as implying a documentation update:

- **Mode A:** implement the doc change in the same commit as the code change.
- **Mode B:** create an additional GitHub issue under the same milestone titled "Docs: update <thing> to reflect <change>".

---

## Guardrails

- **Silent during listening mode.** No questions, no prompts, no summaries while collecting feedback. Save all ambiguities for the todo list review step.
- **Confirm before acting.** Never implement or create issues before the user confirms the todo list in Step 3.
- **Don't pad issues.** One clear item (or one parent with a checklist) per issue. If an item is ambiguous, write the issue with a question in the body rather than blocking on it.
- **Don't invent labels.** Read the repo's existing labels first; apply what fits. If nothing fits, leave labels blank.
- **Mode A: don't stall on one item.** Work in order, note failures, keep moving.
- **Mode A: respect branch protection.** Check before pushing directly to main. When in doubt, open a PR.
