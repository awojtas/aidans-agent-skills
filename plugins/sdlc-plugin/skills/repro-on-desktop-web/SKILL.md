---
name: repro-on-desktop-web
description: Reproduce and verify a front-end bug on a DESKTOP browser viewport against the deployed web app — a thin entry point to /repro-visual with the device preset set to a wide screen. Use when the user reports a layout/responsive bug at desktop widths, or to confirm a fix doesn't regress the wide-screen layout. Drives the per-repo Playwright harness to measure the real DOM (centre, fill, visibility, overflow) at desktop widths, not eyeball screenshots. If no harness exists yet, run /repro-visual-init first. Triggers: repro this on desktop web, check the desktop layout, it's wrong on a wide screen, verify the desktop view, test at full width.
---

This is the **desktop web** entry point to the `/repro-visual` skill. Follow `repro-visual`'s web path workflow, with these viewport defaults:

- Use `--device desktop` (≈1280px). Also check a width that still overflows or a breakpoint boundary if the bug is near one.
- After fixing a mobile bug, always re-run at desktop width too — a narrow fix often regresses the wide layout.

What to look for at each viewport is in **`/repro-visual`**'s visual audit eyeball checklist, including the desktop-specific patterns section. Everything else — prerequisites, the harness CLI contract, measure-don't-eyeball, prove-the-fix-by-injection, verify-on-prod, cleanup — is also in **`/repro-visual`**. If the harness isn't set up in this repo yet, run **`/repro-visual-init`** first.
