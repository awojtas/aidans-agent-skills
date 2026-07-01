---
name: app-web-check
description: 'Audits a deployed or running web app against The Website Specification (specification.website) — foundations, SEO, accessibility, security headers, performance/Core Web Vitals, privacy, resilience, i18n, well-known URIs, and AI-agent readiness. Live-fetches the current spec checklist (never hardcoded), probes the running site via chrome-devtools MCP plus robots/sitemap/.well-known, cross-checks source config (CSP, manifest, SRI), and reports gaps tiered Required/Recommended/Optional. Read-only. Use when the user says "check my web app against web standards", "website specification audit", "is my site spec-compliant", "web standards audit", or "web app conformance check". For visual bugs use /repro-visual; for code-level security use /app-security-check.'
---

Audit a **web app against [The Website Specification](https://specification.website)** — an open, platform-agnostic standard for the technical features a good website should have. Pull the live spec, probe the running site and cross-check its source, then report every gap tiered by the spec's own Required / Recommended / Optional levels.

## Thoroughness mandate

This is a deliberate, one-off audit, **not** a quick smoke test. An hour of exhaustive checking beats a fast pass that misses the gap that bites later. So:

- **Walk every item in every spec category.** Do not sample, do not stop at the obvious wins, do not declare "good enough" early.
- **Never silently skip.** If a check is inconclusive (endpoint times out, header can't be read, source not available), record it as **No-evidence** — never assume a pass.
- Coverage over speed. Take the time it takes.

## When to use this vs others

- **Want to know how well a site conforms to modern web standards?** This skill.
- **Chasing a visual / layout / responsive bug?** Use `/repro-visual` — it measures the rendered UI tree.
- **Need a deep, code-level security audit (OWASP, injection, authz, data-at-rest)?** Use `/app-security-check`. This skill only covers the spec's *surface-level* Security category (TLS, response headers, well-known URIs).
- **Tuning a specific Core Web Vital?** The `debug-optimize-lcp` and `a11y-debugging` skills go deeper on LCP and accessibility respectively.

## Workflow

### 1. Acquire the target

Get a URL to audit:

- A **deployed URL** (preferred — runtime headers and real Core Web Vitals are only observable on a real server), or
- A **local dev server** — offer to start it the way `/repro-visual` launches the app, and note that locally-served headers (CSP, HSTS, cache) often differ from production. Flag any header finding made against a dev server as "verify on prod".

Confirm the **chrome-devtools MCP** is available — it provides `lighthouse_audit`, `list_network_requests`, `navigate_page`, `take_snapshot`. These are **deferred MCP tools**: their schemas must be loaded before you can call them, or the call fails with InputValidationError. Either invoke the `chrome-devtools-mcp:chrome-devtools` skill (which handles loading), or load them yourself via ToolSearch (e.g. `ToolSearch("select:lighthouse_audit,list_network_requests,navigate_page,take_snapshot")`; if `select:` by short name doesn't resolve, search by keyword `ToolSearch("chrome devtools lighthouse network snapshot")`). If there's no display server / the MCP isn't usable, fall back to `curl -sIL` for headers and WebFetch for markup/endpoints, and say in the report that Lighthouse-derived metrics were skipped.

### 2. Pull the live standard (source of truth)

**Fetch the spec at audit time — never hardcode the checklist** (it evolves, and this repo's convention is to avoid baked-in lists that go stale):

- WebFetch `https://specification.website/checklist` for the full flat checklist with each item's **Required / Recommended / Optional** tier and its category.
- For any item whose intent is unclear, fetch that category page or its `.md` (`https://specification.website/spec/<category>/<topic>.md`) or `https://specification.website/llms-full.txt`.
- If the spec's MCP server (`https://mcp.specification.website/mcp`) happens to be connected, you may use it as an accelerator — but the live web pages are the always-available default.

The spec's current top-level categories are roughly: **Foundations, SEO, Accessibility, Security, Well-Known URIs, Agent Readiness, Performance, Privacy, Resilience, Internationalisation.** Treat whatever the live checklist returns as authoritative over this list.

### 3. Probe the live app

Map observed evidence to each spec category. See `references/inspection-methods.md` for the full category → how-to-gather-evidence map. The main channels:

- **Response headers** via `list_network_requests` (or `curl -sIL` — follow redirects so you read the *final* response's headers, not a 301's) → HTTPS/HSTS+preload, CSP, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, COOP/COEP/CORP, Cache-Control, compression (br/zstd/gzip), HTTP/2-3, cookie attributes, Clear-Site-Data.
- **Lighthouse** via `lighthouse_audit` → Performance (Core Web Vitals: LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 at p75), Accessibility, SEO, Best Practices, PWA/installability.
- **Document & markup** via `navigate_page` + `take_snapshot` (or WebFetch) → `<!doctype html>`, `lang`, charset in first 1024 bytes, viewport, meta description, theme-color, canonical, Open Graph, favicons/app icons, heading hierarchy, alt text, form labels, JSON-LD structured data.
- **Endpoints** via WebFetch / curl → `robots.txt`, `sitemap.xml`, `/.well-known/*` (security.txt, change-password, assetlinks.json, apple-app-site-association, openid-configuration as applicable), `/llms.txt` + `/llms-full.txt`, feeds (RSS/Atom), custom 404/500 pages.

### 4. Cross-check the source

Some Required items can't be fully judged from runtime output — confirm them in the codebase:

- **CSP** definition (header vs `<meta>`; presence of `unsafe-inline`/`unsafe-eval`), **Trusted Types**.
- **Web app manifest** (`manifest.webmanifest`) + service worker (offline/installability).
- **SRI** (`integrity=`) on third-party `<script>`/`<link>`.
- **hreflang** / i18n routing, **structured-data** templates, **canonical** generation.

Note the framework (Next/Nuxt/Astro/Vite/plain) — it determines where these live and how headers are configured (e.g. `next.config`, `vercel.json`, `_headers`, middleware).

### 5. Score and report

Produce a single markdown report (offer to save it, e.g. `web-spec-audit-YYYY-MM-DD.md`; don't auto-write without asking). Group by the spec's categories, and within each, by the spec's own tiers:

- **Required gaps** — baseline conformance is broken. Must-fix.
- **Recommended gaps** — should-fix.
- **Optional / situational** — note only; many won't apply.
- **No-evidence** — couldn't verify; list what's needed to confirm.

Each finding states: **what the spec requires**, the **observed evidence** (the actual header value / Lighthouse metric / missing endpoint), and a **fix pointer**. Open with a one-line verdict and a per-category Pass / Gap / N-A / No-evidence summary table, then the top must-fix items.

**Read-only.** Present findings; only edit the app if the user explicitly asks afterwards.

### 6. Cross-references / non-goals

- Deep visual/responsive bugs → `/repro-visual`. Accessibility deep-dive → `a11y-debugging` skill. LCP tuning → `debug-optimize-lcp` skill. Code-level security → `/app-security-check`.
- This skill does not exploit, pentest, or modify the app. It conforms-checks and advises.

## Guardrails

- **Live-fetch the checklist every run.** Never bake the spec's items, counts, or tiers into this skill — read them from specification.website at audit time.
- **Don't pass on no evidence.** Inconclusive ≠ compliant. Mark it No-evidence and say what's missing.
- **Headers are environment-specific.** A finding against `localhost` may not hold on prod (and vice-versa). Label which environment each header finding came from.
- **Respect the spec's tiers.** Don't report an Optional item as a failure — surface it at its real level so the must-fix list stays honest.
- **Exhaustive, not fast.** Cover every category before reporting. Partial audits are worse than none — they read as "all clear" when they aren't.
