---
name: repro-visual
description: Reproduce, diagnose and VERIFY front-end layout / responsive / mobile / cross-viewport bugs against the deployed app by driving an emulated browser and MEASURING the real DOM (centre offset, fill %, element visibility) — not guessing from code or eyeballing screenshots. Drives a per-repo Playwright harness that logs in once (cached session), can seed test data via the app's API, emulates any device or CSS width, screenshots, measures, and re-verifies on production after deploy. Use when a UI bug is about position/scroll/overflow/sizing/responsiveness, when a fix "looks right in the code" but the user says it's still wrong on their device, or when you need ground-truth pixel measurements at specific viewport widths. First-time setup in a repo: run /repro-visual-init. Triggers: repro this on mobile, reproduce the layout bug, check it on a real device, measure the DOM, it's still off on mobile, verify the responsive fix, see the site as a phone.
---

Reproduce a front-end layout/responsive bug **against the live deployed app**, diagnose it from **DOM measurements**, prove the fix before shipping, and re-verify on production. This is the antidote to "fixed it in the code" guesswork that keeps missing — you look at and measure the real thing.

## When to use this

- A bug is about **position / centring / scroll / overflow / sizing / responsiveness**, or "looks wrong on mobile / at width X".
- A fix **looks correct in the code** but the user reports it's still wrong — stop iterating blind; measure reality.
- You need **ground-truth numbers** (px offsets, fill %, is-it-visible) at specific viewport sizes.

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

## Workflow

1. **Set up the scenario.** If the bug needs specific data, write a small seed spec and `--seed` it (note the id so you can clean it up later). Otherwise use an existing screen the user named.
2. **Reproduce + measure** across the relevant viewport sizes — and **always at least one narrow width** for "mobile" bugs. Run `--measure` (and `--screenshot` to *confirm*, never to *judge*) at e.g. `--device 360`, `412`, `desktop`. Read the numbers: is the element centred (offset ≈ 0)? fully visible? clipped? Capture the *failing* numbers — that's your baseline.
3. **Diagnose from the measurements, not a theory.** Inspect the live DOM (`page.evaluate` getBoundingClientRect / scrollWidth / clientWidth / computed styles) to find *why* the numbers are wrong (an element overlapping, a wrong centre reference, an off-by-the-label-width scroll, etc.). See `references/measuring.md`.
4. **Prove the fix before writing code.** Where possible, **inject the corrected behaviour into the live DOM** (`page.evaluate` to set `scrollLeft`, toggle a style, etc.) and re-measure. If the injected version measures right across all widths, your fix is correct — *then* write it in the component. This step is what turns "I think this fixes it" into "this fixes it."
5. **Implement, ship** through the normal flow.
6. **Verify on production after deploy.** Wait for the deploy (the harness defaults to the prod URL), then re-run `--measure` across the same widths and confirm the numbers are now good. **Vercel/preview deploys are often SSO-protected** — you usually can't probe a preview; verify on prod, or wire a protection-bypass token.
7. **Clean up.** Delete any seeded test data and temp scripts/screenshots. Leave the test account tidy.

## Guardrails

- **Measure, don't eyeball.** A screenshot tells you *that* something's off; `getBoundingClientRect` tells you *by how much* and lets you assert a fix. Lead with numbers.
- **Reuse the cached session.** The harness persists login (storageState). Don't log in repeatedly in a loop — many auth providers **rate-limit** rapid logins (you'll get timeouts).
- **Headless + emulation, not the chrome-devtools MCP**, in environments with no display server (the MCP needs one; Playwright headless doesn't).
- **Different sizes matter.** "Works on mobile" is not one width — check a few (small phone ~320–360, large phone ~412–430, and a non-overflowing width) so the fix is size-robust, not tuned to one device.
- **Don't commit secrets.** Creds live in the gitignored env file; the cached session is gitignored too.

## Device aliases

`/repro-on-mobile` and `/repro-on-desktop` are thin entry points to this skill with the device preset chosen for you.
