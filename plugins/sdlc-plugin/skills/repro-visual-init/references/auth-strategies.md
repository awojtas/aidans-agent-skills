# Auth strategies for the repro harness

The harness only needs three functions in `auth.mjs`: `login(page, cfg)`,
`isLoggedIn(page)`, and `authHeaders(page)` (return `{}` when auth rides on
cookies). Wire the **one** strategy this app uses. Always log in **once** and
reuse the persisted `storageState` — many providers rate-limit rapid logins.

## 1. Token in localStorage (Supabase, custom JWT)
- `isLoggedIn`: a token key exists in `localStorage` (e.g. `sb-*-auth-token`).
- `login`: fill the form, submit, wait for the token to appear.
- `authHeaders`: read the token, return `{ authorization: 'Bearer ' + token }`.

## 2. Cookie / session (Rails, Django, Laravel, many SSR apps)
- `login`: submit the form; the session cookie is set automatically.
- `isLoggedIn`: you're not on `/login` and a known authed element/route is reachable (cookies aren't readable from JS if `httpOnly` — assert via the page, not `document.cookie`).
- `authHeaders`: return `{}` — `storageState` already carries the cookie, and same-origin `fetch` sends it. (For CSRF-protected POSTs, read the CSRF token from a meta tag / cookie and add the header the app expects.)

## 3. NextAuth / Auth.js
- Usually a session cookie (`next-auth.session-token`). Treat as strategy 2. For API calls needing a bearer, hit the app's own `/api/auth/session` or a token endpoint and forward what it returns.

## 4. Clerk
- Clerk sets cookies and exposes `window.Clerk`. `login` via the hosted form; `authHeaders` can do `await window.Clerk.session.getToken()` inside `page.evaluate`.

## 5. SSO redirect (Microsoft Entra / Azure AD, AWS Cognito Hosted UI, Google / GCP IAP, Okta)
- `login` follows the redirect to the IdP, fills the IdP form (selectors differ per IdP — inspect once), and waits to land back on the app. These flows are flaky to script; **strongly prefer logging in once and caching `storageState`**, then reusing it for days.
- GCP IAP and some corp SSO also gate by IP/headers — if scripting the IdP is impractical, capture `storageState` from a real manual login (run a headed login once on a machine with a display, save state) and commit only the *path*, never the file.
- `authHeaders`: usually cookie-based → `{}`. If the API wants the IdP bearer, extract it the same way the app does.

## 6. No auth
- `isLoggedIn` → `true`; `login` → no-op; `authHeaders` → `{}`. The harness still gives you emulation + measurement + screenshots.

## Deploy-protection gotcha (orthogonal to app auth)
**Vercel/Netlify preview deployments are often behind their own SSO** — your harness can't reach them even with app creds. Either verify on **production after deploy**, or pass a protection-bypass token. For Vercel: set `VERCEL_AUTOMATION_BYPASS_SECRET` on the project and send header `x-vercel-protection-bypass: <secret>` (add it in the harness's `newContext({ extraHTTPHeaders })`).
