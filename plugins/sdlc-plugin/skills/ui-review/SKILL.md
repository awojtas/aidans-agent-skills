---
name: ui-review
description: "Opinionated, evidence-based review of a running UI's visual/UX quality, organized around 'deliberate design choice, or leftover tool default?' MUST see the rendered app (chrome-devtools MCP or the repro-visual harness); warns and gets consent before going static-only. Runs a deterministic anti-slop pre-scan (npx impeccable detect), measures computed styles instead of eyeballing (contrast, type scale, spacing), exercises hover/focus/loading/empty/error states across breakpoints and dark mode, then fans out judgment lenses (Nielsen heuristics, visual craft, state/responsive completeness, accessibility, AI-slop catalogue) into a verified synthesis ending in a ruthless Critical/High/Medium/Low action list. Read-only; offers issues or a report after. Use when the user says 'UI review', 'design review', 'review the UI', 'does this look AI-generated', 'design QA', or 'why does my app look generic'. Reviews rendered design quality — not component reuse (ui-component-review), not creating UI (frontend-design)."
---

# UI review

Review the **visual and UX quality of a running UI** — opinionated, evidence-based, anti-slop. Findings are backed by *measured* values and screenshots, not eyeballed impressions.

The single organizing question — the UI analog of `architecture-review`'s ETC swap-question — is:

> **"Is this a deliberate design decision, or a leftover tool default?"**

Every AI-slop tell (Inter everywhere, VibeCode-purple, uniform 16px radius, colored left-border cards, all-caps labels, flat type hierarchy) is a default *nobody chose*. The review's job is to separate **intentional point-of-view** (defend it, even when bold or unconventional) from **unchosen default** (flag it) — and to measure the measurable rather than guess.

This skill is **read-only**: it prints a review and a ruthless action list, then *offers* to create issues or a report. It never edits code.

Distinct from siblings: `ui-component-review` reviews component *reuse/duplication* in code; `frontend-design` *creates* UI; `repro-visual` *reproduces a specific bug*; `describe-ui-from-web-app` *documents* the UI. This **judges rendered design quality**.

## Core stance

- **Intentional vs default is the root question.** Slop is the absence of decisions. Flag defaults; defend deliberate choices.
- **Measure, don't eyeball.** A contrast, spacing, or type-scale finding must cite the *measured computed value* (e.g. "1.9:1, fails WCAG AA 4.5:1"), not "looks low." Screenshots are evidence, not the analysis.
- **Opinionated and specific over comprehensive and hedged.** Every finding: severity + location (`screenshot` + `file:line`) + the concrete fix. Recommend, don't survey.
- **Hunt AI-slop — but defend a real point of view.** See `references/ui-slop-catalogue.md`. A bold, unconventional, *consistent* choice is the opposite of slop; don't flatten it toward the default.
- **Reward restraint.** "Change these three tokens", not "adopt a design system." A review that prescribes a rewrite where a few token edits suffice has failed.

## Workflow

Copy and track:

```text
UI Review Progress
- [ ] Step 1: Scope and static read
- [ ] Step 2: Render gate — secure rendered access (or consent-gated static-only)
- [ ] Step 3: Deterministic pre-scan (impeccable detect + static probes)
- [ ] Step 4: Rendered capture — measure, don't eyeball
- [ ] Step 5: Fan out judgment lenses
- [ ] Step 6: Synthesis & verification gate
- [ ] Step 7: Output — review + ruthless action list
- [ ] Step 8: Offer artifacts (issues / report) — only on user say-so
```

### Step 1: Scope and static read

Resolve the repo. Detect the framework and styling approach (Tailwind / CSS-in-JS / CSS modules), the design-token setup (`tailwind.config.*`, CSS custom properties, theme files), and the font stack. Read `docs/design/` if present — as context, not gospel.

Let the user narrow to a flow or screen set; otherwise cover the primary screens.

### Step 2: Render gate — you MUST see the rendered app

A UI review that only reads code misses real contrast, spacing, state, and motion. **Reuse the repo's existing render backends — build nothing new:**

