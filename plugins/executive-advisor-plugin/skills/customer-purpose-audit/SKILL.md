---
name: customer-purpose-audit
description: "Audits a repository against Peter Drucker's foundational principle — 'There is only one valid definition of business purpose: to create a customer' (The Practice of Management, 1954). Reads the codebase, docs, recent commits, and open issues to determine how well the work is oriented toward creating and keeping customers, flags what is getting in the way, and recommends next actions to move in that direction. Use when the user says 'Drucker audit', 'customer purpose audit', 'are we focused on the customer?', 'business purpose review', 'are we building the right thing?', 'strategic alignment check', or wants a senior business-advisor perspective on whether the repo's direction serves its actual business purpose."
---

# Customer purpose audit

> *"There is only one valid definition of business purpose: to create a customer."*
> — Peter F. Drucker, *The Practice of Management*, 1954

Drucker's argument is blunt: everything a business does is either directed at creating (or keeping) a customer, or it is overhead. Not bad — overhead can be necessary — but overhead is a cost, not a purpose. This audit holds a repository up to that standard and asks: **how much of what this team is building actually serves the customer?**

The two functions that serve the purpose directly are **marketing** (understanding who the customer is and what they value) and **innovation** (creating new value for them). Everything else — infrastructure, tooling, process, compliance — is support cost. It may be essential support cost, but it is not the purpose.

---

## Workflow

```text
Customer Purpose Audit Progress
- [ ] Step 1: Understand the product
- [ ] Step 2: Identify the customer
- [ ] Step 3: Map recent work to customer value
- [ ] Step 4: Assess alignment
- [ ] Step 5: Identify blockers
- [ ] Step 6: Produce the report and next actions
```

### Step 1: Understand the product

Read broadly before judging anything:

```bash
cat README.md
cat docs/design/solution-design.md 2>/dev/null
cat docs/architecture/00-system-overview.md 2>/dev/null
gh repo view --json description,homepageUrl
```

Also scan open issues and recent PRs for signals about what the product actually does in practice vs. what the README says:

```bash
gh issue list --state open --limit 20 --json title,body,labels
gh pr list --state merged --limit 20 --json title,body,mergedAt
```

Answer: **What does this product do, and who would pay (or choose) to use it?**

If the answer is unclear from the repo, that is itself a finding — a product without a clear articulated purpose is already misaligned.

---

### Step 2: Identify the customer

The customer is the person whose problem the product solves. Not the team. Not the company. Not "users" in the abstract.

Work through these questions:

| Question | Where to look |
|----------|--------------|
| Who is explicitly named as the customer or user? | README, solution design, requirements docs |
| Is there a paying customer, or is this internal tooling? | README, `docs/`, PR descriptions |
| Are there personas, user stories, or acceptance criteria written in customer terms? | `docs/requirements/`, issue bodies |
| Is the customer's definition of value documented anywhere? | Solution design, product docs |
| Is there any feedback signal from real customers (analytics, support tickets, reviews)? | Issue labels, PR descriptions, external links |

**A customer definition that isn't written down doesn't exist.** If it's in someone's head, it isn't guiding the work.

---

### Step 3: Map recent work to customer value

Classify the last significant batch of commits, merged PRs, and open issues into four buckets:

| Bucket | Definition |
|--------|-----------|
| **Creates customer** | Directly acquires, onboards, or enables new customers — marketing, distribution, first-run experience, discoverability |
| **Keeps customer** | Directly improves value for existing customers — new features, reliability, performance the customer notices, bug fixes that unblock customer workflows |
| **Overhead** | Necessary support work that doesn't directly touch the customer — infrastructure, CI, refactoring, dependency updates, internal tooling |
| **Unclear** | Can't tell from the commit/PR/issue description whether this serves a customer or not |

```bash
# Get recent merged PRs
gh pr list --state merged --limit 30 --json number,title,body,mergedAt \
  --jq '.[] | "\(.number): \(.title)"'

# Get recent commits
git log --oneline -30
```

Read the body of anything non-obvious. Classify each item. Tally the buckets.

**A healthy repo is not one where everything is "Creates customer" — overhead is real and necessary. The signal is the ratio and the trend.** A team spending most of its time on overhead that never ships customer-facing value is drifting from the purpose.

---

### Step 4: Assess alignment

Score the overall alignment on four dimensions:

**Customer clarity** — Is the customer clearly defined, named, and documented?
- Strong: named, documented, informed by real feedback
- Partial: described loosely or only in some documents
- Weak: implied but not written down
- Absent: no evidence of a customer definition

