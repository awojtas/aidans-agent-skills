# 10 — Prioritisation

## Method

**MoSCoW** (Must / Should / Could / Won't this release). Pragmatic, well-understood, and works for solo founders and small teams. See `references/prioritisation-frameworks.md` *(in the skill, not this repo)* for when Kano or WSJF would suit better — they're overkill for an initial requirements pass.

## Rules

- **Must.** Without this, the release isn't shipped or isn't usable. If everything is a Must, MoSCoW has failed — force-rank within Musts (see below).
- **Should.** Important, painful to omit, but the release can launch without it. Typically 30–50% of the eventual scope.
- **Could.** Wanted, but cheap to defer. Don't promise these.
- **Won't (this release).** Explicit deferred items. They go on the post-MVP roadmap and / or in `01-goals-and-non-goals.md` if the deferral is structural.

## MoSCoW table

| Requirement ID    | One-line summary                                           | Priority        | Notes |
|-------------------|------------------------------------------------------------|------------------|-------|
| FR-AUTH-001       |                                                            | Must             |       |
| FR-AUTH-002       |                                                            | Should           |       |
| NFR-SEC-001       |                                                            | Must             |       |
| NFR-OBS-001       |                                                            | Could            |       |

## Force-ranked Musts (the real MVP)

If the budget halves tomorrow, which Musts survive? List them in order. The top half is the **true MVP**; the bottom half are Shoulds masquerading as Musts.

1. **{{ID}}** — *(survives a budget halving)*
2. **{{ID}}** — *(survives a budget halving)*
3. ---
4. {{ID}} *(actually a Should)*
5. {{ID}} *(actually a Should)*

## Won't (this release)

| ID    | Item                                            | Revisit when                                  |
|-------|-------------------------------------------------|-----------------------------------------------|
|       |                                                 | {{date / milestone / external event}}         |

This section should match the "Not yet" entries in `01-goals-and-non-goals.md`.
