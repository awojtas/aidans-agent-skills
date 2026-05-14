# 05 — Open Questions

Architectural questions we deliberately punted on at this stage. Each one has a question, why it's punted, what we'd need to answer it, and a target revisit point.

The point of capturing them: future work (`/create-requirements`, `/tasks-from-requirements`, `/implement-task`) can be honest about what's not yet decided. Don't bury these in prose.

## Format

```markdown
### OQ-NNN: <The question, plainly>

- **Why punted.** What's making this hard to decide now (insufficient information, blocked on a requirement, blocked on a vendor conversation, ...).
- **What would unblock it.** The concrete thing that would let us decide.
- **Revisit when.** A condition (date, milestone, signal) that should trigger a re-look.
- **Impact if wrong.** What changes if we end up deciding the opposite of our current default-assumption.
```

---

## Open questions

### OQ-001: {{e.g. Single-region (us-east-1) vs multi-region from day one?}}

- **Why punted.** {{Don't yet know the geographic distribution of users. Adding multi-region from day one is significantly more complex (read replicas, replication lag handling, write routing) — premature.}}
- **What would unblock it.** {{Real user-base geographic data. Or a hard regulatory constraint (e.g. EU data residency in a contract).}}
- **Revisit when.** {{EU traffic > 20% of total OR a single B2B contract requires EU residency.}}
- **Impact if wrong.** {{If we should have gone multi-region: 4-8 weeks of work to retrofit. Likely cost: increased infra spend + read-replica complexity. If we go multi-region too early: 4-8 weeks of premature work that may be wrong for the actual user distribution.}}

### OQ-002: {{e.g. Is the API a separate service from the web app, or co-located?}}

- **Why punted.** {{Both have plausible arguments. Co-located is simpler now. A separate API surface is necessary if/when we have B2B customers calling it programmatically. We don't know if we'll have those.}}
- **What would unblock it.** {{Concrete signal that B2B / programmatic API consumers exist (e.g. a customer asking, or a partner integration in scope).}}
- **Revisit when.** {{First customer requesting an API integration, or first 3rd-party developer asks "where are the API docs?".}}
- **Impact if wrong.** {{Refactor to extract the API surface — typically 1-2 weeks if the code is well-factored, 4+ weeks if it's tangled. ADR-002's serverless choice means the cost is mostly routing/code organisation, not infra.}}

### OQ-003: {{e.g. Job queue: Inngest vs Cloudflare Queues vs self-hosted (e.g. BullMQ on Redis)?}}

- **Why punted.** {{No queue-shaped workload yet beyond "send welcome email". Once we have more, the right shape will be clearer.}}
- **What would unblock it.** {{First non-trivial async workload — bulk export, scheduled digest, etc.}}
- **Revisit when.** {{Three or more async workloads in flight.}}
- **Impact if wrong.** {{Migrating between queue providers is moderate — typically a week of work plus a deploy that drains the old queue.}}

### OQ-NNN: {{...}}

*(Continue. Add new ones as they surface during requirements / implementation work.)*

---

## Resolved questions

When an open question is resolved, **move it here** with the resolution recorded. Don't delete — the history is useful.

### OQ-NNN: <Question> — RESOLVED YYYY-MM-DD

- **Resolution.** {{What we decided.}}
- **Recorded as.** ADR-NNN (in `04-decisions.md`).
- **Notes.** {{Any context worth keeping.}}
