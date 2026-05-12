# 09 — Risks

Known risks to the project's success. **Different from assumptions** — an assumption is something we believe to be true; a risk is something we know could go wrong.

## Risk register

| ID     | Risk                                  | Likelihood (1–5) | Impact (1–5) | Score | Mitigation                                              | Owner       | Status            |
|--------|----------------------------------------|------------------|--------------|-------|----------------------------------------------------------|-------------|-------------------|
| R-001  | {{What could happen}}                  | 3                | 4            | 12    | {{Concrete steps to reduce likelihood or impact}}        | {{Name}}    | Open / Mitigated / Realised / Closed |
| R-002  |                                        |                  |              |       |                                                          |             |                   |

Score = Likelihood × Impact. Re-score every {{cadence — e.g. monthly, or at every milestone}}.

### Categories to cover

- **Technical** — unknowns in the stack, integration uncertainty, scaling cliffs.
- **Operational** — single-points-of-failure (a person, a vendor, a contract).
- **Market / business** — competitor moves, demand assumptions, channel risk.
- **Legal / regulatory** — incoming legislation, compliance audit.
- **Security** — known unfilled gaps with planned remediation.
- **Resourcing** — solo dev burnout, key hire dropping out.

If a category is genuinely empty, write `R-{{CAT}}-NONE: no known risks in this category as of {{date}}` so it's clear the category was considered.

## Realised risks

When a risk is **Realised**, keep it in the register and add:

- Realised on.
- Actual impact (versus predicted).
- Containment actions.
- Lessons that fed back into other risks or requirements.
