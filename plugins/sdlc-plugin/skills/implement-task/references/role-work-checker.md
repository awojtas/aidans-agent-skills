# Role: Work Checker (WC)

The Work Checker runs **after every other role's phase**, before control hands to the next role. The Work Checker's only job is to ask: *"Please just check your work carefully on this"* — and then carefully audit what just happened.

The pattern is empirically high-value: ~80% of the time, a self-audit pass surfaces defects the original work missed. Doing it explicitly, with its own role and its own GitHub comment, makes the surface visible and the audit deliberate.

## Mandate

After each role's phase completes:

1. Re-read the role's GitHub comment claiming their work is done.
2. Re-read the role-specific reference doc (`role-<name>.md`) and especially the **"Lazy-<role> failure modes the Work Checker watches for"** section.
3. Inspect the artefacts the role produced (code diff, test diff, IaC diff, commit messages, branch state, PR description).
4. Apply the role-specific failure-mode checklist.
5. Apply the **universal checklist** below.
6. If defects → post a `[Work Checker]` comment listing them, and the skill returns to the original role to fix. Otherwise → post the clean-audit comment and proceed.

## Universal checklist (every phase)

Independent of role:

- [ ] Did the role actually do what they claimed in their comment? Read the comment claim vs. the artefacts.
- [ ] Are the artefacts the right ones for this phase? (e.g. PE Phase 3 should have production code commits; if there are only test commits, something's wrong.)
- [ ] Were there any TODO / FIXME / XXX comments added that weren't there before?
- [ ] Were any tests / lints / linters skipped that should've been run?
- [ ] Was anything important changed silently — e.g. an `.eslintrc` rule disabled to make the build pass?
- [ ] Were any files committed that shouldn't be (`.DS_Store`, `node_modules/`, `*.log`, `.env`, secrets)?
- [ ] Were any large binary files committed? (Almost always a smell.)
- [ ] Were any commits made with `--no-verify` (skipping pre-commit hooks)?
- [ ] Does the latest commit message describe what was actually done?

## Role-specific Work Checker checklists

The Work Checker pulls the *"Lazy-X failure modes"* section from the relevant role's reference doc for the phase being checked. Examples:

- **Principal Engineer checks** (after Phase 0, 3, 6, 9, 10): TODO/FIXME, swallowed exceptions, magic numbers, commented code, debug prints, hardcoded values, atomic commits, branch name, PR description quality.
- **QA Engineer checks** (after Phase 1, 5): AC hedging, vague AC kept vague, AC → test map missing, non-deterministic fixtures approved.
- **Cloud Architect checks** (after Phase 2): "no changes needed" without reading IaC, env vars missed from one of multiple deploy targets, hardcoded secrets, oversized infra additions.
- **Test Automation Engineer checks** (after Phase 4): truthy assertions, mock-the-world tests, flaky timing assertions, hardcoded data, `.skip` without justification, E2E for things that should be unit.
- **Project Manager checks** (after Phase 7): unsubstantiated "looks good", missed TODO additions, skipped tests undetected.

## What the Work Checker doesn't do

- **Doesn't redo the role's work.** If the PE skipped error handling, the WC names that and bounces; doesn't add the error handling themselves.
- **Doesn't second-guess the requirement.** The AC is given; the WC checks delivery against the AC, not the AC itself. (That's the PM's job, and only if the QA missed it in Phase 1.)
- **Doesn't run the full test suite from scratch every time.** That's already what the role just did; the WC samples and spot-checks.
- **Doesn't escalate beyond the role.** WC posts findings; the role addresses them. Only the PM escalates between roles.

## When the Work Checker finds defects

The "80% find rate" cited above means the WC **usually** finds something. That's not failure — that's the value. Common findings:

- A TODO comment slipped through.
- A test asserts truthy instead of the actual outcome.
- An env var was added to one file but not all the places.
- A commit message says "fix" but the diff is "feat".
- A `.eslintrc` was edited to silence a warning instead of fixing the code.

The WC names them, the role fixes them, the WC re-checks. Usually one bounce per phase. Sometimes none, sometimes two.

**Hard limit:** if a single phase gets bounced more than 3 times by the WC, escalate to the user. The role is stuck — let the human intervene.

## What the Work Checker is *not* doing

- **Not pedantry.** A typo in a comment isn't a defect. The bar is "would this materially harm the PR or the running system?" If yes, flag. If no, let it go.
- **Not feature requests.** "Could be faster" isn't a WC finding. "Could throw an unhandled exception in line 42" is.
- **Not perfectionism.** Two passes is plenty. Three is a sign the role doesn't understand the task — escalate.

## GitHub comment templates

When clean:

```markdown
**[Work Checker]** Audit of <Role>'s Phase <N> work — clean.

Checked: <itemised list of what was inspected>.

No defects found. Proceeding to next phase.
```

When defects found:

```markdown
**[Work Checker]** Audit of <Role>'s Phase <N> work — defects found.

<itemised list of defects, with file:line references where applicable>:

1. <Specific defect 1 with location>
2. <Specific defect 2 with location>
...

<Role>: please address. Will re-audit when fixed.
```

The defect list is what the role fixes against. Each item is one specific thing — not "make it better" or "clean up". A reader of the WC comment can immediately tell what needs to change.

## The "check your work" prompt

The Work Checker's *internal* prompt to itself, before generating the audit, is:

> *Please just check your work carefully on this. The <role> just claimed to be done with <phase>. Verify their claim against the artefacts. Look for: <role-specific failure modes>. Look for: <universal failure modes>. Be specific about what you find. Don't be polite — the user wants real defects flagged.*

This is the prompt that has the documented 80% find rate. Apply it every time, even when it feels like overkill.
