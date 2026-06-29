# Synthesis checklist — the reviewer-in-chief gate

You have the lens sub-agents' returns (strengths, findings, defended choices), the `impeccable detect` output, and the rendered capture (screenshots + measured computed values). Turn raw findings into a verified, opinionated, executable review. Work this in order.

## 1. Walk the coverage rubric — assign every dimension a status

Open `coverage-rubric.md`. For all 14 dimensions record **covered / checked, nothing to fix / gap / n/a**. A dimension a lens didn't reach is a **gap**, stated honestly — never a silent omission. If the run was static-only, the rendered dimensions (contrast, states, dark mode, motion) are **gaps**, and the static-only banner goes at the very top.

## 2. Verify by measurement

Every **Critical/High** finding must cite a measured value, not an impression:

- Contrast → the computed ratio from the rendered colors ("2.3:1, fails AA").
- Spacing/type → the px / token values.
- A slop tell → the rendered evidence (screenshot) plus, where applicable, the `impeccable` rule it matched.

A finding that can't be backed by a value or a screenshot is **downgraded or dropped**. `impeccable` / static-probe hits are pre-verified deterministically — fold them in without re-deriving, but still apply the intentional-vs-default judgment (a flagged palette may be a deliberate brand choice). **Cross-confirmation** (two lenses independently flag the same thing — e.g. the a11y lens and the anti-slop lens both flag the dark-mode body text) is a strong signal; call it out.

## 3. Strengths + the consistency through-line

Assemble the **strengths** section from what the lenses judged deliberately well-designed. Then find the **"they already do this right on screen X, just not screen Y"** through-line — it reframes a gap as a consistency fix in the product's own idiom, which lands far better than "your design is wrong." Pull the defended bold choices into strengths so the review doesn't read as "make it safer."

## 4. Anti-over-design pass on your own review

Turn the lens on the recommendations:

> "Which of these is itself over-engineering?"

Prefer the smallest fix that works — change three palette tokens, not "adopt a design system"; fix the one contrast variable, not "rework the theme." Cut or downgrade any recommendation heavier than the problem warrants. **Reward restraint**, and reward "keep this — it's an intentional point of view" as a valid outcome.

## 5. Intentional vs default — make the call

For every slop candidate, decide explicitly: deliberate decision (defend) or unchosen default (flag). Don't flatten a real, consistent point of view toward the generic default just because it's unusual. This judgment is the spine of the whole review.

## 6. Calibrate severity

- **Critical** — blocks use or fails a hard a11y bar (text unreadable, no focus indicator anywhere, primary CTA invisible, broken layout at a common breakpoint).
- **High** — clear slop signature or a missing lifecycle state that materially hurts the product's feel/usability.
- **Medium** — craft issues (weak hierarchy, monotonous spacing, palette leaning on defaults).
- **Low** — polish (minor inconsistency, a single off icon).

A busy or dense screen is not automatically a finding — investigate before flagging.

## 7. Emit the ruthless action list

The final "what I'd actually do" is ordered by **impact-per-effort**:

- Lead with the highest-signal, lowest-effort wins — usually the palette/typeface swap that kills the slop signature, and the broken/missing states.
- Mark anything that depends on something else (e.g. "pick the palette" before "fix the contrast tokens").
- Stop short of everything — the user should be able to read only this section and start.
- If the repo has no slop guard, recommend wiring `impeccable detect` (or its CI mode) into the pipeline so the mechanical tells can't reappear.

## Tone

Opinionated and specific over comprehensive and hedged. Every finding: **severity + screenshot/`file:line` + measured value + concrete fix.** Recommend, don't survey.
