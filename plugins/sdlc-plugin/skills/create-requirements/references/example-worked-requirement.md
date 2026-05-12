# Worked Example: GitHub's File-View Toggle (Preview / Code / Blame)

A fully-worked, multi-file example showing what the skill produces *after* an elicitation conversation. Reference this when the user asks "what will the output look like?", or when the agent needs a concrete pattern to emulate.

**The feature.** On any file view in GitHub (e.g. `https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md`) a three-state toggle lets the reader switch between:

- **Code** — raw source with syntax highlighting + line numbers.
- **Preview** — rendered output (only available for renderable file types: Markdown, AsciiDoc, etc.).
- **Blame** — line-by-line annotation showing the last commit that touched each line.

The example below shows the requirements that the skill would produce after a 20-minute interview about this feature. Multiple files; cross-referenced; assumptions and open questions captured.

> **This is an example, not a generator.** The skill must not *produce* these files automatically from the README. They were produced by the agent asking questions, echoing answers back as draft statements, and iterating with the user. Use this example to show the user what a populated requirement looks like, then earn the content through conversation.

---

## File 1 — `docs/requirements/03-functional/file-view-toggle.md`

```markdown
# Functional — File-View Toggle

## Scope of this domain

The three-state toggle (Preview / Code / Blame) at the top of every individual file view. Covers tab availability, default tab selection, switching behaviour, URL/deep-link reflection, and position preservation. Does **not** cover the file view's surrounding chrome (breadcrumb, raw button, edit button) or the contents of each individual view beyond what the toggle interaction guarantees.

## Requirements

### FR-FILEVIEW-001: Three-state toggle on file view

**Statement.** The system SHALL display a three-state toggle ("Code", "Preview", "Blame") at the top of every individual file view for files tracked in the repository's default or selected branch.

**Fit criterion.** Loading any `/blob/<ref>/<path>` URL renders a toggle component containing exactly three tabs in the order: Code, Preview, Blame.

**Rationale.** Readers need to switch between source, rendered, and history views without leaving the file context. Goal G-002 ("Make file inspection a single-page workflow").

**Priority.** Must.

**Acceptance criteria.**
- Given a tracked text file `when` the reader loads its `/blob/<ref>/<path>` URL `then` the toggle is present and shows three tabs in the documented order.
- Given a binary file (image, PDF, archive) `when` the reader loads its file URL `then` the toggle is hidden or shows only the applicable tabs (see FR-FILEVIEW-008).

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** Goal G-002; Journey J-003 ("Inspect a changelog entry"); NFR-A11Y-001 (toggle keyboard-navigable); NFR-PERF-001 (toggle render budget).

---

### FR-FILEVIEW-002: Preview tab is conditional on file renderability

**Statement.** The system SHALL show the "Preview" tab **only** for file types the renderer supports (currently: Markdown `.md`, `.markdown`; AsciiDoc `.adoc`, `.asciidoc`; reStructuredText `.rst`; Jupyter Notebook `.ipynb`; CSV/TSV; geometric formats — see [A-003] for the source-of-truth list).

**Fit criterion.** For a file of an unsupported extension, inspecting the rendered toggle shows only "Code" and "Blame" — no Preview tab DOM element is present.

**Rationale.** Showing a non-functional Preview tab is worse than hiding it; users click and get an error. Goal G-004 ("zero broken interactive elements").

**Priority.** Must.

**Acceptance criteria.**
- Given a file with extension `.md` `when` the file view loads `then` the Preview tab is present and labelled "Preview".
- Given a file with extension `.go` (or any non-renderable type) `when` the file view loads `then` the Preview tab is absent from the DOM.
- Given a file with no extension and no detectable renderer `when` the file view loads `then` the Preview tab is absent.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Notes / open questions.** The exact set of renderable extensions is captured in `07-assumptions.md` as A-003. Resolving the canonical list is OQ-005 in `08-open-questions.md`.

**Traces to:** A-003; OQ-005; NFR-PERF-002 (renderer must complete inside performance budget).

---

### FR-FILEVIEW-003: Default tab on first view

**Statement.** The system SHALL select the "Preview" tab by default when the file is renderable, and the "Code" tab otherwise.

**Fit criterion.** On a fresh page load of a `.md` file with no tab parameter in the URL, the rendered output (not source) is visible above the fold. On a `.go` file, the syntax-highlighted source is visible above the fold.

**Rationale.** Readers of prose-format files (READMEs, changelogs) almost always want the rendered output; readers of code files want the source. Default to the high-frequency case.

**Priority.** Must.

**Acceptance criteria.**
- Given a `.md` file `when` the reader loads its `/blob/<ref>/<path>` URL with no tab parameter `then` Preview is the selected tab.
- Given a `.go` file `when` the reader loads its file URL with no tab parameter `then` Code is the selected tab.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** Goal G-002; FR-FILEVIEW-002.

---

### FR-FILEVIEW-004: URL parameter reflects selected tab (deep linking)

**Statement.** The system SHALL update the URL to reflect the currently selected tab, such that copying the URL and re-opening it in a fresh browser session restores the same tab selection.

**Fit criterion.** Clicking each tab updates the URL via a single history entry (no back-button "trap"). Loading the same URL in a new tab/window restores the same selected tab.

**Rationale.** Sharing a link to a specific view (e.g. "look at this changelog rendered, on this line") is a primary user need. Without URL state, the link defaults to the renderable file's Preview, losing context.

**Priority.** Must.

**Acceptance criteria.**
- Given any file view `when` the reader clicks "Blame" `then` the URL changes to `/blame/<ref>/<path>` (or equivalent canonical form — see A-004).
- Given a URL with an explicit tab parameter `when` the reader loads it in a fresh browser session `then` the selected tab matches the URL.
- Given consecutive tab switches `when` the reader uses browser Back `then` they return to the previously selected tab (single history entry per click).

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Draft. *(Acceptance criterion 3 — single history entry — depends on resolving OQ-006.)*

**Traces to:** Journey J-003; OQ-006.

---

### FR-FILEVIEW-005: Blame view shows per-line commit attribution

**Statement.** The system SHALL, when the Blame tab is selected, render each line of the file alongside the commit, author, and relative date of the most recent commit that touched that line in the selected ref's history.

**Fit criterion.** Inspecting the rendered Blame view shows, for every line, a clickable commit hash, an author name or handle, and a relative date (e.g. "3 weeks ago"). Hovering reveals the commit message subject line.

**Rationale.** Forensic and reading workflows — "who changed this and why" — are the primary purpose of blame. Without per-line attribution, the tab is decorative.

**Priority.** Must.

**Acceptance criteria.**
- Given a file with a multi-author history `when` Blame is selected `then` each line shows commit hash + author + relative date.
- Given hovering the relative date `when` the tooltip appears `then` it shows the absolute date in ISO-8601.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** Journey J-004 ("Trace a regression to its commit"); NFR-PERF-003 (blame compute time for large files).

---

### FR-FILEVIEW-006: Position preservation across tab switches

**Statement.** The system SHOULD preserve the reader's vertical position (the line currently in view) when switching between Code and Blame tabs.

**Fit criterion.** Scrolling to line 200 in Code view, then clicking Blame, places line 200 in roughly the same on-screen position (within ±20px after rendering).

**Rationale.** Forces the reader back to top on every switch makes blame-on-the-fly unusable for files longer than a screen. Reduces UX friction (Goal G-003).

**Priority.** Should.

**Acceptance criteria.**
- Given the reader is scrolled to line N `when` they switch tabs `then` line N remains in the visible viewport.
- Given the reader is scrolled to line N in Code `when` they switch to Preview `then` position preservation is *best-effort* (rendered HTML may not map 1:1 to source lines — see A-005).

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** A-005.

---

### FR-FILEVIEW-007: Toggle is keyboard-operable

**Statement.** The system SHALL allow the reader to switch tabs using keyboard alone, with focus indicators visible at all times and tab semantics conveyed to assistive technology.

**Fit criterion.** Using only the keyboard, the reader can reach the toggle (Tab key), switch tabs (Enter, Arrow keys, or both — per WAI-ARIA Authoring Practices for tab patterns), and observe an OS-level focus indicator. NVDA / VoiceOver announce the toggle as a tablist with three tabs.

**Rationale.** WCAG 2.2 AA conformance (NFR-A11Y-001). Mouse-only toggles are a recurring accessibility regression.

**Priority.** Must.

**Acceptance criteria.**
- Given a screen-reader user `when` they navigate to the toggle `then` it is announced as a tablist with the current tab's role, label, and selected state.
- Given a keyboard-only user `when` they press Tab to reach the toggle, then ArrowRight `then` focus moves to the next tab and ArrowRight on the last tab wraps to the first.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** NFR-A11Y-001; NFR-A11Y-002 (focus visibility).

---

### FR-FILEVIEW-008: Toggle behaviour for non-text files

**Statement.** The system SHALL hide the Preview and Code tabs for binary files where neither view is meaningful (e.g. raw archives), and SHALL show only the applicable tab(s) for files where one view is meaningful (e.g. images: Preview only).

**Fit criterion.** Loading an image file's URL shows the rendered image and no Code tab. Loading a `.zip` URL shows neither Preview nor Code — only the download/raw affordance and (if tracked) the Blame tab.

**Rationale.** Tabs that can't function are worse than no tab. Goal G-004.

**Priority.** Should.

**Acceptance criteria.**
- Given a `.png` file `when` its URL is loaded `then` only Preview (image render) and Blame are shown.
- Given a `.zip` file `when` its URL is loaded `then` no Code or Preview tab is shown.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Draft. *(Edge cases for SVG and Jupyter Notebook — text-but-renderable — pending OQ-007.)*

**Traces to:** OQ-007.
```

