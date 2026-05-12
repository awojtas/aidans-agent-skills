# Labels and Milestones

The skill applies a **minimal, intentional** label set and uses **milestones for phases**. Labels never carry phase information — that's what milestones are for.

## Why this separation

- **Milestones** are time-bounded grouping units that GitHub provides first-class UI for (progress bars, completion dates, filtering). They map naturally onto "Phase 1 — Foundation".
- **Labels** are cross-cutting categorisations that apply across phases. A `priority:high` task can exist in any phase; a `human-required` task can too. Mixing phases into labels makes both labels and milestones less useful.

If a task needs to move between phases, change its milestone. Don't relabel.

## The label set (8 labels — minimal)

### Priority

| Label              | Meaning                                                              |
|--------------------|----------------------------------------------------------------------|
| `priority:high`    | Blocks MVP. Without this, the release does not ship.                  |
| `priority:medium`  | Important. Causes friction or risk if missing, but shippable without. |
| `priority:low`     | Nice to have. First on the chopping block if scope tightens.         |

Mapping from MoSCoW (see `docs/requirements/10-prioritisation.md`):

- **Must** → `priority:high`
- **Should** → `priority:medium`
- **Could** → `priority:low`
- **Won't (this release)** → **no issue created**.

### Type

| Label     | Meaning                                                              |
|-----------|----------------------------------------------------------------------|
| `bug`     | Fixing broken behaviour. Almost never applies to a fresh plan from a clean requirements doc — bugs appear after code exists. |
| `chore`   | Infrastructure, setup, refactoring, dependency updates, CI changes. |
| `docs`    | Documentation work (README, AGENTS.md, `docs/` content).             |

No `feature` label — it would apply to most tasks and add noise. Untyped issues default to "feature work".

### Workflow

| Label             | Meaning                                                                  |
|-------------------|--------------------------------------------------------------------------|
| `human-required`  | A human has to do this (see `human-required-checklist.md`). Front-load.  |
| `blocked`         | Cannot start because a prerequisite task isn't done. Use the `Blocked by:` field in the issue body to link the blocker. Remove the label when the blocker closes. |

## Total: 8 labels

That's the whole set. Resist adding more.

**Anti-patterns the skill must refuse:**

- `phase:1`, `phase:2`, … — phases are milestones, not labels.
- `size:S`, `size:M`, `size:L` — time estimate goes in the issue body. Sizing as a label invites Goodhart's-law gaming.
- `feature`, `enhancement`, `improvement` — too vague; everything would carry one.
- `wip`, `in-progress` — that's GitHub's built-in PR/draft state, not a label concern.
- `good-first-issue`, `help-wanted` — fine for public OSS, irrelevant for solo / small-team work.

## Label colours (suggested)

`gh label create` accepts a hex colour. Suggested for visual scan-ability:

| Label              | Hex       | Why                                       |
|--------------------|-----------|--------------------------------------------|
| `priority:high`    | `B60205`  | Red — high-attention.                      |
| `priority:medium`  | `D93F0B`  | Orange — moderate-attention.               |
| `priority:low`     | `FBCA04`  | Yellow — low-attention.                    |
| `bug`              | `D73A4A`  | GitHub default red for bugs.               |
| `chore`            | `C5DEF5`  | Pale blue — neutral, infra.                |
| `docs`             | `0075CA`  | GitHub default blue for docs.              |
| `human-required`   | `5319E7`  | Purple — distinct so it pops in the list.  |
| `blocked`          | `1D76DB`  | Blue — stable indicator state.             |

The skill should `gh label create` each missing label with these colours.

## Milestones — naming and structure

### Naming pattern

`Phase <N>: <Theme>`

Examples:

- `Phase 1: Foundation`
- `Phase 2: Core Auth & Profile`
- `Phase 3: Billing`
- `Phase 4: Polish & Beta`
- `Phase 5: Public Launch`

Keep the theme short (under 30 chars). The phase number is what drives the task title prefix (`1.1`, `2.3`, etc.).

### Phase 1 is special

Always exists. Always majority-`human-required`. Reasoning in `human-required-checklist.md`.

If a project has zero foundation/setup work (rare — usually because `/repo-bootstrap` and `/repo-level-up` already ran), Phase 1 can be lighter, but it always contains the human decisions / accounts / secrets that the rest depend on.

### How many phases?

A useful plan typically has **3–7 phases**. Fewer than 3 means the plan isn't decomposed enough; more than 7 means the phases are too small and you're using them as labels.

If you find yourself with 8+ phases, consider:

- Are some phases really sub-phases of a larger theme? (e.g. "Phase 3: Billing — Schema" and "Phase 4: Billing — API" and "Phase 5: Billing — UI" → collapse to one "Phase 3: Billing" milestone.)
- Or, if the project really is that large, split into **releases** — only plan one release at a time. The current set of phases is for the release in flight.

### Due dates

Set a milestone `--due-date` when there's a real external deadline (event, regulatory date, customer commitment). Otherwise leave it open — false deadlines create noise.

### Description

Each milestone gets a short description (3-5 lines):

```
Foundation phase. Accounts, secrets, design decisions, and project scaffolding. Mostly human work — front-loaded so the AI doesn't stall waiting. Phase complete when all secrets are in place, design decisions are recorded, and Phase 2 can start unblocked.
```

## How the skill applies labels and milestones

When generating the plan, the skill:

1. **Checks existing labels.** `gh label list --json name --jq '.[].name'`. For each label in the standard set that's missing, `gh label create <name> --color <hex> --description <text>`.
2. **Checks existing milestones.** `gh api repos/:owner/:repo/milestones --jq '.[].title'`. For each phase milestone that's missing, `gh api repos/:owner/:repo/milestones --method POST -f title="Phase N: Theme" -f description="..."`.
3. **Creates issues** with `gh issue create --title "<title>" --body "<body>" --label "..." --milestone "Phase N: Theme"`.

If the user runs the skill twice, existing labels/milestones are skipped (no overwrite). Existing issues are detected by title-prefix match and surfaced for review before any duplicate is created.
