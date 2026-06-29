# AI-UI-slop catalogue — the named tells to hunt

The recognisable signature of AI-generated frontends: tool defaults nobody chose, shipped unchanged. Each entry has the **tell**, the **fix**, and **the legitimate inverse** — the case where the same shape is a deliberate, good choice and must be *defended*, not flattened.

Tags: **[impeccable]** = `impeccable detect` catches this deterministically; fold its hits in, don't re-hunt. **[judgment]** = needs the rendered look + a human call.

> The meta-fix behind almost every entry: make three deliberate choices — a non-default palette, a typeface that isn't Inter, and one layout primitive repeated with intent.

## Typography

- **Inter (or Geist / Space Grotesk) everywhere** — the default stack, especially on a centered hero. Fix: pick an intentional typeface with character. **[impeccable]**
- **Single font for everything** — headings, body, labels, buttons all one face/weight → no hierarchy. Fix: pair a display and a body face, applied systematically. **[judgment]**
- **Flat type hierarchy** — heading levels barely differ in size. Fix: a real scale (≈1.25×+ per level), measured. **[judgment]**
- **Serif-italic accent word** in an otherwise-sans hero; **all-caps section labels/body**; **crushed letter-spacing**. Fix: systematic pairing, sentence case, normal tracking. **[impeccable]**
- *Inverse:* a single, characterful typeface used with a real weight/size system is fine — don't demand two fonts for their own sake.

## Color & contrast

- **VibeCode purple / purple-cyan palette** — lavender that leaks from image generators; cyan-on-dark. The most recognisable AI tell. Fix: a deliberate palette with a point of view (earth tones, cream-and-pink, high-contrast mono+accent). **[impeccable]**
- **Default Tailwind palette** — `indigo/violet/purple` used as-is, or renamed to `primary` without changing the values. Fix: actually pick colors outside the default scale. **[judgment]**
- **Gradients everywhere; large colored glows / colored box-shadows; gradient text.** Fix: use sparingly and purposefully; desaturate and shrink shadows. **[impeccable]**
- **Low-contrast body text** — medium-grey on dark, barely passing or failing AA. Fix: validate the measured ratio (4.5:1 body, 3:1 large). **[judgment + measure]**
- **Permanent/reflexive dark mode** — dark as the universal default rather than a chosen theme. Fix: choose light or dark intentionally; support both well. **[judgment]**
- *Inverse:* a bold, distinctive, *consistent* palette — even a saturated or dark one — is a strength. Defend it.

## Layout & spacing

- **Colored left/top border on cards** — the single most reliable AI tell. Fix: shadow, background, or full border instead. **[impeccable]**
- **Identical icon-card grids** (icon-on-top feature cards), **stat-banner rows**, **numbered 1-2-3 step sequences** — the scaffold's stock sections. Fix: one layout primitive repeated with intent, not a catalogue of stock blocks. **[impeccable]**
- **Nested cards** — cards in cards in cards, each with its own padding + shadow. Fix: flatten; let whitespace group. **[impeccable]**
- **Oversized centered hero** with a vague headline ("Build the future"); **badge/eyebrow pill right above the H1**. Fix: a layout that reflects a brand opinion; question whether the badge serves hierarchy. **[impeccable]**
- **Monotonous spacing** — equal gaps everywhere, so nothing reads as grouped. Fix: tight gaps within groups, generous separation between sections (group padding > inner gap). **[judgment]**
- **Emoji icons in nav/sidebar.** Fix: an intentional icon system, or remove the decoration. **[impeccable]**
- *Inverse:* a single repeated card/section primitive is *good* — the slop is mixing five stock styles, not committing to one.

## Elevation & shape

- **Uniform 16px radius on everything; one shadow on everything** → flat, no hierarchy. Fix: an elevation system of 3–5 named, distinct levels mapped to tokens. **[impeccable]**
- **Glassmorphism overuse; hairline border + wide shadow; extreme border-radius.** Fix: restraint; pick the few levels you actually need. **[impeccable]**

## Motion

- **Bounce / elastic easing; image hover-zoom transforms.** Fix: smooth `ease-out`; animate `transform`/`opacity`, not layout. **[judgment]**
- *Inverse:* a deliberate, restrained micro-interaction at a meaningful moment is a strength.

## Copy

- **Marketing buzzwords** (streamline, empower, supercharge, world-class, enterprise-grade); **em-dash overuse**; **aphoristic "theater" cadence.** Fix: rewrite in a real product voice. **[judgment]**
- *Inverse:* concise, specific, branded copy is good even if confident — the tell is the generic SaaS register.

## State & completeness (not "slop" per se, but the same AI shortfall)

- **Missing loading / empty / error states** — the happy path only. A blank void where an empty state belongs, a raw flash instead of a skeleton, a generic toast instead of a field-adjacent error. Fix: design all three. **[judgment]**
- **Missing/suppressed focus ring** — `outline:none` with no replacement (WCAG F78). Fix: a visible focus indicator of any shape. **[judgment + measure]**
