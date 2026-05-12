# Elicitation Playbook

How to draw requirements out of a single founder/dev (or small team) working with an AI agent. The techniques below are distilled from BABOK Knowledge Area 4 ("Elicitation and Collaboration") and the Volere process, and pared down to what actually works in a 1-on-1 conversational setting.

## Core techniques you will actually use

| Technique | When to lean on it | How it shows up in this skill |
|-----------|--------------------|--------------------------------|
| **Structured interview** | Default mode. Most of the conversation. | Each output file has a question bank below. Ask 3–5 at a time, never a wall. |
| **Document analysis** | Always at the start. | Read `README.md`, `AGENTS.md`, package metadata, any `docs/*` already present. Mine for stated purpose, users, hints. |
| **5 Whys** | When a user gives a feature-level answer ("they need a dashboard") | Push to underlying goal — "why do they need it?" — until you hit a measurable business outcome. |
| **Prototyping (verbal/sketch)** | When the user can't articulate but can recognise | Describe a mock flow ("imagine you log in, see X, click Y, get Z") and ask which parts are right/wrong. |
| **Negative space / "what wouldn't a happy user do?"** | Surfacing non-goals | Ask explicitly: "what should this NOT do?" — most projects under-document this and pay for it later. |
| **Stakeholder mapping** | At kickoff | Even solo projects have multiple stakeholders: end users, customers (who pay), regulators, ops, future self. List them. |
| **Brainstorming with constraints** | NFR section | Force a question per ISO 25010 category — don't let the user say "none" without engaging with each. |

## Question banks (lift these into the interview)

### Stakeholders & users

- Who *pays* for this? Who *uses* it? Are they the same person?
- Who is harmed if it breaks? Who is harmed if it succeeds (competitors, displaced workflows)?
- Who needs to *approve* this work? Anyone outside the building (regulators, partners)?
- Are there any users whose needs are different from the main persona? (Power users, admins, support staff, anonymous visitors.)

### Goals & success

- One sentence: what does success look like 12 months from now?
- What measurable thing changes if this is built well? (Revenue, time-saved, errors-reduced, churn-down.)
- What's the smallest possible version that proves the idea? (This becomes the MVP scope.)
- What would make you cancel the project?

### Scope (the question that prevents blow-outs)

- List 5 things this WILL do. List 5 things people might *assume* it does that it WON'T.
- Of the "won't" list — which are "not yet" vs "never"?
- What does an adjacent product do that we are explicitly not copying?
- If a stakeholder asks "can it also do X?" three months in, what do you want to be able to point at?

### Functional — per domain

For each functional area (auth, billing, profile, search, admin, etc.) work through:

- Who triggers this? What's the trigger?
- What does the happy path look like, step by step?
- What does the system have to *remember* across sessions?
- What are the failure modes the user sees (vs. silently logged)?
- What's the smallest valid input? The largest realistic input?
- What happens to data when the user deletes their account / cancels?
- Is there an admin/support view of this same data?

### Non-functional — see `nfr-catalogue.md`

Run the full catalogue. Don't let the user wave off categories — even "no requirement" is a requirement (it becomes a documented assumption: "we accept performance equivalent to a typical SaaS app at this scale").

### Constraints

- Budget — soft cap or hard cap? Monthly cloud spend ceiling?
- Timeline — fixed launch date? Tied to an external event?
- Team size — solo, hired help, contracted out?
- Tech mandates — must use $LANGUAGE, must run on-prem, must integrate with $LEGACY_THING?
- Regulatory — GDPR, HIPAA, SOC 2, PCI-DSS, age-gated, regional restrictions?

### Data & integrations

- What entities does the system create/own? What does it merely pass through?
- Who else needs the data — analytics, marketing, finance, support?
- What's the data sensitivity level (public / internal / confidential / restricted)?
- What's the retention policy? (And who decides?)
- Which external services are non-negotiable? Which would you swap if a better option appeared?

### Risks & assumptions

- What single change in the world would make this irrelevant?
- What are you assuming about user behaviour that is actually unproven?
- What's the most embarrassing way this could fail in public?
- Is there a hidden dependency (a person, a vendor, a contract) that could disappear?

## Conversational hygiene

- **Batch sensibly.** 3–5 related questions per turn. A wall of 15 questions gets surface-level answers.
- **Echo back.** After each batch, summarise what you heard *as a draft requirement statement* and ask the user to correct it. Catches misinterpretation early.
- **Treat hesitation as signal.** "Hmm, I'm not sure" → log as an open question. Don't push past it.
- **Distinguish facts from opinions from desires.** "Users sign in with email" (fact today) vs. "users should be able to sign in with email" (desire) vs. "users probably want email sign-in" (opinion). Tag each.
- **Never invent a stakeholder.** If the user hasn't mentioned a particular regulator/partner/persona, don't add them — ask.
- **Capture in user's own words.** Use their domain vocabulary in the requirement statement; put the engineering reframe in a "Notes" line.

## Sources

- IIBA, *BABOK v3*, Knowledge Area 4 (Elicitation & Collaboration) — https://www.iiba.org/standards-and-resources/babok/
- ModernAnalyst, *Top 12 Requirements Elicitation Techniques* — https://www.modernanalyst.com/Resources/Articles/tabid/115/ID/1427/Top-12-Requirements-Elicitation-Techniques-for-Software-Projects.aspx
- Volere process — https://www.volere.org/templates/volere-requirements-specification-template/
