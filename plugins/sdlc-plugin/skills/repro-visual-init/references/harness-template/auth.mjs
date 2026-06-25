// Project-specific auth seam. The harness only depends on these three functions
// — implement them for THIS app's auth. See references/auth-strategies.md for
// patterns (Supabase/localStorage token, cookie/session, SSO redirect, none).
//
// The example below is the Supabase-in-localStorage pattern. DELETE/REPLACE it.

/** True when `page` is on an authenticated screen (used for storageState reuse:
 *  a stale/expired saved session falls through to a fresh `login`). */
export async function isLoggedIn(page) {
  if (page.url().includes('/login')) return false;
  return page.evaluate(() =>
    Object.keys(localStorage).some((k) => k.startsWith('sb-') && k.endsWith('-auth-token')),
  );
}

/** Log in from a clean context. Leaves `page` on a signed-in screen. */
export async function login(page, cfg) {
  if (!cfg.email || !cfg.password) throw new Error('Missing REPRO_EMAIL / REPRO_PASSWORD in .env.e2e');
  await page.goto(`${cfg.baseUrl}/login`, { waitUntil: 'domcontentloaded' });
  await page.fill('#email', cfg.email); // TODO(init): real selectors
  await page.fill('#password', cfg.password);
  await page.click('button[type=submit]');
  await page.waitForURL((u) => !u.pathname.includes('/login'), { timeout: 30_000 });
  // TODO(init): wait for a real "logged in" signal (a token, a cookie, an element).
  await page.waitForFunction(
    () => Object.keys(localStorage).some((k) => k.startsWith('sb-') && k.endsWith('-auth-token')),
    { timeout: 10_000 },
  );
}

/** Auth headers for API calls used to seed data. Return {} if the app uses
 *  cookie-based auth (storageState already carries the cookie). */
export async function authHeaders(page) {
  const token = await page.evaluate(() => {
    const k = Object.keys(localStorage).find((x) => x.startsWith('sb-') && x.endsWith('-auth-token'));
    return k ? JSON.parse(localStorage.getItem(k)).access_token : null;
  });
  if (!token) throw new Error('No session token found — not logged in?');
  return { authorization: `Bearer ${token}` };
}
