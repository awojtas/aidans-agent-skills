---
name: describe-ui-from-web-app
description: 'Crawl a running web application and produce a structured UI description under docs/as-built/ui-description/: screen inventory, per-screen ARIA YAML snapshots, screenshots, field observations, and a draft OpenAPI spec from captured network traffic. Uses the chrome-devtools MCP (zero install, available in most Claude Code sessions) for capture, escalating to Playwright scripts via Bash for complex SPAs or HAR recording. Supports three auth modes: public-only crawl, credential injection, or session cookie handoff. Useful standalone for accessibility audits, UI documentation, or test planning — and is the web capture input for /requirements-from-app. Triggers: describe this web app, capture web UI, inventory web app screens, document web app UI, crawl web app, screenshot every screen.'
---

Systematically visit every screen of a running web application and record its structure. Output is raw observation — no BA interpretation, no requirements language. That synthesis happens in `/requirements-from-app`.

## Prerequisites

- **chrome-devtools MCP** (preferred, zero install): available in most Claude Code sessions — attempt `list_pages` to confirm
- **Playwright** (fallback, needed for complex SPAs and HAR recording): `npm install -g playwright && npx playwright install chromium`
- **mitmproxy2swagger** (for API spec generation): `pip install mitmproxy2swagger`
- App is running and accessible at a known URL

---

## Phase 0 — Preflight

Ask the user for:

1. **Entry URL** — the app's starting page (e.g. `http://localhost:3000` or a live URL)
2. **App name** — used for folder and file naming
3. **Auth strategy** — choose one:
   - **Public-only**: crawl without logging in; auth-gated screens listed as gaps, not errors
   - **Credential injection**: user provides username + password; you script the login flow via Playwright before crawling
   - **Session cookie handoff**: user logs in manually in their browser, exports cookies (via DevTools → Application → Cookies → Copy as JSON); you inject them into the crawl session
4. **Scope** — any sections to explicitly skip (e.g. admin panel, payment pages)?

Check tooling:
- Try `list_pages` via chrome-devtools MCP; if it responds → **MCP mode**
- Otherwise run `npx playwright --version` via Bash; if it fails → stop and print: `Install Playwright: npm install -g playwright && npx playwright install chromium`

---

## Phase 1 — Screen discovery

Build a working screen list: `[screen name, URL/route, status: pending/captured/skipped/auth-gated]`

**MCP mode:**
1. `navigate_page` to the entry URL
2. Take a screenshot (`take_screenshot`) and a DOM snapshot (`take_snapshot`)
3. Parse the snapshot for `<a href>`, `<button>`, nav menu items, and any JavaScript-driven route links
4. Add each discovered URL to the screen list (deduplicate by normalised URL)
5. Navigate each pending URL in turn; repeat discovery at each new page
6. Stop at depth 3 unless user asks to go deeper — SPA state spaces explode fast

**Playwright script mode** (escalate when MCP mode hits limits):
- Use when: the app has a login wall, uses History API routing, or discovery via MCP is missing obvious routes
- Write a short Playwright crawl script; run it via Bash
- Record HAR during the crawl: `page.context().tracing` or `--save-har` flag

**Always supplement with:**
- `GET <origin>/sitemap.xml` — may reveal routes not reachable by link-following
- `GET <origin>/robots.txt` — may list disallowed (but real) paths

---

## Phase 2 — Deep capture per screen

For each screen in the list (status: pending):

1. Navigate to the screen
2. Wait for the page to fully render (wait for network idle or a stable DOM state)
3. **Screenshot**: `take_screenshot` (MCP) or `page.screenshot()` (Playwright) → save to `docs/as-built/ui-description/screenshots/<screen-name>.png`
4. **ARIA snapshot**: `take_snapshot` (MCP) or `page.accessibility.snapshot()` (Playwright) → ARIA tree in YAML form; this is 10–15x smaller than raw HTML and is the primary structural record
5. **Field observations**: from the ARIA tree and screenshot, note:
   - Input fields: label, type (text/number/date/email/select/checkbox/radio/textarea), required indicator, placeholder
   - Buttons and links: label, apparent action
   - Data tables and lists: column headers, data type hints
   - Navigation elements: menu items, breadcrumbs, tab labels
6. **Network capture** (MCP): call `list_network_requests` after each navigation; note API endpoints, request methods, and domain names
7. Mark screen status: captured

If a screen returns a 403/401 or redirects to login → mark as auth-gated (not a failure).

---

## Phase 3 — API spec generation (web only)

If Playwright was used and a HAR file was recorded:
1. Run: `mitmproxy2swagger -i <har-file> -o docs/as-built/ui-description/api-spec.yaml -p <api-base-url>`
2. Inspect the output — mitmproxy2swagger requires a second pass with `--examples` flag to add request/response schemas
3. Run the second pass: `mitmproxy2swagger -i <har-file> -o docs/as-built/ui-description/api-spec.yaml -p <api-base-url> --examples`

If MCP mode only, compile network request observations into a minimal OpenAPI stub manually — list each unique `METHOD /path` observed as a path entry with no schema detail.

---

## Phase 4 — Write output

Create `docs/as-built/ui-description/` with this structure:

```
docs/as-built/ui-description/
  screen-inventory.md
  api-spec.yaml             (if generated)
  screenshots/
    <screen-name>.png
  screens/
    <screen-name>.md
```

**`screen-inventory.md`:**
```markdown
# Screen Inventory — <App Name>

| Screen name | URL / Route | Auth required | Screenshot | Notes |
|-------------|-------------|---------------|------------|-------|
| Home        | /           | No            | [view](screenshots/home.png) | |
| …           |             |               |            | |

## Auth-gated screens (not captured)
- <list>

## Out-of-scope screens (skipped per user request)
- <list>
```

**`screens/<screen-name>.md`:**
````markdown
# <Screen Name>

**URL:** <url>
**Screenshot:** ![<screen name>](../screenshots/<screen-name>.png)

## Fields
| Label | Type | Required | Placeholder / default | Notes |
|-------|------|----------|-----------------------|-------|

## Interactive elements
| Element | Type | Label / action |
|---------|------|----------------|

## Navigation
(What this screen links to; what triggers each transition)

## ARIA structure
```yaml
<paste accessibility tree YAML here>
```

## Observed network calls
| Method | Path | Notes |
|--------|------|-------|
````

---

## Commit (standalone use)

If this skill was invoked directly rather than through `/requirements-from-app`, commit the output following [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). Use commit message: `docs(as-built): capture web UI description — <app name>`

If invoked by `/requirements-from-app`, skip this step — that skill owns the commit.

---

## Guardrails

- Never brute-force auth-gated routes — document them as gaps, not attempts
- Cap crawl depth at 3 by default; ask before going deeper
- Do not interpret business rules — record field names and labels literally, even if the intent seems obvious
- If a page returns only a loading spinner after 5 seconds, note it as "dynamic content — may require user interaction" and move on
- ARIA snapshots are preferred over raw HTML in all cases — they strip presentational noise and are what the synthesis skill expects
