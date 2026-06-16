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

## Cross-origin API wiring

Two deployables that must talk aren't done until a real call crosses between them in the target environment through real auth — independently-green builds hide CORS, auth-gateway, and env-wiring failures. Keep internal APIs private with authentication + CORS, not by hiding them from the browsers that must call them.

- **The production API is not behind a platform SSO / deployment-protection wall.** Deployment protection (Vercel Deployment Protection, Cloudflare Access, etc.) is designed for hiding *preview deployments* from external crawlers and viewers — it blocks all unauthenticated requests before the application runs. A production API gated this way blocks end-user browsers before the app's own auth can run, making the product non-functional for real users. The correct model: the API is reachable from the internet; the application's own JWT/session auth + CORS allow-list enforces access.
- **CORS allow-lists the specific client origin(s), not a wildcard.** Include the `Authorization` header and the relevant request methods. A missing `Authorization` in the allow-list silently blocks every authenticated browser request even when CORS appears to be "configured."
- **The client knows the API's URL at build time via an env var** (`NEXT_PUBLIC_API_URL` or equivalent). Hardcoded URLs or an unset env var that evaluates to `undefined` produce silent runtime failures that no unit test catches.
- **The integration is verified with a real browser call through real auth** in the target environment — not mocked, not a server-side test (which doesn't cross origins).
