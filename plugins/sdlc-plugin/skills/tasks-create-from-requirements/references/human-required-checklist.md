# Human-Required Checklist

What work needs a human, why, and why it should be **front-loaded** into the earliest phases of the plan.

## The principle

Humans are slower than AI. A task that takes an AI 10 minutes can take a human 2 hours — because the human:

- Has to context-switch from whatever else they were doing.
- May have to find a credit card, dig out a domain registrar password, sign a legal doc.
- Often has to wait for external systems (email verification, DNS propagation, third-party approval).
- Will batch errands, which adds latency.

If human-required tasks land in Phase 5, the AI gets to Phase 4 and stalls until the human catches up. **Always front-load.** Phase 1 should be majority-human; later phases should be majority-AI.

## What needs a human

A task needs the `human-required` label if **any** of these are true:

### Account & identity

- Creating an account on a third-party service (Vercel, Stripe, Sentry, AWS, GitHub org, npm).
- Verifying email / phone / identity (KYC, SCA-type checks).
- Adding a payment method or accepting billing terms.
- Setting up two-factor / passkeys / hardware keys on a service account.

### Credentials & secrets

- Generating an API key / OAuth client / service token from a third-party UI.
- Adding secrets to GitHub Actions secrets (the agent can't see or set these for security).
- Rotating a credential.
- Granting an OAuth scope that requires admin consent.

### Domain & infrastructure

- Registering a domain.
- Configuring DNS records.
- Verifying domain ownership in a third-party service.
- Configuring email DKIM / SPF / DMARC.
- Setting up a load balancer or CDN that requires console clicks not yet scriptable.

### Legal, compliance, and policy

- Writing or reviewing a privacy policy / terms of service / cookie policy.
- Signing a Data Processing Agreement (DPA) with a sub-processor.
- Opening a compliance ticket (SOC 2, ISO 27001, HIPAA BAA).
- Filing a trademark / company registration.
- Reviewing GDPR sub-processor lists with legal counsel.

### Design & brand

- Picking a colour scheme / typography / logo.
- Reviewing rendered UI for "feel" (the AI can produce, but a human signs off).
- Approving copy on user-facing surfaces (homepage hero, marketing email).
- Selecting fonts or licensing them.

### Decisions & sign-off

- Choosing between architectural options (when the requirements doc has an open question).
- Approving an MVP scope cut.
- Sign-off that moves a requirement Reviewed → Approved.
- Pricing decisions.
- Customer-facing communication wording (launch announcement, status page incident).

### External integrations requiring contact

- Cold-emailing a vendor for an enterprise plan.
- Signing into a partner's portal to whitelist an IP or domain.
- Phone call with a regulator / auditor / customer.

### Physical-world tasks

- Mailing or signing a document.
- Travelling for a meeting.
- Hardware procurement.

## What does NOT need a human

By default, **assume the AI can do it** unless one of the above applies. Common things people *think* need humans but don't:

- Writing code from a clear spec.
- Writing tests.
- Writing documentation from existing requirements.
- Running migrations in a non-prod environment.
- Drafting issue descriptions or PR descriptions.
- Setting up CI workflows from a template.
- Creating GitHub labels / milestones (the agent can do these via `gh` CLI).

## Time estimation for human tasks

In the issue's "Time estimate" field, be honest. Rules of thumb:

- **Account creation:** 15 min for the click-through, but **up to 24 h** if email verification or human approval is involved.
- **DNS changes:** 5 min to configure, **up to 48 h** for propagation. Mark "blocking after configuration: wait 24-48h".
- **Legal review:** Don't estimate; depends entirely on counsel. List as "depends on counsel, target Xd".
- **Design decisions:** 30-90 min for the decision, but allow elapsed time for the human to think it over (a day or two for non-trivial design choices).
- **Vendor approval:** Days to weeks for enterprise sales; hours for self-serve.

## How to write a human-required issue

Use this skeleton in the issue body (over the standard template):

```markdown
## ⚠️ Human Required

**Why:** [Specific reason — account creation, secret generation, legal review, etc.]

**Estimated time:** [15 min — 2h click-time; total elapsed may be longer if external verification is involved.]

**What to do:**

1. Go to https://example.com/signup
2. Sign up with email: [decide which]
3. Verify email (check inbox)
4. Generate API token under Settings → Tokens
5. Add token to GitHub Actions secrets as `EXAMPLE_API_KEY`

**Done when:**

- [ ] Account exists.
- [ ] Secret `EXAMPLE_API_KEY` is set in GitHub Actions secrets.
- [ ] Test workflow run against the new secret succeeds.
```

## Phase 0 — Operator Setup: the isolation principle

**All human-required tasks go into Phase 0 — Operator Setup.** No exceptions, and no AI tasks in Phase 0. This is the structural rule that keeps delivery phases agent-completable.

Why isolation matters: if human tasks are mixed into a delivery phase, an agent assigned to "implement Phase 1" finishes all the AI tasks but can't close or verify the human ones, and loops. A dedicated Phase 0 milestone makes it clear that Phase 0 is the human's domain and Phase 1+ are the AI's.

Phase 0 rules:
- Contains **all and only** `human-required` tasks.
- Mark each human task with the time estimate so the human can batch them ("I'll knock these out Tuesday morning").
- AI delivery tasks that depend on a Phase 0 output carry `Blocked by: #<Phase 0 issue>` — the dependency is recorded on the delivery task, not by moving the human task into a delivery phase.

If a human-required task depends on a delivery-phase output (rare — e.g., domain verification requires the production deploy to exist first), it still lives in Phase 0, but carries `Blocked by: #<delivery issue>`. It is never placed inside a delivery phase.

## Common Phase 0 + Phase 1 pattern

A typical setup for a SaaS-like project:

```
Phase 0 — Operator Setup (human-only)
0.1  [HUMAN] Register domain
0.2  [HUMAN] Create hosting provider account (Vercel / Cloudflare)
0.3  [HUMAN] Create error-tracking account (Sentry)
0.4  [HUMAN] Create analytics account (PostHog / Plausible)
0.5  [HUMAN] Decide on visual identity (colours, typography)
0.6  [HUMAN] Draft / approve privacy policy + terms (or commission)
0.7  [HUMAN] Generate + add all third-party API keys to GitHub secrets

Phase 1 — Foundation (AI-only)
1.1         Bootstrap project structure
1.2         Wire up baseline CI
1.3         Set up basic monitoring
```

The human works through Phase 0 in a focused half-day. The AI starts Phase 1 tasks that aren't blocked by Phase 0 outputs immediately; Phase 1 tasks that need secrets carry `Blocked by: #0.7`.
