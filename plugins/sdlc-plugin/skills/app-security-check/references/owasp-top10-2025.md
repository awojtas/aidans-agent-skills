# OWASP Top 10:2025 — what to look for, how to gather evidence

Reference for `app-security-check`. The ten categories below are the 2025 list. **Consult the live OWASP source (`https://owasp.org/Top10/`) for authoritative, current detail** — do not treat this file as the final word; it's a working checklist, not the spec.

For each category: the surfaces it touches, what a weakness looks like, and how to gather evidence in a read-only audit. Record a verdict per category: Pass / Gap / N-A / No-evidence.

---

## A01:2025 — Broken Access Control
- **Surfaces:** architecture, coding, auth.
- **Look for:** authorization enforced server-side and centrally (not in the UI); deny-by-default; no IDOR (object references checked against the caller); no missing function-level checks; no path traversal; CORS not wildcard-with-credentials; admin routes gated.
- **Evidence:** trace a few sensitive endpoints from route → handler → authz check. Grep for auth middleware, role checks, `@PreAuthorize`/guards/policies. Look for endpoints that read an ID from the request and fetch without an ownership check.

## A02:2025 — Security Misconfiguration
- **Surfaces:** platform, coding.
- **Look for:** debug mode off in prod; no default credentials; unnecessary features/ports/services disabled; security headers present; directory listing off; verbose errors not exposed; sample/admin apps removed; hardened framework config.
- **Evidence:** inspect config files (`*.config`, `settings.py`, `application.yml`, env), Dockerfiles, IaC. Cross-reference `/platform-verify` for branch protection / IAM / exposure. Check response headers on a running instance.

## A03:2025 — Software Supply Chain Failures *(new/expanded)*
- **Surfaces:** coding, platform, build/CI.
- **Look for:** known-vulnerable dependencies; unpinned or floating versions; missing lockfile; unverified package sources; build/CI integrity (no untrusted scripts, pinned action SHAs); typosquat risk; absent SBOM.
- **Evidence:** run the dependency scanners in `scanners-by-stack.md`. Check lockfile presence + integrity hashes. Review CI workflow files for unpinned third-party actions and `curl | sh` patterns.

## A04:2025 — Cryptographic Failures
- **Surfaces:** data storage, coding, platform.
- **Look for:** TLS everywhere (no plaintext transport); sensitive data encrypted at rest (AES-256 / managed KMS); key rotation; strong password hashing (bcrypt/scrypt/argon2, never MD5/SHA1/plain); no weak/custom crypto; no secrets or sensitive data in logs/caches; proper randomness for tokens.
- **Evidence:** grep for crypto APIs, hashing calls, `http://` literals, hardcoded keys/IVs. Inspect DB schema + storage config for encryption. Check how passwords and tokens are generated and stored.

## A05:2025 — Injection
- **Surfaces:** coding.
- **Look for:** SQL/NoSQL/OS-command/LDAP injection; XSS (reflected/stored/DOM); template injection; unparameterised queries; unsanitised input reaching interpreters; missing output encoding.
- **Evidence:** SAST (e.g. `semgrep`). Grep for string-concatenated queries, `eval`, `exec`, `dangerouslySetInnerHTML`, raw shell calls. Confirm ORM/parameterised queries and context-aware output encoding are used.

## A06:2025 — Insecure Design
- **Surfaces:** solution, architecture.
- **Look for:** absent threat model; missing security requirements; no defence-in-depth; trust boundaries unclear; no rate limiting / abuse protection by design; sensitive flows lacking step-up auth.
- **Evidence:** read architecture/design docs and requirements. Assess whether security was designed in, not bolted on. The absence of any security design artefact is itself a Gap.

## A07:2025 — Authentication Failures
- **Surfaces:** auth, coding, platform.
- **Look for:** MFA available; no default/weak/known passwords; credential-stuffing + brute-force protection (rate limit, lockout); secure session management (rotation on login, secure/HttpOnly/SameSite cookies, sane timeout); secure password recovery; no exposed session IDs in URLs.
- **Evidence:** review the auth flow / provider config. Check session + cookie handling. Look for rate limiting on login/reset endpoints.

## A08:2025 — Software or Data Integrity Failures
- **Surfaces:** coding, supply chain, platform.
- **Look for:** unsigned/unverified updates or deserialization of untrusted data; CI/CD pipeline integrity; dependencies from untrusted sources; missing SRI on third-party assets; auto-update without signature checks.
- **Evidence:** review deserialization usage, update mechanisms, CI/CD config. Check for signature/hash verification on artifacts and SRI on external scripts.

## A09:2025 — Security Logging & Alerting Failures
- **Surfaces:** logging/monitoring, platform.
- **Look for:** auth events / access-control failures / high-value actions logged; no secrets or PII written to logs; logs tamper-resistant; alerting on suspicious activity; sufficient retention; monitoring actually wired up.
- **Evidence:** review logging config + a sample of log statements. Check for an alerting/monitoring integration. Grep for logging of passwords/tokens/PII (a Gap if present).

## A10:2025 — Mishandling of Exceptional Conditions *(new)*
- **Surfaces:** coding.
- **Look for:** errors handled consistently and fail-closed (not fail-open); no leaked stack traces / internal details to users; no swallowed exceptions hiding security failures; resource cleanup on error paths; graceful degradation.
- **Evidence:** review error-handling patterns and global handlers. Grep for empty catch blocks, generic catch-and-continue, and detailed error responses returned to clients.

---

## Surface → category quick map
- **Solution / Architecture / Design** → A06, A01
- **Platform** → A02, A09 (cross-ref `/platform-verify`)
- **Coding** → A05, A03, A08, A10
- **Data storage** → A04
- **Auth & sessions** → A07
- **Logging & monitoring** → A09
