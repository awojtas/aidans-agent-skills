---
name: repro-on-mobile
description: 'Reproduce and verify a front-end bug on a MOBILE viewport against the deployed app — a thin entry point to /repro-visual with the device preset set to a phone (narrow width, touch, mobile UA). Use when the user says it''s wrong "on mobile / on my phone / on a small screen", or to check a responsive fix at phone widths. Drives the per-repo Playwright harness to measure the real DOM (centre, fill, visibility) at narrow widths, not eyeball screenshots. If no harness exists yet, run /repro-visual-init first. Triggers: repro this on mobile, check it on my phone, it''s broken on a small screen, test the mobile layout, see the site as a phone.'
---

This is the **mobile** entry point to the `/repro-visual` skill. Follow `repro-visual`'s full workflow, with these viewport defaults:

- Use `--device mobile` (≈412px phone) **and** at least one smaller width like `--device 360` (and ~320 for a tight check) — a mobile fix must hold across phone sizes, not one device.

What to look for at each viewport is in **`/repro-visual`**'s visual audit eyeball checklist, including the mobile-specific mechanics section. Everything else — prerequisites, the harness CLI contract, measure-don't-eyeball, prove-the-fix-by-injection, verify-on-prod, cleanup — is also in **`/repro-visual`**. If the harness isn't set up in this repo yet, run **`/repro-visual-init`** first.
