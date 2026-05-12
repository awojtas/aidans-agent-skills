# 01 — Stack and Hosting

## Languages and frameworks

| Layer          | Choice                                       | Why                                                |
|----------------|----------------------------------------------|----------------------------------------------------|
| Frontend       | {{e.g. TypeScript + Next.js 15 (App Router)}}| {{e.g. Existing team familiarity; SSR + edge SSG}} |
| Backend        | {{e.g. TypeScript on Node.js / Bun}}         | {{e.g. Shared language with frontend}}             |
| Background     | {{e.g. Inngest functions in TypeScript}}     | {{e.g. Reliable retries, schedule + event}}        |
| Mobile *(if applicable)* | {{e.g. React Native + Expo}}      | {{}}                                                |

## Hosting platform(s)

| Surface                  | Platform                                | Region(s)               |
|--------------------------|------------------------------------------|--------------------------|
| Web app (UI)             | {{Vercel}}                               | {{Global edge}}          |
| API / backend functions  | {{Vercel functions / serverless}}         | {{us-east + edge}}       |
| Database                 | {{Supabase / Neon}} (Postgres)            | {{us-east-1}}            |
| Cache                    | {{Upstash Redis}}                         | {{global / edge-pinned}} |
| Background work          | {{Inngest}}                               | {{managed}}              |
| Object storage           | {{Cloudflare R2 / S3}}                    | {{us-east-1}}            |

## Runtime model

How code runs:

- **Frontend:** {{Edge SSR for marketing/SEO pages; client-side React for the app; ISR for content pages}}
- **API:** {{Serverless functions, cold start tolerable (target ≤500ms); some routes pinned to edge for low-latency reads}}
- **Workers:** {{Event-driven (queue consumers) + cron-triggered}}
- **Scaling:** {{Autoscale to zero (serverless); no fixed instances}}

## Build, deploy, observability

| Concern              | Tool                                          |
|----------------------|-----------------------------------------------|
| CI                   | {{GitHub Actions}}                            |
| Deploy               | {{Vercel git integration (Preview + Prod)}}   |
| Logs                 | {{Vercel logs + {{Axiom / Logtail}}}}         |
| Metrics              | {{Built-in to host + {{Grafana Cloud}}}}      |
| Errors               | {{Sentry}}                                    |
| Tracing              | {{Sentry / OpenTelemetry to {{Honeycomb}}}}   |
| Feature flags        | {{GrowthBook / LaunchDarkly / env-var-driven}}|

## Constraints driving the stack

- **Mandated by stakeholder:** {{any hard requirements — must run on AWS, must use Python, must be on-prem}}
- **Avoided deliberately:** {{any anti-choices — no vendor lock-in beyond X; no $LANGUAGE because team can't maintain it}}

## Major libraries (early indicative list)

| Concern          | Library                                          | Why                                          |
|------------------|--------------------------------------------------|----------------------------------------------|
| ORM              | {{Drizzle / Prisma / raw SQL}}                   | {{}}                                          |
| Validation       | {{Zod / Valibot}}                                | {{}}                                          |
| Auth             | {{Auth.js / Clerk / Lucia / built-in}}           | {{}}                                          |
| UI components    | {{shadcn/ui / Headless UI / Radix}}              | {{}}                                          |
| Test runner      | {{Vitest + Playwright}}                          | {{}}                                          |
| Linter / formatter | {{ESLint + Prettier / Biome}}                  | {{}}                                          |

*This is indicative. Many choices will firm up once requirements are clearer.*