---

## File 2 — Extract from `docs/requirements/01-goals-and-non-goals.md`

```markdown
## Non-Goals

| #     | Non-goal                                                    | "Not yet" or "Never" | Why                                                                     |
|-------|--------------------------------------------------------------|----------------------|-------------------------------------------------------------------------|
| NG-010 | Editing the file in-place from any of the three tabs        | Never                | Editing has its own affordance ("Edit" button → editor view). Conflating views with edit modes confuses users and complicates conflict detection. |
| NG-011 | Running/executing code from the Code tab                    | Never                | This is a viewer, not a sandbox. Execution belongs to GitHub Codespaces / Actions, not the file view. |
| NG-012 | Diffing two versions inside the toggle                      | Never                | Compare view (`/compare/<a>...<b>`) is a separate workflow with its own URL. The toggle is single-ref. |
| NG-013 | Preview for non-renderable text types (e.g. `.go`, `.py`)   | Never                | The Code tab already provides syntax-highlighted source; "rendering" code adds no value. |
| NG-014 | Customising default tab per user                            | Not yet              | Adds personalisation complexity. Revisit after we have data on switching frequency by type. |
| NG-015 | Persisting the last-used tab across files                   | Not yet              | Cross-file state is a navigation footgun (users land on Blame for unrelated files). May revisit. |

### Grey-area items

| Assumed feature                                  | Status                | Notes                                                                                |
|---------------------------------------------------|-----------------------|--------------------------------------------------------------------------------------|
| Inline rendered preview for `.svg` files          | In-scope              | SVG renders as image (Preview tab). Confirmed FR-FILEVIEW-008 acceptance criteria.   |
| Diff view inside Blame ("see what this commit changed") | Out-of-scope (Never) | Blame links to commit; commit page is the diff context. See NG-012.               |
| Search-within-file from the toggle area           | Out-of-scope (Not yet)| Search has its own affordance; not on the critical path of the toggle.              |
```

