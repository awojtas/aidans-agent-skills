---
name: platform-provision
description: Provisions the runtime / cloud platforms an application needs to actually run and deploy — hosting providers, observability services, databases, auth providers, email senders, queues, anything the architecture names. Reads docs/architecture/ to inventory what needs to exist, then uses every channel available (connected MCP servers, installed CLIs, HTTP APIs) to stand it all up. Batches the bits only a human can do (sign-ups, billing, copying secrets out of dashboards) into a single checklist, then wires the resulting secrets into GitHub Actions and the platforms' env stores. Trigger phrases include "provision the platform", "stand up the stack", "set up the infrastructure", "wire up the cloud services", "spin up the runtime", "create the cloud resources", "bootstrap the platform".
---

Provisions the external platforms and services described in `docs/architecture/` and wires the resulting secrets into GitHub.

## What this skill does

Reads the architecture, works out what cloud platforms / SaaS products / observability tools / DBs / etc. need to exist, then uses whatever channels are available to create them. Anything a human has to do personally (sign up, pay, click through OAuth, copy a secret out of a UI) is batched into one checklist instead of dripped out one prompt at a time.

## Standing principles

Before writing any provider-specific step, key name, config value, region code, redirect URL, or checklist instruction, consult [`../../shared/platform-standing-principles.md`](../../shared/platform-standing-principles.md). Critical rules:

- **Fetch current official docs before writing any detail** — never rely on training memory. Platforms rename consoles, replace key systems, and change defaults constantly.
- **Verbatim checklist steps** — for every human-required step, include the exact current menu path (verified against live docs), the exact output variable name, and where that output goes.
- **Secret destination classification** — when an auth provider brokers social login (e.g. Supabase Auth + Google/Microsoft OAuth), the OAuth client secrets live in the auth provider's dashboard, not in CI/runtime env vars. The redirect URI is the broker's callback URL, not the app's.

## Workflow

1. **Read `docs/architecture/`.** If it doesn't exist, stop and tell the user to run `/platform-design` first — provisioning without a recorded architecture is guessing.

2. **Inventory what needs to be provisioned.** Walk the architecture and list every external thing the system depends on to run, deploy, observe, or persist. Hosting, observability, databases, auth, email, queues, AI providers, CDN, analytics, search — anything. Don't restrict to a fixed catalogue: anything the architecture names is in scope.

   **Monorepos with multiple independently-deployable apps:** if the architecture records separate apps (e.g. a Next.js web frontend + a standalone Hono/Express API), treat each as a separate deploy project — its own project entry in the hosting platform, its own root directory, its own env scope. Server secrets (database URLs, service-role keys, OAuth client secrets) belong only on the backend project; public/client variables (`NEXT_PUBLIC_*`, anon keys) belong only on the frontend project. Never share a single deploy project for two apps — env scopes will bleed.

3. **For each item, work out how to interact with it. Go and try.** Investigate every available channel:
   - Is there an **MCP server** connected that covers this platform? Check the tools available in the current session.
   - Is the platform's **CLI** installed locally and authenticated?
   - Is there an **HTTP API + a token** you can drive via WebFetch?

   Be assertive about trying. Don't bail because the first channel returns 401 — try a second. If nothing works, surface the platform as a human task in the checklist below.

