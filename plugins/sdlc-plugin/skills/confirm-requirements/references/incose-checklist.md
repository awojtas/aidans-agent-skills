# INCOSE Quality Checklist (self-contained)

Apply these tests to every requirement during a confirmation pass. Adapted from INCOSE's *Guide for Writing Requirements* and ISO/IEC/IEEE 29148:2018. Duplicated into this plugin so it stands alone — the `create-requirements` plugin has the same content for the elicitation phase.

## Per-requirement criteria

| # | Criterion       | Test                                                                                               |
|---|-----------------|----------------------------------------------------------------------------------------------------|
| 1 | **Necessary**   | Removing it breaks something a stakeholder cares about. If not — delete or de-scope.                |
| 2 | **Appropriate** | At the right level of abstraction for this doc (not implementation detail).                         |
| 3 | **Unambiguous** | Two readers can't reasonably interpret it differently. Read it pretending to be hostile.            |
| 4 | **Complete**    | Stands alone. No "...and other things" / "etc." / "where appropriate".                              |
| 5 | **Singular**    | One requirement, not three. "and" / "or" / commas often hide compound requirements.                  |
| 6 | **Feasible**    | Implementable within known constraints (cost, time, tech).                                          |
| 7 | **Verifiable**  | A tester can write a check that returns yes/no. Numeric → has fit criterion with number+unit+window. |
| 8 | **Correct**     | Reflects what the stakeholder actually wants — echo back, get sign-off.                             |
| 9 | **Conforming**  | Follows the doc's writing style and ID/numbering conventions.                                       |

## Set-level criteria

| # | Criterion              | Test                                                                                |
|---|------------------------|--------------------------------------------------------------------------------------|
| 1 | **Complete (as a set)**| All known stakeholders, journeys, NFR categories, constraints are covered.           |
| 2 | **Consistent**         | No two requirements contradict each other.                                           |
| 3 | **Feasible (as a set)**| Achievable together, not just individually.                                          |
| 4 | **Comprehensible**     | Someone joining in month 6 can read and understand.                                  |
| 5 | **Validatable**        | Traces to a goal — there's a goal the set as a whole proves.                         |

## RFC 2119 keyword discipline

Use these words **only** when invoking the formal normative meaning. ALL-CAPS signals normativity; lower-case "must" / "should" is informal prose.

| Keyword                       | Meaning                                                                |
|-------------------------------|------------------------------------------------------------------------|
| **MUST** / **SHALL**          | Absolute requirement. Failure = system failure.                         |
| **MUST NOT** / **SHALL NOT**  | Absolute prohibition.                                                   |
| **SHOULD** / **RECOMMENDED**  | Strong preference. Deviation requires written justification.            |
| **SHOULD NOT**                | Strong preference against. Deviation requires written justification.    |
| **MAY** / **OPTIONAL**        | Truly optional. Implementations differing on this remain interoperable. |

Source: [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119), [RFC 8174](https://datatracker.ietf.org/doc/html/rfc8174).

## Smell list

Trigger words that almost always mean the requirement is unfinished:

- "user-friendly", "intuitive", "modern", "robust", "scalable" → replace with a measurable fit criterion
- "and/or", "etc.", "such as" → usually hides incompleteness; enumerate
- "support", "handle", "process" → vague verbs; what specifically?
- "fast", "quickly", "soon" → replace with a number
- "if possible", "when applicable", "where appropriate" → either required or not
- "the system" without a subject → who/what specifically does this?
- Vague tense ("will be considered", "to be evaluated") → schedule a decision; move to `08-open-questions.md`

## The four-line review

For each requirement, a reviewer reads:

1. **Statement** — passes the 9 INCOSE checks.
2. **Fit criterion** — concrete and testable.
3. **Rationale** — ties to a goal.
4. **Source** — names a stakeholder and date.

If any line fails, the requirement is **Draft**, not **Reviewed**.
