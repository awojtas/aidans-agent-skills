---
name: marketing-metrics
description: 'Measure whether the marketing is actually producing real users — read the product funnel (e.g. PostHog), update the growth tracker''s channel→activated attribution, pull periodic off-site engagement (e.g. Apify), and report what''s working, where people drop off, and which channel to double down on. Distinguishes vanity metrics from real ones. Use when the user says "marketing metrics", "how''s the launch doing", "channel ROI", "funnel", or after a launch.'
---

# Marketing metrics

Tells you the truth about what's working so you stop guessing and double down.

## When to use

After launch and on a recurring cadence (drives `marketing-followup`).

## Two kinds of engagement, two tools

- **In-app engagement** (activation, retention, feature use) → the product-analytics tool (e.g. PostHog). This decides whether you have *real users*.
- **Off-site engagement** (post upvotes/comments, launch rank, mention volume) → the listening tool (e.g. Apify), periodic. Secondary: it explains *why* a channel worked, it is not the scoreboard.

## Process

1. **Read `profile.md` and `marketing-plan.md`** (funnel definition, targets, declared tools).
2. **Pull the funnel:** `visited → signed_up → activated → retained`, by channel where possible.
3. **Update the growth tracker:** channel → activated users and cost-per-activated. This is the scoreboard.
4. **Pull off-site engagement** periodically; drop into tracker notes.
5. **Report:** where the funnel leaks, which channel produces *activated* users cheapest, what to repeat and what to cut. A post can get 200 upvotes and zero signups — say so plainly.

## Output

A short verdict + a recommended next action, feeding `marketing-followup`.

## Lifecycle tracker

This skill owns the **Metrics** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Metrics` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Metrics` line to ✅ (done).

Touch only the `Metrics` line — leave every other stage exactly as found.