- **Primary — chrome-devtools MCP** (zero install, available in most sessions; the backend `describe-ui-from-web-app` uses). Flow: `navigate_page` → `resize_page` / `emulate` for breakpoints → `take_screenshot` → `evaluate_script` for computed styles → `hover` / `click` for states → `take_snapshot` for the a11y tree. Use when the app URL is reachable and a display/session exists. These chrome-devtools tools are **deferred MCP tools** — load their schemas before calling (invoke the `chrome-devtools-mcp:chrome-devtools` skill, or load via `ToolSearch`), or the first call fails with InputValidationError.
- **Escalation — the `repro-visual` Playwright harness** (`scripts/repro/`). Reuse when the app needs auth/session, seeded data, headless/CI, or no-display-server emulation: call its `withSession({ device })` / `deviceContext()` / `page.evaluate()` / `page.screenshot()` (`../repro-visual-init/references/harness-template/harness.mjs`). If the app is auth-gated and the harness isn't scaffolded yet, point the user to `/repro-visual-init` — don't reinvent the login glue.

**No-render fallback (consent-gated).** If neither backend can reach the app, **stop and warn explicitly**: without the rendered UI the review can only read code and will miss real contrast, spacing, state, and motion issues. Proceed static-only **only on the user's explicit consent**, and stamp this banner at the top of the output:

```markdown
> ⚠️ **Static-only review** — the running app could not be reached, so this review reads code only. Rendered contrast, spacing, interaction states, dark mode, and motion were NOT inspected. Re-run with the app reachable for a full review.
```

### Step 3: Deterministic pre-scan (impeccable detect + static probes)

Run the deterministic anti-slop layer early so judgment agents spend their budget on judgment, not counting. This mirrors how `architecture-review` uses `aislop`.

**Impeccable / tokyn (optional, graceful):** if `npx`/node is available:

```bash
npx impeccable detect            # deterministic rule set + browser rules; add a URL/dir target as needed
```

It catches the mechanical slop tells (default palettes, Inter/Geist/Space-Grotesk overuse, uniform radius, colored card borders, gradient stripes, icon-tile grids, etc.). Feed its hits in as **pre-verified**. If unavailable, skip and **note it in the output** (no silent gap). Never just parrot it — it owns the mechanical layer.

**Static probes (always):**

```bash
grep -rn --exclude-dir=node_modules -i "font-family\|'Inter'\|Geist\|Space Grotesk" . | head   # font choices
grep -rn --exclude-dir=node_modules "indigo-\|violet-\|purple-\|fuchsia-\|cyan-" . | wc -l       # default Tailwind palette reliance
grep -rn --exclude-dir=node_modules "rounded-\|border-radius\|box-shadow\|gradient" . | wc -l    # radius/shadow/gradient uniformity
cat tailwind.config.* 2>/dev/null | grep -iA3 'extend\|colors\|fontFamily'                       # is the theme actually customized?
```

These are smells, not verdicts — a hit is a prompt to look at the rendered result.

### Step 4: Rendered capture — measure, don't eyeball

Across breakpoints **320 / 768 / 1024 / 1440** and in **light + dark mode**:

- **Screenshot** each screen × viewport (the evidence each finding cites).
- **Extract computed styles** via `evaluate_script` / `page.evaluate()`: `font-family`, text/background `color` (compute the **contrast ratio**), `border-radius`, `box-shadow`, the spacing scale (`gap`, `padding`, `margin`), `font-size` per heading level.
- **Exercise states**: `hover` / focus (Tab) / active / disabled, and the lifecycle states — **loading / empty / error** (seed or trigger them; a missing empty/error state is itself a finding).

**Reuse `repro-visual`'s existing audit checks** — don't duplicate them. Its `page.evaluate` battery (overflow, off-screen, truncation, small targets <44px, broken/distorted images, unlabelled inputs, clipped popups) and its eyeball checklist (spacing, typography, contrast, interactive states, z-order, component states, forms, hierarchy, mobile mechanics) live in `../repro-visual/SKILL.md` (visual-audit mode). Run that battery as the measurement menu.

