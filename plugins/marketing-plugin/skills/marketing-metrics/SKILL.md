---
name: marketing-metrics
description: 'Measure whether the marketing is actually producing real users — read the product funnel (e.g. PostHog), track retention curves (D1/D7/D30), LTV, ARPU, churn, push performance, and referral conversion; update the growth tracker''s channel→activated attribution; pull periodic off-site engagement (e.g. Apify); and report what''s working, where people drop off, and which channel to double down on. Use when the user says "marketing metrics", "how''s the launch doing", "channel ROI", "funnel", "LTV", "churn", or after a launch.'
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
5. **Pull the retention curve:** Day-1, Day-7, and Day-30 retention rates. This is the most honest signal of product-market fit — a beautiful launch that leaves a flat retention curve just means users tried and left.
6. **Report the full scoreboard:**
   - **Funnel leaks:** where in `visited → signed_up → activated → retained` the drop is worst, and the likely cause
   - **Channel → activated attribution:** which channel produces real users cheapest
   - **LTV proxy:** retention rate × ARPU over the cohort window. If LTV < CAC, paid acquisition is burning money
   - **ARPU (average revenue per user):** total revenue ÷ active users; signals whether monetisation is working
   - **Churn rate:** users lost ÷ total users per period; catch the silent bleed early
   - **Push notification performance (if running):** send rate, open rate, conversion to action. Open rate below ~5% = notification fatigue or irrelevant content
   - **Referral conversion (if running):** invites sent → referral installs → activated from referral
   - A post can get 200 upvotes and zero activated users — say so plainly. Vanity ≠ signal.

## Output

A short verdict + a recommended next action, feeding `marketing-followup`.

## Lifecycle tracker

This skill owns the **Metrics** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Metrics` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Metrics` line to ✅ (done).

Touch only the `Metrics` line — leave every other stage exactly as found.
