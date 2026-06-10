---
name: issue-architect-review
description: "Reviews one or more GitHub issues from a Chief Architect perspective — improves issue bodies and comments with architectural guardrails, SOLID/scalability concerns, implementation landmines, testing strategy, acceptance-criteria sharpness, and overlap detection. Optionally suggests follow-up issues (with confirmation before creating). Use when the user says 'architect review', 'review issues', 'check my issues', 'architecture review', 'issue quality pass', 'review issue #N', 'pre-implementation review', or wants a senior technical review of the backlog before implementation starts."
---

# Issue architect review

Review GitHub issues as a Chief Architect — not a task implementer. The goal is to improve issue quality so that whoever picks the issue up (human or AI) can implement it correctly without stepping into hidden traps.

Fits between `issue-prioritise` and `issue-work` / `task-implement` in the issue lifecycle.

## Inputs and defaults

| Input | Default |
|-------|---------|
| Repo | Resolved from current git checkout |
| Issues to review | Most recently created open issues (up to 20) |
| Single issue | Pass a number or URL to review only that one |
| Skip in-progress | Off by default; enable when asked, or when issues have active-work signals |

## Workflow

Copy and track:

```text
Architect Review Progress
- [ ] Step 1: Resolve repo and determine scope
- [ ] Step 2: Fetch issues
- [ ] Step 3: Review each issue
- [ ] Step 4: Apply safe refinements
- [ ] Step 5: Propose new issues (if any)
- [ ] Step 6: Final summary
```

### Step 1: Resolve repo and determine scope

Resolve the GitHub repo from the current git checkout unless the user provides one:

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

Confirm with the user:
- Single issue or batch (default: 20 most recently created open issues)?
- Skip issues with active-work signals?

Active-work signals: `in-progress` / `wip` labels, a linked open PR, or body/comments that say work has started.

### Step 2: Fetch issues

```bash
# Batch (default)
gh issue list --state open --limit 20 --json number,title,body,labels,comments \
  --jq 'sort_by(.createdAt) | reverse'

# Single issue
gh issue view <number> --json number,title,body,labels,comments
```

For each issue, also check for cross-links: scan the body for `#NNN` references and fetch those briefly.

### Step 3: Review each issue

For each issue, run through the review checklist, then decide the action.

#### Review checklist

**Problem framing**
- Does the issue describe the *right problem*, or only a symptom?
- Is the proposed fix addressing root cause, not a workaround?

**Architecture fit**
- Does the proposed implementation respect the existing architecture (layers, modules, conventions)?
- Does it introduce coupling between layers that should be separate (UI ↔ domain, persistence ↔ UI, provider adapter ↔ business logic)?

**SOLID and extensibility**
- Single responsibility: does the issue ask one thing to do too many things?
- Open/closed: will the solution extend naturally to a second provider, second user flow, second happy path — without rewriting?
- Dependency inversion: does it push interfaces toward abstractions rather than concretes?
- Global state: does it scatter state that should be encapsulated?
- UI-only fix for a server/domain problem?

**Scalability and edge cases**
- Does it work beyond the first user, first provider, first data set?
- Race conditions, lifecycle problems (init order, teardown), retry/idempotency, stale state, cleanup hazards?

**Testing strategy**
- Are unit, integration, and (where relevant) E2E test expectations stated?
- Are fake/stub providers specified where external dependencies exist?
- Is the test strategy for async, concurrent, or timing-sensitive code addressed?
- Are acceptance criteria objective and independently verifiable (not "it should feel right")?

**Scope and overlap**
- Is the issue too broad? Should it be split into smaller focused issues?
- Does it duplicate or substantially overlap an existing issue? If so, should it be cross-linked or narrowed?

**Labels and priority**
- Do the current labels and priority look right? (Note gaps; never create new labels — surface them instead.)

#### Actions per issue

| Situation | Action |
|-----------|--------|
| Issue is clear and well-structured | No change |
| Missing architectural guardrails or landmines | Add a section to the body |
| ACs are vague or untestable | Edit the ACs section or add a DoD section |
| Overlaps another issue | Add a cross-link comment |
| Labels/priority look wrong | Note in summary; suggest correction using existing labels only |
| Issue is too broad | Flag for splitting; suggest sub-issue titles for confirmation |
| Duplicate | Comment pointing to the original; suggest closing |

### Step 4: Apply safe refinements

Apply directly (no confirmation needed) when the change **improves clarity without changing product intent**:
- Add an `## Architecture Guardrails` section listing specific risks to watch for.
- Add an `## Implementation Landmines` section listing known traps (e.g. "this path is called on every keystroke — don't block it").
- Add or sharpen a `## Definition of Done` / `## Acceptance Criteria` section.
- Add cross-links to related issues.
- Fix typos or broken formatting.

Preserve the author's intent and product language. Add the minimum guidance needed — don't turn every issue into an essay.

Make issues **junior-developer-friendly**: name concrete files or areas to look at, state known traps, set clear test expectations, define scope boundaries explicitly.

**Never** rewrite an issue that is mostly good. **Never** create new GitHub labels.

### Step 5: Propose new issues (if any)

If a review surfaces a gap that doesn't fit neatly into an existing issue, propose it. **Before creating anything**, present:

- Proposed title
- Why it doesn't fit an existing issue
- Suggested labels (from existing labels only)
- Draft body

Wait for explicit confirmation. If confirmed, create:

```bash
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --label "<existing-label>"
```

### Step 6: Final summary

```text
## Architect Review — Summary

Issues reviewed:   N
Issues edited:     N
Comments added:    N
Issues skipped:    N (reason)
New issues proposed: N (awaiting confirmation / created)

Changes made:
- #12 — Added Architecture Guardrails and DoD
- #34 — Sharpened ACs; flagged overlap with #28
- #56 — No change needed

Skipped:
- #78 — In-progress (linked PR #80)

New issue suggestions (pending confirmation):
- "<title>" — <one-line reason>
```

## Editing style

- Prefer **adding sections** (`Architecture Guardrails`, `Implementation Landmines`, `Definition of Done`) over rewriting existing content.
- Keep additions concise — bullet points over paragraphs.
- Name **specific files, interfaces, or patterns** where relevant so developers know exactly where to look.
- Set **explicit scope boundaries**: "this issue covers X; Y is out of scope and tracked in #N."

## Edge cases

- **No open issues**: Report and stop.
- **Single issue is already in progress**: Note that it's in flight; review anyway unless the user asked to skip in-progress.
- **Issue has no body**: Comment asking for a description before reviewing, and flag in the summary.
- **Issue references an external system the skill can't inspect**: Note the dependency; don't speculate about its internals.
- **Label gaps found**: Surface them in the summary with suggested label names; never create labels.
