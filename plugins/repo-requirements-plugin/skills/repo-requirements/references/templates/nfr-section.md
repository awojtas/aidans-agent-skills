# NFR — {{CATEGORY_NAME}}

*(One file per NFR category under `04-non-functional/`. Categories: performance, reliability-availability, security, privacy-compliance, usability-accessibility, maintainability, compatibility-portability, observability, internationalisation, cost. See `references/nfr-catalogue.md` for the elicitation questions per category.)*

## Applies?

Yes / No.

If **No**: a one-paragraph statement of why this category doesn't apply to {{PROJECT_NAME}}, and what would have to change for that decision to be revisited. This file then ends here, preserved as the record of the decision.

If **Yes**: proceed.

## Context

One paragraph: the operating envelope this category covers. (For Performance: traffic levels, latency expectations. For Security: threat model, blast radius. For Reliability: criticality of uptime, business cost per hour of downtime.)

## Requirements

### NFR-{{CATEGORY_SLUG}}-001: {{Short title}}

**Statement.** The system SHALL/SHOULD ...

**Fit criterion.** *(Concrete, measurable. For numeric NFRs: the number, the unit, the measurement window, the percentile if relevant.)*

**Rationale.** *(Tie to a goal or threat or stakeholder ask.)*

**Priority.** Must | Should | Could | Won't (this release).

**Verification method.** *(Test / inspection / analysis / demonstration. How do we prove it's met?)*

**Source.** {{Stakeholder name}}, {{date}}.

**Status.** Draft | Reviewed | Approved.

**Traces to:** *Goal G-XXX, FR-YYY-NNN (this NFR shapes that FR), Constraint C-ZZZ.*

**Notes / open questions.**

---

### NFR-{{CATEGORY_SLUG}}-002: ...

*(Continue. If this file exceeds ~30 requirements, split — e.g. `security-auth.md`, `security-data.md`.)*
