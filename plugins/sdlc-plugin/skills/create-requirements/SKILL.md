---
name: create-requirements
description: Interactively elicits and documents software requirements (functional + non-functional) into docs/requirements/ as a structured set of focused markdown files. Uses the project's README.md as the default starting context; if no README exists, asks the user for an alternative source (interactive description, a linked PDF, a markdown brief, etc.) before the interview begins. Then runs a stakeholder/goals/scope discovery interview and walks the user through each functional domain and each ISO/IEC 25010 quality attribute one at a time. Captures every assumption in 07-assumptions.md and every deferred item in 08-open-questions.md so nothing implicit survives. Produces output suitable as input to a downstream architecture-design phase. Grounded in Volere, ISO/IEC/IEEE 29148, ISO 25010, INCOSE Guide for Writing Requirements, BABOK Knowledge Area 4, and RFC 2119. Use when the user says "create requirements", "elicit requirements", "document requirements", "what should this project do", "scope this out", "write a requirements spec", "create an SRS", "start documenting what we're building", or asks for help nailing down what's in/out of scope. Designed as a multi-session skill — re-invoke to continue where the previous session stopped.
---

# Eliciting and Documenting Software Requirements

This skill produces a working requirements specification for a project, captured as a structured set of short markdown files under `docs/requirements/`. It is **highly interactive**, **assumption-capturing**, and **non-goal-aware** by design.

## Why this skill exists

Inaccurate requirements are the single largest contributor to software project blow-outs. Three recurring failure modes drive almost all of them:

1. **Hidden assumptions** that turn out wrong, invalidating downstream work.
2. **Scope creep** through under-documented "won't do" items — stakeholders later assume things were always in scope.
3. **Missing or vague non-functional requirements** — NFRs drive architecture more than functional ones do.

This skill defends against each one. See `references/pitfalls.md` for the full taxonomy.

## Operating mode

This skill is a **conversation**, not a generator. The agent:

- Asks small, focused batches of questions (3–5 per turn).
- Echoes each user answer back as a draft requirement statement and asks for correction.
- Captures every assumption explicitly in `07-assumptions.md`.
- Captures every deferred item in `08-open-questions.md`.
- Treats hesitation as signal — never invents content to fill gaps.
- **Is resumable.** On invocation, if `docs/requirements/` already exists, reads what's there and asks the user where to resume.

If the user wants the skill to "just generate everything from the README", **decline politely** and explain the failure mode: a doc generated without interview pressure-tests no assumptions, surfaces no non-goals, and elicits no NFRs. The skill earns its keep through the conversation, not the file structure.

## Reference material the agent should consult

