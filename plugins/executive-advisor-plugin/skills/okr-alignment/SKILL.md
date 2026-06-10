---
name: okr-alignment
description: "Reviews a repository's objectives, milestones, and roadmap against business outcomes — are the team's goals tied to creating or keeping customers, or just tracking activity? Flags vanity metrics (tickets closed, PRs merged, velocity), objectives with no measurable key results, key results with no baseline, and goals that are internally focused rather than customer-outcome focused. Use when the user says 'OKR review', 'are our goals aligned?', 'objective alignment', 'are we measuring the right things?', 'goal quality check', 'roadmap alignment', 'vanity metrics', or wants to know whether the team's stated goals will actually move the business forward."
---

# OKR alignment

The purpose of an objective is to direct effort toward an outcome that matters. An objective that measures activity ("ship three features this quarter") is not an objective — it is a to-do list. An objective that measures an outcome the customer experiences ("reduce time-to-first-value from 20 minutes to 5") is directional and testable.

This skill reads whatever goal-setting artefacts exist in the repo and asks: if the team achieves every stated objective, will the business be creating more customers or keeping them better?

---

## What good looks like

**Objective:** A clear, qualitative statement of a desired business outcome. Customer-facing or directly enabling customer creation/retention. Inspiring enough to guide daily tradeoff decisions.

**Key result:** A specific, measurable, time-bound indicator that the objective is being achieved. Tied to a starting baseline. Not an output (feature shipped) — an outcome (customer behaviour changed, problem solved, metric moved).

**Anti-patterns to flag:**
- Output KRs: "Ship X", "Close Y tickets", "Complete Z refactor"
- Vanity metrics: traffic up, signups up, PRs merged — without retention, activation, or revenue correlation
- Unmeasurable KRs: "improve the experience", "make it faster" with no number
- No baseline: "increase by 20%" when current state is unknown
- Internal-only objectives: goals that make the team's life easier but don't change what the customer experiences

---

## Workflow

```text
OKR Alignment Progress
- [ ] Step 1: Find goal artefacts
- [ ] Step 2: Extract and structure objectives and key results
- [ ] Step 3: Score each objective/KR pair
- [ ] Step 4: Map objectives to business purpose
- [ ] Step 5: Produce the report
```

### Step 1: Find goal artefacts

Goals can live in many places in a repo. Check all of them:

```bash
# Docs
find docs -name '*.md' | xargs grep -l 'objective\|OKR\|goal\|milestone\|roadmap\|KR\|key result' 2>/dev/null

# GitHub milestones
gh api repos/{owner}/{repo}/milestones --jq '.[] | {title: .title, description: .description, due: .due_on, open: .open_issues, closed: .closed_issues}'

# README
grep -i 'goal\|objective\|roadmap\|milestone' README.md

# Issues labelled as goals/roadmap
gh issue list --label 'roadmap,goal,objective,okr' --state open --json number,title,body 2>/dev/null
```

If no goal artefacts exist, that is itself a finding — a team with no written objectives is navigating by instinct.

---

### Step 2: Extract and structure objectives and key results

For each artefact found, extract:
- The objective statement (the "what we want to achieve")
- The key results or success metrics (the "how we'll know we achieved it")
- The time horizon (quarter, cycle, milestone)
- The current status (not started / in progress / achieved)

If the structure is loose (e.g. milestone titles without explicit KRs), derive the implicit KR from the milestone's issues.

---

### Step 3: Score each objective/KR pair

Score each objective on two dimensions:

**Outcome orientation** — does achieving this objective change something the customer experiences?
- ✅ Customer outcome: directly changes what a customer can do, experiences, or pays
- ⚠️ Enabling outcome: internal change that enables a customer outcome (acceptable if the connection is explicit)
- ❌ Activity/output: measures what the team does, not what changes for the customer

**Measurability** — can you tell unambiguously whether the key result was achieved?
- ✅ Measurable: specific number, clear baseline, defined time horizon
- ⚠️ Directional: clear direction but no number or baseline
- ❌ Unmeasurable: subjective, no way to verify achievement

---

### Step 4: Map objectives to business purpose

For the full set of objectives, ask:

- What fraction are customer-outcome oriented vs. activity-oriented?
- If every objective is achieved, will the business have more customers or better-served customers?
- Are there customer-purpose dimensions (creating customers, keeping customers) that no objective is driving toward?
- Is there any objective explicitly tied to a customer feedback signal?

---

### Step 5: Produce the report

```markdown
## OKR Alignment

### Objectives reviewed
<Count and sources (milestones, docs, issues).>

### Objective scorecard

| Objective | Outcome orientation | Measurability | Notes |
|-----------|-------------------|--------------|-------|
| <title> | ✅/⚠️/❌ | ✅/⚠️/❌ | ... |

### Anti-patterns found
<List specific anti-patterns with evidence — name the milestone, issue, or doc.>

### Coverage gaps
<Business purpose dimensions (creating customers, keeping customers) that no objective is driving toward.>

### Overall assessment
<One paragraph: if this team achieves everything on its current objectives, will the business be better at creating and keeping customers?>

### Recommendations
1. <Most important fix — usually: rewrite the highest-priority objective in outcome terms>
2. ...
```

---

## Maturity dashboard

This skill owns the **Objectives aligned** dimension. See [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md).

- Begin → set **Objectives aligned** to ⏳.
- Complete with majority of objectives customer-outcome oriented and measurable → ✅.
- Complete with mostly activity/output objectives or no objectives found → ❓.

---

## Guardrails

- **Don't require OKR format.** Milestones, roadmap docs, and written goals all count. The question is whether the goals are outcome-oriented, not whether they use the OKR label.
- **Internal objectives can be valid.** A goal to reduce build time is legitimate if it enables faster customer-facing delivery and that connection is explicit.
- **Don't grade on strictness.** A directional KR without a baseline is better than no KR. Flag the gap; don't fail the objective.
