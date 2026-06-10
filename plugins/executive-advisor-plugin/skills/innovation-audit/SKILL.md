---
name: innovation-audit
description: "Audits a repository against Drucker's second business function: innovation — creating genuinely new value for the customer. Maps recent work to an innovation spectrum (new customer value, sustaining improvement, efficiency, maintenance, overhead) and flags innovation starvation (all maintenance, no new value), innovation chaos (too many directions with no customer validation), and missing feedback loops between shipped features and customer outcomes. Use when the user says 'innovation audit', 'are we innovating?', 'are we moving forward?', 'feature velocity', 'are we creating new value?', 'innovation vs maintenance', or wants to understand whether the product is genuinely advancing customer value or just treading water."
---

# Innovation audit

> *"Because the purpose of business is to create a customer, the business enterprise has two — and only two — basic functions: marketing and innovation. Marketing and innovation produce results; all the rest are costs."*
> — Peter F. Drucker, *The Practice of Management*, 1954

Innovation, in Drucker's framing, does not mean invention. It means creating new value for the customer — a new capability, a new experience, a meaningfully better outcome. Shipping a refactored internal module is not innovation. Removing a step the customer previously had to do manually is.

This skill classifies recent work against the innovation spectrum and identifies whether the team is genuinely creating new customer value or has drifted into a maintenance-and-overhead loop.

---

## The innovation spectrum

| Category | Definition | Counts as innovation? |
|----------|-----------|----------------------|
| **New customer value** | Capability the customer couldn't do before, or a problem they had that's now solved | Yes — primary |
| **Sustaining improvement** | Existing capability made meaningfully faster, easier, or more reliable for the customer | Yes — secondary |
| **Efficiency gain** | Same customer value delivered at lower cost or effort — internally visible | Marginal |
| **Maintenance** | Keeping existing behaviour working (bug fixes, dependency updates, security patches) | No |
| **Overhead** | Infrastructure, tooling, process, CI, internal refactors — no direct customer change | No |

A healthy product has a mix. The question is whether *new customer value* is present at all, and whether the ratio is sustainable.

---

## Workflow

```text
Innovation Audit Progress
- [ ] Step 1: Establish the customer value baseline
- [ ] Step 2: Classify recent work
- [ ] Step 3: Check for customer validation
- [ ] Step 4: Identify failure modes
- [ ] Step 5: Produce the report
```

### Step 1: Establish the customer value baseline

Before classifying work, understand what "customer value" means for this product:

```bash
cat README.md
cat docs/design/solution-design.md 2>/dev/null
gh issue list --state closed --limit 5 --json title,body,labels 2>/dev/null
```

Answer: what does a customer actually get from this product today? What are the core workflows they rely on? This is the baseline against which new additions are measured.

---

### Step 2: Classify recent work

Read and classify the last significant batch of commits and merged PRs:

```bash
git log --oneline -40
gh pr list --state merged --limit 30 --json number,title,body,mergedAt \
  --jq '.[] | "#\(.number): \(.title)"'
```

For each item, assign it to one category from the innovation spectrum. Read PR bodies — don't classify from titles alone.

Tally the results. Note any extended periods (multiple sprints / milestones) where **New customer value** is completely absent.

---

### Step 3: Check for customer validation

Innovation without customer validation is speculation. Look for evidence that shipped features are reaching and serving real customers:

```bash
# Issues referencing customer feedback, usage data, or follow-up requests
gh issue list --state open --limit 30 --json title,body \
  --jq '.[] | select(.body | test("feedback|customer|user reported|analytics|usage|metric"; "i")) | .title'

# PRs that reference a customer request or complaint
gh pr list --state merged --limit 20 --json title,body \
  --jq '.[] | select(.body | test("customer|user request|feedback|reported"; "i")) | .title'
```

Also look for:
- Features shipped but never followed up on (no follow-up issues, no "is this working?" signals)
- A backlog that is entirely internally generated (no customer input visible)
- Features built for hypothetical future customers vs. requests from actual current customers

---

### Step 4: Identify failure modes

**Innovation starvation**
The team is spending all its time on maintenance and overhead. New customer value has not shipped in a meaningful period. The product is treading water. Customers may not notice yet, but the gap between what this product can do and what alternatives offer is growing.

Signal: *New customer value* is zero or near-zero in recent work classification.

**Innovation chaos**
Too many directions are being explored simultaneously, with no clear customer validation at any of them. Features are started but not finished. The backlog has many unrelated experiments. Nothing ships to a state where a real customer can use it.

Signal: Many ⏳ features, few ✅ features. High WIP, low completion. Breadth without depth.

**Innovation-maintenance inversion**
The team believes they are innovating (because they are busy building new things) but the new things are internal refactors, new tooling, or infrastructure changes — not customer-visible improvements. Activity is high; customer value creation is low.

Signal: Lots of "new" work that doesn't change what a customer can do.

**Unvalidated innovation**
New customer value is being shipped, but there is no feedback mechanism to determine whether customers are actually using it, valuing it, or having problems with it. Innovation without feedback is eventually misdirected.

Signal: No customer validation signals (Step 3 found nothing).

---

### Step 5: Produce the report

```markdown
## Innovation Audit

### Customer value baseline
<What the product currently does for the customer, in one paragraph.>

### Work classification (recent activity)

| Category | Count | % | Notes |
|----------|-------|---|-------|
| New customer value | N | N% | ... |
| Sustaining improvement | N | N% | ... |
| Efficiency gain | N | N% | ... |
| Maintenance | N | N% | ... |
| Overhead | N | N% | ... |

### Customer validation signals
<What evidence exists that shipped features are reaching and serving real customers. "None found" if absent.>

### Failure modes detected
<List any failure modes from Step 4, with specific evidence (PR numbers, commit ranges, patterns).>

### Assessment
<One paragraph: is this team innovating? What is the trajectory?>

### Recommendations
1. <Most important action>
2. ...
```

---

## Maturity dashboard

This skill owns the **Innovation active** dimension. See [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md).

- Begin → set **Innovation active** to ⏳.
- Complete with evidence of recent new customer value → ✅.
- Complete with innovation starvation or chaos finding → ❓.

---

## Guardrails

- **Maintenance is not failure.** A mature product may legitimately spend more time on maintenance than innovation. The question is whether new customer value is present at all, not whether it dominates.
- **Don't conflate activity with innovation.** A busy team is not necessarily an innovative one.
- **Internal tools can innovate too.** If the customer is an internal team, new capabilities for them count as new customer value.
