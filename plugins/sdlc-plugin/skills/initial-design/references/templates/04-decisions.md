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

### ADR-002: {{e.g. Use serverless functions over containers for the API}}

- **Status.** Accepted.
- **Date.** {{2026-05-13}}
- **Context.** {{Need an API with low ops overhead. Budget is solo-founder scale. Existing team familiar with Node.js but not Kubernetes.}}
- **Decision.** {{Deploy API as Vercel serverless functions (Node runtime), with selected edge functions for latency-sensitive reads.}}
- **Consequences.** *Easier:* zero infra ops; autoscale to zero; native git integration for deploys. *Harder:* cold starts on cold routes (~200-500ms acceptable for now); 10s execution-time limit constrains long operations (push them to Inngest workers); no shared in-memory state between invocations (use Redis). *Locked out of:* WebSockets on the same path (use a separate provider — see ADR-NNN). *Re-decide when:* monthly Vercel bill exceeds {{$200}} or cold-start latency becomes a customer-visible problem.

### ADR-003: {{...}}

*(Continue. Each one stays small. If a decision needs 5+ paragraphs, it's probably a design doc, not an ADR — write that separately under `docs/design/` or `docs/architecture/specs/`.)*

---

## Superseded decisions (kept for history)

When an ADR is replaced, mark it Superseded but don't delete it. Move it here.

### ADR-NNN: <Title> *(Superseded by ADR-MMM on YYYY-MM-DD)*

*(Original content kept as-is — it's the historical record.)*
