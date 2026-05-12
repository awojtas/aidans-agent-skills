# Functional — {{DOMAIN_NAME}}

*(One file per functional domain under `03-functional/`. Domain examples: auth, billing, profile, search, admin, notifications, exports, onboarding.)*

## Scope of this domain

One paragraph: what this domain covers, and the boundary with adjacent domains.

## Requirements

### FR-{{DOMAIN_SLUG}}-001: {{Short title}}

**Statement.** The system SHALL/SHOULD/MAY ...

**Fit criterion.** *(How would we verify this in a test or demo? Concrete and measurable.)*

**Rationale.** *(Why. Link to a goal in `01-goals-and-non-goals.md` if possible.)*

**Priority.** Must | Should | Could | Won't

**Acceptance criteria** *(Given–When–Then; pick the scenarios that matter)*:
- **Given** an authenticated user **when** they submit a valid form **then** the system records the entry and returns a confirmation.
- **Given** invalid input **when** they submit **then** the system rejects the input with a specific error message and no state change.

**Source.** {{Stakeholder name}}, {{date}}.

**Status.** Draft | Reviewed | Approved.

**Traces to:** *Goal G-001; Journey J-001 step 3; NFR-SEC-002.*

**Notes / open questions.** *(Anything deferred → also log in `08-open-questions.md`.)*

---

### FR-{{DOMAIN_SLUG}}-002: ...

*(Continue. If this file exceeds ~30 requirements, split — e.g. `auth-signin.md`, `auth-mfa.md`.)*
