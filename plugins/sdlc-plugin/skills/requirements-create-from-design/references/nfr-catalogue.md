# Non-Functional Requirements Catalogue

Aligned with **ISO/IEC 25010** product quality model, plus the modern additions every product needs to consider explicitly (observability, privacy, accessibility, internationalisation, cost). For each category: what it covers, the elicitation questions to ask, and the trap that catches teams who skip the category.

Each category becomes one file under `docs/requirements/04-non-functional/`. If the user says a category doesn't apply, **don't delete it — write a one-paragraph statement that records why it doesn't apply, so the decision is visible to future reviewers.**

---

## 1. Performance Efficiency

**Covers:** Response time, throughput, resource utilisation, capacity.

**Elicit:**
- What's the 95th-percentile response time the user expects on the slowest screen? On the fastest?
- How many concurrent users / requests per second at launch? At "success"?
- Any single operations that are expected to take more than a few seconds (reports, bulk imports)? How should the user know they're in progress?
- What's the budget for cold-start latency (first request after idle)?

**Trap:** "Fast enough" is not a requirement. If the user can't give a number, ask "what's the slowest it could be before you'd call it broken?" and write that down with `[ASSUMPTION]`.

---

## 2. Reliability & Availability

**Covers:** Uptime targets, fault tolerance, recoverability, RPO/RTO, error budgets.

**Elicit:**
- What uptime target makes sense — 99% (3.6 days/yr down), 99.9% (8.8h), 99.95% (4.4h), 99.99% (52 min)? Don't accept "as high as possible" — every nine is real money.
- What's the acceptable data-loss window if disaster hits (RPO)? Acceptable recovery time (RTO)?
- Which features can degrade vs. which must always work? (Graceful degradation list.)
- Is there a planned-maintenance window or is the system always-on?

**Trap:** Picking 99.99% by default. Each extra nine roughly 10×s the operational cost. Match the target to the business cost of downtime.

---

## 3. Security

**Covers:** Confidentiality, integrity, authenticity, accountability, non-repudiation.

**Elicit:**
- What's the worst thing an attacker could do with this system? (Data exfil? Funds movement? Defacement? Account takeover?)
- Authentication: passwords + something else? Passwordless? SSO?
- Authorisation: roles? row-level / tenant isolation? Admin escape hatches?
- Audit: what user actions need to be logged for forensics, and how long are the logs retained?
- Threat model — drive-by attackers, motivated individuals, organised crime, nation-state? Each implies a different defence posture.
- Are there cryptographic-key-handling requirements (HSM, KMS)?

**Trap:** Naming controls before threats ("we'll use OAuth" before "what are we defending against?"). Always elicit threats first.

---

## 4. Privacy & Compliance

**Covers:** GDPR/CCPA/HIPAA/PCI-DSS/SOC 2/regional regulations, data residency, consent, subject-access rights, retention, sub-processors.

**Elicit:**
- What jurisdictions are users in? Is data allowed to leave them?
- Are minors using the system? (Different consent rules apply.)
- What categories of personal data are collected (basic / sensitive / special-category under GDPR Art. 9)?
- How does a user export their data? Delete their data? How long is "deletion" until backups age out?
- Any third-party processors (analytics, error tracking, AI APIs)? Does the user know about each one?

**Trap:** Assuming "we'll add GDPR later". Retention, consent, and sub-processor lists are easier to bake in than to retrofit.

---

## 5. Usability & Accessibility

**Covers:** Learnability, operability, user-error protection, WCAG 2.2 conformance, support for assistive tech.

**Elicit:**
- What's the user's technical level on a 1–5 scale?
- WCAG conformance target — A, AA, AAA? (Default to AA for public-facing.)
- Keyboard-only support? Screen-reader support? Reduced-motion preference?
- Colour-contrast minimum (AA = 4.5:1 for body text, 3:1 for large)?
- Mobile-first, desktop-first, or parity?
- Error messages — written for end users, or technical?

**Trap:** Calling a11y "nice to have". It's often legally required (ADA in US, EAA in EU from 2025) and architecturally expensive to bolt on late.