4. **Provision what you can autonomously.** Create the project / org / dashboard / DB / whatever. Capture every output the human will care about later: resource IDs, regions, URLs, DSNs, project tokens, organization slugs. Record them as you go.

   **Supabase Postgres — connection strings (apply whenever Supabase is the database):**

   Supabase exposes three connection modes. The Direct connection (`db.<ref>.supabase.co:5432`) is IPv6-only by default and unreachable from GitHub Actions runners and most dev machines — do not use it in CI or serverless. Use the pooler host instead:

   | Var name | Pooler mode | Port | For |
   |---|---|---|---|
   | `MIGRATION_DATABASE_URL` | Session (DDL-capable) | 5432 | drizzle-kit / CI migrations |
   | `DATABASE_URL` | Transaction (serverless-optimized) | 6543 | Vercel functions / Edge runtime |

   Username format for both: `postgres.<project-ref>` (not `postgres`).

   Construct both strings from the Supabase dashboard "Connect" page and record them as separate secrets — keeping them named differently prevents the wrong URL being placed in the wrong secret store. When wiring `DATABASE_URL` into the app, ensure the Postgres client has `prepare: false` (Transaction pooler does not support prepared statements).

   **Automated migrations workflow:** create `.github/workflows/migrate.yml` that runs `drizzle-kit migrate` (or the project's equivalent) on merge to `main` when files under the migrations directory change, using `MIGRATION_DATABASE_URL`. Migrations must not be a manual step. Commit this workflow as part of provisioning.

   **Serverless adapter entrypoint (standalone API frameworks):** a Next.js app deploys natively on Vercel. A standalone API framework (Hono, Express, Fastify, etc.) requires a serverless adapter entrypoint — a specific file (e.g., `api/index.ts`, a `vercel.json` `functions` config) that wraps the app to run as serverless functions. Verify this file exists and is correctly configured before considering the app provisioned. Checking that the framework is imported is not enough — the entrypoint must exist.

   **Compute region:** pin the compute region to the region named in the architecture ADR, co-located with the database. Set it in version-controlled config (e.g., `vercel.json` → `"regions": ["iad1"]`) — not a dashboard toggle that can silently change or default to a different continent. If no region ADR exists, raise it as a blocker and ask the user to decide before provisioning.

   **Web app ↔ API wiring (when architecture has a separate web frontend + API as separate Vercel projects):** use the **BFF + Vercel Trusted Sources** pattern — not direct browser-to-API calls. Browsers cannot produce OIDC tokens; Trusted Sources is service-to-service only.

   **Autonomous steps (do these yourself):**

   1. **Keep Deployment Protection ON** on the API project. Do not disable it.
   2. **Install `@vercel/oidc`** in the web app: `npm install @vercel/oidc`.
   3. **Implement BFF proxy route handlers** in the web app (e.g. `app/api/[...path]/route.ts` for a Next.js app): (a) verify the user's JWT/session and reject unauthenticated requests, (b) call `await getVercelOidcToken()` from `@vercel/oidc`, (c) forward the request to the API with the `x-vercel-trusted-oidc-idp-token` header and the user's JWT. Commit this as code (not a dashboard toggle).
   4. **Set `API_URL` (server-side) env var** on the web app's Vercel project pointing to the API's deployment URL. Server-side only — not `NEXT_PUBLIC_`. Record the var name in `.env.example`. No CORS configuration needed: the browser never calls the API directly.

   **Human-required (add to the step 5 checklist — do not attempt autonomously):**

   - **Configure Trusted Sources** on the API's Vercel project: Settings → Deployment Protection → Trusted Sources → add the web app's Vercel project as a trusted source. Dashboard-only — no CLI or API equivalent. Fetch the current Vercel documentation to confirm the exact menu path and field names before writing the checklist step. Record in the provisioning log once done.

   **Free/low-tier constraints:** before provisioning a new resource, check whether the free/low tier of the chosen service imposes a constraint the project is likely to hit (single custom domain, single region, seat caps, email sending limits, etc.). If you encounter one:
   1. **Surface the limit explicitly** — name the specific constraint.
   2. **Propose a lean workaround** that reuses an existing resource the org already owns (e.g. reuse an existing domain, an existing Resend account, an existing Sentry org) rather than forcing a paid upgrade.
   3. **File a deferred GitHub issue** for the proper solution (paid upgrade or dedicated resource), explicitly `Blocked by:` its prerequisite (e.g., "blocked on: team decides to go paid"), so it's tracked without blocking current work.
   4. **Align with budget ADRs** — check the architecture for a "lean / avoid fixed monthly cost early" constraint. If one exists, the lean workaround is the approved path; do not push a paid upgrade.

5. **Batch the human-only bits into a single checklist, and file it as a GitHub issue.** Some things are inherently human:
   - Creating an account in a new SaaS product
   - Agreeing to ToS or choosing a billing plan
   - OAuth / device-code flows
   - Copying a generated secret out of a UI that doesn't expose it via API

   Group them into a single checkbox checklist and **create a GitHub issue** in the repo via `gh issue create` — title `"Provisioning checklist — sign up for v1 platforms and bring back tokens"`, body as a Markdown task list (`- [ ]`) with one section per platform. Each item must name the exact dashboard URL, the exact page/field, and the exact env var name to bring back. Close the issue body with a fenced code block listing every env-var name the user is expected to paste back, so they have a single place to fill in. Show the issue URL to the user and have them work through it at their pace. Don't drip prompts in chat — the issue is the durable surface for the slow path.

   If the repo has no GitHub remote (rare — this skill normally runs after `/repo-bootstrap`), fall back to printing the checklist in chat and tell the user it would normally be a GitHub issue.

6. **Wire secrets in once the human returns.** When the human pastes secrets back:
   - GitHub Actions: `gh secret set <NAME>` (repo-level), or `gh secret set <NAME> --env <env>` for env-scoped.
   - Platform env vars: via that platform's MCP/CLI (e.g., its env-setting command for the deployed runtime).
   - Repo: append the variable name to a `.env.example` with a one-line comment explaining what it's for. **Never write the value into a file or commit.**

7. **Record what was done.** Append (or create) `docs/architecture/provisioning-log.md`:
   - Date, what got provisioned, which platform, IDs / URLs / regions.
   - Which secrets exist now, where they live (GH Actions repo vs env, platform env stores).
   - Which human-required tasks are still outstanding, if any.
   - A link to the provisioning-checklist GH issue created in Step 5, and whether it's still open. Close the issue (or note the remaining items inline) once provisioning is complete.

   This is the bridge between the architecture doc and the actual state of the cloud. Future skills (`/task-implement`, `/requirements-rework`, debugging sessions) read this to know what's real.

## Guardrails

- **Never write a secret value into any file, commit, or PR comment.** Secret stores only.
- **Don't invent integrations.** If the architecture doesn't name observability, don't add Sentry just because it's popular. Ask the user first.
- **Ask for tokens up front, not on first failure.** If you'll need tokens for several platforms, enumerate them and ask in one go.
- **One or two tries per channel, then move on.** Don't loop on a 4xx — surface it. The human can debug auth faster than you can.
- **If the architecture is vague** ("we need a database") **pause and ask the human to pick a specific service** before provisioning. You don't get to choose the architecture — but when you ask, offer the [`../../shared/default-stack.md`](../../shared/default-stack.md) pick as the suggested option so the human has an easy default to accept.

## Output

- `docs/architecture/provisioning-log.md` (created or appended).
- GitHub Actions secrets set for every value the deployed system will need.
- `.env.example` updated with the variable names (no values).
- A final report to the user: what was provisioned, what's still pending and why, and any access / billing questions still open.

## Commit and push

Stage `docs/architecture/provisioning-log.md`, `.env.example`, and `README.md` (lifecycle tracker), commit with `chore(platform): provision <list of platforms>`, then follow [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). The provisioning-checklist GitHub issue raised in Step 5 is already pushed via `gh issue create` — no further git action needed for it.

## Lifecycle tracker

This skill owns the **Platform provisioned** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Platform provisioned` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Platform provisioned` line to ✅ (done).

Touch only the `Platform provisioned` line — leave every other stage exactly as found.
