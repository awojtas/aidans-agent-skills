# Architecture Patterns

A short reference of the most common architectural patterns and when each fits. The skill uses this during Topic 7 of the interview ("name the pattern that best fits").

The patterns aren't mutually exclusive — most real systems combine a couple (e.g. "modular monolith on serverless functions with an event-driven worker tier").

## Monolith (single deployable)

**Shape.** One application, one deployable artefact, one process model.

**Fits when.**
- Single team (or solo).
- One product domain at this stage.
- Operational simplicity is the priority.
- No clear sub-system that needs independent deploy / scaling.

**Trade-offs.** Easy to start, easy to deploy, fast feedback. Can grow into a "ball of mud" without internal discipline.

**Modern variant:** the **modular monolith** — a monolith with strong internal module boundaries (e.g. Rails engines, Java modules, separate Go packages with explicit interfaces). Best-of-both for most early-stage products. ([Fowler on monolith vs microservices](https://martinfowler.com/bliki/MonolithFirst.html).)

## Microservices

**Shape.** Multiple independently deployable services, each owned by a small team, each with its own data store.

**Fits when.**
- Multiple teams large enough to own a service each.
- Different services have genuinely different scaling shapes.
- A specific service has wildly different release cadence from the rest.
- The cost of coordination across teams exceeds the cost of inter-service communication.

**Trade-offs.** Independent scaling and deploy, technology heterogeneity. *Bought with:* network complexity, distributed-systems issues (consistency, retries, idempotency), operational overhead.

**Warning.** Almost always premature for early-stage projects. Fowler: "almost all the successful microservice stories have started with a monolith that got too big and was broken up." ([MonolithFirst](https://martinfowler.com/bliki/MonolithFirst.html).) If suggested at this stage, push back — recommend modular monolith first, plan the split as an open question.

## Serverless / Functions-as-a-Service

**Shape.** Stateless functions invoked on demand, scaled by the platform. No persistent processes.

**Fits when.**
- Variable / spiky load (autoscale to zero is genuinely useful).
- Solo or small team without dedicated ops.
- Cost-sensitive — pay-per-invocation beats fixed instances at low traffic.
- Workload fits the platform's limits (typically ≤10-15s execution, ≤256MB RAM, no WebSocket persistence on the same path).

**Trade-offs.** Operational simplicity, autoscale, cost-at-zero. *Bought with:* cold starts, execution-time limits, no in-memory state between invocations, vendor-specific runtime quirks. Long-running or stateful workloads need a sidecar (queue worker, durable execution).

## JAMstack / Edge-rendered

**Shape.** Static HTML + JavaScript shipped to a CDN, dynamic data fetched at the edge or client-side. Often paired with serverless functions for the dynamic bits.

**Fits when.**
- Content-heavy (marketing, docs, blogs, e-commerce browsing).
- Read-heavy with occasional writes.
- Global latency matters (CDN serves from near the user).
- SEO matters.

**Trade-offs.** Best-in-class performance and SEO for the static part. *Bought with:* dynamic-data plumbing is more thought-through (ISR, on-demand revalidation, edge functions); auth flows need careful handling.

## Event-driven

**Shape.** Components communicate by publishing events to a queue or pub-sub; consumers subscribe.

**Fits when.**
- Async workloads dominate (exports, emails, ML inference, complex retries).
- Multiple downstream consumers per event (analytics + audit + side-effect).
- Loose coupling between producer and consumer needed.
- Reliable retry semantics needed (queue handles redelivery).

**Trade-offs.** Decoupling, observability of system events, scalable retry. *Bought with:* eventual consistency, debugging is harder (no stack trace across event boundaries), need an event-schema discipline.

Common starter shapes: Inngest (durable execution), Cloudflare Queues, AWS SQS + Lambda, BullMQ on Redis.

## Hexagonal / Ports & Adapters

**Shape.** A *style* more than a topology. The application core (domain logic) is at the centre; everything else (HTTP, DB, queues, external APIs) is plugged in via "ports" (interfaces) and "adapters" (implementations).

**Fits when.**
- The domain logic is complex enough to be worth isolating from infrastructure.
- Testability is a priority (replace adapters with fakes for tests).
- Likely to swap infrastructure pieces (DB vendor, queue vendor, etc.) over time.

**Trade-offs.** Clean separation, very testable, infrastructure-agnostic core. *Bought with:* upfront design cost, can feel over-engineered for small systems. Apply where the domain warrants it; don't blanket-apply.

## Client-server with real-time hub

**Shape.** A WebSocket / SSE hub that keeps clients in sync — collaborative editors, chat, presence, live dashboards.

**Fits when.**
- Multiple users need to see each other's actions in real time.
- The data shape benefits from server-pushed updates (rather than client polling).

**Trade-offs.** Genuine real-time UX. *Bought with:* persistent connections cost more (memory, file descriptors), graceful reconnection logic, hub-state model is a discipline (Yjs/CRDT, operational transforms, or simple last-write-wins).

Common starter shapes: managed (Ably, Pusher, Liveblocks); semi-managed (Supabase Realtime, Phoenix Channels); rolled-your-own (Socket.IO on a dedicated process).

## Quick chooser

| If your project is...                                                   | Default to...                              |
|--------------------------------------------------------------------------|---------------------------------------------|
| Solo founder, web SaaS, < 1k MAU expected year 1                         | Modular monolith on serverless              |
| Content site, marketing, blog                                            | JAMstack + edge                             |
| B2B SaaS with complex domain, multiple bounded contexts                  | Hexagonal modular monolith                  |
| Backend with heavy async / scheduled / retry workloads                   | Modular monolith + event-driven worker tier |
| Collaborative editor / chat / multiplayer                                | Web app + real-time hub                     |
| Internal tool, small fixed user base                                     | Single-region monolith on a managed PaaS    |
| Mobile app                                                               | Native or React Native client + serverless API + managed DB |
| CLI / library                                                            | Just the thing itself; no architecture doc needed |

## Sources

- Fowler, *MonolithFirst* — https://martinfowler.com/bliki/MonolithFirst.html
- Fowler, *Microservice Trade-Offs* — https://martinfowler.com/articles/microservice-trade-offs.html
- Simon Brown, **C4 model** — https://c4model.com/
- *The Twelve-Factor App* — https://12factor.net/
- Cockburn, *Hexagonal Architecture* — https://alistair.cockburn.us/hexagonal-architecture/
- Newman, *Building Microservices* (book)