---

## File 3 — Extract from `docs/requirements/07-assumptions.md`

```markdown
### A-003: The set of renderable file types is fixed at design time

- **Made by.** The elicitation agent, 2026-05-12.
- **Date.** 2026-05-12.
- **Validation status.** Unvalidated.
- **Validation method.** Confirm with the rendering team / read the source code of the renderer to enumerate supported types.
- **Linked requirements.** FR-FILEVIEW-002.
- **What changes if wrong.** If the renderable type list is dynamic (e.g. plugin-loaded), FR-FILEVIEW-002's fit criterion becomes inadequate — we need to test against a dynamic capability check rather than a static extension allow-list.

### A-004: Canonical URL form for Blame is `/blame/<ref>/<path>`

- **Made by.** Stakeholder, 2026-05-12.
- **Date.** 2026-05-12.
- **Validation status.** Unvalidated.
- **Validation method.** Inspect GitHub's actual URL patterns for the Blame view.
- **Linked requirements.** FR-FILEVIEW-004.
- **What changes if wrong.** FR-FILEVIEW-004's fit criterion ("URL changes to `/blame/<ref>/<path>`") becomes wrong. The requirement still holds in spirit (URL reflects tab) but the specific URL string in the AC needs editing.

### A-005: Preview position-preservation is best-effort only

- **Made by.** Stakeholder, 2026-05-12.
- **Date.** 2026-05-12.
- **Validation status.** Validated. *(Confirmed by user: "rendered HTML doesn't map to source lines, so exact preservation isn't possible.")*
- **Linked requirements.** FR-FILEVIEW-006.
- **What changes if wrong.** N/A — validated. Captured for traceability.
```

