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

## Front-loading guidance

Phase 1 of every plan should:

- Contain **most or all** `human-required` tasks.
- Have a minimum of AI-implementable feature work — the AI will sit waiting for the human anyway, so don't queue feature work behind the human-required gates.
- Mark each human task with the time estimate so the human can batch them ("I'll knock these out Tuesday morning").

If a human-required task can't be done in Phase 1 because it depends on an earlier phase's output (rare but happens — e.g., domain verification requires production code to be deployed first), still mark it `human-required` and call out the dependency clearly in the issue.

## Common Phase 1 pattern

A typical Phase 1 for a SaaS-like project:

```
1.1  [HUMAN] Register domain
1.2  [HUMAN] Create hosting provider account (Vercel / Cloudflare)
1.3  [HUMAN] Create error-tracking account (Sentry)
1.4  [HUMAN] Create analytics account (PostHog / Plausible)
1.5  [HUMAN] Decide on visual identity (colours, typography)
1.6  [HUMAN] Draft / approve privacy policy + terms (or commission)
1.7  [HUMAN] Generate + add all third-party API keys to GitHub secrets
1.8         Bootstrap project structure (AI can do once secrets are in)
1.9         Wire up baseline CI (AI can do)
1.10        Set up basic monitoring (AI can do)
```

The human can knock 1.1 through 1.7 out in a focused half-day. The AI does 1.8-1.10 while waiting. Phase 2 starts with everything in place.
