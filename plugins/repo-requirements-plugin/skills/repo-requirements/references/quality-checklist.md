# Requirement Quality Checklist

Apply these tests **to every requirement before it's marked Reviewed**. They are condensed from INCOSE's *Guide for Writing Requirements* and ISO/IEC/IEEE 29148:2018.

## Per-requirement criteria (INCOSE characteristics)

| # | Criterion       | Test                                                                                               |
|---|-----------------|----------------------------------------------------------------------------------------------------|
| 1 | **Necessary**   | Removing this requirement would break something a stakeholder cares about. Can you name what?      |
| 2 | **Appropriate** | The requirement is at the right level of abstraction for this document (not implementation detail).|
| 3 | **Unambiguous** | One reader can't reasonably interpret it differently from another. Re-read it pretending to be hostile. |
| 4 | **Complete**    | Stands on its own. No "...and other things" / "etc." / "where appropriate."                        |
| 5 | **Singular**    | One requirement, not three. Look for "and" / "or" / commas that hide compound requirements.        |
| 6 | **Feasible**    | Implementable within known constraints (cost, time, tech).                                         |
| 7 | **Verifiable**  | A tester can write a check that returns yes/no. Includes a measurable fit criterion if numeric.    |
| 8 | **Correct**     | Reflects what the stakeholder actually wants (echo it back; let them sign off).                   |
| 9 | **Conforming**  | Follows the doc's writing style and ID/numbering conventions.                                      |

## Set-level criteria

| # | Criterion              | Test                                                                            |
|---|------------------------|----------------------------------------------------------------------------------|
| 1 | **Complete (as a set)**| All known stakeholders, journeys, NFR categories, and constraints are covered.   |
| 2 | **Consistent**         | No two requirements contradict each other.                                       |
| 3 | **Feasible (as a set)**| The full set is achievable together, not just individually.                      |
| 4 | **Comprehensible**     | Someone joining the project in month 6 can read the set and understand the system. |
| 5 | **Able to be validated** | The set can be confirmed against business goals — there's a goal it traces to. |

## Keyword discipline (RFC 2119)

Use these words **only** when invoking the formal normative meaning. ALL-CAPS signals normativity; lower-case "must" / "should" is informal.

| Keyword                | Meaning                                                                |
|------------------------|------------------------------------------------------------------------|
| **MUST** / **SHALL**   | Absolute requirement. Failing the requirement = failing the system.     |
| **MUST NOT** / **SHALL NOT** | Absolute prohibition.                                            |
| **SHOULD** / **RECOMMENDED** | Strong preference. Deviation requires written justification.     |
| **SHOULD NOT**         | Strong preference against. Deviation requires written justification.   |
| **MAY** / **OPTIONAL** | Truly optional. Implementations differing on this remain interoperable.|

Source: [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119), [RFC 8174](https://datatracker.ietf.org/doc/html/rfc8174) (capitalisation rule).

## The four-line review

For each requirement, the reviewer reads:

1. **Statement** — pass the 9 INCOSE tests above.
2. **Fit criterion** — concrete and testable? (If absent, the requirement is not Verifiable.)
3. **Rationale** — does it tie back to a goal? If not, why is this requirement here?
4. **Source** — who asked for it? When? (Orphan requirements are deletion candidates.)

If any of those fails, the requirement is **Draft**, not **Reviewed**.

## Smell list

Trigger words that almost always mean the requirement is unfinished:

- "user-friendly", "intuitive", "modern", "robust", "scalable" — replace with a measurable fit criterion
- "and/or", ", etc.", "such as" — usually hides incompleteness; enumerate
- "support", "handle", "process" — vague verbs; what specifically?
- "fast", "quickly", "soon" — replace with a number
- "if possible", "when applicable", "where appropriate" — either it's required or it isn't
- "the system" without a subject — who/what specifically does this?

## Sources

- INCOSE, *Guide for Writing Requirements* — https://www.incose.org/
- ISO/IEC/IEEE 29148:2018 — https://www.iso.org/standard/72089.html
- RFC 2119 / RFC 8174 — https://datatracker.ietf.org/doc/html/rfc2119
