# Platform standing principles

These cross-cutting rules apply to all platform-* skills (`platform-design`, `platform-provision`, `platform-verify`). Stated once here, inherited by each skill.

## Ground every vendor-specific detail in current official documentation

Cloud platforms change faster than any model's knowledge: console navigation gets renamed (e.g. "Azure AD" → "Microsoft Entra", "Google Cloud Credentials" → "Google Auth Platform"), key/credential systems get replaced (e.g. shared-secret keys → publishable/secret keys + JWKS), region codes and default regions shift, free-tier limits move, and API/SDK shapes evolve.

Before writing any setup step, key name, config value, region code, redirect URL, or default-behavior claim:

1. **Fetch and confirm.** Retrieve the current official doc (vendor docs site / Context7 MCP tool / WebFetch) and verify the detail against it. If a detail cannot be verified from a current source, say so explicitly rather than guessing.
2. **Prefer non-deprecated mechanisms.** For new builds, use current, non-deprecated paths. If a legacy mechanism still works, note its deprecation timeline (e.g., "legacy X works until <date>, but new builds should use Y").
3. **Record the source.** Next to any non-obvious choice or config value, include the URL of the doc used to verify it, so a human can re-verify later.

**Treat anything remembered-but-unverified as a likely-stale hypothesis, not a fact.** This single habit prevents the most downstream rework.

## Human-required checklist items: verbatim detail

For every step a human must perform manually:

- Include the **exact current menu path**, verified against live docs — not paraphrased. E.g., "Supabase Dashboard → Project Settings → API → `service_role` key", not "find the service role key in settings".
- Name the **exact output variable** (key name, field label, slug) the step produces.
- State **where that output goes** — which secret store, which config file, which env var name.

Verbatim paths and field names remove ambiguity and prevent the human from guessing when the console layout differs from what they expected.

## Secret destination classification

Classify secrets by where they actually live, not where they're convenient to stage:

- When an auth provider **brokers social login** (e.g. Supabase Auth handling Google / Microsoft OAuth), the OAuth client ID and secret live in the **auth provider's dashboard** (e.g. Supabase → Authentication → Providers → Google) — **not** in CI/runtime env vars.
- The OAuth **redirect URI** is the **auth broker's callback URL** (e.g. `https://<ref>.supabase.co/auth/v1/callback`), **not** the application's URL.
- Do **not** stage these as deploy environment variables — doing so misclassifies where the authoritative credential lives and risks leaking it to the wrong scope.

Only values the application's own runtime must read directly (database URLs, API keys the app calls directly) belong in the deploy secret store.

## Cross-origin API wiring (BFF + Vercel Trusted Sources)

When a web frontend (e.g. Next.js on one Vercel project) and a separate API (e.g. Hono/Express on a second Vercel project) must communicate, the correct pattern is a **Backend for Frontend (BFF)** proxy — never a direct browser-to-API call:

```
browser → web-app (Next.js route handler, same origin)
              → adds Vercel OIDC token (Trusted Sources) + forwards user JWT
              → api-project (Deployment Protection stays ON)
```

Two deployables that must talk aren't done until a real call crosses between them in the target environment through real auth — independently-green builds hide BFF-wiring, OIDC-token, and server-env-var failures.

**Why BFF, not direct browser calls:**

- Vercel Deployment Protection blocks all unauthenticated requests before the app runs. Browsers cannot produce OIDC tokens, so they cannot bypass protection via Trusted Sources — Trusted Sources is service-to-service only.
- Even without protection, exposing the API directly to the internet requires CORS and makes the API reachable from anywhere. The BFF keeps the API private: only reachable from the Vercel projects you explicitly authorise.
- Bonus: no CORS configuration needed — the browser only ever hits its own origin.

**Implementation requirements:**

- **Keep Deployment Protection ON** on the API project. Do not disable it.
- **Trusted Sources** configured in the API project's Vercel dashboard (Settings → Deployment Protection → Trusted Sources): add the web app's Vercel project as a trusted source. Dashboard-only — there is no `vercel.json` equivalent.
- **`@vercel/oidc` package** installed in the web app (`npm install @vercel/oidc`).
- **BFF proxy route handlers** in the web app (e.g. `app/api/[...path]/route.ts`) that: (1) authenticate the user (reject unauthenticated requests), (2) call `await getVercelOidcToken()` from `@vercel/oidc`, (3) forward the request to the API with `x-vercel-trusted-oidc-idp-token: <oidc-token>` and the user's JWT.
- **`API_URL` env var on the web app project** (server-side, not `NEXT_PUBLIC_`) pointing to the API's deployment URL. The BFF reads this; the browser never sees it.
- App-level per-user auth is unchanged — the proxy forwards the user's JWT, so tenant scoping and roles still apply on the API.
