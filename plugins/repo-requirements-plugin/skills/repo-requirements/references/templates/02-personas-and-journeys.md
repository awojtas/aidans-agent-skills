# 02 — Personas and User Journeys

## Personas

Don't invent personas. Each one represents a real stakeholder type identified in `00-overview.md`.

### P-{{ROLE_SLUG}}-001 — {{Persona name}}

- **Who.** {{Short description: role, expertise level, context}}
- **Primary goal.** {{What they're trying to achieve with the product}}
- **Frustrations / pain points.** {{What's broken today; what they're escaping}}
- **Technical comfort.** {{1–5 scale, with one sentence of justification}}
- **Frequency of use.** {{Daily / weekly / occasional / one-shot}}
- **Devices / context.** {{Desktop in office / mobile on the go / kiosk / API only}}

*(Repeat for each persona — typically 2–5 for an MVP. More than 7 → probably collapse some.)*

## User Journeys

The top journeys end-to-end. Each is a happy path; failure-mode behaviour lives in the functional requirement that handles it.

### J-001 — {{Journey name}}

**Persona.** P-XXX-001.

**Trigger.** What event starts this journey (notification, scheduled time, deliberate action).

**Outcome.** What success looks like at the end.

**Steps:**
1.
2.
3.

**Touches functional requirements:** FR-XXX-NNN, FR-YYY-NNN.

**Touches data:** *(entities created/read/updated — see `05-data-and-integrations.md`)*.

**Notes / variations.** *(Optional. Common branches.)*

*(Repeat for top 3–7 journeys. Edge-case journeys can stay implicit inside their functional requirement.)*
