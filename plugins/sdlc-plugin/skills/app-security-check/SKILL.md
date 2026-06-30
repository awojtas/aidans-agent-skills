---
name: app-security-check
description: Audits an application's whole security posture across solution, architecture, platform, coding, and data storage — mapped to OWASP Top 10:2025 and OWASP Secure-by-Design. Detects the stack, runs whatever scanners are available (dependency/supply-chain audit, secret scanning, SAST) as evidence, reviews code, dependencies, secrets hygiene, auth, and data-at-rest, then reports tiered P0/P1/P2 findings with file:line evidence. Read-only and deliberately exhaustive — never edits. Use when the user says "check my app's security", "security posture audit", "is my app secure", "OWASP audit", "secure-by-design review", "secrets/dependency audit", "data storage security", "harden my app", or "application security review". For a diff-scoped review use /security-review; for platform/infra wiring use /platform-verify.
---

Audit an application's **whole security posture** — solution, architecture, platform, coding, and data storage — against **OWASP Top 10:2025** and **OWASP Secure-by-Design**. Detect the stack, run available scanners for evidence, review the code and configuration, and report prioritised findings. **Read-only: this skill never edits the app.**

## Thoroughness mandate

This is a deliberate, hours-if-needed audit. *One hour of careful checking beats twelve hours debugging why the site got hacked at 3am Sunday.* So:

- **Assess every OWASP category against every surface.** Don't stop at the first few findings or the easy wins.
- **No evidence ≠ secure.** A category you couldn't verify is reported as **No-evidence** (a gap in assurance), never silently assumed safe.
- **Say what you ran and what you couldn't.** If a scanner isn't installed, name it as a coverage gap rather than skipping in silence.
- Coverage over speed. Take the time it takes.

## When to use this vs others

- **Want a whole-app security posture review?** This skill.
- **Reviewing the security of just the pending diff/branch?** Use the built-in `/security-review` — it's diff-scoped; this skill is app-wide.
- **Checking that provisioned platform/infra is wired and locked down (branch protection, secret scanning, IAM, deploy tokens)?** Use `/platform-verify`. This skill cross-references it rather than duplicating it.
- **Android release signing specifically?** Use `android-key-signer`.

## Workflow

### 1. Scope & stack detection

Establish what you're auditing before checking anything:

- Languages, frameworks, package managers, build tooling.
- Data stores (SQL/NoSQL, object storage, caches) and where secrets live.
- Hosting/platform, auth provider, external integrations, trust boundaries.
- Read any `docs/architecture/`, `docs/design/`, `README`, threat model, or `docs/requirements/` present — reuse the source-of-truth reading pattern from `/platform-verify`. If architecture docs exist, audit the *designed* posture too, not just the code.

State the scope back to the user (what's in, what's out) before going deep.

### 2. Gather evidence — run available scanners (read-only)

Detect-then-run; skip gracefully if a tool isn't installed **and record the skip as a coverage gap**. See `references/scanners-by-stack.md` for exact commands per ecosystem. Categories:

- **Dependency / supply-chain (A03):** `npm/pnpm/yarn audit`, `pip-audit`, `dotnet list package --vulnerable`, `osv-scanner`, `govulncheck`, `cargo audit` — whatever matches the stack. Also check for lockfiles, pinned versions, and integrity hashes.
- **Secrets:** `gitleaks` / `trufflehog` if available; otherwise grep the working tree **and git history** for hardcoded credentials, tokens, private keys, connection strings.
- **SAST:** `semgrep` (with an appropriate ruleset) or framework security linters if present.

Capture raw scanner output as evidence. **Never auto-fix**, never run scanners that mutate the repo.

### 3. Assess by surface, mapped to OWASP Top 10:2025

Work through every surface the user named, cross-referenced to OWASP categories. Full "what to look for" + "how to gather evidence" per category is in `references/owasp-top10-2025.md`. The mapping:

| Surface | Primary OWASP categories | Core questions |
|---|---|---|
| **Solution / Architecture / Design** | A06 Insecure Design, A01 Broken Access Control | Is there a threat model? Are trust boundaries explicit? Is authorization designed centrally, deny-by-default, and enforced server-side? |
| **Platform** | A02 Security Misconfiguration | Hardened defaults, no exposed admin/debug, TLS, security headers, least-privilege IAM. *(Cross-ref `/platform-verify`.)* |
| **Coding** | A05 Injection, A03 Supply Chain, A08 Integrity, A10 Mishandling of Exceptional Conditions | Parameterised queries / output encoding, validated input, trusted dependencies + CI integrity, and exceptions handled (no leaked stack traces, fail-closed). |
| **Data storage** | A04 Cryptographic Failures | Encryption in transit + at rest, managed keys + rotation, no sensitive data in logs/caches, data minimisation, strong hashing for passwords. |
| **Auth & sessions** | A07 Authentication Failures | MFA support, no default/weak credentials, secure session/token handling, rate-limited + lockout on auth endpoints. |
| **Logging & monitoring** | A09 Security Logging & Alerting Failures | Security events logged, no secrets/PII in logs, alerting on suspicious activity, tamper-resistant audit trail. |

For each category record a verdict: **Pass** (with evidence), **Gap** (finding), **N-A** (with reason), or **No-evidence** (what's needed to confirm).

### 4. Report — tiered findings

Produce a single markdown report (offer to save it, e.g. `security-posture-audit-YYYY-MM-DD.md`; don't auto-write without asking). Structure:

1. **Verdict line** + a **Security Posture table** (one row per OWASP category: Pass / Gap / N-A / No-evidence).
2. **Findings, tiered:**
   - **P0** — exploitable now / critical exposure (e.g. committed secret, SQL injection, unauthenticated admin route, unencrypted PII at rest). Fix before anything ships.
   - **P1** — serious weakness, not trivially exploitable yet.
   - **P2** — hardening / defence-in-depth.
   Each finding: **what's wrong**, **`file:line` (or config/arch) evidence**, **why it matters (impact)**, and a **concrete remediation pointer**.
3. **Coverage note** — which scanners ran, which were unavailable, what couldn't be verified (the No-evidence items).

**Read-only: never edit.** Offer to fix or to raise issues only if the user asks afterwards.

### 5. Cross-references / non-goals

- Distinct from `/security-review` (diff-scoped), `/platform-verify` (platform wiring), `android-key-signer` (Android signing). This is whole-app *posture*.
- This skill **does not pentest or exploit** — it audits and advises. No live attacks, no fuzzing against production, no destructive probes.

## Guardrails

- **Read-only, always.** Run only non-mutating scanners. Never edit code, never auto-bump dependencies, never rewrite config. Reporting is the deliverable.
- **No silent gaps.** Every scanner you couldn't run and every check you couldn't complete is named in the coverage note. Unverified is reported, not hidden.
- **Evidence, not vibes.** Every finding cites a `file:line`, a config value, a scanner result, or an architecture-doc reference. No hand-waved claims.
- **Don't leak what you find.** Treat any discovered secret as sensitive — reference its location, never paste the value into the report or chat. Recommend rotation.
- **Map to the standard.** Anchor findings to OWASP Top 10:2025 categories so the report is auditable; consult `references/owasp-top10-2025.md` and the live OWASP source rather than memory for authoritative detail.
- **Exhaustive, not fast.** Cover every surface and every category before reporting.
