---
name: marketing-launch
description: 'Run the actual promotion as per-channel runbooks — directory submissions, app review sites, a Product Hunt launch, value-first Reddit/forum posts, LinkedIn, press outreach, and a first-week retention push. The agent PREPARES everything; the human posts anything public. Each push is logged in the growth tracker. Use when the user says "launch", "Product Hunt", "submit to directories", "post to Reddit", "press outreach", or is ready to start promoting.'
---

# Marketing launch runbooks

Where prep becomes promotion. The hard rule: **agents prepare, humans post anything public** (see `../../shared/guardrails.md`). This protects accounts and the brand.

## When to use

After assets exist and readiness passes. For seed pushes and the main launch.

## Process

Read `marketing-plan.md`, the assets, and `../../shared/guardrails.md`. Then, per channel:

- **Directories (seed):** prep every listing (description, links, screenshots) as a copy-paste pack; human submits. One-time, permanent backlinks. Cover: BetaList, AlternativeTo, AppAdvice, and any niche directories surfaced in research. (Product Hunt is a full launch event, not a directory — see its dedicated runbook below.)
- **Review sites + niche press:** use the press kit from assets; identify 3–5 relevant review blogs, YouTube channels, or niche journalists who cover the category; draft a short personal pitch (one paragraph — not an attachment dump) and link the press kit; human sends. Third-party validation drives installs and builds long-lived backlinks that directories alone don't.
- **Product Hunt (the one big push):** assemble the full kit; line up the pre-launch email list for first-hours momentum; prep the launch-day cross-posts and a first-comment plan; the human runs the day. Launches win on pre-built audience, not luck.
- **Reddit / forums:** use the thread shortlist from research; draft genuinely-helpful, value-first replies where the product is the real answer; human posts. Never spam — read each sub's self-promo rule.
- **LinkedIn / brand:** draft posts in the owner's voice per the visibility constraint.
- **First-week retention push:** send the onboarding push notification sequence (from assets) to users who installed during launch. Also send the welcome / launch-announcement email to the beta list. The first 7 days determine whether a new user becomes a real user — treat this window like a concierge experience, not an afterthought. Prepare all messages; human triggers or schedules.

Log each push in the growth tracker (channel, effort, spend, link) so `marketing-metrics` can attribute results.

## Output

Channel-ready, human-postable packs + tracker rows. Nothing public is auto-posted.

## Lifecycle tracker

This skill owns the **Launch** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Launch` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Launch` line to ✅ (done).

Touch only the `Launch` line — leave every other stage exactly as found.
