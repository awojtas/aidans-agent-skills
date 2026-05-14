# Interview Playbook

How to draw an initial architectural design out of a project owner without going past "first stab". This is the question bank the SKILL.md runbook uses during each phase.

## Conversational principles

- **Light touch.** This is a first stab; don't pressure-test like `/requirements-validation` does. Capture the user's current thinking and surface what's clearly unknown.
- **One topic at a time.** Don't ask 12 questions about hosting in the same breath as 12 about data. Walk the topics in the order below.
- **Document open questions immediately.** When the user says "I'm not sure" or "let's figure that out later" — add an entry to `05-open-questions.md` right then.
- **Default-assume sensibly.** If the project doesn't know, propose a sensible default and tag it as a default-assumption. "I'll assume single-region us-east-1 for v1 unless you'd rather choose differently."

## Topic 1 — System type

Goal: classify the system's basic shape so the rest of the conversation has the right context.

- What kind of system is this? Web app / mobile app / desktop / CLI / library / distributed service / hybrid?
- Who's the primary user — humans through a browser? An app on their phone? A developer calling an API? A scheduled job?
- Does it run for one user at a time (CLI, embedded) or many users simultaneously (web SaaS)?
- Is it always-on or run-on-demand?

**Why this matters:** the user's example — a messaging app over a serial cable vs cloud infrastructure — is exactly the kind of decision that needs to land before requirements. The shape of "messaging" is utterly different in the two cases.

## Topic 2 — Hosting / runtime

- Where will this run? Cloud (which provider)? Self-hosted? Hybrid? On user's device only?
- If cloud: is there an existing vendor commitment (org policy, existing accounts)?
- What's the budget shape — free-tier-only, low monthly cap, or scale-as-you-go?
- Single region (where?) or multi-region from day one?
- Edge (Cloudflare, Vercel Edge, fly.io) or origin (single-region)?
- What's the runtime — long-lived processes, containers, serverless functions, edge functions, JAMstack static?

## Topic 3 — Major components

- What are the moving parts? Typically: web UI, API, database, background worker.
- Are there separable services or is this a single application?
- Any pieces you already know you'll need (search index? real-time hub? AI inference?)
- Any pieces you definitely won't have (no admin app yet; no public API yet)?

**Don't pre-design microservices.** Default to the smallest set that captures reality. A modular monolith is almost always the right starting shape — split when you have evidence you need to.

## Topic 4 — Stack

- Language(s)? Why this language?
- Framework? Default to the team's existing competence; don't pick something for novelty.
- Major libraries you already know you want (ORM, auth, UI components)?
- Anything ruled out (team can't maintain Rust; security team blocks XYZ library)?

## Topic 5 — Data

- What top-level entities does the system own? (Users, Accounts, Resource X, ...)
- Roughly what shape — relational, document, graph, time-series?
- Sensitive data classes — PII, financial, health, special-category under GDPR?
- Volume estimate — rows in the biggest table at year 1? at year 5? (Even rough guesses are useful.)
- Real-time requirements — synchronous DB queries acceptable, or do we need streaming / pub-sub / event sourcing?

## Topic 6 — External integrations

- What third-party services are already chosen or required?
- Auth provider — built-in, Auth.js, Clerk, Auth0, Cognito, SSO?
- Payments — Stripe, Paddle, Lemon Squeezy, custom?
- Email — Resend, Postmark, SES, SendGrid?
- Error tracking — Sentry, Honeybadger, Rollbar?
- Analytics — PostHog, Plausible, Amplitude, Mixpanel?
- Any partner integrations that are non-negotiable?

For each: what's the alternative we'd swap to if this one became a problem? (Cheap insurance against lock-in.)

## Topic 7 — Architecture pattern fit

Once the above is sketched, name the **pattern** that best fits:

- Monolith / modular monolith
- Microservices (rare for early-stage; flag if proposed)
- Serverless / functions-as-a-service
- JAMstack (static + edge functions)
- Event-driven (queues + workers)
- Hexagonal / Ports & Adapters
- Client-server (real-time hub model)

See `references/architecture-patterns.md` for when each pattern fits. The pattern name goes in `00-system-overview.md` under "Why this shape?"

## Topic 8 — Decisions vs unknowns

Walk back through topics 1-7. For each piece of information collected:

- If it's **decided** with reasoning → entry in `04-decisions.md`.
- If it's **unknown / punted** → entry in `05-open-questions.md`.
- If it's **default-assumed** → entry in `04-decisions.md` *and* flagged as a default that should be confirmed later (with the trigger condition in the decision's "Re-decide when" line).

## Anti-patterns to push back on

If the user says any of these during the interview, gently push back:

- **"Let's use microservices from day one."** Almost always wrong for early-stage. Recommend modular monolith; capture the future-split as an open question.
- **"Let's pick the latest [shiny framework]."** Stack stability beats novelty. Recommend defaulting to the team's existing competence.
- **"We need Kubernetes."** Almost never true for early-stage. Serverless or managed PaaS until you have evidence you outgrow them.
- **"We'll figure out auth ourselves."** Roll-your-own auth is a security risk. Recommend a managed provider unless there's a hard reason.
- **"We need multi-region from day one."** Adds 10x complexity. Capture as an open question unless there's a contractual / regulatory driver.
- **"We need real-time everywhere."** Real-time has real cost (WebSockets, hub state). Confirm it's actually needed, or polling/SSE/long-polling is the lighter option.

In all cases: don't dictate. Surface the trade-off, propose the lighter default, and let the user decide. If they push back with a good reason, capture the reason in the ADR.
