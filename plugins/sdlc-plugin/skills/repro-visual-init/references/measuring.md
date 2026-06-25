# Measuring the DOM (and proving a fix)

The whole point of this harness is to replace "looks right to me" with **numbers**.
Write a `measureScreen()` that returns the few metrics that decide whether the bug
is present, then assert against them across viewport sizes.

## Pick metrics that define "correct"

Run inside `page.evaluate(() => …)` using `getBoundingClientRect()`,
`scrollWidth`/`clientWidth`, and `getComputedStyle`. Common ones:

- **Centred?** `centerOffsetPx = (el.left + el.right)/2 − (container.left + container.right)/2`. ≈ 0 is centred.
- **Fully visible / not clipped?** `el.left >= container.left && el.right <= container.right`.
- **Fill %** of its container: `(el.width / containerWidth) * 100` — for "too tight / too loose".
- **Overflow?** `scrollWidth > clientWidth + 1` (horizontal scroll present).
- **Overlap?** compare two elements' rects (e.g. is a sticky header covering content).
- **Off-screen?** rect outside the viewport (`right < 0 || left > innerWidth`).

### Beware the *visible* region, not the raw container
If a column/header is `position: sticky`, it overlays part of the viewport — so
the area where content should centre is **the container minus the sticky element**.
Measure the sticky element's edge and centre within `[stickyEdge, containerRight]`,
not within the whole container. (This exact trap caused a "centred but looks
left-shifted" bug.)

## Always check several widths
"Mobile" is not one size. Measure at e.g. **320, 360, 412/430**, and a width where
the layout no longer overflows (so the fix is size-robust, not tuned to one phone).
Drive each with `--device <width>`.

## Prove the fix *before* writing code (inject-and-remeasure)
You can apply a candidate fix to the live DOM and re-measure — no deploy needed:

```js
await page.evaluate(() => {
  const el = document.querySelector('.scroller');
  // e.g. test a corrected centring:
  el.scrollLeft = /* computed target */ 0;
});
const after = await measureScreen(page);
```

If the injected version measures correct across all widths, the fix is right —
then implement it in the component. This converts guesswork into evidence and
stops the "I think this fixes it → user says still broken" loop.

## Screenshots: confirm, don't judge
Take a screenshot to *sanity-check* what the numbers say (and to share with the
user), but lead with the measurements — a screenshot won't tell you it's off by
64px, and you can't assert a regression test against a vibe.

## Verify on production after deploy
Re-run the same `--measure` across the same widths once the fix is live. Preview
deploys are often SSO-protected (see auth-strategies.md) — verify on prod, or wire
a bypass token.
