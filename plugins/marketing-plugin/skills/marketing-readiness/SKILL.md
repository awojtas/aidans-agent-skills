---
name: marketing-readiness
description: 'Check whether an app is actually ready to have traffic driven at it, before any promotion starts. Audits the live site, onboarding/first-run, analytics wiring, signup + pricing story, social-share metadata, legal basics, app store listing quality (if on iOS/Android), and campaign infrastructure (deep links, push opt-in timing); produces a severity-ranked punch-list and files GitHub issues for the gaps. Use when the user says "is my app ready to market", "pre-launch audit", "marketing readiness", or before running marketing-launch.'
---

# Is the app ready to be marketed?

Promotion is the last 20%. Driving traffic at an app with no onboarding, no way to measure conversion, and no share preview is pouring water into a bucket with no bottom. This skill finds the holes first.

## When to use

Before any public promotion, and any time the product changed materially.

## Process

Read `docs/marketing/profile.md`, then audit:

1. **The live site.** Does the apex serve a marketing page or dump visitors into the app? Are there `<title>`, meta description, and **Open Graph / Twitter card tags + image** (shared links with no preview image quietly kill click-through)? Mobile glance-view OK? Reasonable load speed?
2. **First-run / onboarding.** Does a brand-new user land somewhere friendly, or on a blank screen? This is the activation blocker — the difference between a signup and a real user.
3. **Analytics.** Is the funnel instrumented (`visited → signed_up → activated → retained`)? You cannot manage what you cannot see.
4. **Signup + pricing story.** Can a stranger sign up? Is there a pricing page (even a "free beta + coming soon" one)? Launch visitors expect one.
5. **Legal basics.** Privacy notice, analytics consent if needed, terms.
6. **App store listing (if on iOS/Android).** Does the title lead with the primary keyword without sounding robotic? Does the description open with benefits, not features? Are screenshots storytelling — do they convey what the experience *feels* like rather than just showing raw UI? Is an in-app review prompt implemented, timed to fire after a user completes a genuinely positive action (task completed, goal hit, streak reached) — not on first launch, where most users decline?
7. **Campaign infrastructure.** Can marketing campaigns (ads, emails, push notifications) deep-link users to a specific in-app screen, not just the home screen? If push is in the plan: is the permission ask timed to a meaningful moment rather than cold on first app open? Drop-off here silently caps your push reach for good.

## Output

A punch-list ranked by severity, and a GitHub issue per real gap (use the repo's existing labels; do not invent labels). Call out the single highest-leverage fix. Recommend holding public promotion until the essentials pass.

See `../../shared/guardrails.md` for the legal items.

## Lifecycle tracker

This skill owns the **Readiness** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Readiness` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Readiness` line to ✅ (done).

Touch only the `Readiness` line — leave every other stage exactly as found.
