# 05 — Data and Integrations

## Data entities

The system owns or processes these entities. Schema detail belongs in the architecture document — here we capture *what exists, who owns it, how sensitive it is, how long it lives*.

| Entity              | Owner / source-of-truth     | Sensitivity                              | Retention                                | Notes |
|---------------------|------------------------------|------------------------------------------|------------------------------------------|-------|
| {{ENTITY_1}}        | {{This system / external}}  | Public / Internal / Confidential / Restricted | {{e.g. life of account + 30 days}} |       |

### Personal data inventory

| Field / attribute       | Subject (whose data)  | GDPR category    | Lawful basis        | Stored where    | Encrypted at rest? |
|-------------------------|------------------------|------------------|---------------------|-----------------|---------------------|
| {{e.g. email address}}  | End user              | Basic            | Consent / Contract  | DB / Auth provider |  Yes / No        |

If no personal data is collected, write that here explicitly:

> **{{PROJECT_NAME}} does not collect personal data.** *(Or: collects only the following: ...)*

## Data flows

Brief description of how data moves through the system at the boundary level. Architecture-level diagrams belong elsewhere; here we just enumerate the flows.

- **Inbound from {{external system}}** — {{what arrives, when}}.
- **Outbound to {{external system}}** — {{what leaves, when, in what form}}.

## External integrations

| Integration         | Type (API / SDK / file / webhook) | Direction   | Required for MVP? | Vendor lock-in level | Notes |
|---------------------|-----------------------------------|-------------|---------------------|----------------------|-------|
| {{Stripe}}          | API                                | Outbound   | Yes / No            | Medium               |       |
| {{Sentry}}          | SDK                                | Outbound   | Yes / No            | Low                  |       |

For each, note:

- Sub-processor status (if user data flows to it, it goes on the sub-processor list in `04-non-functional/privacy-compliance.md`).
- Authentication mechanism — API key (rotated how?), OAuth, mTLS, etc.
- Failure mode — required for the request to succeed, or fire-and-forget?
