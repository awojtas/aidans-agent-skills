---
name: repro-visual
description: 'Reproduce, diagnose and VERIFY front-end layout / responsive / mobile bugs against the deployed app by driving an emulated browser and MEASURING the real DOM — not guessing from code or eyeballing screenshots. Also runs post-build visual audits: sweeps the feature screens, catalogues findings with severity, presents for approval, then works through each fix. Drives a per-repo Playwright harness that logs in once (cached session), can seed test data via the app API, emulates any device or CSS width, screenshots, measures, and re-verifies on production after deploy. Use when a UI bug is about position/scroll/overflow/sizing/responsiveness, when a fix looks right in code but user says still wrong, or to QA a newly-built feature before declaring it done. First-time setup in a repo: run /repro-visual-init. Triggers: repro this on mobile, reproduce the layout bug, measure the DOM, it is still off on mobile, verify the responsive fix, visual audit this feature, check the UI after building, QA sweep the new screen.'
---

Reproduce a front-end layout/responsive bug **against the live deployed app**, diagnose it from **DOM measurements**, prove the fix before shipping, and re-verify on production. Also runs post-build visual audits: sweeps screens, catalogues every issue found, and works through the list on approval. Both modes use the same per-repo Playwright harness.

## When to use this

- A bug is about **position / centring / scroll / overflow / sizing / responsiveness**, or "looks wrong on mobile / at width X". → use the **bug repro workflow** below.
- A fix **looks correct in the code** but the user reports it's still wrong — stop iterating blind; measure reality. → **bug repro workflow**.
- You need **ground-truth numbers** (px offsets, fill %, is-it-visible) at specific viewport sizes. → **bug repro workflow**.
- You just **built or shipped a feature** and want a systematic visual QA sweep before declaring it done. → use the **visual audit mode** below.

If the bug is pure logic/data (not visual), this skill is overkill — fix it directly.

## Prerequisites