**Work orientation** — What fraction of recent work (by count and by effort signal) directly creates or keeps a customer?
- Strong: clear majority of merged work is Creates/Keeps customer
- Partial: mix, with overhead present but not dominant
- Weak: most work is overhead or unclear
- Absent: nothing in the recent history maps to a customer

**Innovation signal** — Is the team building things that create new value for the customer, or only maintaining what already exists?
- Strong: new features or capabilities shipped recently that expand customer value
- Partial: incremental improvements to existing features
- Weak: only maintenance, no new value shipped
- Absent: no customer-facing output

**Feedback loop** — Is there any mechanism for the customer to inform what gets built?
- Strong: issues/PRs reference customer feedback, support tickets, or analytics
- Partial: some customer signals present but not systematically used
- Weak: occasional mention of user needs, no systematic process
- Absent: no evidence of customer input shaping the backlog

---

### Step 5: Identify blockers

Look for patterns that actively prevent customer focus. Common ones:

**No customer definition**
The team is building for a hypothetical customer. Decisions get made on internal preference rather than customer value. Every prioritisation debate is unresolvable because there's no "does this serve the customer?" test.

**Overhead spiral**
Infrastructure, tooling, refactoring, and process work have crowded out customer-facing delivery. Often visible as: long stretches of commits with no customer-facing output; PRs whose purpose is to make other PRs easier rather than to ship value.

**Feature-without-customer-validation**
New features being built without evidence that a customer asked for them, will pay for them, or will use them. Common in eng-led roadmaps.

**Internal customer confusion**
The team is optimising for internal stakeholders (other teams, management, compliance) rather than for the end customer. Internal work gets dressed up as customer work.

**Definition-of-done not in customer terms**
Acceptance criteria written as technical completeness ("the API returns 200") rather than customer outcome ("the user can complete checkout without error"). Technically done ≠ customer value delivered.

**No feedback mechanism**
Nothing in the repo's workflow brings customer signals in. Issues don't reference support tickets. PRs don't reference customer complaints or requests. The backlog is entirely internally generated.

**Vanity metrics**
Progress tracked as lines of code, tickets closed, or PRs merged — not as customers created or customer problems solved.

---

### Step 6: Report and next actions

```markdown
## Customer Purpose Audit

> "There is only one valid definition of business purpose: to create a customer."
> — Drucker, 1954

### The product
<One paragraph: what it is, who the apparent customer is, and what problem it solves.>

### Customer definition
**Score:** Strong / Partial / Weak / Absent

<Evidence and gaps.>

### Work alignment
**Score:** Strong / Partial / Weak / Absent

| Bucket | Count | Notes |
|--------|-------|-------|
| Creates customer | N | ... |
| Keeps customer | N | ... |
| Overhead | N | ... |
| Unclear | N | ... |

<Key observations about the ratio and trend.>

### Innovation signal
**Score:** Strong / Partial / Weak / Absent

<What new customer value has been shipped recently, if any.>

### Feedback loop
**Score:** Strong / Partial / Weak / Absent

<Evidence of customer signals shaping the backlog.>

---

### Blockers

<List of specific blockers found, with evidence. Be concrete — name the issues, PRs, or patterns that demonstrate each blocker.>

---

### Next actions

Ordered by leverage on the customer purpose:

1. **[Action]** — <what to do, and why it moves toward the customer purpose>
2. **[Action]** — ...
3. **[Action]** — ...

The highest-leverage next action is almost always: **write down who the customer is and what they consider value**, because without that, every other improvement is directional guesswork.
```

---

## Maturity dashboard

This skill owns **two** dimensions. See [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md).

| Dimension | When to set ✅ | When to leave ❓ |
|-----------|---------------|----------------|
| **Customer defined** | Audit completes with a clear, documented customer definition | No written customer definition found |
| **Feedback loop active** | Audit finds systematic customer signals shaping the backlog | No customer input visible in issues/PRs |

- Begin → set **both** owned lines to ⏳.
- Complete → set each line independently based on the Step 4 scores for "Customer clarity" and "Feedback loop".
- Leave every other dimension line exactly as found.

---

## Guardrails

- **Don't moralize about overhead.** Overhead is necessary. The goal is right-sizing it relative to customer-facing work, not eliminating it.
- **Don't invent a customer.** If the repo gives no signal, say so — don't project a customer onto it.
- **Internal tools have customers too.** The customer of an internal tool is the team that uses it. "Create a customer" still applies; the customer is just inside the company.
- **Don't recommend a pivot.** This skill identifies alignment and blockers; strategic direction decisions belong to the humans who own the business.
- **Be specific.** Name actual files, issues, and PRs. "The team seems to do a lot of overhead" is useless. "PRs #34, #41, and #47 were all CI pipeline changes with no customer-facing output" is actionable.
