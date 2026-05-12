# Worked Example: Tasks from the File-View Toggle Requirements

A full plan generated from the GitHub Preview/Code/Blame toggle requirements in the `create-requirements` plugin's `example-worked-requirement.md`. Shows the staged numbering, phase decomposition, human-required front-loading, labels, and milestone structure.

**Input.** A `docs/requirements/` folder containing:

- 8 functional requirements (`FR-FILEVIEW-001` to `FR-FILEVIEW-008`) — see the `create-requirements` plugin example.
- 1 NFR (`NFR-PERF-003` — blame compute budget).
- Open questions OQ-005 (renderable extension list), OQ-006 (history-entry semantics — assumed resolved here), OQ-007 (SVG/Jupyter edge cases).
- Assumptions A-003 (renderable-types list), A-004 (canonical Blame URL — Validated), A-005 (Preview position-preservation best-effort).
- MoSCoW priorities: FR-001 through 005, 007 are Must; FR-006, 008 are Should.

**Output (proposed before user approval).**

---

## Labels to create (8)

`priority:high`, `priority:medium`, `priority:low`, `bug`, `chore`, `docs`, `human-required`, `blocked`.

## Milestones to create (5)

- **Phase 1: Foundation** — Decisions, design sign-off, dependencies. Mostly human.
- **Phase 2: Toggle Component** — The three-tab switcher itself; keyboard + ARIA semantics.
- **Phase 3: Code View** — Default tab content for non-renderable files.
- **Phase 4: Preview View** — Renderer integration, conditional tab visibility.
- **Phase 5: Blame View & Deep Linking** — Blame fetch + rendering, URL state, position preservation, special-file handling.

## Issues to create (22)

### Phase 1 — Foundation

| # | Title | Labels | Why human / Notes |
|---|-------|--------|-------------------|
| 1.1 | `[HUMAN] Decide on browser support matrix` | `priority:high`, `human-required`, `chore` | Decision drives test-target matrix in Phase 2. |
| 1.2 | `[HUMAN] Confirm canonical list of renderable file extensions (resolves OQ-005)` | `priority:high`, `human-required`, `chore` | Pull from renderer team; blocks FR-FILEVIEW-002 work in Phase 4. |
| 1.3 | `[HUMAN] Confirm Vercel-specific URL form for /blame (validates A-004 — already done in confirmation)` | `priority:high`, `human-required`, `chore` | Already Validated per confirmation session, but issue tracks closure. |
| 1.4 | `[HUMAN] Decide SVG and Jupyter Notebook toggle behaviour (resolves OQ-007)` | `priority:medium`, `human-required`, `chore` | Blocks FR-FILEVIEW-008 in Phase 5. |
| 1.5 | `Set up Playwright + axe-core test scaffolding` | `priority:high`, `chore` | Phase 2's tests depend on this. |
| 1.6 | `Add CI job: visual regression for tablist component` | `priority:medium`, `chore` | Catches a11y / styling regressions. |

### Phase 2 — Toggle Component

| # | Title | Labels | Implements |
|---|-------|--------|------------|
| 2.1 | `Implement Tablist component with three tabs (Code, Preview, Blame)` | `priority:high` | FR-FILEVIEW-001 |
| 2.2 | `Add keyboard navigation (Tab into list, ArrowKeys within, Home/End)` | `priority:high` | FR-FILEVIEW-007 |
| 2.3 | `Add ARIA tablist semantics + focus indicators` | `priority:high` | FR-FILEVIEW-007 (a11y subset) |
| 2.4 | `Hide / show tabs based on file capability (initial wiring, content comes later)` | `priority:high` | FR-FILEVIEW-002, FR-FILEVIEW-008 (visibility only) |

### Phase 3 — Code View

| # | Title | Labels | Implements |
|---|-------|--------|------------|
| 3.1 | `Wire up syntax-highlighting library and basic Code-tab render` | `priority:high` | FR-FILEVIEW-003 (Code-default branch) |
| 3.2 | `Add line numbers + line anchors` | `priority:high` | FR-FILEVIEW-003 (supporting) |
| 3.3 | `Default to Code tab for non-renderable file types` | `priority:high` | FR-FILEVIEW-003 |

### Phase 4 — Preview View

| # | Title | Labels | Implements |
|---|-------|--------|------------|
| 4.1 | `Integrate markdown renderer for Preview tab` | `priority:high` | FR-FILEVIEW-002 (content) |
| 4.2 | `Apply extension-list capability check (depends on Phase 1.2 outcome)` | `priority:high`, `blocked` | FR-FILEVIEW-002 |
| 4.3 | `Default to Preview tab for renderable file types` | `priority:high` | FR-FILEVIEW-003 |
| 4.4 | `Render renderable text-AND-renderable types per Phase 1.4 decision` | `priority:medium`, `blocked` | FR-FILEVIEW-008 (SVG/Jupyter branch) |

### Phase 5 — Blame & Deep Linking

