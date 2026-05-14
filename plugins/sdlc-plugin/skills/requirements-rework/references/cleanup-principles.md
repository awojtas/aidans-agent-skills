# Cleanup Principles

How aggressive to be about deleting vs. archiving vs. keeping. The bias is **strongly toward deletion**. Document sprawl is a real cost — every artefact a future reader has to filter is a tax on every future session.

## The decision tree

```
Is the artefact still relevant?
├── Yes → Keep (Pass 2 / Pass 3 "Keep" bin)
└── No
    ├── Does it represent a decision worth remembering even though it's been reversed?
    │   ├── Yes → Archive (with a header explaining the posterity rationale)
    │   └── No
    │       ├── Is it a doc? → Delete (git history preserves it)
    │       └── Is it an issue? → Close (with a clear closure comment)
```

Most artefacts going through this tree end up at delete/close. That's the desired outcome.

## When deletion is correct (the default)

Delete a doc — don't archive — when **any** of these apply:

- The doc captured a feature/requirement that's no longer being built and there's no remarkable lesson to record.
- The doc was an early draft that's been superseded by a later version.
- The doc captured an experiment that didn't pan out and isn't going to be re-tried.
- The doc was created as a placeholder and never filled in.
- The doc captured a decision that's been reversed by a more recent decision documented elsewhere.

Reasoning:

- Git history preserves the file. `git log --diff-filter=D --name-only` finds deleted files. The content is one command away if anyone needs it.
- The session log captures *that* it was deleted and *why*. That's the durable record.
- `docs/archive/` is friction. Future readers see it, wonder if it's relevant, click in, read, decide it's not, move on. Multiply that by every reader and every archived file.

## When archive is correct (the exception)

Archive a doc only when **all** of these apply:

- The artefact captured a **significant decision** (architectural, strategic, regulatory) — not just a feature description.
- The decision was **reversed**, but the reversal itself is instructive — someone might ask "why didn't we do X?" and the answer is non-obvious without seeing the original analysis.
- The artefact contains **content that doesn't appear elsewhere** — not just a summary, but the actual reasoning, options considered, data examined.

Examples:

- ✅ A non-functional requirement document arguing for self-hosting that got reversed in favour of cloud — keep the original arguments, because someone in 18 months will ask "why aren't we self-hosting?" and the answer needs the original case.
- ✅ A goals document from before a major scope reframe — keep the original goals, because they show how the project's direction shifted.
- ❌ A functional requirement for a feature that's no longer being built. **Delete.** Git has it; the rework rationale captures the why; no future reader needs the original.
- ❌ An open question that turned out to be a non-question. **Delete.** Or, if you want a trail, leave a one-line entry in the Resolved section of `08-open-questions.md` instead.

## Archive format

When you do archive, follow this template strictly so the archive itself doesn't become sprawl:

**Path:** `docs/archive/<original-path>--archived-YYYY-MM-DD.md`

Example: `docs/archive/03-functional/file-view-toggle--archived-2026-05-13.md`

**Top-of-file header (always present, always above the original content):**

```markdown
> **Archived YYYY-MM-DD during rework session.**
>
> **Original location:** `docs/requirements/03-functional/file-view-toggle.md`
>
> **Why archived (not deleted):** [One concrete sentence with posterity value. Not "we put effort into it"; not "for reference"; something specific like "captures the original analysis arguing for self-hosting, useful context for the eventual revisit in 2027 when our DPA with the cloud provider expires".]
>
> **Rework rationale:** [Link or one-sentence summary of why the original is no longer current.]
>
> ---
>
> *Original content below, unchanged.*

[original content]
```

The header is the only modification. Don't edit the original content — the archive is meant to be a faithful snapshot, not a corrected one.

## Issue closure principles

Issues follow the same bias. Closed issues:

- Are recoverable. `gh issue reopen <number>` works any time.
- Are filterable. `gh issue list --state closed` shows them.
- Carry their full history (comments, PR links, labels, milestone, body) on close — no information is destroyed.

Therefore: **close, don't apply a `wontfix` label**. A `wontfix` label is sprawl: now your label filter has to exclude it, your saved searches need updating, and the label itself accumulates.

When closing an issue during rework, the closure comment must include:

1. **The rework session date** (e.g. "Closed during rework session 2026-05-13").
2. **The reason** — one sentence linking to the rework rationale.
3. **What replaced it, if anything** (e.g. "Superseded by #34" or "Requirement deleted; see session log").

Example closure comment:

```markdown
Closed during rework session 2026-05-13.

The renderer-extension list is now dynamic (read at build time from the renderer's JSON manifest) per the falsified assumption A-003. This task (manually confirming the static list) is no longer needed. Replacement work tracked in #41.
```

## What about the session log?

The session log (`docs/requirements/session-log.md`) is the **only** place where rework outcomes are durably enumerated for future readers. Every rework session appends a single entry capturing:

- Rework rationale (the Pass 1 finding).
- Requirements deleted (IDs).
- Requirements updated (IDs + one-line summary).
- Requirements archived (IDs + path + why).
- New requirements (IDs).
- Issues closed (numbers + one-line reasons).
- Issues updated (numbers + one-line summaries).
- Issues reopened (numbers + reasons).
- New issues (numbers).
- Assumptions flipped (IDs + Validated/Falsified).
- Open questions resolved/created (IDs).

That's the audit trail. No need to keep redundant per-file records.

## When in doubt

If you genuinely can't decide between delete and archive, ask: **"What would a reader find here in six months that they couldn't find anywhere else?"** If the answer is "nothing specific", delete. If you can name something specific (and the something is non-obvious), archive.

The honest answer is "nothing specific" 90%+ of the time. Lean into deletion.
