# ADR Format (lightweight)

How to write Architecture Decision Records (ADRs) at the "initial design" stage. Drawn from [Michael Nygard's original ADR template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locations/nygard/index.md), abbreviated for early-stage use.

## When to write an ADR

Add an entry in `04-decisions.md` when:

- A **technical choice** has been made between alternatives, and the choice constrains future work.
- The reasoning is **non-obvious enough** that a reader six months later would want to know why.
- A previous decision is being **changed** — mark the old one Superseded, add a new one explaining the change.

Do **not** add an ADR for:

- Implementation detail ("use `for` instead of `forEach`").
- Cascading consequences of an earlier ADR ("we use Postgres → we use SQL").
- Personal style preferences with no architectural impact.

## The template

```markdown
### ADR-NNN: <Title in present tense, declarative>

- **Status.** Proposed | Accepted | Superseded by ADR-NNN | Deprecated
- **Date.** YYYY-MM-DD
- **Context.** What forces are at play; what's making the decision necessary now.
- **Decision.** What we picked.
- **Consequences.** What's easier as a result; what's harder; what we now can't do without re-deciding.
```

That's it. Aim for **1-2 paragraphs total per ADR**.

## Worked example

```markdown
### ADR-001: Use Postgres as the primary store

- **Status.** Accepted.
- **Date.** 2026-05-13
- **Context.** Need a managed, transactional store for relational data (Users, Accounts, Resource X, audit history). Alternatives considered: managed MySQL, MongoDB, DynamoDB.
- **Decision.** Postgres on Supabase.
- **Consequences.** *Easier:* SQL is universally well-understood; rich tooling (Drizzle, dbt, PgAdmin); strong consistency; row-level security if we go multi-tenant. *Harder:* less ideal for very high write throughput; would need sharding if we hit 10M+ rows in hot tables. *Locked out of:* document-first modelling without JSONB shortcuts.
```

## The most-valuable part: "Consequences"

Most decisions look obvious in retrospect. The thing that's not obvious is **what the decision bought you and what it cost**. The Consequences line captures this and is the part future readers will value most.

Structure each Consequences line as:

- *Easier:* what becomes easier or cheaper as a result.
- *Harder:* what becomes harder or more expensive.
- *Locked out of:* what we now can't do without re-deciding (the "exit cost").
- *(Optional) Re-decide when:* the trigger condition that should prompt a revisit.

## Title style

ADR titles are **declarative**, **present tense**, **stating the decision** — not the topic.

Good:
- "Use Postgres as the primary store"
- "Deploy as serverless functions, not containers"
- "Authenticate via Clerk, not built-in auth"

Bad:
- "Storage decision" *(too vague — title doesn't tell me what was decided)*
- "Picking a DB" *(verb-form, doesn't read as a record)*
- "Postgres vs MongoDB" *(describes the options, not the decision)*

## Numbering

`ADR-NNN` — three-digit zero-padded sequence within the project (`ADR-001`, `ADR-002`, ...). Never reuse a number even when an ADR is superseded.

## What about a separate `docs/adr/` folder?

Some teams put each ADR in its own file under `docs/adr/0001-use-postgres.md`. That's fine — useful when ADRs proliferate beyond ~20.

At the "initial design" stage, **one `04-decisions.md` file with all ADRs inline** is lighter and easier to scan. The skill produces this single-file layout. Migrate to per-file later when the count justifies it (Mind the ADR-NNN numbering — keep consistent across either layout).

## Status transitions

```
Proposed → Accepted → Superseded by ADR-NNN
                   ↘ Deprecated
```

- **Proposed.** The decision is on the table but not yet committed. Use for ADRs raised during a planning session that haven't been signed off.
- **Accepted.** The decision is in force. Default state for newly written ADRs once the decision is real.
- **Superseded by ADR-NNN.** A later ADR replaces this one. Keep the entry — it's the historical record.
- **Deprecated.** The decision no longer applies (e.g. the dependency was removed entirely) but no replacement ADR exists.

## Common pitfalls

- **Writing ADRs that are too long.** If you're past 3 paragraphs, you're writing a design doc, not an ADR. Move the design doc to a separate file and link from the ADR.
- **Skipping Consequences.** "Use Postgres" with no Consequences line is just a fact, not a decision-with-rationale.
- **Writing ADRs after the fact, in retrospect, all at once.** The point of ADRs is to capture the reasoning *at the time of the decision*. Retrospective ADRs are better than nothing but lose much of their value.
- **Deleting superseded ADRs.** The historical record is the point. Always Supersede, never delete.

## Sources

- [Nygard's original ADR template](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locations/nygard/index.md)
- [ADR Tools (CLI)](https://github.com/npryce/adr-tools)
- [Lightweight Architecture Decision Records — ThoughtWorks Technology Radar](https://www.thoughtworks.com/en-us/radar/techniques/lightweight-architecture-decision-records)
