## Repo Level-Up: Checklist for Human Admin

This repo was just put through `/repo-release-ready`. Most of the wiring landed in the PR, but a handful of things need a human with admin permissions on the repo (and on the linked hosting/secret-scanning accounts) to finish. Tick each one when done.

### 1. Required GitHub Actions secrets

Add these under **Settings → Secrets and variables → Actions**:

- [ ] **`GITGUARDIAN_API_KEY`** — gives the `GitGuardian Security Scan` workflow access to scan for committed secrets. Get one at https://dashboard.gitguardian.com/api/personal-access-tokens (free tier is fine for a single repo).
- [ ] **`CLAUDE_CODE_OAUTH_TOKEN`** — token for the `Claude On-Demand` workflow (`@claude` mentions). Generate from the Claude Code app or `claude` CLI (`claude setup-token`).
- [ ] **`PROMOTE_TO_PROD_TOKEN`** *(optional but recommended)* — a fine-grained PAT or GitHub App token with `contents: write` and `pull_requests: write` scopes. Without it, the promote workflows fall back to the default `GITHUB_TOKEN`, which cannot bypass branch protections in `force_deploy` mode.

### 2. Verify branch protection rulesets

Three rulesets were installed automatically: `Main {{REPO_NAME_TITLE}}`, `UAT {{REPO_NAME_TITLE}}`, `Production {{REPO_NAME_TITLE}}`. Verify them under **Settings → Rules → Rulesets**:

- [ ] All three are listed and **Active**.
- [ ] Each rule's target branch matches (`main`, `release/uat`, `release/prod`).
- [ ] Once CI is added (later), come back here and add the relevant status checks as **Required** under each ruleset.

Do **not** rename `Production {{REPO_NAME_TITLE}}` — the promote-to-production workflow looks it up by name when `force_deploy: true`.

### 3. Vercel project (hosting)

The promote workflows include a Vercel deployment-status gate (context: `Vercel – {{REPO_NAME}}`). For that gate to ever turn green:

- [ ] Create a Vercel project linked to this GitHub repo. Project name should be `{{REPO_NAME}}` (lowercase) so the status context matches.
- [ ] Set the production branch in Vercel to `release/prod` (Settings → Git → Production Branch).
- [ ] Set environment-scoped domains:
  - `release/prod` → your production domain
  - `release/uat` → e.g. `uat.<your-domain>`
  - `main` → e.g. `dev.<your-domain>`
- [ ] Add any required env vars under **Settings → Environment Variables** (one per environment).
- [ ] Confirm the GitHub Vercel integration is producing a commit status with context exactly `Vercel – {{REPO_NAME}}`. If your Vercel project has a different display name, edit the two workflow files (`.github/workflows/promote-to-uat.yml` and `.github/workflows/promote-to-production.yml`) and update the `select(.context == "Vercel – {{REPO_NAME}}")` line.

> If you're **not** using Vercel: delete the `Verify main branch deployments are ready` step from both promote workflows, or replace its `gh api ... statuses` block with the equivalent check for your provider (Cloudflare Pages, Firebase Hosting, Netlify, etc.).

### 4. Dependabot

`.github/dependabot.yml` is scaffolded with the `github-actions` ecosystem only. After you pick a stack:

- [ ] Add the matching ecosystem block (`npm`, `pip`, `cargo`, `gomod`, `nuget`, `gradle`, ...) in `.github/dependabot.yml`.
- [ ] Enable **Dependabot security updates** under **Settings → Code security**.
- [ ] Enable **Dependabot version updates** under the same page (if not already on).

### 5. GitHub Security tab

- [ ] Enable **Secret scanning** under **Settings → Code security** (free for public repos, paid for private — check current GHAS pricing).
- [ ] Enable **Code scanning** so the SARIF output from `Vibe-Guard Security Scan` becomes visible in the Security tab.
- [ ] Once Node/TS is the stack: leave `vibe-guard-scan.yml` enabled. If you pick a non-Node stack, either delete it or swap in the equivalent SARIF scanner.

### 6. Promote workflow trial run

After secrets are in, do a smoke run of the promote workflows to prove the wiring is correct:

- [ ] **Actions → `Promote "main" branch to UAT` → Run workflow.** Expect it to fail at "Verify main branch deployments are ready" until Vercel is wired (Step 3). That's fine — it proves the workflow loads and reads the ruleset.
- [ ] Once Vercel is up, repeat. Expect success and a clean fast-forward of `release/uat`.
- [ ] Same drill for `Promote "main" branch to Production` once UAT is happy.

### 7. PR template + version labels (if using the label-driven version bump)

The new `.github/pull_request_template.md` references `version:major / minor / patch / skip` labels. Create them once so they're pickable on PRs:

- [ ] In **Issues → Labels**, add `version:major`, `version:minor`, `version:patch`, `version:skip` (any colours).
- [ ] If you don't actually use semver-driven bumping, simplify the template — delete the "Version Bump" section.

### 8. Claude On-Demand smoke test

- [ ] Open or comment on any issue/PR with `@claude hello` and confirm the workflow triggers and Claude replies. If it doesn't, double-check the `CLAUDE_CODE_OAUTH_TOKEN` secret and the workflow run logs.

---

When this list is fully ticked, the repo is ready for normal development against `main`, UAT promotions, and production releases. Close this issue.