1. **The harness must exist** in this repo (a `repro` script + `scripts/repro/`). Check: `grep -q '"repro"' **/package.json` or look for `scripts/repro/run.mjs`. **If absent, run `/repro-visual-init` first** (one-time setup), then come back.
2. **Playwright browser installed** (`npx playwright install chromium`, or the repo's e2e-install script).
3. **Test creds** in the gitignored env file (the harness's `.env.e2e`). Never use a real user's account.

## The harness contract (CLI)

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

---

## Bug repro workflow

1. **Set up the scenario.** If the bug needs specific data, write a small seed spec and `--seed` it (note the id so you can clean it up later). Otherwise use an existing screen the user named.
2. **Reproduce + measure** across the relevant viewport sizes — and **always at least one narrow width** for "mobile" bugs. Run `--measure` (and `--screenshot` to *confirm*, never to *judge*) at e.g. `--device 360`, `412`, `desktop`. Read the numbers: is the element centred (offset ≈ 0)? fully visible? clipped? Capture the *failing* numbers — that's your baseline.
3. **Diagnose from the measurements, not a theory.** Inspect the live DOM (`page.evaluate` getBoundingClientRect / scrollWidth / clientWidth / computed styles) to find *why* the numbers are wrong (an element overlapping, a wrong centre reference, an off-by-the-label-width scroll, etc.). See `references/measuring.md`.
4. **Prove the fix before writing code.** Where possible, **inject the corrected behaviour into the live DOM** (`page.evaluate` to set `scrollLeft`, toggle a style, etc.) and re-measure. If the injected version measures right across all widths, your fix is correct — *then* write it in the component. This step is what turns "I think this fixes it" into "this fixes it."
5. **Implement, ship** through the normal flow.
6. **Verify on production after deploy.** Wait for the deploy (the harness defaults to the prod URL), then re-run `--measure` across the same widths and confirm the numbers are now good. **Vercel/preview deploys are often SSO-protected** — you usually can't probe a preview; verify on prod, or wire a protection-bypass token.
7. **Clean up.** Delete any seeded test data and temp scripts/screenshots. Leave the test account tidy.

---

## Visual audit mode

Use this after building a feature to catch everything that needs fixing before declaring it done. The workflow is: sweep → catalogue → present → (user approves) → fix in order.

### Step 1: Establish scope

Ask the user (in one prompt, not one-at-a-time):
- Which screen(s) / route(s) to cover?
- Which viewports matter — mobile, desktop, or both?
- Any known gaps or sections to skip?

If the feature involves data, seed a representative scenario first (`--seed`) so screens aren't empty during the sweep.

### Step 2: Sweep each screen × viewport

For each screen + viewport combination, run `--screenshot` then `--measure`, then run the following checks via `page.evaluate`:

```js
// Horizontal overflow (causes unexpected horizontal scroll)
const hasOverflow = document.documentElement.scrollWidth > window.innerWidth + 1;

// Elements clipped or pushed off-screen
const offScreen = [...document.querySelectorAll('*')].filter(el => {
  const r = el.getBoundingClientRect();
  return r.width > 0 && (r.right < 0 || r.left > window.innerWidth);
});

// Text truncation (text taller than its container)
const truncated = [...document.querySelectorAll('p, span, h1, h2, h3, li, label')].filter(el => {
  return el.scrollHeight > el.offsetHeight + 2;
});

// Touch targets too small on mobile (< 44px wide or tall)
const smallTargets = [...document.querySelectorAll('button, a, [role="button"]')].filter(el => {
  const r = el.getBoundingClientRect();
  return r.width < 44 || r.height < 44;
});
```

Also navigate to the **empty/zero state** of any list or collection on the screen — check whether it has a clear call-to-action or just shows a blank.

Note anything that looks visually wrong in the screenshot even if the numbers don't catch it (obvious misalignment, inconsistent spacing, unexpected colours, broken images).

### Step 3: Present findings and ask to proceed

Compile all findings into a table and present it — do not start fixing yet:

```
Visual audit — <Feature name>

| # | Screen | Viewport | Type        | Description                                              | Severity |
|---|--------|----------|-------------|----------------------------------------------------------|----------|
| 1 | /dash  | 360px    | Bug         | Horizontal overflow at 360px — sidebar not constrained   | High     |
| 2 | /dash  | mobile   | Bug         | "Create" button is 38px tall — below 44px touch target   | Medium   |
| 3 | /dash (empty) | mobile | Enhancement | Zero-state shows blank space with no call-to-action | Medium   |
| 4 | /dash  | desktop  | Enhancement | Heading weight inconsistent with the rest of the app     | Low      |
```

Severity: **High** (broken or unusable) / **Medium** (clearly wrong, affects UX) / **Low** (polish, noticeable but not blocking).

Ask: *"Found N issue(s) across X screen(s). Proceed to fix all, or tell me which numbers to skip?"*

### Step 4: Work through the list

Once the user approves, fix each item in order. For each:

- Use the bug repro workflow: measure baseline → prove fix by DOM injection → implement → re-verify on prod.
- Mark the item done in the list as you go (`~~1~~` or similar).
- **For enhancements that need design judgement** (e.g. what the empty state should say, which colour to use) — pause and ask the user before implementing. Don't invent copy or design decisions.
- One item at a time — don't batch-fix; a fix for one item can affect the measurements for another.

---

## Guardrails

- **Measure, don't eyeball.** A screenshot tells you *that* something's off; `getBoundingClientRect` tells you *by how much* and lets you assert a fix. Lead with numbers.
- **Reuse the cached session.** The harness persists login (storageState). Don't log in repeatedly in a loop — many auth providers **rate-limit** rapid logins (you'll get timeouts).
- **Headless + emulation, not the chrome-devtools MCP**, in environments with no display server (the MCP needs one; Playwright headless doesn't).
- **Different sizes matter.** "Works on mobile" is not one width — check a few (small phone ~320–360, large phone ~412–430, and a non-overflowing width) so the fix is size-robust, not tuned to one device.
- **Don't commit secrets.** Creds live in the gitignored env file; the cached session is gitignored too.

## Device aliases

`/repro-on-mobile` and `/repro-on-desktop` are thin entry points to the bug repro workflow with the device preset chosen for you.
