---
name: build-buy-partner
description: "For capabilities in a backlog or architecture, determines whether each should be built in-house, bought (library, SaaS, or off-the-shelf), or acquired through a partnership. Applies Drucker's principle that a business should not build what is not core to customer value creation. Reads open issues, requirements, and architecture docs to identify the highest-leverage build/buy/partner decisions and flags where the team is building undifferentiated infrastructure instead of focusing on the core customer problem. Use when the user says 'build vs buy', 'make vs buy', 'should we build this?', 'build buy partner', 'strategic sourcing', 'are we building the right things?', or wants a principled framework applied to specific capabilities in the backlog."
---

# Build / buy / partner

> *"Do not build what is not part of your distinctiveness."*
> — Peter F. Drucker (paraphrased from *The Practice of Management*, 1954)

Every engineering hour spent building a capability that could be bought or partnered is an hour not spent on the thing that actually differentiates the product for the customer. The question is not "can we build this?" — the answer is almost always yes. The question is "should we be the ones to build it?"

---

## The decision framework

For each capability, ask three questions in order:

**1. Is this core to customer value?**
A capability is core if customers choose the product *because of* this capability — if removing it would cause customers to leave or not arrive. Non-core capabilities support delivery but are not why customers show up.

- Core → strongly prefer **Build** (own and differentiate)
- Non-core → move to question 2

**2. Does a good enough external solution exist?**
"Good enough" means: solves the customer problem adequately, doesn't introduce unacceptable dependencies (vendor lock-in, compliance risk, pricing risk), and can be integrated without architectural damage.

- Good solution exists → strongly prefer **Buy** or **Partner**
- No good solution → **Build**, but document why

**3. Would a partner's reach or capability amplify your customer value?**
A partnership is different from buying: a partner brings their own customers, distribution, or capability that you cannot replicate easily. Partnerships are strategic; buying is transactional.

- Strategic amplification possible → evaluate **Partner**
- No strategic amplification → **Buy** if solution exists, **Build** if not

---

## Workflow

```text
Build/Buy/Partner Progress
- [ ] Step 1: Identify capabilities in scope
- [ ] Step 2: Classify each by the decision framework
- [ ] Step 3: Flag undifferentiated build work
- [ ] Step 4: Produce the recommendation table
```

### Step 1: Identify capabilities in scope

Gather the capabilities to analyse. These can come from:

```bash
# Open issues that represent capabilities to build
gh issue list --state open --limit 30 --json number,title,body,labels \
  --jq '.[] | "#\(.number): \(.title)"'

# Requirements docs
find docs/requirements -name 'FR-*.md' | head -20 2>/dev/null

# Architecture decisions involving external dependencies
find docs/architecture -name '*.md' | xargs grep -l 'ADR\|decision\|third.party\|dependency\|integration' 2>/dev/null
```

The user may also pass a specific capability or list of capabilities as arguments. If they do, scope to those.

Default: the most significant open capabilities (highest-priority or highest-effort items) in the current backlog.

---

### Step 2: Classify each capability

For each capability, apply the three-question framework:

**Is this core to customer value?**

Signals that a capability is core:
- It is the primary reason a customer would describe the product when recommending it to a colleague
- It is unique to this product — competitors don't do it this way
- It is in the user's critical path: removing it stops the customer's core workflow

Signals that a capability is not core:
- It is infrastructure (auth, payments, storage, email, search, notifications, analytics)
- It is a standard workflow present in every product in this category
- A customer would not mention it when describing what makes this product good

**Does a good enough external solution exist?**

Search briefly for existing solutions:
- Well-maintained open-source libraries
- SaaS products that solve the problem
- Cloud-provider managed services

Assess:
- Does it solve the actual problem, or only a nearby one?
- What is the vendor/dependency risk?
- What is the integration cost vs. build cost?
- What are the ongoing costs (licence, operational)?

**Would a partnership amplify customer value?**

A partnership makes sense when:
- Another company already has the customers, distribution, or capability you need
- The partnership creates value for both parties' customers
- The integration or commercial arrangement is feasible

---

### Step 3: Flag undifferentiated build work

Look for open issues or in-progress work where the team is building something that:
- Has obvious, mature external solutions (auth systems, payment processing, email delivery, search, file storage, PDF generation, etc.)
- Is not distinctive to this product's customer value
- Would take significant engineering time to build to parity with an existing solution

These are the highest-leverage build/buy/partner decisions because the opportunity cost is real and immediate.

---

### Step 4: Produce the recommendation table

```markdown
## Build / Buy / Partner

### Capability decisions

| Capability | Core? | External solution? | Recommendation | Rationale |
|-----------|-------|-------------------|---------------|-----------|
| <name> | Yes/No | Yes/No/Partial | Build/Buy/Partner | <one line> |

### Highest-leverage decisions
<The top items where changing from Build to Buy/Partner would free the most engineering capacity for core customer value work.>

### Flagged undifferentiated build work
<Specific issues or capabilities in the backlog where the team is building something non-core when a good external solution exists.>

### Recommendations
1. <Most impactful — typically: adopt an existing solution for the highest-cost non-core capability>
2. ...
```

---

## Guardrails

- **Don't recommend buying everything non-core.** External dependencies have costs: vendor risk, integration complexity, contractual constraints. The recommendation is to *prefer* buy/partner for non-core; the human team makes the final call.
- **Don't evaluate build cost precisely.** This skill gives directional recommendations, not project estimates.
- **Core can change.** A capability that is core today may become commodity tomorrow (and vice versa). Flag where a capability's core status is uncertain or evolving.
- **Never recommend specific vendors by name unless the user asks.** Surface the category of solution; the team evaluates vendors.
