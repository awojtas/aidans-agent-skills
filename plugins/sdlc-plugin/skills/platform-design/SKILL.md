---
name: platform-design
description: 'Produces a lightweight initial architecture design for a project, capturing system shape, hosting, components, stack, data, integrations, ADRs, and open questions in docs/architecture/. Use before detailed requirements or implementation when the technical direction is not yet recorded.'
---

# Producing an initial architectural design

This skill fills the gap between *"the repo exists"* and *"we know what we're building in detail"*. Without it, requirements work happens against an undefined technical shape — and the requirements bake in hidden assumptions that may not match reality.

The example the user gives: a messaging app over serial cable vs cloud infrastructure produces very different requirements. Without an initial design step, the team can spend hours eliciting requirements that turn out to be wrong because the technical shape was different from what the requirements-writer assumed.

The skill is **deliberately light**. "Initial design" means **first stab** — not perfect, not exhaustive, not architecturally complete. Just enough that:

- Downstream requirements work has context.
- Major architectural decisions get recorded (`04-decisions.md`).
- Open questions get surfaced explicitly (`05-open-questions.md`) instead of buried.

## Operating mode

- **Conversational.** 7 content topics walked in order (system type → hosting → components → stack → data → integrations → pattern fit), then a short review sweep ("Topic 8 — Decisions vs unknowns"). 3-5 questions per topic.
- **30-90 minutes** is a typical session. Don't try to make this exhaustive.
- **Default-assume sensibly.** If the user doesn't know, propose a sensible default and capture it as an ADR with a re-decide trigger.
- **Push back on premature complexity.** Microservices, Kubernetes, multi-region, real-time-everywhere are all worth questioning at this stage.
- **Open questions are first-class.** When the user says "I'm not sure" or "let's figure that out later", add an entry to `05-open-questions.md` immediately.

## Reference material

The orchestrator and the agent should consult:

