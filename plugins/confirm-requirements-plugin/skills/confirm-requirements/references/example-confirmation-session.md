# Worked Example: Confirming FR-FILEVIEW-004

A before/after walkthrough of one confirmation session. The starting state is taken from `repo-requirements-plugin/skills/repo-requirements/references/example-worked-requirement.md` — the GitHub Preview/Code/Blame toggle case.

The session here picks up that requirement at **Status: Draft** with one linked open question (OQ-006: should tab switches collapse to a single history entry?), runs the five-pass model, and ends with the requirement at **Status: Reviewed** plus tidied assumptions and open questions.

---

## Before state

### `docs/requirements/03-functional/file-view-toggle.md` (extract)

```markdown
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

**Status.** Draft. *(AC3 depends on resolving OQ-006.)*

**Traces to:** Journey J-003; OQ-006.
```

### `docs/requirements/08-open-questions.md` (extract)

```markdown
### OQ-006: Should tab switches collapse to a single history entry, or behave like a navigation?

- **Raised.** 2026-05-12 by elicitation agent.
- **Linked.** FR-FILEVIEW-004 AC3.
- **Owner.** UX lead.
- **Next step.** Decide on browser-history behaviour. Two camps: (a) every tab click is a new history entry — back button reverses each switch; (b) tab switches replace the current history entry — back button leaves the file view entirely. Pick one; document with rationale.
- **Target resolve date.** Before FR-FILEVIEW-004 moves from Draft to Reviewed.
```

---

## Confirmation session

**Agent:** *We're looking at FR-FILEVIEW-004. Status is Draft, blocked on OQ-006. Let me read it back:*

> "The system SHALL update the URL to reflect the currently selected tab, such that copying the URL and re-opening it in a fresh browser session restores the same tab selection."

*Three quick checks first. Has anything changed about the URL-sharing use case since this was written? Any new constraints — e.g. from the analytics team about URL parameters?*

**User:** *Nothing's changed. Sharing links is still the primary need.*

**Agent:** *Good. Pass 1 clean.*

*Pass 2 — the fit criterion. Walk me through how we'd verify this. What's the test?*

**User:** *Headless browser. Click each tab. Inspect `window.location.href`. Confirm it changed. Then load the URL fresh in a new session, confirm the right tab is active.*

**Agent:** *Solid. One thing — the criterion currently says "single history entry". That depends on OQ-006 being resolved. Let me park Pass 2 there and jump to Pass 4.*

*Pass 4 — OQ-006. Has the history-entry question been decided?*

**User:** *Yes — we decided every tab click is a new history entry, so Back reverses each switch. Same as the discussion last Tuesday with the UX lead.*

**Agent:** *Got it. Recording the resolution. OQ-006 moves to the Resolved section in `08-open-questions.md`. AC3 of the requirement stays as-is because it already specifies the behaviour we just confirmed. The "(AC3 depends on resolving OQ-006)" note on the Status field can come off.*

*Back to Pass 2 now. The fit criterion says "single history entry per click" — that's measurable: count history entries before vs after a click; expect +1. Good.*

*Pass 3 — assumptions. A-004 says "Canonical URL form for Blame is `/blame/<ref>/<path>`". Validation status: Unvalidated. Has anyone confirmed this against the real URL scheme?*

**User:** *Yes — I checked. It's `/blame/<ref>/<path>`. Validated.*

**Agent:** *Updating A-004 to Validated, recording validation method "manual URL inspection on github.com, 2026-05-12". The AC1 reference to A-004 stays. And since A-004 is now a confirmed dependency of this requirement, I'll add it to the Traces-to line so it shows up in dependency walks.*

*Pass 5 — INCOSE + smell list.*

- *Necessary? Yes — Journey J-003 depends on it.*
- *Unambiguous? Hostile re-read: someone could implement "URL reflects selected tab" by setting only a hash fragment (`#blame`) — which would technically pass but wouldn't survive cross-session. Should we tighten?*

**User:** *Good catch. Tighten it.*

**Agent:** *I'll add to the fit criterion: "URL change must use pathname (e.g. `/blob/` ↔ `/blame/`) or a query parameter (e.g. `?view=blame`); pure hash-fragment changes do not satisfy this requirement."*

- *Singular? One requirement (URL state). ✓*
- *Verifiable? Yes — AC are concrete. ✓*
- *Traceable? Traces to J-003. Add NFR-A11Y-001 link? URL-reflective state helps screen-reader navigation. Add.*

**User:** *Sure.*

**Agent:** *Smell list — none triggered.*

*All five passes done. Ready to advance Status from Draft to Reviewed?*

**User:** *Yes.*

