// Visual-repro harness — drive the *deployed* app in an emulated browser to
// reproduce, diagnose and verify layout / responsive / mobile bugs by MEASURING
// the real DOM (not eyeballing screenshots). Generic plumbing lives here;
// project-specific bits are in `auth.mjs` and the `goto*/measure*` functions at
// the bottom of this file.
//
// Auth uses a persisted Playwright storageState so we log in once and reuse the
// session (fast, and it dodges login rate-limiting); a stale session re-auths.

import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from '@playwright/test'; // or 'playwright' if that's the dep
import { authHeaders, isLoggedIn, login } from './auth.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
// Points to <webapp>/.env.e2e — update only if your .env.e2e lives elsewhere.
const ENV_FILE = path.join(HERE, '..', '..', '.env.e2e');
const STATE_PATH = path.join(HERE, '.auth', 'state.json');
// TODO(init): the base for the app's API (same-origin '/api', or a full host).
const API_BASE = '/api';

/** Minimal .env loader (no dependency): KEY=VALUE lines; never overrides real env. */
function loadEnv() {
  if (!existsSync(ENV_FILE)) return;
  for (const line of readFileSync(ENV_FILE, 'utf8').split('\n')) {
    const m = /^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/.exec(line);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^['"]|['"]$/g, '');
  }
}

/** Emulation profile for a device keyword or a raw CSS width (e.g. "390"). */
export function deviceContext(device = 'mobile') {
  const presets = {
    mobile: { width: 412, height: 915, dsf: 3, mobile: true },
    desktop: { width: 1280, height: 900, dsf: 1, mobile: false },
  };
  const p = presets[device] ?? { width: Number(device) || 412, height: 915, dsf: 2, mobile: true };
  return {
    viewport: { width: p.width, height: p.height },
    deviceScaleFactor: p.dsf,
    isMobile: p.mobile,
    hasTouch: p.mobile,
    ...(p.mobile
      ? { userAgent: 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36' }
      : {}),
  };
}

export function getConfig(overrides = {}) {
  loadEnv();
  return {
    baseUrl: overrides.url || process.env.REPRO_BASE_URL, // TODO(init): sensible default
    email: process.env.REPRO_EMAIL,
    password: process.env.REPRO_PASSWORD,
    statePath: STATE_PATH,
  };
}

/** Run `fn({ page, api, cfg })` in an emulated, authenticated session.
 *  Reuses a saved storageState; re-auths + re-saves if it's missing/stale. */
export async function withSession({ device = 'mobile', url, forceLogin = false }, fn) {
  const cfg = getConfig({ url });
  const ctxOpts = deviceContext(device);
  const browser = await chromium.launch({ headless: true });
  try {
    const haveState = existsSync(cfg.statePath) && !forceLogin;
    let ctx = await browser.newContext(haveState ? { ...ctxOpts, storageState: cfg.statePath } : ctxOpts);
    let page = await ctx.newPage();
    await page.goto(cfg.baseUrl, { waitUntil: 'domcontentloaded' }).catch(() => {});
    if (!(await isLoggedIn(page))) {
      await ctx.close();
      ctx = await browser.newContext(ctxOpts);
      page = await ctx.newPage();
      await login(page, cfg);
      mkdirSync(path.dirname(cfg.statePath), { recursive: true });
      await ctx.storageState({ path: cfg.statePath });
    }
    const api = async (apiPath, opts = {}) => {
      const headers = { 'content-type': 'application/json', ...(await authHeaders(page)), ...(opts.headers || {}) };
      return page.evaluate(
        async ([base, p, o]) => {
          const r = await fetch(`${base}${p}`, o);
          return { status: r.status, body: await r.json().catch(() => null) };
        },
        [API_BASE, apiPath, { ...opts, headers }],
      );
    };
    return await fn({ page, api, cfg });
  } finally {
    await browser.close();
  }
}

// ─── Project-specific: the component under test ───────────────────────────────
// TODO(init): replace the selectors + metrics below with the real component and
// the numbers that define "correct" for it. See references/measuring.md.

export async function gotoScreen(page, cfg, route) {
  await page.goto(`${cfg.baseUrl}${route}`, { waitUntil: 'networkidle' });
  await page.waitForSelector('SELECTOR-FOR-A-RENDERED-ELEMENT', { timeout: 20_000 });
  await page.waitForTimeout(1500); // let any on-open animation/centring settle
}

export async function measureScreen(page) {
  return page.evaluate(() => {
    const el = document.querySelector('SELECTOR-FOR-THE-COMPONENT');
    if (!el) return { error: 'component not found' };
    const r = el.getBoundingClientRect();
    // EXAMPLE metric — replace with what matters for this bug:
    return { left: Math.round(r.left), right: Math.round(r.right), overflowX: el.scrollWidth > el.clientWidth };
  });
}
