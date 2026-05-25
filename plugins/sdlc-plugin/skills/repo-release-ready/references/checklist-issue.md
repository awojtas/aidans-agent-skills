## Repo Level-Up: Checklist for Human Admin

This repo was just put through `/repo-release-ready`. Most of the wiring landed in the PR, but a handful of things need a human with admin permissions on the repo (and on the linked hosting/secret-scanning accounts) to finish. Tick each one when done.

### 1. Required GitHub Actions secrets

Add these under **Settings → Secrets and variables → Actions**:

- [ ] **`GITGUARDIAN_API_KEY`** — gives the `GitGuardian Security Scan` workflow access to scan for committed secrets. Get one at https://dashboard.gitguardian.com/api/personal-access-tokens (free tier is fine for a single repo).
- [ ] **`CLAUDE_CODE_OAUTH_TOKEN`** — token for the `Claude On-Demand` workflow (`@claude` mentions). Generate from the Claude Code app or `claude` CLI (`claude setup-token`).
- [ ] **`PROMOTE_TO_PROD_TOKEN`** *(optional but recommended)* — a fine-grained PAT or GitHub App token with `contents: write` and `pull_requests: write` scopes. Without it, the promote workflows fall back to the default `GITHUB_TOKEN`, which cannot bypass branch protections in `force_deploy` mode.

### 2. Branch protection rulesets — Phase A complete; Phase B needs CI history

Three rulesets were installed automatically as **Phase A**: `Main {{REPO_NAME_TITLE}}`, `UAT {{REPO_NAME_TITLE}}`, `Production {{REPO_NAME_TITLE}}`. Phase A locks down the basics — require PR, no force-push, no deletion — and works on a fresh repo because it requires no check history.

**Phase A — verify (a glance):**

- [ ] Three rulesets are listed under **Settings → Rules → Rulesets** and all **Active**.
- [ ] Each rule's target branch matches (`main`, `release/uat`, `release/prod`).

Do **not** rename `Production {{REPO_NAME_TITLE}}` — the promote-to-production workflow looks it up by name when `force_deploy: true`.

**Phase B — add required status checks (do this AFTER CI has run at least once):**

GitHub's "Require status checks" picker only shows checks it has *actually observed running* in the repo. On a freshly-scaffolded repo, the picker is **empty** — there's nothing to require yet. Three ways to populate it:

- **Easiest:** merge this level-up PR. The on-push workflows (`gitguardian-scan`, `vibe-guard-scan`) fire when the merge lands on `main`; their contexts appear in the picker shortly after.
- **Faster:** trigger the scan workflows manually — both have `workflow_dispatch:`. Either click **Actions → (workflow) → Run workflow**, or:
  ```bash
  gh workflow run gitguardian-scan.yml
  gh workflow run vibe-guard-scan.yml
  ```
- **Vercel check** (`Vercel – {{REPO_NAME}}`): comes from the Vercel-GitHub integration, not a GitHub Actions workflow. It appears after the first Vercel deploy (after Step 3 below).

Once contexts are visible, edit each ruleset under **Settings → Rules → Rulesets → (ruleset) → Edit rules → Require status checks** and tick the ones you want required.

- [ ] Required status checks added to `Main {{REPO_NAME_TITLE}}` (typically: GitGuardian, Vibe-Guard).
- [ ] Required status checks added to `UAT {{REPO_NAME_TITLE}}` (typically: Vercel deployment, GitGuardian, Vibe-Guard).
- [ ] Required status checks added to `Production {{REPO_NAME_TITLE}}` (same as UAT).

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

### 4. Dependabot version updates

`.github/dependabot.yml` is scaffolded with the `github-actions` ecosystem only. **Version updates** are free on all plans (public and private). After you pick a stack:

- [ ] Add the matching ecosystem block (`npm`, `pip`, `cargo`, `gomod`, `nuget`, `gradle`, ...) in `.github/dependabot.yml`.
- [ ] Confirm **Dependabot version updates** is on under **Settings → Code security** (usually auto-on once `dependabot.yml` is committed).

<!-- code-security:start -->

### 5. Code security features

These are free on public repos and on private repos with GitHub Advanced Security. The skill attempted to enable them via API in Step 7.5; any that succeeded are already on. Confirm or enable the rest under **Settings → Code security**:

- [ ] **Secret scanning** — alerts on committed secrets.
- [ ] **Push protection** — blocks pushes that contain detected secrets.
- [ ] **Dependabot security updates** — auto-PR'd vulnerability fixes (distinct from version updates in Section 4).
- [ ] **Code scanning** — so SARIF output from `Vibe-Guard Security Scan` becomes visible in the Security tab.
- [ ] If you switch away from Node/TS as the stack, either delete `vibe-guard-scan.yml` or swap it for an equivalent SARIF scanner.

<!-- code-security:end -->

<!-- code-security-plan-gated:start -->

### 5. Code security features — Skipped (requires GitHub Advanced Security)

This is a **private repo on a plan without GitHub Advanced Security** (Free plan; or Team/Enterprise without the GHAS license; or no Code Security add-on). The following features are **plan-gated** and cannot be enabled until the repo's plan changes:

- Secret scanning
- Push protection
- Dependabot **security** updates (auto-PR'd vulnerability fixes — version updates in Section 4 still work)
- Code scanning / SARIF visibility in the Security tab

`vibe-guard-scan.yml` still runs and posts findings to the PR; they just won't appear under the Security tab without code scanning enabled.

If the repo later moves to a plan with GHAS (Team/Enterprise + GHAS, or the standalone Code Security plan): come back to **Settings → Code security** and enable these toggles. They'll work the same as on a public repo.

<!-- code-security-plan-gated:end -->

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
