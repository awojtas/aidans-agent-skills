---
name: marketing-assets
description: 'Produce the marketing assets from the positioning and plan — landing + pricing copy, social posts, directory listings, Product Hunt kit, press kit, push notification sequences, referral messaging, in-app review prompt copy, ASO copy pack (if on iOS/Android), social/OG metadata, and visual briefs. Copy is written to sound human (no AI tells), using the audience''s own words. Use when the user says "marketing copy", "landing page copy", "create assets", "launch kit", "press kit", "push notifications", "app store copy", or after the plan is set.'
---

# Marketing assets

Turns the brief into the actual words and asset specs. The agent writes everything textual; the human makes the visuals (the demo asset is their unfair advantage and worth real effort).

## When to use

After `marketing-plan`. Re-run to add assets for a new channel.

## Process

1. **Read `positioning.md`, `marketing-plan.md`, `research-findings.md`.**
2. **Write the copy**, close to the audience's verbatim language:
   - landing page (hero headline + sub-head + CTA, problem, what-it-does, how-it-works, trust signals + user quotes, closing CTA)
   - pricing page (e.g. free-beta framing + a "coming soon" teaser with email capture, if that's the plan)
   - social posts, directory listings, the Product Hunt kit (tagline, description, first comment)
   - `<title>` + meta description + **OG/Twitter card tags and a 1200x630 OG image brief**
   - **press kit** — branded screenshots (3–5), app icon (high-res), company bio (2–3 sentences), tagline + one-liner, social links, and a "coverage" placeholder for future press mentions. Package as a single shareable doc so journalists can self-serve without asking.
   - **push notification sequences (if the app uses push):** onboarding drip — day 1 ("here's the one thing to try"), day 3 ("have you tried X?"), day 7 re-establishment nudge; plus a re-engagement template for users inactive 7+ days. Keep each message under 100 characters with a clear action.
   - **referral messaging (if a referral program is in the plan):** the invite copy, per-platform share text (short enough for SMS/WhatsApp), and the reward stated plainly and immediately. Friction-free: one tap to share, one clear sentence on what the referrer gets.
   - **in-app review prompt copy + timing guidance.** Write two variants (iOS / Android). Trigger after a user completes a genuinely positive action — task finished, goal hit, streak milestone — not on first launch or during a slow moment. Include a one-tap "Not now" skip path.
   - **ASO copy pack (if on iOS/Android):** app title (≤30 chars, lead keyword first without sounding robotic), subtitle (≤30 chars), keyword field candidates ranked by relevance + competition, long description (benefits-first, ≤4000 chars, call out the wedge in the first two sentences), short description / promotional text (≤80 chars), and a screenshots brief specifying what story each of the first 3 screenshots should tell.
3. **Make it sound human.** Plain words, varied sentences, no em dashes, no AI-tell vocabulary. If the `content-plugin` prose-humanize skill is available, apply its checklist.
4. **Spec the visuals, don't fake them.** Write image briefs (hero demo GIF, OG image) for the human + image tool; leave clean placeholders so the build isn't blocked.
5. **Write to `docs/marketing/copy-*.md`.**

## Output

Approved-ready copy + asset specs for `marketing-launch`. Visual production is a human task.

## Lifecycle tracker

This skill owns the **Assets** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Assets` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Assets` line to ✅ (done).

Touch only the `Assets` line — leave every other stage exactly as found.