| # | Title | Labels | Implements |
|---|-------|--------|------------|
| 5.1 | `Implement blame data fetch (per-line commit attribution)` | `priority:high` | FR-FILEVIEW-005 |
| 5.2 | `Render blame view with commit hash, author, relative date` | `priority:high` | FR-FILEVIEW-005 |
| 5.3 | `Add commit-message hover tooltip on relative-date column` | `priority:medium` | FR-FILEVIEW-005 (AC2) |
| 5.4 | `Enforce performance budget — p95 < 2s for 10k-line files` | `priority:high` | NFR-PERF-003 |
| 5.5 | `Implement URL state: /blob ↔ /blame; preserves selected tab across sessions` | `priority:high` | FR-FILEVIEW-004 |
| 5.6 | `Position-preservation on tab switch (best-effort for Preview)` | `priority:medium` | FR-FILEVIEW-006 |

---

## Sample issue body (issue 2.1 — full template)

```markdown
## What

Build the `<Tablist>` UI component with exactly three tabs in fixed order: Code, Preview, Blame. The component should expose props for which tabs are enabled (a tab can be hidden when its content isn't applicable for the file) and which tab is selected.

## Why now

Phase 2 starts the user-visible toggle work. FR-FILEVIEW-001 is the foundation — every other Phase 2-5 task assumes the tablist exists and is operable. Phase 1's decision on browser support (issue #X) drives the matrix this component is tested against.

## Definition of Done

- [ ] Code implemented per acceptance criteria.
- [ ] Tests added: unit (rendering + props), integration (in a file-view page).
- [ ] `axe-core` reports zero violations on the rendered component.
- [ ] Storybook entry or equivalent visual reference added.
- [ ] PR opened, self-reviewed, merged.

## Acceptance Criteria

- [ ] Given a file view with all three tabs enabled, when the page renders, then the three tabs appear in the order Code, Preview, Blame.
- [ ] Given a file view with only Code + Blame enabled (e.g. a `.go` file), when the page renders, then Preview is absent from the DOM.
- [ ] Given any rendered tablist, when the user inspects accessibility tree, then the component is announced as a tablist with three tabs, the correct one marked `aria-selected="true"`.

## Implements

- FR-FILEVIEW-001 — Three-state toggle on file view.

## Context

- **Phase / milestone:** Phase 2 — Toggle Component
- **Estimated effort:** 1 day
- **Blocked by:** #5 (1.5 Playwright + axe-core scaffolding)
- **Blocks:** #7 (2.2 keyboard), #8 (2.3 ARIA semantics), #9 (2.4 visibility wiring)
- **Requirement source:** [docs/requirements/03-functional/file-view-toggle.md](../docs/requirements/03-functional/file-view-toggle.md)
```

## Sample human-required issue body (issue 1.2)

```markdown
## ⚠️ Human Required

**Why human:** The canonical list of renderable file extensions lives in the renderer team's source. Confirming the list requires reading their source or a conversation — both human-shaped tasks. Resolves OQ-005 in `docs/requirements/08-open-questions.md`.

**Click-time estimate:** 30 minutes.

**Elapsed time estimate:** 1-2 days (depends on renderer team responsiveness).

**What to do:**

1. Find the renderer service's source repo or contact the renderer team.
2. Enumerate the file extensions / MIME types the renderer supports.
3. Update `docs/requirements/07-assumptions.md` A-003: Validation status → Validated; record the list.
4. Update `docs/requirements/08-open-questions.md` OQ-005: move to Resolved section with the resolution.
5. Update FR-FILEVIEW-002 in `docs/requirements/03-functional/file-view-toggle.md`: replace the `[A-003]` reference with the actual list, or keep the link if the list is too long to inline.

**Where to record outputs:**

- `docs/requirements/07-assumptions.md` updated.
- `docs/requirements/08-open-questions.md` updated.
- `docs/requirements/03-functional/file-view-toggle.md` updated.

## Why now

Phase 1 — Phase 4 issue #X (4.2 "Apply extension-list capability check") cannot start until this is resolved.

## Definition of Done

- [ ] Renderable-extension list confirmed.
- [ ] A-003 marked Validated.
- [ ] OQ-005 moved to Resolved.
- [ ] FR-FILEVIEW-002 updated.

## Context

- **Phase / milestone:** Phase 1 — Foundation
- **Estimated effort:** 30 min click-time; 1-2 days elapsed.
- **Blocks:** #11 (4.2 capability check)
- **Requirement source:** [docs/requirements/08-open-questions.md](../docs/requirements/08-open-questions.md)
```

---

## What this example demonstrates

1. **Phase 1 is mostly human (4 of 6 tasks).** The human can batch them — half a day of focused click-work resolves everything.
2. **AI tasks in Phase 1 (1.5, 1.6) don't depend on human tasks.** They run in parallel, so the AI doesn't sit idle.
3. **Phase 2 has zero human tasks.** All decisions are made; all dependencies are in place.
4. **Issues 4.2 and 4.4 carry the `blocked` label** because they explicitly depend on Phase 1 human decisions. The `Blocked by:` field names the blocker.
5. **Staged numbering reads as a sequence.** Reading the titles top-to-bottom tells the story of the build.
6. **Labels are sparse.** Most issues have 1–2 labels. The minimal set keeps the issue list scannable.
7. **No phase labels.** Phase information is exclusively in the milestone and the title prefix.
8. **Bug label is absent.** Bugs emerge from real code; the plan from a fresh requirements doc shouldn't pre-create them.
9. **`Implements:` traces back to the requirement.** Every issue can be traced to one or more requirement IDs, so when a requirement changes the affected issues are findable.
10. **Estimates are honest.** Human tasks distinguish "click-time" from "elapsed-time" — important for batching expectations.
