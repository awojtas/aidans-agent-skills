---
name: repro-visual
description: 'Reproduce, diagnose and VERIFY UI bugs against the live app by MEASURING the real UI tree — not eyeballing screenshots. Two paths: Web drives a per-repo Playwright harness (emulated browser, any viewport, cached session, API seeding) for layout/responsive/mobile bugs and post-build visual audits; WPF/WinForms attaches via wpfbuddy-mcp (UIAutomation) and measures at DPI scale. First-time web setup: /repro-visual-init. Use when a bug is about position/sizing/responsiveness/layout, a fix looks right but the user says it''s still wrong, or to QA a feature before declaring it done. Triggers: repro on mobile, layout bug, measure the DOM, verify the fix, visual audit, WPF UI bug, wpfbuddy, desktop app layout.'
---

Reproduce a UI bug **against the live app**, diagnose it from **measurements of the real UI tree**, prove the fix before shipping, and re-verify on the deployed build. Works for both **web apps** (Playwright + DOM) and **WPF / WinForms desktop apps** (wpfbuddy-mcp / UIAutomation + PrintWindow). The philosophy is identical: measure, don't eyeball; prove the fix; re-verify on prod.

## Step 0: Identify the target type

Before anything else, determine what kind of app the user is working on:

- **Web app** (React, Next.js, Vue, plain HTML/CSS, etc.) → proceed to the **[Web path](#web-path)** below.
- **WPF or WinForms desktop app** — look for `<OutputType>WinExe</OutputType>` in any `.csproj`, or `UseWPF` / `UseWindowsForms` properties → proceed to the **[WPF / native-Windows path](#wpf--native-windows-path)** below.
- **Something else** (Electron, macOS native, mobile, CLI, etc.) — this skill doesn't cover those. Say so and stop.

## When to use this

- A bug is about **position / centring / scroll / overflow / sizing / responsiveness** (web), or **element bounds / margins / DPI scaling** (WPF/desktop) — "looks wrong on mobile" or "looks off on the installed app".
- A fix **looks correct in the code** but the user reports it's still wrong. Stop iterating blind — measure the real running app.
- You need **ground-truth numbers** at specific viewport sizes (web) or DPI scales (desktop).
- You just **built or shipped a feature** and want a systematic visual QA sweep before declaring it done (web path only).

If the bug is pure logic/data (not visual), this skill is overkill — fix it directly.

---

## Web path

### Prerequisites

1. **The harness must exist** in this repo (a `repro` script + `scripts/repro/`). Check: `grep -q '"repro"' **/package.json` or look for `scripts/repro/run.mjs`. **If absent, run `/repro-visual-init` first** (one-time setup), then come back.
2. **Playwright browser installed** (`npx playwright install chromium`, or the repo's e2e-install script).
3. **Test creds** in the gitignored env file (the harness's `.env.e2e`). Never use a real user's account.

### The harness contract (CLI)

The harness exposes a stable CLI (exact invocation prefix is per-repo, e.g. `pnpm --filter <web> repro --`):

| Flag | Purpose |
|---|---|
| `--login` | Log in once and cache the session (storageState). Run this first if measures fail with auth errors. |
| `--device mobile\|desktop\|<width>` | Emulate a device or a raw CSS width (e.g. `360`). |
| `--url <baseUrl>` | Override the target (defaults to the prod URL in env). |
| `--path <route>` | Navigate to the screen under test (e.g. `--path /dashboard`). |
| `--seed <spec.json>` | Create test data via the app's API; prints the new id(s). |
| `--measure` | Print DOM metrics for the component under test (e.g. `{centerOffsetPx, workFillPct, allWorkVisible, …}`). |
| `--screenshot <file>` | Save a screenshot. |
| `--assert-loads` | Smoke check: the screen renders; non-zero exit on failure. |

### Bug repro workflow

1. **Set up the scenario.** If the bug needs specific data, write a small seed spec and `--seed` it (note the id so you can clean it up later). Otherwise use an existing screen the user named.
2. **Reproduce + measure** across the relevant viewport sizes — and **always at least one narrow width** for "mobile" bugs. Run `--measure` (and `--screenshot` to *confirm*, never to *judge*) at e.g. `--device 360`, `412`, `desktop`. Read the numbers: is the element centred (offset ≈ 0)? fully visible? clipped? Capture the *failing* numbers — that's your baseline.
3. **Diagnose from the measurements, not a theory.** Inspect the live DOM (`page.evaluate` getBoundingClientRect / scrollWidth / clientWidth / computed styles) to find *why* the numbers are wrong. See `references/measuring.md` (in `repro-visual-init`).
4. **Prove the fix before writing code.** Where possible, **inject the corrected behaviour into the live DOM** (`page.evaluate` to set `scrollLeft`, toggle a style, etc.) and re-measure. If the injected version measures right across all widths, your fix is correct — *then* write it in the component.
5. **Implement, ship** through the normal flow.
6. **Verify on production after deploy.** Wait for the deploy, then re-run `--measure` across the same widths. **Vercel/preview deploys are often SSO-protected** — verify on prod, or wire a protection-bypass token.
7. **Clean up.** Delete any seeded test data and temp scripts/screenshots. Leave the test account tidy.

### Visual audit mode

Use this after building a feature to catch everything that needs fixing before declaring it done. Workflow: sweep → catalogue → present → (user approves) → fix in order.

#### Step 1: Establish scope

Ask the user (in one prompt): which screen(s) / route(s) to cover? Which viewports matter? Any known gaps to skip? Seed a representative scenario first if screens would otherwise be empty.

#### Step 2: Sweep each screen × viewport

Run `--screenshot` then `--measure`, then run these checks via `page.evaluate`:

```js
const checks = await page.evaluate(() => {
  const hasOverflow = document.documentElement.scrollWidth > window.innerWidth + 1;

  const offScreen = [...document.querySelectorAll('body *')].filter(el => {
    const r = el.getBoundingClientRect();
    return r.width > 0 && (r.right < 0 || r.left > window.innerWidth);
  }).map(el =>
    el.tagName.toLowerCase() +
    (el.id ? '#' + el.id : el.classList.length ? '.' + el.classList[0] : '')
  );

  // Horizontal ellipsis truncation (scrollWidth > clientWidth)
  const truncated = [...document.querySelectorAll('p, span, h1, h2, h3, li, label, td')].filter(el => {
    return el.scrollWidth > el.clientWidth + 1;
  }).map(el => el.textContent.trim().slice(0, 60));

  // Touch targets too small on mobile (< 44px in either dimension)
  const smallTargets = [...document.querySelectorAll('button, a, [role="button"]')].filter(el => {
    const r = el.getBoundingClientRect();
    return r.width > 0 && (r.width < 44 || r.height < 44);
  }).map(el => {
    const r = el.getBoundingClientRect();
    return { text: el.textContent.trim().slice(0, 40), w: Math.round(r.width), h: Math.round(r.height) };
  });

  // Broken images (loaded but empty)
  const brokenImages = [...document.querySelectorAll('img')].filter(img =>
    img.complete && img.naturalWidth === 0
  ).map(img => img.getAttribute('alt') || img.src.split('/').pop().slice(0, 50) || '(no alt)');

  // Images rendered at wrong aspect ratio (squished/stretched > 15% off natural)
  const distortedImages = [...document.querySelectorAll('img')].filter(img => {
    if (!img.complete || img.naturalWidth === 0 || img.naturalHeight === 0) return false;
    const r = img.getBoundingClientRect();
    if (r.width === 0 || r.height === 0) return false;
    return Math.abs(r.width / r.height - img.naturalWidth / img.naturalHeight) / (img.naturalWidth / img.naturalHeight) > 0.15;
  }).map(img => {
    const r = img.getBoundingClientRect();
    return { src: img.src.split('/').pop().slice(0, 40), natural: `${img.naturalWidth}×${img.naturalHeight}`, rendered: `${Math.round(r.width)}×${Math.round(r.height)}` };
  });

  // Inputs with no accessible label (no <label for>, aria-label, aria-labelledby, title, or wrapping label)
  const unlabelledInputs = [...document.querySelectorAll(
    'input:not([type="hidden"]):not([type="submit"]):not([type="button"]):not([type="reset"]):not([type="image"])'
  )].filter(input => {
    if (input.id && document.querySelector(`label[for="${input.id}"]`)) return false;
    if (input.getAttribute('aria-label') || input.getAttribute('aria-labelledby')) return false;
    if (input.getAttribute('title')) return false;
    if (input.closest('label')) return false;
    return true;
  }).map(input => input.getAttribute('placeholder') || input.getAttribute('name') || input.type);

  // Popup-role elements inside an overflow:hidden ancestor — these will be clipped when opened
  const clippedPopups = [...document.querySelectorAll(
    '[role="menu"], [role="listbox"], [role="tooltip"], [role="dialog"]'
  )].filter(el => {
    if (getComputedStyle(el).position === 'fixed') return false; // fixed positioning bypasses overflow clipping
    let p = el.parentElement;
    while (p && p !== document.body) {
      const s = getComputedStyle(p);
      if (s.overflow === 'hidden' || s.overflowX === 'hidden' || s.overflowY === 'hidden') return true;
      p = p.parentElement;
    }
    return false;
  }).map(el =>
    el.getAttribute('role') +
    (el.id ? '#' + el.id : el.classList.length ? '.' + el.classList[0] : '')
  );

  return { hasOverflow, offScreen, truncated, smallTargets, brokenImages, distortedImages, unlabelledInputs, clippedPopups };
});
console.log(JSON.stringify(checks, null, 2));
```

Then eyeball each screenshot for things DOM metrics can't catch:

**Spacing & alignment** — consistent gaps between like elements; nothing cramped or oddly spaced; content aligned to an implicit grid. Outer padding of a grouped section should exceed the spacing between items inside it — if the two are equal, elements feel randomly stacked rather than grouped.

**Typography** — body text at 16px or larger for comfortable reading; heading levels have genuinely visible size jumps (each level roughly 1.25× the one below — five barely-distinguishable sizes is noise, not hierarchy); consistent font weights and sizes for the same content type; line-height not cramped.

**Colour & contrast** — text on gradient or image backgrounds; error/warning text. All readable without straining. Check both light and dark areas of the screen. Disabled elements are exempt from WCAG contrast requirements but should still be visually recognisable as disabled — not invisible.

**Interactive states** — hover buttons and links: should have a visible state change. Tab through the page: each interactive element needs a visible focus indicator (ring, border, background fill — any form; the WCAG requirement is visibility, not shape). Selected/active states are distinct from default. If an indicator is missing: look for `outline: none` or `outline: 0` in CSS without a replacement — this is WCAG Failure F78, and it is NOT exempt as "browser default" (suppressing the outline is author modification; the browser-default exemption only applies when the author's CSS leaves `:focus` completely untouched). Also check modals: focus must move inside the modal on open, stay trapped there while open, and return to the trigger element on close.

**Layering & z-order** — open every interactive layer (dropdown menus, tooltips, date pickers, popovers, context menus, bottom sheets, modals) and confirm it renders fully above all other content. Two distinct failure patterns: (1) the popup is clipped at a container edge — a parent has `overflow: hidden` that cuts the element off (the automated `clippedPopups` check above catches this passively; verify visually by opening the popup and seeing if it's truncated); (2) the popup renders at full size but another element is painted on top of it — a `z-index` stacking context collision, only visible when the popup is actually open. For clipping (pattern 1), the usual culprit is a card or scroll container using `overflow: hidden` for border-radius or animation containment — not sticky headers. For stacking collisions (pattern 2), sticky headers and fixed sidebars are the most common offenders.

**Component states:**
- *Empty*: lists, grids, and feeds with no data show a helpful message + CTA, not a blank void.
- *Loading*: async content shows a skeleton or spinner — no raw flash of unstyled content.
- *Error*: validation messages are adjacent to their field, legible, and specific (not just "invalid").

**Images** — crop and focal-point appropriate for the container shape; `object-fit` not cutting off the subject.

**Icons** — consistent style across the screen (all outlined or all filled, never mixed); consistent stroke weight and size; not blurry on high-DPI displays (SVG preferred over raster).

**Forms** — every input has a visible label above it, not just a placeholder (placeholder disappears on typing and is never a substitute for a label); required fields indicated consistently; error messages sit directly below their field, not in a generic toast; validation triggers on blur (leaving the field), not on each keystroke — mid-entry errors interrupt the user mid-thought and are confirmed bad UX (exception: password-strength meters and character counters).

**Visual hierarchy** — step back and look at the whole screen before moving on. There should be one obvious focal point (headline or primary CTA) per screen; if everything competes equally for attention, nothing registers. The primary CTA should be visually dominant (size, colour, placement) and clearly distinct from secondary actions. Quick test: squint at the screenshot — the thing that survives blur should be the intended entry point.

**Mobile-specific mechanics** (narrow viewports):
- Page scrolling sideways from a `min-width` + `overflow-x` container escaping its bounds.
- `position: sticky` elements overlaying scrollable content underneath them.
- Bottom bars / fixed navs covering the last list item.
- iOS overscroll bounce revealing a background-colour mismatch at top or bottom.

**Desktop-specific patterns** (wide viewports):
- Max-width containers centred, not left-aligned or edge-to-edge.
- Multi-column layouts balanced; not one tall column next to a stub.
- Hover-only affordances (tooltips, action menus) — information only reachable by hover is inaccessible on touch.

#### Step 3: Present findings and ask to proceed

Compile into a table — do not start fixing yet:

```
Visual audit — <Feature name>

| # | Screen | Viewport | Type        | Description                                              | Severity |
|---|--------|----------|-------------|----------------------------------------------------------|----------|
| 1 | /dash  | 360px    | Bug         | Horizontal overflow at 360px — sidebar not constrained   | High     |
| 2 | /dash  | mobile   | Enhancement | Zero-state shows blank space with no call-to-action      | Medium   |
```

Severity: **High** (broken or unusable) / **Medium** (clearly wrong, affects UX) / **Low** (polish).

Ask: *"Found N issue(s) across X screen(s). Proceed to fix all, or tell me which numbers to skip?"*

#### Step 4: Work through the list

Fix each item in order — do not deploy between items:

- For each: measure baseline → prove fix by DOM injection → implement (commit).
- Mark done as you go (`~~1~~`).
- **For enhancements needing design judgement** — pause and ask. Don't invent copy or design decisions.
- One item at a time — a fix for one can affect measurements for another.

#### Step 5: Deploy and verify on production

Once all items are committed, deploy once, then verify: for each fixed item, re-run `--measure` at the same viewport(s) and confirm numbers are correct. Clean up seeded data and temp screenshots.

---

## WPF / native-Windows path

Same philosophy as the web path — measure, don't eyeball; prove the fix; re-verify on the built/installed binary — but different tooling. The primary backend is **wpfbuddy-mcp**: a UIAutomation-based MCP server that attaches to any running WPF app and provides structured inspect / measure / interact / assert tools without requiring changes to the target app. Full tool reference, PrintWindow recipe, and gotchas in `references/wpf-desktop.md`.

### Step 1: Load wpfbuddy tools

wpfbuddy tools may be registered as deferred MCP tools — load their schemas before calling them:

```
ToolSearch("select:wpf_list_apps,wpf_attach,wpf_list_windows,wpf_select_window,wpf_focus_window,wpf_snapshot,wpf_explain_screen,wpf_click,wpf_invoke,wpf_double_click,wpf_set_value,wpf_select_by_text,wpf_grid_get_rows,wpf_grid_find_row,wpf_grid_get_cell,wpf_grid_double_click_row,wpf_wait_for_window,wpf_wait_for_element,wpf_probe_connect,wpf_get_bindings,wpf_get_binding_errors,wpf_assert_text,wpf_assert_exists")
```

If no `wpf_*` tools are found after this, wpfbuddy-mcp is not registered in this session. Tell the user to follow the setup steps in `references/wpf-desktop.md` and restart the Claude Code session.

### Step 2: Attach to the running app

Prefer attaching to an already-running instance — especially if a human is mid-task. Never kill or restart the app without asking.

```
wpf_list_apps()          // find the target process and note its PID
wpf_attach(pid=...)      // attach (or processName='MyApp')
wpf_list_windows()       // list windows in the attached process
wpf_select_window(...)   // select the target window
wpf_focus_window()       // bring it to the foreground
```

After any navigation that opens a new window or dialog, call `wpf_select_window` again — the active window context changes.

### Step 3: Snapshot and measure

```
wpf_explain_screen()     // start here if you don't know what screen you're on
wpf_snapshot()           // structured tree: bounds, patterns, className, isOffscreen,
                          // AutomationId — auto-flags missing / duplicate IDs
```

Read the snapshot before interacting. The `.className` field exposes real WPF control types (`DataGrid`, `ComboBox`, `TabItem`, etc.) that bare UIAutomation `ControlType` collapses into coarse categories. For grids: `wpf_grid_get_rows` / `wpf_grid_get_cell`.

**Axis note:** "viewport width" is meaningless on desktop. The real axis is **DPI scaling** (100% / 125% / 150%) + window state (normal / maximised / resized). Re-check at each DPI scale just as the web path checks each viewport width.

### Step 4: Capture a screenshot

**Use PrintWindow — NOT `wpf_screenshot`.** `wpf_screenshot` grabs the physical screen region: any overlapping window bleeds through (occlusion + privacy hazard) and the inline base64 it returns overflows agent context. Instead, run the PrintWindow recipe from `references/wpf-desktop.md` in PowerShell 5.1 (`powershell.exe`) and save directly to a PNG file, then open natively. PrintWindow renders from the window's own surface, so it works even when fully occluded or off-screen.

### Step 5: Diagnose from the tree

Compare snapshot bounds against expected XAML sizes. Check `isOffscreen`, `className`, available patterns, and AutomationId uniqueness. If diagnosis stalls on a data question, try `wpf_probe_connect` then `wpf_get_bindings` / `wpf_get_binding_errors` (probe mode — see `references/wpf-desktop.md`).

Common issues: margins accumulating, Grid column widths not summing, z-order from `Panel.ZIndex`, DPI-unaware coordinates.

### Step 6: Prove the fix

Two options:

a. **Interact to verify** — use `wpf_click` / `wpf_invoke` / `wpf_set_value` / `wpf_select_by_text` / grid tools to drive the scenario and re-snapshot. If measurements are now correct, the logic is right.

b. **Rebuild and re-measure** — implement the XAML/C# change, `dotnet build --project <csproj>` (scope to the changed project for speed), re-launch, re-attach, re-snapshot. Lock in with `wpf_assert_*` so regressions are detectable.

### Step 7: Re-verify on the installed/deployed artifact

"Prod" for a desktop app is the installed binary (ClickOnce, MSIX, xcopy). Re-attach to or relaunch that artifact, re-snapshot at the same states and DPI scales, and confirm bounds are correct.

### Step 8: Clean up

If you launched a throwaway instance: `Stop-Process -Id $proc.Id`. Delete any temp screenshots.

---

## Guardrails

**Web:**
- **Measure, don't eyeball.** `getBoundingClientRect` tells you by how much; a screenshot only tells you that something's off.
- **Reuse the cached session.** Don't log in in a loop — auth providers rate-limit rapid logins.
- **Headless + emulation, not the chrome-devtools MCP**, in environments with no display server.
- **Different sizes matter.** Check 320, 360, 412, and a non-overflowing width — a fix tuned to one size often regresses another.
- **Metrics don't catch everything.** After the automated sweep, eyeball each screenshot: text contrast on complex or gradient backgrounds, placeholder text that's too long or too small to read comfortably, monospace fonts on non-code inputs. These aren't reliably caught by DOM measurements.
- **Don't commit secrets.**

**WPF / desktop:**
- **Load wpfbuddy tools first** — they may be deferred; call ToolSearch before any `wpf_*` tool or the call fails.
- **Attach, don't launch,** when a human is mid-task. Never kill or restart the app without asking.
- **Never `wpf_screenshot`** — physical screen grab (occlusion + privacy hazard, context overflow from base64). Use PrintWindow (PS 5.1) → PNG file. See `references/wpf-desktop.md`.
- **Re-select the window after navigation.** Dialogs and new windows change the active window context; call `wpf_select_window` again.
- **DPI, not viewport width.** Re-check at 100% / 125% / 150% display scaling.
- **`wpf_grid_find_row` matches on Name, not cell text.** Act by row index when in doubt.
- **Kill only throwaway instances** (`Stop-Process`). Don't leave ghost processes running.

## Aliases

| Alias | What it does |
|---|---|
| `/repro-on-mobile` | Web path, mobile viewport (≈412px). |
| `/repro-on-desktop-web` | Web path, desktop browser viewport (≈1280px). |
| `/repro-on-desktop-windows-app` | WPF / WinForms path — skips Step 0 detection, goes straight to the native-Windows workflow. |