---

## 6. Maintainability

**Covers:** Modularity, reusability, analysability, modifiability, testability.

**Elicit:**
- Who maintains this in year 2? Same person? Successor? Open-source contributors?
- What's the minimum test coverage that ships? What gets blocked by a coverage drop?
- How long can a build take before it's "broken"?
- Is monorepo or polyrepo a fixed decision?
- Documentation — code-only, docstrings, hosted docs site, what level?

**Trap:** Treating maintainability as "good engineers will care about it". Make the bar explicit so reviewers can enforce it.

---

## 7. Compatibility & Portability

**Covers:** Browser/OS/device support, integration with co-resident systems, ease of moving to a different cloud/runtime.

**Elicit:**
- Browser support matrix — last 2 versions of evergreen, or include IE11-class legacy?
- Mobile — native, PWA, responsive web, none?
- Cloud lock-in tolerance — happy to use AWS-specific services, or stay portable?
- Does it need to run inside another product (iframe, plugin, extension)?

**Trap:** Promising "any browser" — measurable browser support comes from a stated matrix, not aspirations.

---

## 8. Observability

**Covers:** Logging, metrics, tracing, alerting, dashboards. *Not strictly ISO 25010 — add it anyway, every team regrets skipping.*

**Elicit:**
- Which user actions and system events MUST be logged?
- What metrics drive an on-call alert? (Latency? Error rate? Saturation? Specific business events?)
- Retention — logs (7d? 30d? 90d?), metrics (13mo? 25mo?), traces (sampled?).
- Where do alerts go — PagerDuty? Slack? Email?
- Privacy: are logs free of PII, or is PII redacted/encrypted?

**Trap:** Bolting observability on after the first incident. Decide log/metric/trace schema before the code is written.

---

## 9. Internationalisation & Localisation

**Covers:** Multiple languages, locale-aware formatting (dates, numbers, currency), RTL support, timezone handling.

**Elicit:**
- Single language now? Plans for more? Which languages, in what order?
- RTL (Arabic, Hebrew) ever on the roadmap? (Architecturally cheap if planned, expensive if retrofitted.)
- All times stored UTC, displayed in user-local? Or single-region?
- Currency — single, multi-display, multi-charge? Tax implications?

**Trap:** Hard-coding strings, dates, and currencies. Even single-language launches should externalise strings if i18n is *possible*.

---

## 10. Cost & Sustainability

**Covers:** Cloud spend ceilings, per-tenant cost, carbon footprint, scaling-cost predictability.

**Elicit:**
- What's the monthly cloud-spend ceiling before someone gets paged?
- Is there a per-user / per-tenant cost target the unit economics require?
- Any green/sustainability commitment (carbon-aware regions, low-power scheduling)?

**Trap:** Designing for technical scale without designing for cost scale. A working system can still be a failing one.

---

## How to render this in `docs/requirements/04-non-functional/`

For each category, produce a short file with this skeleton:

```markdown
# NFR — <Category>

## Applies?

<Yes / No with one-sentence rationale. If No, this file ends here and is preserved as the record of the decision.>

## Requirements

### NFR-<CATEGORY>-001: <Short title>

**Statement.** The system SHALL/SHOULD ...

**Fit criterion.** <How would we verify this? Concrete, measurable.>

**Rationale.** <Why.>

**Priority.** Must | Should | Could | Won't (this release).

**Source.** <Stakeholder, date.>

**Status.** Draft.

**Notes / open questions.** <Anything deferred.>
```

If a single NFR file would exceed ~30 requirements, split it (e.g. `security-auth.md` + `security-data.md`).

## Sources

- ISO/IEC 25010:2011 system and software quality model — https://en.wikipedia.org/wiki/ISO/IEC_25010
- ISO/IEC/IEEE 29148:2018 — https://www.iso.org/standard/72089.html
- WCAG 2.2 — https://www.w3.org/WAI/standards-guidelines/wcag/
- GDPR — https://gdpr-info.eu/
