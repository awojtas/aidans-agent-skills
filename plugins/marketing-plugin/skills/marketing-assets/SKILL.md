---
name: marketing-assets
description: 'Produce the marketing assets from the positioning and plan — landing + pricing copy, social posts, directory listings, the Product Hunt kit, social/OG metadata, and image briefs for the human to produce. Copy is written to sound human (no AI tells), using the audience''s own words. Use when the user says "marketing copy", "landing page copy", "create assets", "launch kit", or after the plan is set.'
---

# Marketing assets

Turns the brief into the actual words and asset specs. The agent writes everything textual; the human makes the visuals (the demo asset is their unfair advantage and worth real effort).

## When to use

After `marketing-plan`. Re-run to add assets for a new channel.

## Process

1. **Read `positioning.md`, `marketing-plan.md`, `research-findings.md`.**
2. **Write the copy**, close to the audience's verbatim language:
   - landing page (hero headline + sub-head + CTA, problem, what-it-does, how-it-works, trust, closing CTA)
   - pricing page (e.g. free-beta framing + a "coming soon" teaser with email capture, if that's the plan)
   - social posts, directory listings, the Product Hunt kit (tagline, description, first comment)
   - `<title>` + meta description + **OG/Twitter card tags and a 1200x630 OG image brief**
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
