---
name: repro-visual-init
description: One-time setup that scaffolds the visual-repro harness into a repo so /repro-visual can drive the deployed app in an emulated browser. Inspects THIS repo to wire the per-project glue — the deployed/base URL, the login flow and selectors, the auth mechanism (Supabase/cookie/SSO/Cognito/Entra/GCP IAP/none), the API base used to seed test data, and the selectors + metrics that define "correct" for the component under test — then writes scripts/repro/ (Playwright harness with cached-session login), a gitignored .env.e2e for test creds, a package.json "repro" script, a one-line pointer in AGENTS.md, and .gitignore entries. Run this once per repo (human or agent), or with intent to refresh/upgrade an existing harness. Triggers: set up the repro harness, init repro-visual, scaffold the visual repro tooling, add the mobile repro harness to this repo.
---

Scaffold the **visual-repro harness** into the current repo and wire it to *this* project's specifics, so `/repro-visual` (and `/repro-on-mobile` / `/repro-on-desktop`) can reproduce and verify layout bugs against the deployed app. Run once per repo.

The reusable *method* is generic; the *glue* (URL, auth, selectors) is per-repo — and that glue is exactly what an agent inspecting the repo can wire up. Do that here.

## 0. Bail-out check

If a harness already exists (`scripts/repro/run.mjs` or a `"repro"` script in a `package.json`), **do not overwrite it** — tell the user it's already set up and stop, unless they explicitly asked to refresh/upgrade (then diff and update only what's needed).

## 1. Discover the project specifics (inspect the repo — don't assume)

Gather, by reading the codebase, and confirm anything ambiguous with the user:

1. **Web app location & package manager** — which workspace holds the front-end (`apps/web`, `web/`, root?), and npm/pnpm/yarn. The harness lives under that app's `scripts/repro/`.
2. **Deployed/base URL** — the production URL to drive (check README, vercel/netlify config, CI). This is the default target; the user can override per-run.
3. **Playwright availability** — is `@playwright/test` (or `playwright`) a dependency? If not, note that the user must add it + `npx playwright install chromium`.
4. **Auth mechanism** — how the app authenticates a browser session. Read the login page and the auth client. Map it to a strategy in `references/auth-strategies.md` (Supabase/localStorage-token, cookie/session, NextAuth, Clerk, Cognito/Entra/GCP SSO redirect, or none). Note the **login form selectors** and how an **API token/cookie** is obtained for seeding.
5. **API base for seeding** — the path/host used to create test data (e.g. same-origin `/api`, or a separate API host), and the minimal calls to create the entity under test. If the app has no seeding need, skip seeding.
6. **Component under test + "correct" definition** — the selector(s) for the thing that breaks visually, and the **metrics** that decide pass/fail (centre offset, fill %, is-it-fully-visible, no-overflow…). This becomes the `measure*()` function.

## 2. Scaffold from the template

Copy `references/harness-template/` into `<webapp>/scripts/repro/` and **adapt**:

- **`auth.mjs`** — implement `login(page,cfg)`, `isLoggedIn(page)`, and `authHeaders(page)` (or `authCookies`) for the discovered auth strategy. This is the main per-repo edit; use `references/auth-strategies.md`.
- **`harness.mjs`** — set the `.env` path + the API base; replace the example `gotoX()` / `measureX()` with the real selectors + metrics from step 1.6 (see `references/measuring.md`).
- **`run.mjs`** — adjust the `--seed` body to the app's create-entity calls; set the default route/`--<entity>` flag name; update the `SELECTOR-FOR-A-RENDERED-ELEMENT` placeholder in the `--assert-loads` branch to the same rendered-element selector used in `gotoScreen`.
- **`.env.e2e.example`** — the env keys (`REPRO_BASE_URL`, creds or token).
- **`README.md`** — fill in the real commands.

## 3. Wire it into the repo

1. Add a **`repro` script** to the web app's `package.json`: `"repro": "node scripts/repro/run.mjs"`.
2. Create the gitignored **`.env.e2e`** (next to where the harness loads it) with the **test** creds — ask the user for them; never invent or use a real account.
3. Add **.gitignore** entries: the `.env.e2e` and the cached-session dir (`scripts/repro/.auth/`).
4. Add a **one-line pointer in `AGENTS.md`** (and `CLAUDE.md` if it's separate): "Visual/responsive/mobile bug? Use the `/repro-visual` skill — Playwright harness in `<webapp>/scripts/repro`."

## 4. Verify it actually works

1. `… repro --login` → caches the session without error.
2. `… repro --<entity> <existing-id> --device mobile --assert-loads` → PASS.
3. `… repro --<entity> <existing-id> --device 360 --measure` → prints sane numbers.

If any step fails, fix the glue (usually auth selectors or the API base) before declaring done. Then hand back to `/repro-visual` for actual bug work.

## Guardrails

- **Never commit secrets** (`.env.e2e`, the cached session) — verify with `git check-ignore`.
- **Test account only** for creds.
- **Don't over-build.** Wire the *one* auth strategy this repo uses; the others are documented for when a different app needs them. No plugin system before a second consumer exists.
