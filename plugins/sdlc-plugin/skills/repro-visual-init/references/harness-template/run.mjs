// CLI for the visual-repro harness. Examples:
//   <pm> repro --login
//   <pm> repro --seed scripts/repro/fixtures/example.json   # prints created id(s)
//   <pm> repro --path /some/route --device mobile --measure --screenshot /tmp/x.png
//   <pm> repro --path /some/route --device 360 --assert-loads
// Config from .env.e2e (see .env.e2e.example).

import { readFileSync } from 'node:fs';
import { gotoScreen, measureScreen, withSession } from './harness.mjs';

const a = process.argv.slice(2);
const get = (n) => (a.indexOf(`--${n}`) >= 0 ? a[a.indexOf(`--${n}`) + 1] : undefined);
const has = (n) => a.includes(`--${n}`);
const device = get('device') || 'mobile';
const url = get('url');

// TODO(init): replace with the app's real create-entity calls for the thing
// under test. Keep it a tiny, declarative seed driven by a JSON spec.
async function seed(api, spec) {
  // example: const res = await api('/things', { method: 'POST', body: JSON.stringify(spec) });
  // return { id: res.body.id };
  throw new Error('seed() not implemented — wire it to the app API, or remove --seed');
}

async function main() {
  if (has('login')) {
    await withSession({ device, url, forceLogin: true }, async () => {});
    console.log('Session cached at scripts/repro/.auth/state.json');
    return;
  }
  await withSession({ device, url }, async ({ page, api, cfg }) => {
    if (has('seed')) {
      console.log(JSON.stringify(await seed(api, JSON.parse(readFileSync(get('seed'), 'utf8')))));
      return;
    }
    const route = get('path');
    if (!route) {
      console.error('Pass --path <route>, --seed <file>, or --login');
      process.exitCode = 1;
      return;
    }
    await gotoScreen(page, cfg, route);
    if (has('assert-loads')) {
      const ok = await page.locator('SELECTOR-FOR-A-RENDERED-ELEMENT').count().then((c) => c > 0).catch(() => false);
      console.log(`assert-loads: ${ok ? 'PASS' : 'FAIL'}`);
      if (!ok) process.exitCode = 1;
    }
    if (has('measure')) console.log(`[${device}] ${JSON.stringify(await measureScreen(page))}`);
    if (has('screenshot')) {
      await page.screenshot({ path: get('screenshot') });
      console.log(`screenshot → ${get('screenshot')}`);
    }
  });
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
