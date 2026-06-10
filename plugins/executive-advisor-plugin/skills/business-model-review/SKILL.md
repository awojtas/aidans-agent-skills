---
name: business-model-review
description: "Reviews how a product creates economic value — whether the business model is coherent with the product direction, the pricing is aligned with the value delivered, and the unit economics are at least directionally sound. Reads README, solution design, docs, and any monetisation signals in the codebase. Flags misalignment between what the product optimises for and how it makes money. Use when the user says 'business model review', 'how do we make money?', 'is our pricing right?', 'revenue model', 'monetisation review', 'unit economics', 'is this a viable business?', or wants to understand whether the product direction and the revenue model are pulling in the same direction."
---

# Business model review

A product that creates real customer value but cannot capture any of that value economically is a charity, not a business. A product that captures value without creating it is a racket. The business model is how the two sides — value creation and value capture — are connected.

This skill reads a repo for signals about how money flows (or is intended to flow) and asks: is the business model coherent with what the product actually does for customers? Is there a plausible path from "customer gets value" to "business receives economic return"?

---

## The business model components

| Component | Question |
|-----------|---------|
| **Value proposition** | What specific value does the customer receive? What problem is solved? |
| **Customer segment** | Who pays? Who uses? (They may be different.) |
| **Revenue mechanism** | How does money flow to the business — subscription, usage, transaction, licence, freemium, advertising, services? |
| **Pricing alignment** | Is the price tied to the value the customer receives, or to cost/internal metrics? |
| **Unit economics** | Does serving one customer create more value than it costs? Is that ratio improving? |
| **Switching costs and retention** | What keeps a customer? Is the model resilient to churn? |
| **Growth mechanism** | How does the business get more customers — product-led, sales-led, network effects, content, referral? |

---

## Workflow

```text
Business Model Review Progress
- [ ] Step 1: Extract the business model from available signals
- [ ] Step 2: Test coherence between product direction and model
- [ ] Step 3: Assess pricing alignment
- [ ] Step 4: Identify model risks
- [ ] Step 5: Produce the report
```

### Step 1: Extract the business model from available signals

Business model information can be scattered or absent in a repo. Read broadly:

```bash
cat README.md
cat docs/design/solution-design.md 2>/dev/null
find docs -name '*.md' | xargs grep -il 'pricing\|revenue\|subscription\|billing\|payment\|freemium\|plan\|tier\|licence\|monetis' 2>/dev/null
grep -r 'pricing\|subscription\|billing\|payment\|stripe\|paddle\|revenue' --include='*.md' docs/ README.md 2>/dev/null | head -30
# Check for payment integrations in code
grep -r 'stripe\|paddle\|lemon\|chargebee\|billing' --include='*.ts' --include='*.js' --include='*.py' src/ app/ 2>/dev/null | head -20
```

Reconstruct as much of the business model as the available signals allow. Note where each piece of information came from, and note clearly what is inferred vs. stated.

If no monetisation signal exists anywhere, that is a finding — not necessarily a blocker (pre-revenue products exist) but a gap worth naming.

---

### Step 2: Test coherence between product direction and model

The product direction and the business model must pull in the same direction. Common misalignments:

**Usage model vs. seat model**
The product is optimised for solo power-user workflows, but the revenue model is per-seat (number of users). Heavy individual users generate the most costs and create no additional revenue. Incentive: restrict per-user value to force more seats.

**Engagement model vs. outcome model**
Revenue depends on users spending time in the product, but the product's core value is achieving something quickly and leaving. Incentive: make the product stickier than is good for the user.

**Freemium funnel vs. product direction**
The free tier is so capable that almost no user converts to paid. Or the paid tier is so incrementally different from free that conversion is hard to justify. The product direction keeps improving the free tier, narrowing the conversion reason.

**Services dependency**
Revenue depends on professional services/implementation, but the product roadmap is moving toward self-serve. Services revenue falls before product revenue compensates.

**B2C product with B2B pricing**
Pricing decisions (annual contracts, per-seat, procurement process) are B2B, but the product is optimised for individual consumers. Wrong buyer, wrong pricing muscle.

Read recent PRs, open issues, and the roadmap to see which direction the product is moving, then test for these misalignments.

---

### Step 3: Assess pricing alignment

Healthy pricing is tied to the value the customer receives, not to the cost to serve or to internal convenience.

Ask:
- Is the pricing unit tied to something the customer values? (Per active user, per transaction processed, per outcome achieved — vs. per API call, per GB stored, per employee)
- Does a customer who gets 10× the value pay roughly 10× the price? Or does the pricing structure cap at a flat fee that decouples value from revenue?
- Is there a clear reason a free/trial user would upgrade — and is that reason visible in the product direction?

This can only be fully assessed if pricing information is available. If it isn't, note the absence and recommend documenting it.

---

### Step 4: Identify model risks

**No revenue model**
Pre-revenue product with no stated path to monetisation. Not a failure mode by itself (early stage), but requires naming.

**Revenue-product decoupling**
The team optimising the product is not the same as the team thinking about revenue. Feature decisions are made without asking "does this make us money?"

**Single revenue stream**
All revenue from one customer, one contract type, or one channel. High concentration risk.

**Churn blindness**
No mechanism to detect, measure, or respond to customer churn. Growth is tracked; retention is not.

**Grow-by-adding complexity**
Revenue grows by adding features, not by customers getting more value from existing features. Feature bloat eventually destroys the core value proposition.

---

### Step 5: Produce the report

```markdown
## Business Model Review

### Extracted business model
| Component | Finding | Confidence |
|-----------|---------|-----------|
| Value proposition | <stated or inferred> | High/Medium/Low |
| Customer segment | <stated or inferred> | High/Medium/Low |
| Revenue mechanism | <stated or inferred> | High/Medium/Low |
| Pricing alignment | <stated or inferred> | High/Medium/Low |
| Growth mechanism | <stated or inferred> | High/Medium/Low |

*Confidence reflects how much direct evidence was available.*

### Coherence assessment
<Is the product direction pulling in the same direction as the business model? Specific misalignments found.>

### Model risks
<List specific risks from Step 4, with evidence.>

### Gaps
<Components of the business model that aren't documented anywhere.>

### Recommendations
1. <Most important — often: write down the business model explicitly so it can guide product decisions>
2. ...
```

---

## Maturity dashboard

This skill owns the **Business model clear** dimension. See [`../../shared/business-maturity-tracker.md`](../../shared/business-maturity-tracker.md).

- Begin → set **Business model clear** to ⏳.
- Complete with a coherent, documented model → ✅.
- Complete with significant gaps or misalignments → ❓.

---

## Guardrails

- **Don't require a profitable business.** Early-stage products legitimately don't have a working model yet. The question is whether there is a coherent intended path.
- **Inferred ≠ stated.** Always flag when a component of the model is inferred from code or behaviour rather than explicitly documented.
- **Don't recommend pricing changes.** Surface misalignments; pricing decisions belong to humans.
- **Internal tools:** if the product is an internal tool, "revenue" may be cost avoidance or productivity gain. The model still exists — it just measures differently.
