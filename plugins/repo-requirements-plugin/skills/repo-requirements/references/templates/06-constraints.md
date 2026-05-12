# 06 — Constraints

Constraints are non-negotiable limits the system has to live within. Distinct from requirements: requirements describe what the system *does*; constraints describe the *boundary* it operates inside.

> **Move technology mandates here when they appear in conversation.** "We have to use AWS" is a constraint, not a requirement. This keeps the requirements doc free of `how`.

## Technical constraints

| #     | Constraint                                  | Source                  | Rationale                                                 | Workaround if violated |
|-------|----------------------------------------------|--------------------------|-----------------------------------------------------------|------------------------|
| C-T-001 | {{Must run on AWS}}                          | {{Stakeholder, date}}   | {{Existing org commitment}}                              | {{None / escalate}}    |
| C-T-002 |                                              |                          |                                                           |                        |

## Legal / regulatory constraints

| #     | Constraint                                  | Source                                    | Notes |
|-------|----------------------------------------------|--------------------------------------------|-------|
| C-L-001 | {{GDPR — EU user data must remain in EU}}    | {{GDPR Art. 44; legal counsel review YYYY-MM-DD}} |       |
| C-L-002 |                                              |                                            |       |

## Budget constraints

| #     | Constraint                                       | Source                  | Notes |
|-------|---------------------------------------------------|--------------------------|-------|
| C-B-001 | {{Monthly cloud spend ceiling $X}}                | {{Founder, YYYY-MM-DD}} |       |

## Schedule constraints

| #     | Constraint                                | Source                  | Notes |
|-------|--------------------------------------------|--------------------------|-------|
| C-S-001 | {{MVP by YYYY-MM-DD (event-tied)}}         | {{Founder, YYYY-MM-DD}} |       |

## Resource / team constraints

| #     | Constraint                              | Source                  | Notes |
|-------|------------------------------------------|--------------------------|-------|
| C-R-001 | {{Solo founder, no hires for 6 months}} | {{Founder, YYYY-MM-DD}} |       |
