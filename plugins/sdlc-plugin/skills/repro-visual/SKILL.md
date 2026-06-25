---
name: repro-visual
description: 'Reproduce, diagnose and VERIFY UI bugs against the live app by MEASURING the real UI tree — not eyeballing screenshots. Two paths: Web — drives a per-repo Playwright harness (emulated browser, any viewport, cached session, seed via API) for layout/responsive/mobile bugs and post-build visual audits; WPF/WinForms — launches the exe, captures via PrintWindow, measures via UIAutomation BoundingRectangle, checks at DPI scale. First-time web setup: run /repro-visual-init (web-only; WPF recipe in references/wpf-uiautomation.md). Use when a bug is about position/sizing/responsiveness/layout, a fix looks right but user says still wrong, or to QA a feature before declaring done. Triggers: repro on mobile, layout bug, measure the DOM, still off on mobile, verify the fix, visual audit this feature, WPF UI bug, measure WPF window, desktop app layout.'
---

Reproduce a UI bug **against the live app**, diagnose it from **measurements of the real UI tree**, prove the fix before shipping, and re-verify on the deployed build. Works for both **web apps** (Playwright + DOM) and **WPF / WinForms desktop apps** (UIAutomation + PrintWindow). The philosophy is identical: measure, don't eyeball; prove the fix; re-verify on prod.

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

**Layering & z-order** — open every interactive layer (dropdown menus, tooltips, date pickers, popovers, context menus, bottom sheets, modals) and confirm it renders fully above all other content. Two distinct failure patterns: (1) the popup is clipped at a container edge — a parent has `overflow: hidden` that cuts the element off (the automated `clippedPopups` check above catches this passively; verify visually by opening the popup and seeing if it's truncated); (2) the popup renders at full size but another element is painted on top of it — a `z-index` stacking context collision, only visible when the popup is actually open. Sticky headers and sidebars are the most common culprits for both.

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

Same philosophy — measure, don't eyeball; prove the fix; re-verify on the built/installed binary — but different tooling. No browser, no Node, no Playwright. Full recipe with ready-to-run PowerShell in `references/wpf-uiautomation.md`.

### Step 1: Launch and wait for the target window

- Build if needed (`dotnet build` or MSBuild). Locate the `.exe` under `bin\Debug\` or the installed/deployed path.
- Launch as a background process; record the PID.
- **Desktop apps start slowly and variably** (the same app can take 16s to 33s across runs). Poll for the window with a 60s+ timeout — a fixed sleep will intermittently time out.
- Enumerate windows by PID + visible + Win32 class starts with `HwndWrapper` to find the WPF window handle. **Skip the splash screen** (`SplashScreen` opens its own `HwndWrapper`); wait until the real `<Window>` appears.
- See `references/wpf-uiautomation.md` for the `EnumWindows` + `GetClassName` recipe.

### Step 2: Screenshot via PrintWindow

Run in **Windows PowerShell 5.1 (`powershell.exe`), not PowerShell 7 (`pwsh`)** — `System.Drawing.Bitmap` and UIAutomation types live in .NET Framework assemblies that PS 7 does not load by default.

Use `PrintWindow(hwnd, hdc, 2 /*PW_RENDERFULLCONTENT*/)` — **never `Graphics.CopyFromScreen`**. `CopyFromScreen` grabs the physical screen at the window's coordinates: if anything is in front of the app, you capture the wrong content (a calendar, a chat window, sensitive data). `PrintWindow` renders from the window's own surface and works even when fully occluded or minimised. See `references/wpf-uiautomation.md` for the script.

### Step 3: Measure via UIAutomation BoundingRectangle

```powershell
# powershell.exe (PS 5.1 only)
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$cond = [System.Windows.Automation.Condition]::TrueCondition  # NOT AutomationElement.TrueCondition
$all  = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, $cond)

foreach ($el in $all) {
    $r   = $el.Current.BoundingRectangle
    $id  = $el.Current.AutomationId   # = XAML x:Name
    if ($r.Width -gt 0) { Write-Host "$($el.Current.ControlType.ProgrammaticName)  id=$id  ${r.Width}x${r.Height}" }
}
```

`AutomationId` = XAML `x:Name` (WPF maps these automatically). `BoundingRectangle` is in screen pixels at the current DPI. At 100% scaling, `BoundingRectangle.Width` matches XAML `Width` exactly for fixed-size elements.

**The right scale axis for WPF is DPI, not viewport width.** Re-check at 100% / 125% / 150% display scaling to confirm the layout holds across monitor configurations.

### Step 4: Diagnose from the tree

Compare `BoundingRectangle` values against XAML-specified sizes. Common issues: margins accumulating, Grid column widths not summing correctly, DPI-unaware coordinates. Use the full element tree to spot the point where layout diverges from spec.

### Step 5: Prove the fix (rebuild + re-measure)

DOM-injection has no direct WPF analogue. The equivalent: implement the XAML/C# change, rebuild (`dotnet build --project <csproj>`, not the whole solution), re-launch, re-capture, re-measure. If numbers are now correct across DPI scales → commit. Keep rebuilds scoped to the changed project to stay fast.

### Step 6: Re-verify on the installed/deployed build

"Prod" for a desktop app is the installed binary (ClickOnce, MSIX, xcopy, or similar). Re-run capture + measure against that build, not just `bin\Debug`.

### Step 7: Clean up

`Stop-Process -Id $proc.Id`. Delete any temp screenshots.

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
- **Run in Windows PowerShell 5.1** (`powershell.exe`). PS 7 fails on .NET Framework types.
- **Never `CopyFromScreen`** — it captures whatever is physically behind the window. Privacy hazard.
- **Expect a splash screen.** Wait for the real window, not the first `HwndWrapper` that appears.
- **Use polled waits** (60s+ timeout, 500ms poll interval). Desktop apps start slowly and variably.
- **Kill the launched process** when done (`Stop-Process`). Don't leave ghost instances.
- **Win32 ClassName ≠ UIAutomation ClassName.** `GetClassName` → `HwndWrapper[…]`; UIAutomation → `Window`. Don't mix them.

## Aliases

| Alias | What it does |
|---|---|
| `/repro-on-mobile` | Web path, mobile viewport (≈412px). |
| `/repro-on-desktop-web` | Web path, desktop browser viewport (≈1280px). |
| `/repro-on-desktop-windows-app` | WPF / WinForms path — skips Step 0 detection, goes straight to the native-Windows workflow. |
