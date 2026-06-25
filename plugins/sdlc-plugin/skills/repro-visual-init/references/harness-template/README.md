# Visual-repro harness

Drive the **deployed** app in an emulated browser to reproduce, diagnose and
**verify** layout / responsive / mobile bugs by *measuring the real DOM*.
Scaffolded by `/repro-visual-init`; driven by `/repro-visual` (or run it yourself).

## Setup
1. `cp scripts/repro/.env.e2e.example <webapp>/.env.e2e` then fill in creds (test account only).
2. Install the browser once: `npx playwright install chromium`.

`.env.e2e` and `scripts/repro/.auth/` are gitignored — they hold credentials.

## Commands
```
<pm> repro --login                         # cache the session once
<pm> repro --seed scripts/repro/fixtures/example.json
<pm> repro --path <route> --device mobile  --measure --screenshot /tmp/x.png
<pm> repro --path <route> --device 360     --measure   # any CSS width
<pm> repro --path <route> --device desktop --assert-loads
```

## Adapting
- **Auth** → `auth.mjs` (`login` / `isLoggedIn` / `authHeaders`).
- **What "correct" means** → `measureScreen()` (+ `gotoScreen`) in `harness.mjs`.
- **Seeding** → `seed()` in `run.mjs`.