---

## File 4 — Extract from `docs/requirements/08-open-questions.md`

```markdown
### OQ-005: Canonical list of renderable file extensions

- **Raised.** 2026-05-12 by elicitation agent.
- **Linked.** FR-FILEVIEW-002 (Status: Reviewed, but extension list is in A-003 not in the requirement).
- **Owner.** Tech-lead, rendering subsystem.
- **Next step.** Pull the supported-extension list from the renderer source; either update FR-FILEVIEW-002 with the explicit list or accept A-003 as the source of truth and link from the requirement.
- **Target resolve date.** Before architecture-phase kickoff.

### OQ-006: Should tab switches collapse to a single history entry, or behave like a navigation?

- **Raised.** 2026-05-12 by elicitation agent.
- **Linked.** FR-FILEVIEW-004 AC3.
- **Owner.** UX lead.
- **Next step.** Decide on browser-history behaviour. Two camps: (a) every tab click is a new history entry — back button reverses each switch; (b) tab switches replace the current history entry — back button leaves the file view entirely. Pick one; document with rationale.
- **Target resolve date.** Before FR-FILEVIEW-004 moves from Draft to Reviewed.

### OQ-007: Toggle behaviour for SVG and Jupyter Notebook

- **Raised.** 2026-05-12 by elicitation agent.
- **Linked.** FR-FILEVIEW-008.
- **Owner.** UX lead.
- **Next step.** SVG is text-AND-renderable (XML source + visual render). Jupyter Notebook is JSON-AND-renderable (raw JSON + executed cells). Should both tabs (Code + Preview) be shown for these? Likely yes — confirm.
- **Target resolve date.** Before FR-FILEVIEW-008 moves from Draft to Reviewed.
```

---

## File 5 — Extract from `docs/requirements/04-non-functional/performance.md`

```markdown
### NFR-PERF-003: Blame compute time for typical files

**Statement.** The system SHALL render the Blame view for files up to 10,000 lines and 5,000 commits of history within a p95 latency of 2 seconds from request to first contentful paint.

**Fit criterion.** Measured by synthetic monitoring against a representative file set: p95 of `time-to-first-blame-line` < 2,000 ms over a 24-hour window. Steady state of 50 req/s.

**Rationale.** Blame on large files is a known slow path; without a budget, it tends toward 10+ seconds and users abandon the view. Goal G-002 ("single-page workflow") fails if any tab is unusable.

**Priority.** Must.

**Verification method.** Synthetic monitoring + load test.

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed.

**Traces to:** FR-FILEVIEW-005; Goal G-002.
```

---

## How to use this example with the user

When the user asks *"what will the output look like?"* — show them this file (or a relevant excerpt).

When the agent is drafting its first real requirement during an interview — pattern-match against the **FR-FILEVIEW-001** shape: short title, single SHALL/SHOULD statement, fit criterion, rationale tracing to a goal, priority, Given–When–Then acceptance criteria, source line, status, traces-to line.

**What this example deliberately does *not* show:**

- A `LICENSE`-style legal section. Requirements docs are not legal docs.
- Implementation detail (CSS classes, HTML structure, framework choice). Those belong in the architecture document.
- Test code. Acceptance criteria are *executable specifications*, not test scripts.

If you find yourself writing any of those in a requirements doc, stop and move them to the appropriate downstream artefact.