| File                                            | When to consult                                                      |
|-------------------------------------------------|-----------------------------------------------------------------------|
| `references/elicitation-playbook.md`            | Question banks for each section; conversational hygiene.              |
| `references/nfr-catalogue.md`                   | ISO 25010 categories + modern additions, with per-category questions. |
| `references/quality-checklist.md`               | INCOSE characteristics; RFC 2119 keyword discipline; smell list.      |
| `references/pitfalls.md`                        | What to defend against during the conversation.                       |
| `references/example-worked-requirement.md`      | A fully-populated multi-file example (GitHub's Preview/Code/Blame file-view toggle). Show this to the user when they ask "what will the output look like?", or pattern-match against it when drafting a first real requirement. |
| `references/templates/*`                        | Markdown templates to copy into `docs/requirements/`.                 |

## Prerequisites

1. **Working directory is a project directory** (ideally a git repo, but not required).
2. **A grounding source exists.** The skill needs *something* describing the project's purpose before the interview is useful. The default is the repo's `README.md`. If it isn't present, see "Choosing a grounding source" below — the skill will ask the user to supply an alternative rather than refusing to start.
3. **The user has time for a real conversation.** Set expectation: a first useful pass is typically 30–90 minutes. They can pause and resume.

### Choosing a grounding source

`README.md` in the working directory is the default. If it exists, read it and move on — no question needed.

If `README.md` is missing or empty, do **not** stop. Ask the user (single AskUserQuestion turn) how they want to supply project context:

| Option                       | What the agent does                                                                                       |
|------------------------------|------------------------------------------------------------------------------------------------------------|
| Describe interactively        | Ask the user for a 3–5 sentence paragraph in chat. Save it to `docs/requirements/00-source-brief.md` so the source is recoverable. |
| Point to a local file         | User gives a path to a `.md`, `.txt`, or `.pdf` already in the working directory. Read it (use the Read tool — it handles PDFs).   |
| Point to a URL                | User gives a link to a public page, gist, or hosted PDF. Fetch with WebFetch.                              |
| Point to a Google Doc / Notion / Confluence page | Use the matching MCP server if available (Google Drive, Notion, Atlassian). If none is configured, ask the user to paste the contents or export to markdown/PDF and pick one of the options above. |

Whichever option is chosen, treat the resulting text as the equivalent of a README for the rest of the workflow. If the supplied source is very thin (under ~3 sentences of substance), pause and ask 2–3 grounding questions before scaffolding, so Step 4 has something to build on.

## Workflow

Track progress with this checklist:

```text
Requirements elicitation progress:
- [ ] Step 1: Read existing context (README, AGENTS.md, any prior docs/requirements/)
- [ ] Step 2: Set expectations and confirm session length
- [ ] Step 3: Scaffold docs/requirements/ folder structure
- [ ] Step 4: Stakeholder + glossary interview → 00-overview.md
- [ ] Step 5: Goals + non-goals interview → 01-goals-and-non-goals.md
- [ ] Step 6: Personas + top user journeys → 02-personas-and-journeys.md
- [ ] Step 7: Identify functional domains → create 03-functional/<domain>.md files
- [ ] Step 8: Walk each functional domain (one at a time)
- [ ] Step 9: Walk each NFR category (one at a time, ISO 25010 + modern)
- [ ] Step 10: Data and integrations → 05-data-and-integrations.md
- [ ] Step 11: Constraints → 06-constraints.md
- [ ] Step 12: Risks → 09-risks.md
- [ ] Step 13: MoSCoW pass → 10-prioritisation.md
- [ ] Step 14: Quality-checklist sweep
- [ ] Step 15: Summary and handoff
```

Throughout: assumptions go in `07-assumptions.md`, deferred items go in `08-open-questions.md`. Never inline.

### Step 1: Read existing context

Read in this order, surfacing what you learn back to the user:

1. **Grounding source** — `README.md` is the default. If it's present and non-empty, read it for purpose, intended users, and any feature list. If it's missing or empty, run the "Choosing a grounding source" flow from the Prerequisites section before continuing. Do not proceed past this step without a grounding source.
2. `AGENTS.md` if present — additional context.
3. `docs/requirements/` if present — **this is a continuation, not a fresh start**. Read all existing files and ask the user where they want to resume. Do not overwrite without permission.
4. `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` — confirms tech stack (informs constraints).

If `docs/requirements/` exists, jump to a *resume* mode: skim the existing files, identify gaps (Draft requirements, empty sections, open questions older than 14 days), and propose where to focus this session.

### Step 2: Set expectations

Tell the user:

- This is a conversation; expect 30–90 minutes for a first useful pass.
- They can pause anytime — the skill is resumable.
- Their job is to be honest about uncertainty. "I don't know" is a valid answer and gets logged as an open question.
- Every assumption gets captured. The doc is meant to be reviewable.

Then confirm: do they want to do this in one go, or break into sessions by section? Either is fine.

### Step 3: Scaffold the folder structure

Create the structure under `docs/requirements/`. For each file, copy the matching template from `references/templates/` and substitute `{{PROJECT_NAME}}` / `{{TODAY}}` placeholders:

```text
docs/requirements/
├── README.md                       (from templates/README.md)
├── 00-overview.md                  (from templates/00-overview.md)
├── 01-goals-and-non-goals.md       (from templates/01-goals-and-non-goals.md)
├── 02-personas-and-journeys.md     (from templates/02-personas-and-journeys.md)
├── 03-functional/
│   └── README.md                   (one-line: "Index of functional domains. One file per domain.")
├── 04-non-functional/
│   └── README.md                   (one-line: "Index of NFR categories. One file per category.")
├── 05-data-and-integrations.md     (from templates/05-data-and-integrations.md)
├── 06-constraints.md               (from templates/06-constraints.md)
├── 07-assumptions.md               (from templates/07-assumptions.md)
├── 08-open-questions.md            (from templates/08-open-questions.md)
└── 09-risks.md                     (from templates/09-risks.md)
```

`10-prioritisation.md` is created at Step 13 — it can't be done sensibly until functional and NFR requirements exist.

**Substitutions** (literal string replacement only, not regex; ignore any `${{ ... }}` GitHub Actions expressions):

| Placeholder         | Replace with                                                  |
|---------------------|----------------------------------------------------------------|
| `{{PROJECT_NAME}}`  | Project name from README's H1, or asked from user.             |
| `{{TODAY}}`         | `date +%Y-%m-%d`.                                              |

Other placeholders inside templates (`{{GOAL_1}}`, `{{ENTITY_1}}`, etc.) are **content stubs**. Leave them in place — they signal sections the agent will fill in during the interview. Replace them as interview answers come in.

After scaffolding, show the user the structure and confirm before proceeding.

### Step 4: Stakeholder + glossary interview → `00-overview.md`

Use the **Stakeholders & users** question bank from `references/elicitation-playbook.md`. Run as a single AskUserQuestion batch (3–5 questions). After each answer, echo back as a stakeholder-table row and confirm before writing.

Watch for the negative-space question: *"Who would be unhappy if they found out about this project after launch?"* This often surfaces a regulator, finance, support, or ops stakeholder the user hadn't mentioned.

For the **glossary**: don't pre-seed. Add terms as they appear in conversation. Whenever the user uses a domain word, ask if it has a canonical definition.

### Step 5: Goals + non-goals interview → `01-goals-and-non-goals.md`

This is the most important file. Two phases:

**Goals.** Ask:
- One sentence: what does success look like 12 months from now?
- What's the smallest version that proves the idea?
- What measurable thing changes if this is built well?

Get them to a numbered, ordered list of 3–7 goals, each with a measurable outcome.

**Non-Goals.** Now ask the negative space:
- "List five things people might *assume* this does that it WON'T do."
- "What does an adjacent product do that we're explicitly not copying?"
- "Of the things you just said it won't do — which are 'not yet' vs 'never'?"

Aim for **at least as many non-goals as goals**. If the user struggles, prompt with adjacent-product features ("Most apps in this space have X — is X in or out?").

Then: enumerate **grey-area items** — features stakeholders may *assume* are included but aren't. Push hard here. Every grey-area item resolved now is a stakeholder argument avoided later.

### Step 6: Personas + journeys → `02-personas-and-journeys.md`

For each stakeholder identified in Step 4 that *uses the product directly*, capture a persona using the template. Don't invent personas — there should be a 1-to-1 mapping to stakeholder types.

Then identify the **top 3–7 user journeys**. For each:

- Who's the persona?
- What's the trigger?
- What's the happy-path outcome?
- 3–10 numbered steps (high-level — implementation belongs in the functional requirement).

If the user names more than 7 journeys, suggest collapsing — the long tail is implied by the functional requirements anyway.

### Step 7: Identify functional domains → seed `03-functional/<domain>.md` files

From the journeys + the README + the user's mental model, list the functional domains. Typical for a SaaS product: `auth`, `onboarding`, `<core-feature>`, `billing`, `notifications`, `admin`, `exports`. Internal tool: smaller set.

Ask the user: "Here are the domains I see: [list]. Anything missing? Anything I've split that should be one domain?"

For each confirmed domain, create `03-functional/<domain>.md` from `templates/functional-domain.md`, substituting `{{DOMAIN_NAME}}` and `{{DOMAIN_SLUG}}`.

### Step 8: Walk each functional domain

For each domain, **one at a time**:

1. Ask the **Functional — per domain** question bank from the playbook.
2. After each answer, draft a requirement statement using the template's atomic format (Statement / Fit criterion / Rationale / Priority / Acceptance criteria in Given-When-Then / Source / Status / Traces to).
3. Echo it back to the user before writing.
4. Apply the **smell list** from `quality-checklist.md` — if the statement triggers any smell, push for specificity before saving.
5. Number requirements as `FR-<DOMAIN_SLUG>-NNN`.

When the user defers a decision: write the partial requirement at Status `Draft`, then add an `OQ-NNN` entry to `08-open-questions.md`.

When the agent makes an assumption: write an `A-NNN` entry in `07-assumptions.md` and reference it from the requirement's Notes line.

Aim for ~5–15 requirements per domain. If a single file exceeds ~30 requirements, **split it** (e.g. `auth-signin.md` + `auth-mfa.md`).

### Step 9: Walk each NFR category

Use `references/nfr-catalogue.md` as your script. For **every** category in ISO 25010 plus the modern additions (10 categories total), do this:

1. Create `04-non-functional/<category>.md` from `templates/nfr-section.md`.
2. Ask: "Does this category apply to {{PROJECT_NAME}}?"
3. **If no**: write a one-paragraph "Applies? No" with rationale, then move on. The file stays as the visible record of the decision.
4. **If yes**: ask the category's question bank from the catalogue.
5. Capture each answer as an `NFR-<CATEGORY_SLUG>-NNN` requirement with a **fit criterion** (concrete, measurable). If the user can't give a number, write the assumption and move on — don't leave the fit criterion blank.

**Do not let the user skip categories.** Each one must produce either a populated file or an explicit "doesn't apply" record. This is the highest-leverage defensive practice in the skill.

### Step 10: Data and integrations → `05-data-and-integrations.md`

Use the **Data & integrations** question bank. Particular attention:

- **Personal data inventory** — what fields, whose data, GDPR category, lawful basis. If the answer is "we don't collect personal data", state it explicitly in the file.
- **External integrations** — every one is a sub-processor candidate (loops back to `04-non-functional/privacy-compliance.md`) and a coupling risk (loops to `09-risks.md`).
- **Retention** — what gets deleted when an account is closed; what's preserved (backups, audit logs) and for how long.

### Step 11: Constraints → `06-constraints.md`

Use the **Constraints** question bank. Make sure technical, legal, budget, schedule, and resource categories are each visited.

**Move technology mandates here when they appear.** "We have to use AWS" is a constraint, not a requirement. If you spot one in a functional requirement statement, refactor: the requirement describes behaviour, the constraint records the mandate.

### Step 12: Risks → `09-risks.md`

Use the **Risks & assumptions** question bank. Score each on Likelihood × Impact (1–5 each). Walk all six categories (Technical / Operational / Market / Legal / Security / Resourcing) — write `R-<CAT>-NONE` for any that genuinely has no entries, so the consideration is visible.

### Step 13: MoSCoW pass → `10-prioritisation.md`

Create `10-prioritisation.md` from `templates/10-prioritisation.md`. Tabulate every requirement (functional and non-functional) with its priority. Then:

- **Force-rank the Musts.** "If your budget halved tomorrow, which Musts survive?" Top half is the **true MVP**; the rest are Shoulds in disguise.
- **Won't (this release) section.** Cross-check against the "Not yet" non-goals in `01-goals-and-non-goals.md` — they should match.

### Step 14: Quality-checklist sweep

For every requirement now in the doc, run the 9 INCOSE characteristics from `references/quality-checklist.md`. For each requirement that fails any check:

- If small fix → ask the user the specific gap and update.
- If the issue is fundamental (no source, no rationale, no fit criterion) → mark Status `Draft` and create an Open Question.

Apply the **smell list** one more time across all files.

### Step 15: Summary and handoff

Print a tight summary:

- Folder contents (file count, total requirement count by category).
- Status distribution (Draft / Reviewed / Approved counts).
- Open question count and any older than 14 days.
- Assumption count, with falsified/validated breakdown.
- **Next-step pointer:** *"This requirements set is ready as input to an architecture-design phase. The architecture doc should trace every architectural decision back to a requirement ID here."*

Commit the changes (do **not** commit automatically — show the diff and let the user commit).

## Resume mode

If `docs/requirements/` already exists when the skill is invoked:

1. List the files present.
2. Read each, identify:
   - Draft requirements (need pressure-testing).
   - Empty `04-non-functional/*` files (NFR walk incomplete).
   - Open questions older than 14 days.
   - Assumptions with `Validation status: Unvalidated`.
3. Present the user with a menu: "What do you want to focus on this session?"
4. Pick up there. Do not restart from Step 4.

## Strict non-goals for this skill

- **No code generation.** This is a specification skill. Code belongs to a separate phase.
- **No architecture decisions.** Tech-stack discussion gets captured as constraints; the rest goes to the architecture phase.
- **No invented requirements.** If the user hasn't said it, it's not in the doc. The skill captures, it does not propose.
- **No bulk auto-fill.** Each requirement comes from a conversational turn.
- **No file deletion.** Resolved Open Questions move within the file, they don't disappear. Falsified Assumptions stay in the register with a "Falsified" status.

## Edge cases

- **README is missing or empty.** Don't stop — run the "Choosing a grounding source" flow in the Prerequisites section so the user can supply an alternative (interactive description, local file, URL, doc-server link). Only stop if the user declines to supply any source at all.
- **User wants the skill to "just produce a draft".** Explain the failure mode (see "Operating mode" above) and offer a structured option: the agent can produce *empty-but-scaffolded* files, populated only with what's in the README, and mark every section as `Draft — pending interview`. This is honest and still useful.
- **The project is a hard fork or rewrite of an existing system.** Ask for the original system's docs; use `references/elicitation-playbook.md`'s "document analysis" technique. Capture differences from the original explicitly.
- **Multi-stakeholder review (rare for solo founders).** Each stakeholder gets a turn at the relevant sections; conflicts go to `08-open-questions.md` with both viewpoints captured.
- **The user pushes back on capturing an assumption** ("that's obvious"). Capture it anyway, briefly. Buried-obvious assumptions are exactly the ones that fail.
