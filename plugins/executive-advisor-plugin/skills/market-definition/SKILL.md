---
name: market-definition
description: "Forces a crisp answer to Drucker's most important strategic question: 'What business are we actually in?' Reads the repo to surface the implicit market definition, tests it for common misidentification traps (describing the product instead of the market, defining by feature rather than by customer problem, market too broad or too narrow), and produces a one-paragraph market definition statement with gaps and recommendations. Use when the user says 'market definition', 'what business are we in?', 'who is our market?', 'are we targeting the right customers?', 'market clarity', 'strategic focus', or wants to pressure-test the product direction against the actual market being served."
---

# Market definition

> *"The first question in defining a business is: what is our business?"*
> — Peter F. Drucker, *The Practice of Management*, 1954

Drucker's observation was that most companies answer this question with a description of their product. That is the wrong answer. A product is the delivery mechanism. The business is defined by the customer, the problem, and the value created — not by the technology or features used to deliver it.

IBM was not in the computer business. It was in the information-processing business. Kodak was not in the film business. It was in the memory business. The difference determined whether each company could see substitutes coming.

This skill forces a repo's implicit market definition to the surface and tests it.

---

## Workflow

```text
Market Definition Progress
- [ ] Step 1: Extract the stated market definition
- [ ] Step 2: Derive the implicit market definition
- [ ] Step 3: Test for misidentification traps
- [ ] Step 4: Identify the competitive frame
- [ ] Step 5: Produce the market definition statement and gaps
```

### Step 1: Extract the stated market definition

Read every place a market or customer definition might be written down:

```bash
cat README.md
cat docs/design/solution-design.md 2>/dev/null
cat docs/requirements/00-overview.md 2>/dev/null
find docs -name '*.md' | xargs grep -l 'market\|segment\|persona\|customer\|user' 2>/dev/null
gh issue list --state open --limit 10 --json title,body --jq '.[].body' 2>/dev/null | head -100
```

Extract any explicit statements about: who the customer is, what problem is being solved, what segment is targeted, what value is created. Note the source of each statement.

If nothing is written down, that is the primary finding.

---

### Step 2: Derive the implicit market definition

Even when no market definition is written, the product's actual direction implies one. Read the codebase structure, recent PRs, and open issues to infer:

- **Who is actually being served?** What kind of person would use what's being built?
- **What problem does the product solve?** Not "what does it do" — what painful situation does it resolve?
- **When would someone reach for this?** What triggers the decision to use the product?

Compare the stated definition (Step 1) to the implicit one (Step 2). Divergence is a finding — it means the team says they serve one market but their work serves a different one.

---

### Step 3: Test for misidentification traps

Run the stated or derived definition through these tests:

**Product-description trap**
Is the "market" actually a description of the product? ("We're in the AI assistant market" is a product description. "We're in the market for knowledge workers who lose hours each week to context-switching" is a market definition.)

**Feature-not-problem trap**
Is the market defined by a feature rather than a customer problem? ("The real-time collaboration market" is a feature. The underlying market is "teams that lose productivity to version conflicts and communication lag.")

**Too broad**
Is the definition so wide it gives no guidance? ("Businesses" or "people who use computers" don't help you decide what to build next.)

**Too narrow**
Is the definition so specific it describes only the first customer, not a repeatable market? (One pilot customer is a proof of concept, not a market.)

**Backward-looking**
Is the market defined by an existing solution ("the spreadsheet market") rather than the underlying need? The underlying need persists when the solution changes.

**Substitute blindness**
Does the definition acknowledge that customers have alternatives, including doing nothing? A market definition that doesn't account for substitutes will be surprised by competition.

---

### Step 4: Identify the competitive frame

For the derived market definition, ask:

- What are the realistic alternatives for a customer in this market? (Other products, workarounds, doing nothing.)
- Why would a customer choose this product over those alternatives?
- Is that differentiation reason evident in the product's direction and the backlog?

If the differentiation reason isn't visible in the work being done, the team is building without a clear competitive position.

---

### Step 5: Produce the market definition statement and gaps

Output a crisp one-paragraph market definition statement, then gaps and recommendations.

```markdown
## Market Definition

### Stated definition
<Verbatim or paraphrased from Step 1, with source. "None found" if absent.>

### Derived definition
<One paragraph: customer segment + specific problem + trigger + why now.>

**Format:** We serve [customer segment] who [specific problem/pain], when [triggering situation], and for whom [existing alternatives] are insufficient because [gap].

### Misidentification findings
<List any traps triggered from Step 3, with evidence.>

### Competitive frame
<What alternatives exist. What the differentiation claim is. Whether that claim is visible in recent work.>

### Gaps
<What's missing or unclear from the market definition.>

### Recommendations
1. <Most important clarification needed>
2. ...
```

---

## Maturity dashboard

This skill owns the **Market defined** dimension of the business maturity dashboard in `README.md`. See [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md) for the block format and algorithm.

- When this skill begins its substantive work → set **Market defined** to ⏳.
- When it completes with a clear, documented market definition → set to ✅.
- When it completes but the market definition remains unclear → leave at ❓ and note the gap.

---

## Guardrails

- **Don't invent a market.** If the evidence is genuinely ambiguous, say so.
- **Don't conflate market with product.** The market exists independently of the product. The product is the attempt to serve it.
- **Don't recommend a pivot.** Surface the definition gaps; humans own the strategic direction decision.
- **Be specific.** "The market is unclear" is not useful. "The README describes a B2C product but all three open features are obviously B2B workflows" is useful.
