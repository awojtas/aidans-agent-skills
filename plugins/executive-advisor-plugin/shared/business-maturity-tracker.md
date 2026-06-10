# Business maturity tracker — shared spec

The `executive-advisor-plugin` skills maintain a maturity dashboard at the **very bottom of the acted-on repo's `README.md`**. `/business-status-check` rebuilds the whole block from a repo scan; individual advisory skills update their own dimension line as they run. This file is the single source of truth for the dimension list, block format, and create-or-update algorithm.

## The dimensions

Each dimension has an owning skill and maps to a foundational business question.

| Dimension label | Owning skill | Question it answers |
|----------------|-------------|---------------------|
| Customer defined | `/customer-purpose-audit` | Who exactly is the customer, and what do they value? |
| Market defined | `/market-definition` | What business are we actually in? |
| Business model clear | `/business-model-review` | How do we create economic value from the customer relationship? |
| Innovation active | `/innovation-audit` | Are we creating genuinely new customer value, or only maintaining? |
| Objectives aligned | `/okr-alignment` | Are our goals tied to business outcomes, not just activity? |
| Feedback loop active | `/customer-purpose-audit` | Are real customer signals shaping what gets built? |

## The emoji legend

- ✅ — established. The dimension has clear, documented, current evidence.
- ⏳ — in progress. Work is underway but not complete or not yet documented.
- ❓ — not yet. No meaningful evidence found.

## The block

A find-and-replace-safe block delimited by HTML comments, living at the **very bottom** of `README.md`:

```markdown
<!-- business-maturity:start -->
## Business maturity

- ✅ Customer defined — `/customer-purpose-audit`
- ✅ Market defined — `/market-definition`
- ⏳ Business model clear — `/business-model-review`
- ❓ Innovation active — `/innovation-audit`
- ❓ Objectives aligned — `/okr-alignment`
- ❓ Feedback loop active — `/customer-purpose-audit`

✅ established · ⏳ in progress · ❓ not yet — maintained by the executive-advisor-plugin skills.
<!-- business-maturity:end -->
```

The two `<!-- business-maturity:… -->` comment lines are the anchors. Never remove them. Always keep every dimension line and the legend line.

## Create-or-update algorithm

Target: `README.md` in the **root of the repo being acted on**.

1. **No `README.md`** → create it with an H1 (repo name from git remote or directory name), a blank line, then the block — every dimension ❓ except any this run sets.
2. **`README.md` exists, no `<!-- business-maturity:start -->`** → append the block at the very bottom, preceded by one blank line. Every dimension ❓ except any this run sets.
3. **Block already present** → replace the content between the anchors in place; leave the block where it sits.

### Individual skills update one line

A skill that owns a dimension touches **only its own line**:
- When it begins its substantive work → set the line to ⏳.
- On successful completion → set the line to ✅.
- Every other line is left exactly as found.

### `/business-status-check` rebuilds every line

`/business-status-check` scans the repo for evidence of every dimension and writes **all** lines from that scan, then commits `docs: update business maturity dashboard` and pushes. If the block already matches the scan, it skips the commit.

## Guardrails

- Always preserve the comment anchors, every dimension line, and the legend line.
- An individual skill never edits a dimension other than its own.
- Use the exact dimension labels in the table above — they must match across skills.
- The dashboard is best-effort signal, not a gate. Never block skill work on it.
