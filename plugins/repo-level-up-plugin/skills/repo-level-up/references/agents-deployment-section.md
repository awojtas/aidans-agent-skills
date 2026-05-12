## Deployment & Branching Strategy

### Branch Structure

| Branch        | Purpose                          | Notes                                                     |
|---------------|----------------------------------|-----------------------------------------------------------|
| `release/prod`| Production                       | Locked. Only updated via the promote-to-production workflow. |
| `release/uat` | User Acceptance Testing          | Locked. Only updated via the promote-to-uat workflow.        |
| `main`        | Trunk; integration target        | All feature branches merge here.                          |
| `preview/*`   | Feature branches / per-PR previews | Branch off `main`, open a PR back into `main`.            |

### Promotion Flow

1. **Feature development.** Open a branch off `main`, work, open a PR back into `main`.
2. **Trunk.** Once merged to `main`, the change is live in the dev/preview environment.
3. **Promote to UAT.** Run the `Promote "main" branch to UAT` workflow (`workflow_dispatch`). It creates and auto-merges a PR from `main` → `release/uat`.
4. **Promote to production.** Run the `Promote "main" branch to Production` workflow. Same shape, base is `release/prod`. Includes a `force_deploy` input that temporarily disables the production ruleset for the merge, then re-enables it (used for emergency releases — leave off by default).

### CI / Security

- `GitGuardian Security Scan` — runs on every push and PR. Requires the `GITGUARDIAN_API_KEY` secret.
- `Vibe-Guard Security Scan` — Node-based SARIF scan, results visible under repo Security tab.
- `Claude On-Demand` — mention `@claude` in any issue or PR comment to invoke. Requires `CLAUDE_CODE_OAUTH_TOKEN`.
- `Copilot Setup Steps` — keeps the GitHub Copilot agent environment aligned with local build. Update when build setup changes.
- `Dependabot` — weekly updates for `github-actions`. Add ecosystems (npm/pip/etc.) when the stack is chosen.

### Branch Protection

Three rulesets are installed at level-up time and **must remain active** for the promote flow to be safe:

| Ruleset name                       | Target                | Enforces                                                  |
|------------------------------------|-----------------------|-----------------------------------------------------------|
| `Main {{REPO_NAME_TITLE}}`         | `refs/heads/main`     | PR required, no force-push, no deletion                  |
| `UAT {{REPO_NAME_TITLE}}`          | `refs/heads/release/uat` | PR required, no force-push, no deletion                |
| `Production {{REPO_NAME_TITLE}}`   | `refs/heads/release/prod` | PR required, no force-push, no deletion              |

The production promote workflow looks up `Production {{REPO_NAME_TITLE}}` by name when `force_deploy: true` — do not rename it.
