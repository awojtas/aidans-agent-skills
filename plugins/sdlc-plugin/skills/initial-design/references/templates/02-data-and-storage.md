# 02 — Data and Storage

## Storage by class

| Class                | Store                                  | Why                                                    |
|----------------------|----------------------------------------|---------------------------------------------------------|
| Relational app state | {{Postgres on Supabase}}               | Strong consistency, well-known query model.            |
| Cache / sessions     | {{Upstash Redis}}                      | Fast key-value, fits session and rate-limit shapes.    |
| Blob / files         | {{Cloudflare R2}}                       | S3-compatible, no egress fees, generous free tier.     |
| Search *(if any)*    | {{Postgres full-text / Typesense / MeiliSearch}} | {{Postgres FTS sufficient for early scale}}   |
| Analytics events     | {{PostHog / event table in Postgres + dbt}} | {{}}                                              |
| Logs / metrics       | *(see `01-stack-and-hosting.md`)*       |                                                         |

## Top-level entities (initial sketch)

What this system stores. Not a full schema — just the shape.

| Entity          | Owned by this system? | Notes                                                  |
|-----------------|------------------------|--------------------------------------------------------|
| User            | Yes                    | Identity is partially Auth provider's (see 03-).       |
| Account / Org   | Yes                    | One User can belong to multiple Accounts.              |
| {{Resource X}}  | Yes                    | The main business object. Owned by an Account.         |
| {{Resource Y}}  | Yes                    | Audit / history of changes to Resource X.              |
| {{Sub-resource}}| Yes                    | Nested under Resource X.                                |

## Data sensitivity

| Sensitivity class       | Examples in this system                              | Handling                                                  |
|-------------------------|------------------------------------------------------|-----------------------------------------------------------|
| Public                  | Marketing pages, public Resource X content (if any). | No special handling.                                       |
| Internal                | Resource X content (private), Account names.         | Encrypted at rest by the managed DB; access via authz.    |
| Confidential            | User email, billing details.                         | Encrypted at rest; access logged.                         |
| Restricted (special-cat)| {{PII, health info, payment data — only if relevant}} | {{TLS in transit; column-level encryption}}             |

## Retention

| Data                        | Retention                                           |
|-----------------------------|------------------------------------------------------|
| User account                | Life of account + 30 days after deletion (backups age out). |
| User-generated content      | Same as account.                                     |
| Audit logs                  | {{e.g. 12 months}}                                   |
| Application logs            | {{e.g. 30 days}}                                     |
| Analytics events            | {{e.g. 13 months for cohort analysis}}               |
| Backups                     | {{e.g. Daily, retained 30 days, plus monthly archives 12 months}} |

## Data flow at a glance

```mermaid
flowchart LR
    user["User"]
    web["Web App"]
    api["API"]
    db["Postgres"]
    cache["Redis"]
    blob["R2 (blobs)"]
    queue["Inngest (queue)"]

    user -->|HTTPS| web
    web -->|HTTPS| api
    api -->|SQL| db
    api -->|GET/SET| cache
    api -->|sign URL| blob
    user -.->|direct upload via signed URL| blob
    api -->|enqueue event| queue
    queue -->|consume| api
```

*Edit to reflect the actual flow.*

## Multi-region / single-region

{{Single region for v1 — us-east-1.}}
{{Reasons: Latency to primary user base is acceptable; multi-region adds significant operational complexity; budget constrained.}}

When we revisit: {{e.g. when EU users exceed 20% of traffic OR when GDPR data-residency becomes a contractual requirement.}}
