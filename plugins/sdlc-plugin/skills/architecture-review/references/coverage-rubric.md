# Coverage rubric — the mandatory dimension gate

The whole point of this rubric is the **gate**: the synthesis must walk every dimension and assign it a status. "We didn't look at testing" must be impossible to ship. A review built by reading source naturally over-weights what lives in the code and under-weights what surrounds it — this list forces the surrounding dimensions to be looked at on purpose.

## Status vocabulary (assign exactly one per dimension)

- **Covered** — findings exist; see the report.
- **Checked, nothing to fix** — genuinely looked, genuinely fine. **A first-class, valuable outcome** (lint/tsconfig/globals/secrets being clean is worth stating). Must be *stated*, never omitted.
- **Gap** — not adequately reviewed this run (e.g. an agent died, the area was out of scope). Say so honestly; don't let a gap masquerade as "nothing to fix."
- **n/a** — dimension doesn't apply to this repo (e.g. no DB, no multi-tenancy).

## The dimensions, their owner, and the cheap probe

| # | Dimension | Owner | Mechanical probe (run it; don't infer) |
|---|-----------|-------|----------------------------------------|
| 1 | SOLID & module boundaries | layer readers | — (judgment from reading) |
| 2 | Abstraction (incl. over-abstraction) | layer readers | grep for interfaces/abstract classes with a single implementer |
| 3 | **Testing & testability** | Testing specialist | `git ls-files '*.test.*' '*.spec.*' \| wc -l`; counts per layer; open e2e specs |
| 4 | Data integrity / unrepresentable bad states | data layer reader | `grep -rc "check (\|not null\|unique\|references" migrations/`; check for RLS |
| 5 | **Security breadth** (authz, tenancy, injection, secrets, CSRF, SSRF, rate-limit) | Security specialist | hardcoded-secret scan (below); grep auth middleware coverage |
| 6 | **Global state, side-effects & config** | Global-state specialist | `grep -rn "process\.env\." \| wc -l` (sites + files); module-level mutable singletons |
| 7 | Robustness / error strategy | cross-cutting reader | grep `catch` blocks; `catch {}` / swallow patterns |
| 8 | Code specs (lint config, type strictness) | pre-scan + cross-cutting | suppression count; tsconfig `strict` flags |
| 9 | Documentation & comment hygiene | pre-scan + all readers | aislop comment rules; spot-read comments |
| 10 | Observability | cross-cutting / SRE lens | grep logging/metrics/tracing init; structured-log usage |
| 11 | Performance hot-paths | layer readers | identify per-keystroke / per-request / N+1 paths by reading; no premature optimization |
| 12 | Refactoring debt | synthesis | aggregate god-modules, duplication, dead code from the above |

Owners marked **bold** (Testing, Security breadth, Global state/config) are the dimensions that get *silently skipped* when you only read business logic, so they get a dedicated dimension specialist in Step 4 — not just whatever falls out of a layer read.

## Probe snippets

```bash
# Lint suppressions (count is a signal; clusters are a finding)
grep -rn --exclude-dir=node_modules "biome-ignore\|eslint-disable\|@ts-ignore\|@ts-expect-error\|# noqa\|nolint" . | wc -l

# Type strictness
cat tsconfig*.json 2>/dev/null | grep -i 'strict\|noUncheckedIndexedAccess\|noImplicitAny'

# Debt markers
grep -rn --exclude-dir=node_modules "TODO\|FIXME\|HACK\|XXX" . | wc -l

# Env spread (config / global state)
grep -rn --exclude-dir=node_modules "process\.env\." . | sort | uniq -c

# Test inventory
git ls-files '*.test.*' '*.spec.*'

# Hardcoded-secret smell (tune per stack)
grep -rnE --exclude-dir=node_modules "(api[_-]?key|secret|password|token|private[_-]?key)\s*[:=]\s*['\"][A-Za-z0-9/_+-]{12,}" .
```

These are smells, not verdicts. A hit is a prompt to read the site, not a finding on its own. The synthesis verifies anything load-bearing with a real command (see `synthesis-checklist.md`).
