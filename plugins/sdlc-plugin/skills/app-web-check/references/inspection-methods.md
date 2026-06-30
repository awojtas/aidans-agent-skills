# Inspection methods — how to gather evidence for each spec category

This is the durable how-to that pairs with `app-web-check`. The **checklist itself stays live-fetched** from specification.website; this file only records *how to observe* each category against a running app + its source. Map each live checklist item to one or more channels below.

Primary channels:
- **`list_network_requests`** (chrome-devtools MCP) — response headers, protocol, compression, caching. Fallback: `curl -sIL <url>`.
- **`lighthouse_audit`** (chrome-devtools MCP) — Performance/CWV, Accessibility, SEO, Best Practices, PWA.
- **`navigate_page` + `take_snapshot`** (chrome-devtools MCP) — rendered DOM/markup. Fallback: WebFetch (note: WebFetch sees server HTML, not post-hydration DOM).
- **WebFetch / `curl`** — `robots.txt`, `sitemap.xml`, `/.well-known/*`, `/llms.txt`, feeds, raw HTML `<head>`.
- **Source grep** — build-time config the runtime can't reveal.

---

## Foundations (HTML & document basics)
- **How:** fetch raw HTML + `take_snapshot`. Grep source for framework head config.
- **Look for:** `<!doctype html>` as first line; `<html lang>`; UTF-8 charset declared in first 1024 bytes; `<meta name="viewport">`; title; meta description; `theme-color`; canonical URL; favicon + app icons; Open Graph tags; feed `<link rel>` discovery.

## SEO
- **How:** `lighthouse_audit` (SEO category) + fetch `robots.txt` / `sitemap.xml`; `take_snapshot` for headings/links; grep source for JSON-LD and SSR.
- **Look for:** `robots.txt`; XML sitemap (+ sitemap index for large sites); sane URL structure; correct redirects (301 vs 302); server-side rendering / no soft-404s; meta robots; single `<h1>` + logical heading order; descriptive internal links; JSON-LD structured data; breadcrumb markup.

## Accessibility (WCAG)
- **How:** `lighthouse_audit` (Accessibility) as a floor — it is **not** complete; supplement with the `a11y-debugging` skill for keyboard/focus/contrast.
- **Look for:** colour contrast; `alt` on images; programmatic form labels; keyboard reachability; visible focus indicators; skip links; semantic landmarks; minimal/justified ARIA; descriptive link text; form error handling; reduced-motion support; captions/transcripts; data-table markup; touch targets ≥ 24×24 CSS px.

## Security (transport, headers, policies)
- **How:** `list_network_requests` / `curl -sIL` (follow redirects — read the final response, not a 301) for headers; fetch `/.well-known/security.txt`; grep source for CSP/Trusted Types/SRI.
- **Look for:** HTTPS + HSTS (with preload); no mixed content; CSP (flag `unsafe-inline`/`unsafe-eval`); Reporting-Endpoints; `X-Content-Type-Options: nosniff`; frame-ancestors / anti-clickjacking; COOP/COEP/CORP; Referrer-Policy; Permissions-Policy; SRI on third-party assets; Trusted Types; secure cookie attributes (`Secure`, `HttpOnly`, `SameSite`); Clear-Site-Data where relevant; DNS CAA / DNSSEC (optional, registrar-side).
- **Boundary:** stop at the spec's transport/header surface. Code-level vulns (injection, authz, secrets, data-at-rest) belong to `/app-security-check`.

## Well-Known URIs (RFC 8615)
- **How:** fetch each `/.well-known/<path>` and check status + content type.
- **Look for (only those that apply to the site type):** `change-password`; `security.txt`; WebAuthn config; `openid-configuration`; `apple-app-site-association`; `assetlinks.json`; `nodeinfo`; WebFinger; traffic-advice.

## Agent Readiness (AI & crawler legibility)
- **How:** fetch `/llms.txt`, `/llms-full.txt`, `robots.txt` (AI-crawler directives), Link headers; grep source for schema.org + MCP/agent endpoints.
- **Look for:** `/llms.txt` (+ `-full`); Markdown source endpoints (`.md`); AI-crawler directives in `robots.txt`; stable URLs; schema.org structured data; machine-readable formats (JSON/RSS); HTTP `Link` headers; MCP server / A2A agent card / Agent-Skills discovery where the product offers them.

## Performance (Core Web Vitals & optimisation)
- **How:** `lighthouse_audit` (Performance) for CWV + opportunities; `list_network_requests` for caching/compression/protocol.
- **Look for:** LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 (p75); modern image formats (WebP/AVIF) + lazy-loading; resource hints (preload/preconnect); `Cache-Control` + ETag/304; compression (br/zstd); font subsetting + `font-display`; deferred/async/module scripts; HTTP/2-3; BFCache eligibility; `content-visibility`; Speculation Rules; reserved scrollbar gutter; Server-Timing.

## Privacy (consent & data protection)
- **How:** fetch privacy policy link; inspect cookies + third-party requests in `list_network_requests`; check GPC handling.
- **Look for:** privacy policy present; cookie consent mechanism; Global Privacy Control respected; third-party script audit; data minimisation; cookieless-analytics option.

## Resilience (graceful failure)
- **How:** fetch a known-missing path for the 404; check `manifest.webmanifest` + service worker; test no-JS rendering (WebFetch sees pre-JS HTML).
- **Look for:** custom 404/500; maintenance page with 503; graceful no-JS degradation; service worker / offline; web app manifest (installable PWA); uptime/monitoring in place.

## Internationalisation
- **How:** grep source + `take_snapshot` for hreflang/lang; check sitemap for hreflang; inspect localized metadata.
- **Look for:** `hreflang` (HTML + sitemap); localized titles/descriptions/structured data; language switcher; RTL/bidi support where needed; CJK writing modes; locale-aware formatting; CLDR plural handling; IDN support if applicable.

---

## Recording results
For every checklist item, emit one of: **Pass** (with evidence), **Gap** (observed value + what the spec wants + fix pointer), **N-A** (doesn't apply to this site type — say why), or **No-evidence** (couldn't verify — say what's needed). Preserve the spec's Required / Recommended / Optional tier on each so the must-fix list stays honest.
