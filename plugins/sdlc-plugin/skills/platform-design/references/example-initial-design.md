# Worked Example: Initial Design for a hypothetical "Codeview" project

A condensed run of `/platform-design` on a hypothetical project whose README says:

> **Codeview** — a tool for inspecting GitHub repositories, with a three-state toggle (Preview / Code / Blame) on every file view. Markdown renders inline. Designed for developers reading other people's code.

This is the same case that the `create-requirements` and `implement-task` worked examples build on, so the architecture you see here is what those skills later assume.

The example shows: the interview by topic, the resulting docs, and the open questions that get punted to later phases.

---

## Topic 1 — System type

**Agent.** *What kind of system is this? Web app, mobile, CLI, library, embedded?*

**User.** *Web app. Probably also a mobile-responsive view.*

**Agent.** *Who's the primary user?*

**User.** *Developers reading code. They land on a file URL, want to see it rendered, then maybe see git blame.*

**Agent.** *Always-on or run-on-demand?*

**User.** *Always-on. Public URLs that anyone can hit.*

**Captured.** Web app, public, always-on, primary user is a developer in a browser.

---

## Topic 2 — Hosting / runtime

**Agent.** *Where will it run? Cloud? Self-hosted?*

**User.** *Vercel for the frontend. Maybe Vercel functions for the API too — I'm familiar with that stack.*

**Agent.** *Budget shape — free tier, low cap, scale-as-you-go?*

**User.** *Low cap for v1. Don't want to spend more than $50/month until there's traction.*

**Agent.** *Single region or multi-region?*

**User.** *Single region — us-east. I haven't thought about geographic distribution yet.*

**Agent.** *Capturing as ADR. The multi-region question gets an open-question entry.*

**Captured.** Vercel + Vercel functions, us-east, $50/month soft cap. Multi-region → OQ.

---

## Topic 3 — Major components

**Agent.** *What are the moving parts? Web UI, API, database, worker, ...?*

**User.** *Web UI for sure. An API to fetch git data — the renderer is its own service we depend on (separate). Probably a cache because parsing big files is slow. Maybe a worker for periodic refresh of indexed repo data.*

**Captured.**
- Web UI (Next.js)
- API (Vercel functions, same Next.js app)
- Cache (Redis on Upstash)
- Background worker (Inngest for periodic refresh)
- Database (Postgres — for index of repos, user prefs, etc.)
- Blob store for parsed-file caches → flagged for later

---

## Topic 4 — Stack

**Agent.** *Languages, frameworks?*

**User.** *TypeScript everywhere. Next.js 15 App Router for the UI. Drizzle ORM. Auth.js for sign-in.*

**Agent.** *Anything ruled out?*

**User.** *No microservices. No Kubernetes. Keep it boring.*

**Captured.** TypeScript / Next.js 15 / Drizzle / Auth.js. Modular monolith on serverless.

---

## Topic 5 — Data

**Agent.** *What top-level entities?*

**User.** *User. Indexed Repo (a GitHub repo the user has registered for inspection). Cached File Snapshot (recent fetches). Settings.*

**Agent.** *Sensitivity?*

**User.** *User email is PII. Everything else is public-data-derived. No payments, no special-category PII.*

**Agent.** *Volume estimate at year 1?*

**User.** *Maybe 1k users; 10k indexed repos; cached snapshots evicted after a week so the cache table is bounded.*

**Captured.** Postgres for relational. Redis for snapshot cache (TTL-based). Blob store deferred.

---

## Topic 6 — External integrations

**Agent.** *Auth provider?*

**User.** *GitHub OAuth (it's the natural login for our user base). Via Auth.js.*

**Agent.** *Payments?*

**User.** *None for v1.*

**Agent.** *Error tracking, analytics, email?*

**User.** *Sentry for errors. PostHog for analytics. Resend for transactional email (welcome, password reset).*

**Agent.** *The renderer service you mentioned — what's the integration?*

**User.** *Their public API. I'll fetch their `supported-extensions.json` manifest at build time to know which file types to show Preview for.*

**Captured.** GitHub OAuth via Auth.js, Sentry, PostHog, Resend, renderer service API.

---

## Topic 7 — Architecture pattern fit

**Agent.** *Given all of the above, the pattern is:* **modular monolith on serverless functions**, with a queue-backed worker tier and edge caching for read-heavy paths. *I'll capture this in 00-system-overview.md.*

**User.** *Yes.*

---

## Topic 8 — Decisions vs unknowns

ADRs captured:

- ADR-001: Use Postgres as the primary store.
- ADR-002: Deploy as Vercel serverless functions, not containers.
- ADR-003: Use Auth.js with GitHub as the only OAuth provider.
- ADR-004: Modular monolith over microservices.
- ADR-005: Single-region (us-east-1) for v1.
- ADR-006: Read renderer's `supported-extensions.json` at build time (resolves a question the requirements skill would later ask).

Open questions captured:

- OQ-001: Multi-region — revisit when EU traffic > 20%.
- OQ-002: Dedicated blob store (R2 / S3) for parsed-file caches — revisit when Redis memory pressure becomes a signal.
- OQ-003: Whether to build a public API surface for third-party tools — revisit when a partner asks.

---

## Resulting `docs/architecture/` folder

After this 30-minute conversation, the folder contains:

```
docs/architecture/
├── README.md                       (4 lines of front-matter + the table of contents from the template)
├── 00-system-overview.md           (~50 lines: system type, users, context diagram, container view, "Why this shape?" paragraph)
├── 01-stack-and-hosting.md         (~40 lines: tables filled with the actual choices)
├── 02-data-and-storage.md          (~40 lines: entity sketch, sensitivity, retention, single-region note)
├── 03-external-integrations.md     (~30 lines: 5 integrations + sub-processor list + failure-mode table)
├── 04-decisions.md                 (6 ADRs, each 1-2 paragraphs)
└── 05-open-questions.md            (3 OQs, each with revisit trigger)
```

Total: ~250 lines of markdown, written in a 30-minute conversation. Light, focused, useful.

---

## What this example demonstrates

1. **Light touch is the point.** The interview is 7 topics, each 3-5 questions. The user's first-stab thinking gets captured; perfection isn't the goal.
2. **Defaults are surfaced, not hidden.** "Single-region us-east-1 for v1" is an explicit ADR with a re-decide trigger, not a buried assumption.
3. **Open questions are first-class.** OQ-001/002/003 capture what the team deliberately didn't decide — and what would unblock the decision.
4. **The output informs downstream work.** When `/requirements-create-from-design` runs next, it can ask requirement questions in the context of "this is a serverless web app on Vercel with GitHub OAuth and Postgres" — not "what kind of system is this even?" That's the whole point.
5. **The renderer-extension-list decision in ADR-006 resolves a question** that the `create-requirements` worked example later treats as an open question (OQ-005 in that example). In a real flow, the architecture skill would resolve it first and the requirements skill would skip the open question. The two examples are sequential snapshots — different points in time, same project.
