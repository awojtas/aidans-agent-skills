# 04 — Decisions (lightweight ADRs)

Architecture Decision Records, kept light. Each entry is **1–2 paragraphs** and follows [Michael Nygard's ADR format](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locations/nygard/index.md) abbreviated.

When to add an entry:

- We made a technical choice that constrains future work.
- We picked option A over options B and C — and the reasoning is non-obvious enough that a reader six months from now will want to know why.
- We changed our mind on a previous decision — keep the old entry (mark Superseded) and add a new one.

When **not** to add an entry:

- Implementation detail ("use `for` instead of `forEach`").
- Choices fully determined by another decision ("we use Postgres → we use SQL").
- Personal style preferences with no architectural impact.

## Format per decision

```markdown
### ADR-NNN: <Title in present tense — e.g. "Use Postgres for primary store">

- **Status.** Proposed | Accepted | Superseded by ADR-NNN | Deprecated
- **Date.** YYYY-MM-DD
- **Context.** What forces are at play. The thing that made this decision necessary.
- **Decision.** What we picked.
- **Consequences.** What becomes easier as a result. What becomes harder. What we now can't do without re-deciding.
```

The "Consequences" line is the most valuable part — it captures what the decision *bought* and what it *cost*. Future readers (including future-you) need that to understand whether the trade-off still applies.

---

## Decisions

### ADR-001: Use Postgres as the primary store

- **Status.** Accepted.
- **Date.** {{2026-05-13}}
- **Context.** We need a managed, transactional store for relational data (Users, Accounts, Resource X, audit history). Alternatives considered: managed MySQL, MongoDB, DynamoDB.
- **Decision.** Postgres on {{Supabase}}.
- **Consequences.** *Easier:* SQL is universally well-understood; rich tooling (Drizzle, dbt, PgAdmin); strong consistency for the transactional shape of the data; row-level security if we go multi-tenant later. *Harder:* less ideal for very high write throughput; would need to be sharded eventually if we hit 10M+ rows in hot tables. *Locked out of:* document-first modelling (no JSONB shortcuts at this stage — schema discipline expected).

### ADR-002: Use Supabase publishable / secret keys (not legacy anon / service_role)

*(Include this ADR if Supabase is in the stack. Delete if not.)*

- **Status.** Accepted.
- **Date.** {{date}}
- **Context.** Supabase's legacy JWT-based `anon` and `service_role` keys are deprecated (EOL end of 2026). They are static JWTs that can only be rotated by rotating the entire project JWT secret — a high-blast-radius operation. The replacement key types are opaque tokens that are individually revocable, rotatable, and audit-logged.
- **Decision.** Client-side code (web app, mobile, CLIs) uses the **publishable key** (`sb_publishable_…`). Server-side code (API, Edge Functions, background workers) uses the **secret key** (`sb_secret_…`). User-issued JWTs are verified via the JWKS endpoint (`https://<ref>.supabase.co/auth/v1/.well-known/jwks.json`) using asymmetric signing (ES256 recommended), not the legacy shared JWT secret. Edge Functions set `verify_jwt = false` and verify tokens in application code. Env vars use the new JSON-object shape: `SUPABASE_PUBLISHABLE_KEYS` and `SUPABASE_SECRET_KEYS` (see [migration guide](https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys)).
- **Consequences.** *Easier:* keys are independently revocable without rotating the JWT secret; secret key is browser-blocked (HTTP 401 on browser User-agent — accidental client-side exposure is caught automatically). *Harder:* Edge Functions must explicitly handle JWT auth in code; env var values are JSON objects, not plain strings (`JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS')!)['default']`). *Re-decide when:* Supabase changes the key model again, or the project migrates away from Supabase.

### ADR-003: Use Session pooler for migrations, Transaction pooler for serverless runtime

*(Include if Supabase is in the stack. Delete otherwise.)*

- **Status.** Accepted.
- **Date.** {{date}}
- **Context.** Supabase exposes a Direct connection (`db.<ref>.supabase.co:5432`) and two pooler modes on a shared pooler host. The Direct connection is IPv6-only by default and unreachable from GitHub Actions runners and most development machines — making it unsuitable for CI or serverless runtimes without purchasing the IPv4 add-on. The Session pooler (port 5432) is IPv4, DDL-capable, and supports prepared statements. The Transaction pooler (port 6543) is IPv4 and optimised for many short-lived connections (serverless), but does not support prepared statements.
- **Decision.** CI migrations (drizzle-kit / migrate) use the **Session pooler** stored as `MIGRATION_DATABASE_URL`. The serverless app runtime (Vercel functions) uses the **Transaction pooler** stored as `DATABASE_URL` with `prepare: false` in the Postgres client. The Direct connection is reserved for local Supabase CLI use only. The two env var names are kept distinct so the wrong URL cannot be put in the wrong secret store. Migrations run automatically in CI on merge when migration files change — not as a manual step.
- **Consequences.** *Easier:* CI migrations and serverless runtime both connect over IPv4 with no add-on required; accidental misuse is caught by the naming split. *Harder:* prepared statements unavailable in the serverless runtime (use query-level placeholders instead — Drizzle handles this transparently with `prepare: false`). *Re-decide when:* IPv6 becomes universally available in CI runners; or Supabase changes the pooler model.

### ADR-004: {{e.g. Use serverless functions over containers for the API}}

- **Status.** Accepted.
- **Date.** {{2026-05-13}}
- **Context.** {{Need an API with low ops overhead. Budget is solo-founder scale. Existing team familiar with Node.js but not Kubernetes.}}
- **Decision.** {{Deploy API as Vercel serverless functions (Node runtime), with selected edge functions for latency-sensitive reads.}}
- **Consequences.** *Easier:* zero infra ops; autoscale to zero; native git integration for deploys. *Harder:* cold starts on cold routes (~200-500ms acceptable for now); 10s execution-time limit constrains long operations (push them to Inngest workers); no shared in-memory state between invocations (use Redis). *Locked out of:* WebSockets on the same path (use a separate provider — see ADR-NNN). *Re-decide when:* monthly Vercel bill exceeds {{$200}} or cold-start latency becomes a customer-visible problem.

### ADR-005: {{...}}

*(Continue. Each one stays small. If a decision needs 5+ paragraphs, it's probably a design doc, not an ADR — write that separately under `docs/design/` or `docs/architecture/specs/`.)*

---

## Superseded decisions (kept for history)

When an ADR is replaced, mark it Superseded but don't delete it. Move it here.

### ADR-NNN: <Title> *(Superseded by ADR-MMM on YYYY-MM-DD)*

*(Original content kept as-is — it's the historical record.)*