---

## After state

### `docs/requirements/03-functional/file-view-toggle.md` (extract)

```markdown
### FR-FILEVIEW-004: URL parameter reflects selected tab (deep linking)

**Statement.** The system SHALL update the URL to reflect the currently selected tab, such that copying the URL and re-opening it in a fresh browser session restores the same tab selection.

**Fit criterion.** Clicking each tab updates the URL via a single history entry (no back-button "trap"). URL change must use pathname (e.g. `/blob/` ↔ `/blame/`) or a query parameter (e.g. `?view=blame`); pure hash-fragment changes do not satisfy this requirement. Loading the same URL in a new tab/window restores the same selected tab.

**Rationale.** Sharing a link to a specific view (e.g. "look at this changelog rendered, on this line") is a primary user need. Without URL state, the link defaults to the renderable file's Preview, losing context.

**Priority.** Must.

**Acceptance criteria.**
- Given any file view `when` the reader clicks "Blame" `then` the URL changes to `/blame/<ref>/<path>` (see A-004).
- Given a URL with an explicit tab parameter `when` the reader loads it in a fresh browser session `then` the selected tab matches the URL.
- Given consecutive tab switches `when` the reader uses browser Back `then` they return to the previously selected tab (single history entry per click).

**Source.** Stakeholder interview — Aidan Wojtas, 2026-05-12.

**Status.** Reviewed (confirmed 2026-05-13).

**Traces to:** Journey J-003; A-004; NFR-A11Y-001.
```

Changes from before:

- Statement unchanged.
- Rationale unchanged (preserved as-is since it still describes the user need).
- Fit criterion **expanded** with the hash-fragment exclusion (caught in Pass 5 hostile re-read).
- AC1 reference to A-004 simplified to "(see A-004)" since A-004 is now Validated.
- Status advanced **Draft → Reviewed** with confirmation date.
- Traces-to: removed OQ-006 (resolved), added A-004 (now a validated dependency, was only in AC text before), added NFR-A11Y-001 (Pass 5 surfaced).
- Removed the *"(AC3 depends on resolving OQ-006)"* note.

### `docs/requirements/07-assumptions.md` (extract)

```markdown
### A-004: Canonical URL form for Blame is `/blame/<ref>/<path>`

- **Made by.** Stakeholder, 2026-05-12.
- **Date.** 2026-05-12.
- **Validation status.** Validated (2026-05-13, manual URL inspection on github.com).
- **Linked requirements.** FR-FILEVIEW-004.
- **What changes if wrong.** Validated. N/A.
```

### `docs/requirements/08-open-questions.md` (extract)

```markdown
## Resolved questions

### OQ-006: Should tab switches collapse to a single history entry, or behave like a navigation?

- **Raised.** 2026-05-12 by elicitation agent.
- **Resolved on.** 2026-05-13.
- **Resolution.** Decided: every tab click is a new history entry — Back reverses each switch. Rationale: matches user mental model of "Back undoes the last action".
- **Resulting changes.** FR-FILEVIEW-004 status advanced Draft → Reviewed. AC3 unchanged (already specified the chosen behaviour).
```

### `docs/requirements/session-log.md` (new entry)

```markdown
## Session 2026-05-13 14:20 — Confirmation pass

**Scope.** FR-FILEVIEW-004 (single requirement).

**Outcomes.**
- **Advanced:** FR-FILEVIEW-004 (Draft → Reviewed).
- **Edited:** FR-FILEVIEW-004 fit criterion expanded to exclude hash-fragment-only URL updates; traces-to updated.
- **Assumptions resolved:** A-004 validated.
- **Open questions resolved:** OQ-006 (every tab click is a new history entry).
- **New open questions:** none.
- **New assumptions:** none.

**Notes.** Hostile re-read in Pass 5 surfaced the hash-fragment edge case that wasn't addressed by the original fit criterion. Good catch — log as a smell-list pattern to watch ("URL state" requirements should always specify the *mechanism* of state, not just that state exists).
```

---

## Lessons from this example

1. **The hostile re-read paid off.** Pass 5 surfaced an implementation that would technically pass the original fit criterion while failing the actual intent. Always do it.
2. **Multi-pass interleaving is fine.** The agent jumped from Pass 2 to Pass 4 because Pass 2 was blocked on the same open question. Don't be rigid about order if a dependency is obvious.
3. **Status advancement requires explicit user confirmation.** Even with all five passes clean, the agent asked before flipping Draft → Reviewed.
4. **The session log is the audit trail.** Five months later, when someone asks "why does the URL use pathname not fragment?", the log + the resolved OQ-006 entry tell the whole story.