### Step 5: Fan out judgment lenses (parallel)

Launch sub-agents (Task tool). Hand each `references/review-lens.md` verbatim and point it at `references/ui-slop-catalogue.md`. One per lens:

- **Usability heuristics** — Nielsen's 10 (system status visibility, real-world match, user control, consistency, error prevention, recognition over recall, flexibility, aesthetic/minimalist design, error recovery, help).
- **Visual craft** — hierarchy (one focal point per screen), type scale (≥1.25 ratio, genuine size jumps), spacing rhythm (group padding > inner gap), color/palette intentionality.
- **State & responsive completeness** — the hover/focus/active/disabled/loading/empty/error sweep × breakpoints × dark mode.
- **Accessibility** — WCAG AA contrast (4.5:1 body, 3:1 large), visible focus (F78), target size, keyboard path, labels.
- **Anti-slop** — the catalogue, with the intentional-vs-default question.

Each returns **strengths** (what's deliberately well-designed) + findings (severity + screenshot/`file:line` + concrete fix + the measured value) + any **deliberate bold choice it chose to defend**.

### Step 6: Synthesis & verification gate

Per `references/synthesis-checklist.md`:

1. **Coverage gate** — walk `references/coverage-rubric.md`; every dimension gets a status (**covered / checked, nothing to fix / gap / n/a**). A clean "checked, nothing to fix" is first-class — state it.
2. **Verify by measurement** — every Critical/High finding cites a measured value (contrast ratio, px, computed token), not an impression. Cross-confirmation by two lenses = strong signal.
3. **Strengths + consistency through-line** — "they already do this right on screen X, just not Y" reframes a gap as a consistency fix in the product's own idiom.
4. **Anti-over-design pass** — "which recommendation is itself over-engineering?" Prefer token edits over rewrites; reward restraint and "this bold choice is intentional — keep it."
5. **Intentional vs default** — make the call explicitly for each slop candidate; don't flatten a real point of view.

### Step 7: Output — review + ruthless action list

Print, in order: the **static-only banner** (if applicable) → **coverage status table** → **strengths** (+ through-line) → **findings** grouped by severity (**Critical / High / Medium / Low**), each with screenshot ref + measured value + `file:line` + fix → a short **"what I'd actually do"** list ordered by impact-per-effort, leading with the highest-signal slop tells and any broken/missing states. The user should be able to read only the last section and start. Surface the `npx impeccable detect` CI-guard recommendation if the repo has none.

### Step 8: Offer artifacts (only on user say-so)

Offer to turn findings into GitHub issues or a dated report. If accepted: read existing labels/milestones/templates first, reuse the repo's vocabulary and `file:line` + screenshot framing, **never invent labels/milestones**, and surface gaps instead of filling them.

## Edge cases

- **No frontend / wrong directory:** report and stop.
- **App can't be reached and user declines static-only:** stop — explain that `/repro-visual-init` (for auth'd apps) or a running dev server is the prerequisite.
- **`npx`/impeccable unavailable:** skip the deterministic pre-scan, run the static probes + rendered capture, and note the skipped mechanical pass.
- **Non-web UI (desktop/mobile):** the rendered-capture mechanics differ — use the relevant `repro-visual` / `describe-ui-from-*-app` path; the lenses and catalogue still apply.
- **Deliberately bold / brand-driven design:** do not flag an intentional, consistent point of view as slop. Note it as a strength.

## Reference docs

- `references/review-lens.md` — the verbatim "how to think" lens handed to every sub-agent.
- `references/ui-slop-catalogue.md` — the named AI-UI-slop tells, each with its fix and legitimate inverse.
- `references/coverage-rubric.md` — the mandatory dimension rubric + the measurement per dimension.
- `references/synthesis-checklist.md` — the synthesis / verify-by-measurement / prioritisation gate.
- Reuse (don't duplicate): `../repro-visual/SKILL.md` visual-audit battery; `../repro-visual-init/references/harness-template/harness.mjs` for the Playwright harness.
