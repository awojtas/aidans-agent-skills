---
name: business-status-check
description: "Scans a repository and updates the business maturity dashboard in README.md — assessing all six dimensions (Customer defined, Market defined, Business model clear, Innovation active, Objectives aligned, Feedback loop active) from available evidence, writing the dashboard block, and committing it. The executive-advisor equivalent of /status-help — use this to see where a product stands across all business fundamentals at a glance, and to get a recommendation on which advisory skill to run next. Use when the user says 'business status', 'business health', 'business maturity', 'how are we doing as a business?', 'executive summary', 'update the business dashboard', 'what should I focus on?', or wants a top-level view of business readiness."
---

# Business status check

Surveys a repo for evidence of all six business maturity dimensions, rebuilds the dashboard in `README.md`, commits it, and recommends the single most valuable next advisory skill to run.

The companion to `/customer-purpose-audit`, `/market-definition`, `/innovation-audit`, `/okr-alignment`, `/business-model-review`, and `/build-buy-partner` — this skill reads the signals those skills would read, makes a coarser pass, and gives an overall picture rather than a deep audit of any one dimension.

---

## The six dimensions

| Dimension | Evidence of ✅ | Owning skill |
|-----------|--------------|-------------|
| **Customer defined** | Named customer segment, documented value, written definition | `/customer-purpose-audit` |
| **Market defined** | Crisp market definition statement, competitive frame acknowledged | `/market-definition` |
| **Business model clear** | Revenue mechanism stated, pricing aligned to value, model coherent with product direction | `/business-model-review` |
| **Innovation active** | Recent work includes new customer value, not only maintenance/overhead | `/innovation-audit` |
| **Objectives aligned** | Goals tied to customer outcomes and measurable, not just activity | `/okr-alignment` |
| **Feedback loop active** | Real customer signals (feedback, analytics, support) visibly shaping the backlog | `/customer-purpose-audit` |

---

## Workflow

```text
Business Status Check Progress
- [ ] Step 1: Scan repo for evidence across all dimensions
- [ ] Step 2: Map evidence to dimension scores
- [ ] Step 3: Identify the most critical gap
- [ ] Step 4: Rebuild the README dashboard
- [ ] Step 5: Commit and push
- [ ] Step 6: Report and recommend
```

### Step 1: Scan repo for evidence

Read broadly and quickly — this is a survey pass, not a deep audit:

```bash
# Core docs
cat README.md
cat docs/design/solution-design.md 2>/dev/null
find docs -name '*.md' -maxdepth 3 | head -15 | xargs head -30 2>/dev/null

# Git activity (innovation signal)
git log --oneline -20

# Milestones and objectives
gh api repos/{owner}/{repo}/milestones --jq '.[] | {title: .title, description: .description}' 2>/dev/null

# Recent merged PRs (innovation + feedback signals)
gh pr list --state merged --limit 15 --json title,body --jq '.[] | "\(.title): \(.body[:200])"' 2>/dev/null

# Open issues (feedback loop, objectives)
gh issue list --state open --limit 15 --json title,body,labels --jq '.[] | "\(.title)"' 2>/dev/null
```

---

### Step 2: Map evidence to dimension scores

For each dimension, apply this evidence test:

**Customer defined** ✅ if: there is a written definition naming a specific customer segment and stating what they value. ⏳ if: a definition exists but is vague, outdated, or only partially written. ❓ if: no customer definition found.

**Market defined** ✅ if: the README or solution design includes a market definition that names the problem, the segment, and acknowledges alternatives. ⏳ if: some market framing present but incomplete (no alternatives, or only product description). ❓ if: no market definition found.

**Business model clear** ✅ if: the revenue mechanism is stated, pricing is described, and the model is visibly coherent with the product direction. ⏳ if: some monetisation signal present (payment integration in code, pricing mentioned) but not explicitly documented. ❓ if: no monetisation signal found.

**Innovation active** ✅ if: the last significant batch of commits/PRs includes work that creates new customer value (not only maintenance/overhead). ⏳ if: some new-value work present but it is the minority. ❓ if: recent work is entirely maintenance, refactoring, or overhead.

**Objectives aligned** ✅ if: milestones or roadmap docs contain objectives with measurable, outcome-oriented key results tied to customer behaviour. ⏳ if: milestones exist but are output-oriented ("ship X") rather than outcome-oriented. ❓ if: no milestones, roadmap, or objectives found.

**Feedback loop active** ✅ if: open issues or PR descriptions reference customer feedback, support requests, analytics, or usage data. ⏳ if: occasional customer signal present but no systematic mechanism. ❓ if: no evidence of customer input shaping the backlog.

---

### Step 3: Identify the most critical gap

With all six dimensions scored, identify the single most critical ❓ or ⏳ using this priority order:

1. **Customer defined** — without this, every other dimension is guesswork
2. **Market defined** — without this, the product direction has no anchoring
3. **Feedback loop active** — without this, the business is flying blind on whether it's creating customers
4. **Business model clear** — without this, customer value creation has no economic sustainability
5. **Objectives aligned** — without this, the team is optimising for the wrong things
6. **Innovation active** — without this, the product is stagnating relative to alternatives

The most critical gap determines the recommended next skill.

---

### Step 4: Rebuild the README dashboard

Write the full dashboard block using the format in [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md). Every dimension gets ✅, ⏳, or ❓ from the Step 2 scores.

---

### Step 5: Commit and push

Stage **only** `README.md`, commit, and push:

```bash
git add README.md
git commit -m "docs: update business maturity dashboard"
git push
```

If the block already matches the scan exactly, skip the commit. If there is no remote or push fails, keep the local commit and tell the user.

---

### Step 6: Report and recommend

Output a concise report in chat:

```markdown
## Business Status

| Dimension | Score | Signal |
|-----------|-------|--------|
| Customer defined | ✅/⏳/❓ | <one-line evidence or gap> |
| Market defined | ✅/⏳/❓ | <one-line evidence or gap> |
| Business model clear | ✅/⏳/❓ | <one-line evidence or gap> |
| Innovation active | ✅/⏳/❓ | <one-line evidence or gap> |
| Objectives aligned | ✅/⏳/❓ | <one-line evidence or gap> |
| Feedback loop active | ✅/⏳/❓ | <one-line evidence or gap> |

**Most critical gap:** <dimension> — <one sentence on why>

**Recommended next skill:** `/<skill-name>` — <one sentence on what it will do>

Dashboard updated in README.md.
```

---

## Guardrails

- **This is a survey, not a deep audit.** The individual skills go deep; this skill goes broad. Don't spend time on detailed analysis of any one dimension — that's what the owning skill is for.
- **Don't speculate beyond evidence.** If a dimension shows no signal, score it ❓ and say so. Don't infer a customer definition from vibes.
- **One recommendation only.** The most critical gap gets the recommendation. Don't list all six skills.
- **Dashboard update is mandatory.** Even if nothing has changed, verify the block exists and is accurate. It's the reason this skill runs.
