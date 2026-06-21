---
name: marketing-research
description: 'Find out who the users are, where they gather, the exact words they use for their pain, and what they hate about competitors — by listening, not guessing. Drives a listening tool (e.g. Apify) to mine real discussion, then synthesises themes, verbatim language, a thread shortlist, and competitor pain into docs/marketing/research-findings.md. Use when the user says "marketing research", "voice of customer", "who are my users", "competitor research", or before positioning/copy.'
---

# Voice-of-customer research

The highest-leverage thing in the bundle. Real users describing their problem in their own words beats any copy you'd invent. Borrow their language back to them.

## When to use

Before positioning and copy, and periodically to refresh (recycle from `marketing-followup`).

## Process

1. **Read `profile.md`** for the ICP, where they gather, and the declared listening tool.
2. **Define/refine the ICP and venues** — the subreddits, communities, directories, and forums where this audience actually is.
3. **Listen.** Drive the listening tool to pull real discussion about the problem and the alternatives. Follow the method in `../../shared/tooling.md` (for Reddit: API actor, tight global search phrases, then filter to relevant communities — browser scrapers get blocked).
4. **Analyse, don't dump.** Pull out: recurring pain themes ranked by frequency; **verbatim phrases** real users use (gold for copy); the named competitors and what people dislike about each; a shortlist of specific threads where the product is a genuine answer (feeds value-first engagement later) and SEO topics.
5. **Write `docs/marketing/research-findings.md`** with quotes and the thread/SEO shortlist.

## Output

`research-findings.md` — feeds `marketing-positioning`, `marketing-assets`, and the thread list for `marketing-launch`/`marketing-followup`.

## Guardrails

Listening only. Do not scrape personal profiles to build cold-contact lists. See `../../shared/guardrails.md`.

## Lifecycle tracker

This skill owns the **Research** stage of the marketing lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/marketing-lifecycle.md`](../../shared/marketing-lifecycle.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Research` line to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Research` line to ✅ (done).

Touch only the `Research` line — leave every other stage exactly as found.
