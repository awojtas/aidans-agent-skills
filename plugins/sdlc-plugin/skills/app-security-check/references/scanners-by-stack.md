# Scanners by stack

Reference for `app-security-check` step 2. **Detect the stack first, then run only what's installed.** If a scanner isn't present, record it as a coverage gap in the report — do **not** silently skip. All commands below are read-only / non-mutating. Never run a fix/`--fix`/auto-update variant in this skill.

## Detect first
- Lockfiles & manifests: `package.json`/`pnpm-lock.yaml`/`yarn.lock`, `requirements.txt`/`poetry.lock`/`Pipfile.lock`, `*.csproj`/`packages.lock.json`, `go.mod`/`go.sum`, `Cargo.toml`/`Cargo.lock`, `composer.json`, `Gemfile.lock`, `pom.xml`/`build.gradle`.
- Check a tool exists before invoking: `command -v <tool>` (or the ecosystem's own `--version`).

## Dependency / supply-chain (A03)
| Ecosystem | Command (read-only) | Notes |
|---|---|---|
| npm | `npm audit --json` | Use `--omit=dev` to focus on prod deps. |
| pnpm | `pnpm audit --json` | |
| yarn | `yarn npm audit --json` (berry) / `yarn audit --json` (classic) | |
| Python | `pip-audit -f json` | Or `pip-audit -r requirements.txt`. |
| .NET | `dotnet list package --vulnerable --include-transitive` | Needs network; restore first if needed (read-only restore). |
| Go | `govulncheck ./...` | Source-aware; only reports reachable vulns. |
| Rust | `cargo audit` | |
| PHP | `composer audit` | |
| Ruby | `bundle audit check --update` | |
| Java/Kotlin | `mvn org.owasp:dependency-check-maven:check` / OWASP Dependency-Check CLI | Heavier; run if present. |
| Multi/any | `osv-scanner --recursive .` | Language-agnostic; great fallback covering many lockfiles at once. |

## Secrets
| Tool | Command (read-only) | Notes |
|---|---|---|
| gitleaks | `gitleaks detect --no-banner --redact` | Scans working tree **and** git history. `--redact` keeps values out of output. |
| trufflehog | `trufflehog filesystem . --json` / `trufflehog git file://. --json` | Verifies live credentials where possible. |
| Manual fallback | grep tree + history for `password`, `secret`, `api_key`, `token`, `BEGIN PRIVATE KEY`, connection strings, cloud keys (`AKIA`, `AIza`, `sk-`, `ghp_`, `xox`) | Use when no scanner is installed — and note it's lower-confidence. |

Always treat hits as sensitive: reference location only, never paste the value; recommend rotation.

## SAST
| Tool | Command (read-only) | Notes |
|---|---|---|
| semgrep | `semgrep --config auto --json` | `--config auto` pulls a curated ruleset; or pin a ruleset (e.g. `p/owasp-top-ten`). |
| CodeQL | (if a DB/workflow already exists) review results | Don't build a DB from scratch mid-audit unless asked. |
| Framework linters | e.g. `bandit -r .` (Python), `gosec ./...` (Go), `brakeman` (Rails), ESLint security plugins (JS) | Run whichever match the stack and are installed. |

## Config / IaC (supports A02)
- Dockerfiles, `docker-compose.yml`, k8s manifests, Terraform: review by hand for exposed ports, `:latest` tags, privileged containers, public buckets, permissive IAM.
- `hadolint <Dockerfile>`, `tfsec` / `checkov`, `kube-score` if installed — otherwise manual review (note the gap).

## Reporting the run
In the audit's coverage note, list for each category: **scanner used + version**, or **"not installed — coverage gap"**. This makes the No-evidence items explicit and the audit reproducible.