| File                                            | Purpose                                                                      |
|-------------------------------------------------|------------------------------------------------------------------------------|
| `references/interview-playbook.md`              | The 7-topic question bank with conversational principles.                    |
| `references/architecture-patterns.md`           | Catalogue of patterns (monolith, microservices, serverless, JAMstack, event-driven, hexagonal, real-time hub) — when each fits. |
| `references/adr-format.md`                      | Lightweight ADR style (Michael Nygard's format, abbreviated).                |
| `references/example-initial-design.md`          | Worked example: a 30-minute session producing a complete architecture folder.|
| `references/templates/*`                        | The markdown templates the skill writes into `docs/architecture/`.           |

## Prerequisites

1. **Working directory is inside a git repo** (or at least a project directory).
2. **`README.md` exists** with at least a paragraph describing what the project is. If not, ask the user to write one — without the seed, the interview has no anchor.
3. **`docs/architecture/` does not yet exist**, or only contains stubs. If real content is there, this is a *re-design* — see the *Re-design mode* section below.
4. **The user has 30-90 minutes.** Set the expectation up front.

## Workflow

```text
Initial-design progress:
- [ ] Step 1: Read README.md (and any existing context)
- [ ] Step 2: Set expectations and confirm session length
- [ ] Step 3: Scaffold docs/architecture/ folder
- [ ] Step 4: Topic 1 — System type
- [ ] Step 5: Topic 2 — Hosting / runtime
- [ ] Step 6: Topic 3 — Major components
- [ ] Step 7: Topic 4 — Stack
- [ ] Step 8: Topic 5 — Data
- [ ] Step 9: Topic 6 — External integrations
- [ ] Step 10: Topic 7 — Architecture pattern fit
- [ ] Step 11: Topic 8 — Decisions vs unknowns (review the captured ADRs and OQs)
- [ ] Step 12: Summary + handoff
```

### Step 1: Read the README

`Read` `README.md`. The user's project description is the anchor for the conversation. Echo back the system in one sentence so they can correct any misreading before the interview starts.

If `AGENTS.md`, `CLAUDE.md`, or `docs/` already exist with relevant content, skim them too — there may be architectural hints (existing infrastructure references, mandated technologies, etc.).

### Step 2: Set expectations

Tell the user:

- *This will take 30-90 minutes. We'll walk 7 content topics + a short review sweep at the end.*
- *The goal is a **first stab**, not a perfect design. We'll capture decisions where you have them and open questions where you don't.*
- *Anything you're unsure about goes into `05-open-questions.md` — it's not wrong to say "I don't know yet", we just record it as a known unknown.*

### Step 3: Scaffold the folder

Create `docs/architecture/`. For each template in `references/templates/`, copy to the matching destination and substitute `{{PROJECT_NAME}}` and `{{TODAY}}`:

```text
docs/architecture/
├── README.md                       (from templates/README.md)
├── 00-system-overview.md           (from templates/00-system-overview.md)
├── 01-stack-and-hosting.md         (from templates/01-stack-and-hosting.md)
├── 02-data-and-storage.md          (from templates/02-data-and-storage.md)
├── 03-external-integrations.md     (from templates/03-external-integrations.md)
├── 04-decisions.md                 (from templates/04-decisions.md)
└── 05-open-questions.md            (from templates/05-open-questions.md)
```

**Substitutions** (literal string replacement, not regex):

| Placeholder         | Replace with                                          |
|---------------------|--------------------------------------------------------|
| `{{PROJECT_NAME}}`  | Project name from README's H1 (or ask if missing).     |
| `{{TODAY}}`         | `date +%Y-%m-%d`.                                      |

Other placeholders inside templates (`{{ONE_PARAGRAPH_SYSTEM_DESCRIPTION}}`, `{{e.g. ...}}`, etc.) are **content stubs**. Leave them in place until you fill them with interview answers.

After scaffolding, show the user the structure and confirm before starting the interview.

### Steps 4-10: The seven topics

Walk the topics in order, per `references/interview-playbook.md`. Per topic:

1. Ask 3-5 questions from the playbook (one batch via AskUserQuestion-style or conversationally).
2. After the answers, echo back what you heard as draft content for the relevant file.
3. Capture **decisions** in `04-decisions.md` (lightweight ADR per `references/adr-format.md`).
4. Capture **unknowns** in `05-open-questions.md` (OQ format from the template).
5. Update the topic-specific file (`01-stack-and-hosting.md`, `02-data-and-storage.md`, etc.).
6. Confirm before moving to the next topic.

The topics map to files like this:

| Topic | Primary file updated                  | Decisions captured in                     |
|-------|----------------------------------------|--------------------------------------------|
| 1 — System type | `00-system-overview.md`           | `04-decisions.md` (system type ADR)        |
| 2 — Hosting     | `01-stack-and-hosting.md`         | `04-decisions.md` (hosting ADRs)           |
| 3 — Components  | `00-system-overview.md` (containers) | `04-decisions.md` (component ADRs)      |
| 4 — Stack       | `01-stack-and-hosting.md`         | `04-decisions.md` (stack ADRs)             |
| 5 — Data        | `02-data-and-storage.md`          | `04-decisions.md` (data store ADRs)        |
| 6 — Integrations| `03-external-integrations.md`     | `04-decisions.md` (integration choice ADRs)|
| 7 — Pattern fit | `00-system-overview.md` ("Why this shape?") | `04-decisions.md` (pattern ADR)  |

### Step 11: Topic 8 — Decisions vs unknowns review

Once the seven content topics are walked, do a sweep:

- Show the user the ADRs captured (read aloud the title + status + decision line of each).
- Show the user the open questions captured (read each title).
- Ask: *"Anything you wanted to record that we missed? Anything in here that should move from decided to open, or vice versa?"*

This catches the cases where the user said "yeah, let's go with X" during the conversation but in retrospect realised it was a soft call.

### Step 12: Summary + handoff

Print a tight summary:

- `docs/architecture/` exists with 6 files + README.
- N decisions captured (ADRs).
- M open questions captured.
- Pattern: {{the named pattern from Topic 7}}.
- **Next step:** run `/requirements-create-from-design` next. That skill will read `docs/architecture/` and use it as context — so requirements work will be informed by the technical shape, not done in a vacuum.

Show the diff (`git status` + summary of what was added). Don't auto-commit — let the user review and commit.

## Re-design mode (when `docs/architecture/` already exists)

If the folder exists with real content, the skill switches to re-design mode:

1. Read every existing file.
2. Show the user a summary of what's there — count of ADRs (by status), count of open questions (by status), the pattern named.
3. Ask: *"What's prompting the re-design? Is this a refinement (firming up open questions), a pivot (changing decisions), or an expansion (adding scope)?"*
4. Walk only the affected topics, not all seven.
5. **Supersede ADRs, don't delete them.** Mark the old one Superseded by ADR-NNN; add the new one with the same template.
6. **Move resolved open questions** to the Resolved section of `05-open-questions.md`.
7. **Same summary + handoff at Step 12.**

If the architectural change is large enough that the existing structure is wrong (e.g. the project pivots from a serverless monolith to an event-driven microservices system), this isn't a re-design — it's a fresh design. Tell the user: *"This is a big enough change that we should regenerate the architecture folder from scratch. The git history preserves the old version; I'll archive it under `docs/architecture/archive/`."*

## Strict non-goals

- **No code generation.** This is a design phase. Implementation belongs in `/task-implement`.
- **No exhaustive design.** The point is a first stab, not a finished design doc. If the conversation runs past 90 minutes, stop and put what's outstanding in `05-open-questions.md`.
- **No microservices proposals at this stage** unless the user is explicit about why. Default to modular monolith; capture the split as an open question.
- **No premature optimisation in the design.** No CDN-cache layers proposed before the project has CDN-cacheable content; no separate read/write replicas proposed before the project has measurable read pressure.
- **No requirement elicitation.** That's `/requirements-create-from-design`. If during the interview the user starts giving feature requirements, capture them as a note ("user wants X functionality") and tell them they'll be elicited properly in the next phase.
- **No pre-emptive ADR creation.** An ADR is recorded *when a decision is made*. Don't pre-create ADRs that say "we'll decide later" — those are open questions, not decisions.

## Edge cases

- **README is missing or empty.** Stop and ask the user to write one paragraph stating the project's purpose before continuing.
- **User wants the skill to "just generate everything from the README".** Decline politely and explain: the architectural shape is too consequential to invent. Offer to scaffold *empty templates with TBD placeholders* and run the interview separately.
- **User answers everything "I don't know".** Two passes through with sensible defaults proposed; if still no answers, stop and suggest they think more about the project before continuing — without input, the design would be invention.
- **User wants an architecture for an already-coded project.** This is *reverse engineering*, not initial design. The skill can run, but tell the user that the goal is *capturing* the architecture that exists (read the code, infer the structure) rather than *deciding* it.
- **`docs/architecture/` already exists** — see *Re-design mode* above.
- **Project has multiple sub-projects** (monorepo with separate apps). Run the skill once per sub-project, producing `apps/<name>/docs/architecture/` for each, OR a single top-level `docs/architecture/` that has sub-sections. Ask the user.
