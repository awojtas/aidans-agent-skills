# Default platform stack — a steer, not a mandate

When a project needs a capability — hosting, a database, payments, analytics — and the user has **no preference and no existing constraint**, these are sensible defaults to propose. The list reflects what has become the common, well-trodden path for AI-assisted app development: generous free tiers, good docs, fast to wire up, well-supported by AI coding tools.

**This is a steer, not a mandate.** It loses to, in priority order: an explicit user choice; an existing org standard; a tool the repo already uses; a genuine technical reason to pick differently. Never override any of those with a default from this list — if the user names Fly.io instead of Vercel, that wins, no argument.

The second job of this list is to **prompt consideration**. Walking the capabilities below makes the user decide *do I actually need this?* — analytics and error tracking especially are easy to forget until far later than you'd want.

## Core — almost every web app

| Capability | Default | Notes |
|---|---|---|
| Version control + CI | **GitHub** | Also hosts Actions, issues, PRs. |
| Hosting + deploy | **Vercel** | Per-branch preview deploys; generous free tier. |
| Backend — Postgres DB, storage, realtime | **Supabase** | Managed Postgres; bundles file storage, realtime, and auth. |
| Domain registrar + DNS | **Cloudflare** | One vendor for registration *and* DNS; at-cost domains. |

## Common — most apps; raise each one explicitly so it's a conscious choice

| Capability | Default | When you need it |
|---|---|---|
| Auth | **Clerk** | Signups / logins. If you're already on Supabase and don't need Clerk's org / B2B features, Supabase Auth is fine — don't run both. |
| Transactional email | **Resend** | The moment you have signups, password resets, receipts, or notifications. |
| Error tracking | **Sentry** | From day one — cheap insurance; catches what users won't report. |
| Product analytics | **PostHog** | If you want to know how the product is actually used — funnels, retention, feature flags. |
| Payments | **Stripe** | Only if you charge money. |

## Situational — only when a specific need surfaces

| Capability | Default | When you need it |
|---|---|---|
| Redis — cache, rate-limit, sessions | **Upstash** | Rate limiting, session store, hot-data cache, lightweight queues. |
| Background jobs + durable workflows | **Inngest** | Scheduled jobs, multi-step workflows, retries, event-driven fan-out. |
| SMS | **Twilio** | Phone verification, SMS notifications, OTP. |
| Vector database | **Pinecone** | RAG, semantic search, embeddings. Most apps never need this — don't add it speculatively. |
| User testing | **TestFi** | Recruiting testers for usability feedback. |

## How the platform skills use this

- **`/platform-design`** walks these capabilities during the hosting / stack / data / integrations topics — surfacing each so the user consciously considers it, and proposing the default (recorded as an ADR with a re-decide trigger) wherever the user has a need but no preference.
- **`/platform-provision`** provisions whatever the architecture recorded. If the architecture names a capability but no specific vendor, this list is the fallback pick to *offer* — but confirm with the user before standing up an account they didn't choose.
