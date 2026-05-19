---
name: ai-check-work
description: A deliberate "please just check your work carefully" second pass on whatever was just produced. Generic — works on code, plans, writing, analysis, designs, calculations, summaries, anything. Use whenever the user says "check your work", "check my work", "double-check this", "look this over", "did I miss anything", "review what you just did", "self-review", "is this right?", "go over this again", "audit this", or any variation of asking for a deliberate second pass. Reports findings specifically (what's wrong, where) so they're actionable. Doesn't redo the work, doesn't pedant on taste, doesn't request features. Stops after two passes — a third audit is a signal of stuckness, not of high standards. Backed by Madaan et al.'s Self-Refine research — a second-pass critique surfaces something worth changing roughly 80% of the time.
---

# Check your work

A deliberate second pass on whatever was just produced. The *"please just check your work carefully on this"* pattern catches things the first attempt missed about 80% of the time (Madaan et al., *Self-Refine*: https://arxiv.org/abs/2303.17651). This skill exists so the user doesn't have to type that phrase out every time.

## What to audit

Default: the most recent piece of work in the conversation — the code, the plan, the analysis, the message, the calculation, the summary. Whatever the user just received from you (or from themselves).

If it's genuinely unclear what to audit, ask the user in one line. Don't guess.

## How to audit

1. **Re-read the work with fresh eyes** — as if you were a critical reviewer who didn't produce it.

2. **Apply this internal prompt** before saying anything:

   > *Please just check this work carefully. Was the original ask fully met? Are there obvious mistakes, omissions, or things that would surprise the reader? If you were shipping this, would you ship it as-is? If not, what would you push back on?*

3. **Look for the classics:**
   - **Ask vs. reality** — does the work actually do what was asked? Re-read the original request and compare.
   - **Missing pieces** — something the user wanted that isn't there.
   - **Mistakes** — wrong numbers, broken logic, contradictions with earlier parts, references to things that don't exist.
   - **Half-finished bits** — placeholders, TODOs, "(to be filled in)", stub sections.
   - **Confusing or inaccurate wording** — claims that aren't quite true, sentences a reader would stumble on.
   - **Hand-waved parts** — places where the original pass skipped over something hard.
   - **If the work is test code, also check:**
     - Playwright/Cypress locator chains with multiple `.or()` — strict-mode violation candidates; they pass static review but throw at runtime when more than one element matches.
     - Assertions on text strings that recently moved elsewhere in the same diff — cross-reference with `git log -p -1` of UI source files.
     - Hardcoded literals (`getByText('Done')`) where the project recently changed the visible label — search the codebase for both old and new.

4. **Report findings** using one of the two formats below.

## Output

**Clean:**

```
Checked. No issues found.

(Optional: one or two specific things you verified — e.g. "re-ran the math; numbers add up" or "every section of the brief is addressed". Skip if there's nothing notable.)
```

**Defects:**

```
Found N issue(s):

1. <Specific issue with location — quote the text or point at the line/section>
2. <Specific issue>
...

Want me to fix them, or will you?
```

Each item must be **specific** — a reader should know exactly what to change without asking a follow-up. Not *"tighten the intro"* — *"the intro says X but the body on line 14 contradicts that"*.

## Don't

- **Don't redo the work.** Report; don't silently rewrite. If the user wants the issues fixed, they'll say so.
- **Don't pedant.** Stylistic taste, throwaway typos, debatable preferences — not issues. The bar is *"would this materially harm the result if shipped?"*
- **Don't request features.** *"Could be better"* isn't an issue. *"Doesn't do what was asked"* is.
- **Don't second-guess the original ask.** Check delivery against the stated intent. If the intent itself seems off, note it briefly as an observation — but don't refuse to audit.
- **Stop after two passes.** If issues remain after a second audit, the underlying work needs rethinking, not a third audit.
