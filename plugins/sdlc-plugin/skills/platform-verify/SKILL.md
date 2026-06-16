---
name: platform-verify
description: Smoke-tests and security-audits the platforms provisioned by /platform-provision. Reads docs/architecture/provisioning-log.md to know what was stood up, then verifies reachability (every platform answers via MCP/CLI/API), secret hygiene (every secret is where it should be, no values committed), wiring (CI/CD can read what it needs, smoke-build succeeds), and security posture (branch protection, secret scanning, dependabot, least-privilege tokens, no public exposure). Produces a green/red report with remediation suggestions. Trigger phrases include "verify the platform", "smoke-test the platform", "check the platform is wired up", "security pass on the platform", "is the platform ready".
---

Verifies the platform stood up by `/platform-provision` is actually wired correctly and locked down — before serious development begins.

## When to use this skill vs others

- **Just ran `/platform-provision` and want to confirm everything is real?** This skill.
- **Haven't provisioned yet?** Run `/platform-provision` first — there's nothing to verify.
- **Locking down branch protection / SAST?** Use `/repo-release-ready` (which this skill cross-checks against once both have run).

## Workflow

1. **Read `docs/architecture/provisioning-log.md`.** If it doesn't exist, stop and tell the user to run `/platform-provision` first. The log is the source of truth for what should exist.

2. **Reachability checks** — for every platform listed in the provisioning log, confirm Claude can interact with it via whatever channel was used originally:
   - MCP server connected and responding?
   - CLI installed and authenticated?
   - HTTP API responding with the token?
   - Resource (project, org, DB, dashboard) exists at the recorded ID/URL?

3. **Secret hygiene checks:**
   - Every secret listed in the provisioning log is set in the right scope (GH Actions repo or env, platform env stores).
   - `.env.example` lists the names but no values.
   - `git log -p` doesn't show any secret values committed in the recent history (best-effort scan — last ~50 commits).
   - No secret values appear in PR comments, issue bodies, or `docs/`.
   - **Supabase key type (if Supabase is in the stack):** check whether the project uses legacy keys (`SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY`, or any value starting with `eyJ`) or the new opaque keys (`sb_publishable_…` / `sb_secret_…`). Legacy keys still work until end of 2026 — flag as **amber** (not red) with a migration note pointing to `docs/architecture/04-decisions.md` ADR-002 and the [Supabase migration guide](https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys). For new builds, legacy keys are **red** — new projects should use the new key types from day one. Also verify JWT signing: user tokens should be verified via the JWKS endpoint (`https://<ref>.supabase.co/auth/v1/.well-known/jwks.json`) with asymmetric signing, not the shared JWT secret.

4. **Wiring checks:**
   - CI workflows referenced by `/repo-release-ready` (or planned to be) can actually read the secrets they need — at least lint-check the workflow YAML for env-var references against the secret list.
   - A smoke deploy (preview env if available, otherwise a build-only run) succeeds.
   - End-to-end health endpoint / canary URL responds if one was provisioned.

5. **Security posture checks** — sweep what's typical for the kinds of platforms in the provisioning log:
   - Branch protection enabled on `main` (and on release branches if they exist).
   - Secret scanning enabled (GitHub Advanced Security, GitGuardian, or equivalent if visible).
   - Dependabot / SCA enabled.
   - Least-privilege on tokens (scoped tokens rather than PATs; deploy tokens limited to their target).
   - No accidentally-public resources (bucket ACLs, repo visibility, dashboard sharing).
   - Default-deny IAM where applicable on cloud providers.

6. **Cross-check against `/repo-release-ready`** if it has already run — match SAST/secret-scanning/branch-protection expectations against what the platform side reports.

7. **Report** — write a single markdown report. Default location: append to `docs/architecture/provisioning-log.md` under a *"Verification YYYY-MM-DD"* heading (or, if it's getting big, spin out `docs/architecture/platform-verification.md`). Format:
   - Green/red per check
   - For reds: what's broken, why, and a remediation step
   - Overall verdict: ready / not-ready, with the top 3 blockers if not-ready

## Guardrails

- **Read-only, with one exception.** This skill does *not* re-provision anything. The single exception is closing out completed items on the provisioning-log human-task checklist once the corresponding verification check passes — that's a status update, not a re-provision.
- **Don't make assumptions about what to verify.** Drive the check list off the provisioning log, not a fixed catalogue. If the log doesn't mention Sentry, don't check Sentry.
- **Don't surface false positives.** If a check is inconclusive (e.g., can't tell whether secret scanning is enabled without admin rights), report it as "inconclusive — needs admin check" rather than "red".
- **Bound the smoke build.** Don't run an open-ended deploy job. A build-only or preview-deploy is sufficient. If a full deploy is what's needed, surface that as a separate user task.
- **Surface human-only checks.** Some verification is inherently human — confirming a console UI shows the right billing plan, for instance. List these as separate items rather than trying to automate them.

## Output

- `docs/architecture/provisioning-log.md` (or `platform-verification.md`) updated with a fresh verification block.
- A short summary to the user: overall verdict, top reds, what's next (typically: address reds, then `/repo-release-ready` if not yet done; otherwise `/requirements-create-from-design`).

## Commit and push

Stage the verification doc (`docs/architecture/provisioning-log.md` or `docs/architecture/platform-verification.md` if spun out) and `README.md` (lifecycle tracker), commit with `docs(platform): verification YYYY-MM-DD`, then follow [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md).

## Lifecycle tracker

This skill owns the **Platform verified** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Platform verified` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Platform verified` line to ✅ (done).

Touch only the `Platform verified` line — leave every other stage exactly as found.
