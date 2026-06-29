# Coverage rubric — the mandatory dimension gate

The point of this rubric is the **gate**: the synthesis must walk every dimension and assign a status, so a whole concern (focus visibility, empty states, dark mode) can't be silently skipped because it didn't jump out of a screenshot.

## Status vocabulary (assign exactly one per dimension)

- **Covered** — findings exist; see the report.
- **Checked, nothing to fix** — genuinely inspected, genuinely fine. A first-class outcome; state it, don't omit it.
- **Gap** — not adequately inspected this run (e.g. couldn't reach a state, agent died). Say so; don't pass a gap off as "nothing to fix."
- **n/a** — doesn't apply (e.g. no dark mode offered, no forms).

## The dimensions, owner, and how it's measured

| # | Dimension | Owner lens | How it's measured (rendered + computed) |
|---|-----------|-----------|------------------------------------------|
| 1 | Visual hierarchy | Visual craft | Squint test on the screenshot; one dominant focal point per screen |
| 2 | Typography & scale | Visual craft | `font-size` per heading level; ratio ≥1.25×; ≤2–3 faces |
| 3 | Color & palette intentionality | Anti-slop | Is the theme customized vs default Tailwind/VibeCode-purple |
| 4 | Contrast (a11y) | Accessibility | **Measured ratio** from rendered colors: 4.5:1 body, 3:1 large |
| 5 | Spacing & rhythm | Visual craft | `gap`/`padding`/`margin`; group padding > inner gap |
| 6 | Elevation & shape | Anti-slop | `border-radius`/`box-shadow` variety; 3–5 distinct levels vs flat |
| 7 | Interaction states | State completeness | hover / focus / active / disabled actually present + distinct |
| 8 | Lifecycle states | State completeness | loading / empty / error designed (trigger/seed them) |
| 9 | Responsive | State completeness | 320 / 768 / 1024 / 1440 — overflow, reflow, target size ≥44px |
| 10 | Dark mode | State completeness | rendered in dark; contrast + palette hold up |
| 11 | Focus visibility & keyboard | Accessibility | Tab through; visible indicator (F78); logical order; labels |
| 12 | Usability heuristics | Heuristics | Nielsen's 10 — status, control, error prevention/recovery, consistency |
| 13 | Motion | Anti-slop | easing curve; transform/opacity vs layout animation |
| 14 | Copy | Anti-slop / Heuristics | buzzwords, em-dash overuse, generic SaaS register |

Reuse `../repro-visual/SKILL.md` (visual-audit mode) as the measurement battery for #1–11 — its `page.evaluate` checks (overflow, off-screen, truncation, small targets, broken/distorted images, unlabelled inputs, clipped popups) and eyeball checklist map directly onto these rows. Don't duplicate it.

## Static probes (run when the rendered path is degraded or to corroborate)

```bash
grep -rn --exclude-dir=node_modules -i "font-family\|'Inter'\|Geist\|Space Grotesk" . | head   # font choices
grep -rn --exclude-dir=node_modules "indigo-\|violet-\|purple-\|fuchsia-\|cyan-" . | wc -l       # default palette reliance
grep -rn --exclude-dir=node_modules "outline:\s*none\|outline:\s*0" .                            # suppressed focus (F78 candidates)
cat tailwind.config.* 2>/dev/null | grep -iA3 'extend\|colors\|fontFamily'                       # is the theme customized?
```

A hit is a smell, not a verdict. Anything load-bearing is confirmed against the rendered, measured result (see `synthesis-checklist.md`).
