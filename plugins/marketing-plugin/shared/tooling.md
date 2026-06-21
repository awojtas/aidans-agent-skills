# Tooling notes

The app's `profile.md` declares which tools are in play. Skills read that, they do not hardcode a vendor. This file is the how-to plus hard-won gotchas, so nobody re-debugs them.

> Secrets never live in the repo. Read a token from the environment or a local file outside the repo (e.g. `~/.<tool>/token`, perms `600`), and reference it inline (`$(cat ~/.<tool>/token)`) so it never lands in a command log or transcript.

## Listening / research (e.g. Apify)

- **Division of labour:** the tool COLLECTS raw data; the agent ANALYSES it. Never make a human read a spreadsheet of 2,000 comments.
- **Reddit gotcha (learned the hard way):** browser/puppeteer scrapers get 403-blocked on Reddit search even through a residential proxy. Use an **API-based actor**, run a **global search on tight, domain-specific phrases**, then **filter the results to the relevant communities in analysis**. Subreddit-restricted search URLs are often ignored by API actors — do not rely on them.
- **Keep it lean:** periodic pulls (around a launch, then monthly), not an always-on listener. Mind free-tier credit caps.
- **Use it for:** voice-of-customer language, competitor pain, thread shortlists, brand monitoring, and off-site engagement measurement (post/launch metrics). NOT cold lead lists (see `guardrails.md`).

## Product analytics (e.g. PostHog)

- This measures **in-app engagement** — the engagement that decides if you have real users. Distinct from off-site engagement (that's the listening tool).
- Instrument the funnel: `visited → signed_up → activated (first real action) → retained (came back)`. Define "activated" as the moment the user gets the product's core value.
- Gate on an env var so dev/preview traffic does not pollute data. Send no PII in event properties.

## Living docs (e.g. Google Drive)

- **Split:** the repo holds versioned text (plan, positioning, copy, research, runbooks); Drive holds living spreadsheets/dashboards (growth tracker, launch checklist, asset inventory).
- Copy these from a central **"Marketing Templates"** Drive folder into the app's `Projects/<App>/` folder during `marketing-init`.

## Email (e.g. Loops / MailerLite / Resend)

- Needed for opt-in capture ("notify me"), launch announcements, light nurture.
- **Deliverability needs domain auth (SPF/DKIM/DMARC)** on the sending domain — a one-time human DNS step. Skip it and launch mail lands in spam.
- See `guardrails.md` for anti-spam law.

## Images / scheduler

- Images: generate a base (e.g. Gemini), polish (e.g. Photoshop). The hero demo asset is worth real effort — it is what makes a launch look professional.
- Scheduler: batch a month of posts in one sitting; the human approves, the tool drips them out.
