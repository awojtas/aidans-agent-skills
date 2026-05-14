# 03 — External Integrations

External systems this design depends on. Each one is a coupling that constrains future change — so list them deliberately.

## Integrations table

| Integration         | Purpose                       | Connection                  | Lock-in level   | Replaceability                                       |
|---------------------|-------------------------------|------------------------------|------------------|------------------------------------------------------|
| {{Auth provider}}   | Sign-in, identity             | OAuth + JWT                  | Medium           | Replaceable with another OAuth provider with effort. |
| {{Stripe}}          | Payments                       | REST API + webhooks          | High             | Replaceable but expensive; webhook semantics differ. |
| {{Sentry}}           | Error tracking                 | SDK                          | Low              | Replaceable with any error-tracker SDK.              |
| {{PostHog}}          | Product analytics              | SDK                          | Low              | Replaceable with any event-based analytics SDK.      |
| {{Resend}}           | Transactional email            | REST API                      | Low              | Replaceable with any SMTP-compatible provider.       |
| {{Cloudflare R2}}   | Blob storage                   | S3-compatible API             | Low              | Standardised on S3 API — portable.                   |

## Why each?

A one-paragraph note per integration capturing **what the alternative was** and **why we picked this one**. This is the most-useful institutional memory artefact in the architecture folder — six months from now nobody will remember the reasoning unless it's written down.

### {{Stripe}}

{{Alternatives considered: Lemon Squeezy (simpler taxes, but no card-vault for our future B2B subscriptions); Paddle (similar to LS); built-in (out of scope at our scale). Picked Stripe for: developer experience, breadth of payment methods, established compliance posture.}}

### {{Auth provider}}

{{...}}

*(Continue per integration. Keep it tight.)*

## Sub-processor list (for the privacy/compliance NFR)

Every integration where personal data flows to it is a **sub-processor** under GDPR. List them here in the same order as the table above so the requirements doc's privacy section can cross-reference:

- **Sub-processor:** {{e.g. Stripe — receives email, name, billing address, payment method token.}}
- **Sub-processor:** {{e.g. Sentry — receives error context which may incidentally contain user identifiers.}}
- ...

If the project is **B2B** and you have a Data Processing Agreement template, list which sub-processors have signed it. If not yet, that's an entry in `05-open-questions.md`.

## Failure mode for each

How does this system behave when each integration goes down?

| Integration         | Failure mode                                                                  |
|---------------------|--------------------------------------------------------------------------------|
| Auth provider       | Sign-in unavailable. App shows a friendly down banner with status-page link. Cached sessions keep working until expiry. |
| Stripe              | Payments disabled. Existing subscribed customers keep service. New signups queue or are rejected with a friendly message. |
| Sentry              | Errors are not tracked (logged locally). Application unaffected.               |
| Resend              | Transactional email fails. {{Retry with backoff; alert ops; surface to user if email is required for the action.}} |

The right level of detail here is "what happens if it's down for 1 hour" — not a full disaster-recovery plan.
