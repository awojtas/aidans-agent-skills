---
name: ui-component-review
description: "Reviews a frontend codebase for reusable UI component opportunities — identifies where the app is reinventing base primitives, where reuse is healthy, and where abstraction would be premature. Produces prioritised findings with file/line references, a suggested component set, a do-not-abstract list, and a migration order. Pragmatic and incremental by default. Use when the user says 'review reusable UI components', 'are we reinventing components?', 'component reuse review', 'design system audit', 'base components audit', 'UI primitive review', or wants to understand component duplication and drift in a frontend codebase."
---

# UI component review

Inspect a frontend codebase for component duplication, accessibility drift, design drift, and premature-abstraction traps. Produce a prioritised, actionable report — not a design-system rewrite plan unless the codebase clearly needs one.

## Scope rules

Before reviewing, understand the codebase. Do not apply a generic component checklist without first mapping the actual structure.

- **Inspect first, judge second.** Identify the framework, styling approach, and existing shared layer before drawing any conclusions.
- **Incremental by default.** Recommend extracting the highest-duplication, highest-risk primitives first. Migrate feature areas opportunistically, not all at once.
- **Domain-specific components stay local.** Not everything that looks similar should be abstracted. Call this out explicitly.
- **No new dependencies** unless framework-native APIs and existing local patterns genuinely can't address the need.

## Workflow

```text
UI Component Review Progress
- [ ] Step 1: Map the frontend structure
- [ ] Step 2: Locate the existing shared layer
- [ ] Step 3: Find duplication and drift
- [ ] Step 4: Classify findings
- [ ] Step 5: Produce the report
```

### Step 1: Map the frontend structure

Understand what you're working with before touching anything else:

```bash
# Top-level layout
find . -type d -name 'components' -o -name 'ui' -o -name 'shared' \
  | grep -v node_modules | head -30

# Framework and styling
cat package.json | grep -E '"react|vue|svelte|angular|tailwind|styled|emotion|css-modules'

# Component file count by directory
find src -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' \
  | grep -v node_modules | xargs dirname | sort | uniq -c | sort -rn | head -20
```

Record: framework, styling approach (Tailwind, CSS Modules, CSS-in-JS, plain CSS), whether a component library (shadcn, Radix, MUI, etc.) is already in use.

### Step 2: Locate the existing shared layer

Find what already exists as shared/reusable:

```bash
# Shared component directories
find src -type d \( -name 'ui' -o -name 'shared' -o -name 'common' \
  -o -name 'primitives' -o -name 'base' \) | grep -v node_modules

# Design tokens / CSS variables
grep -r 'var(--' src --include='*.css' --include='*.scss' -l
grep -r ':root' src --include='*.css' --include='*.scss' -l

# Tailwind config (if used)
cat tailwind.config.* 2>/dev/null | head -40
```

Note: shared components scoped under a feature folder (e.g. `features/chat/components/Button.tsx`) count as **not shared** even if they could be.

### Step 3: Find duplication and drift

Search for repeated patterns across the following surfaces. Read file contents; don't stop at filenames.

#### Interactive primitives

Look for hand-rolled versions of:

| Primitive | What to grep for |
|-----------|-----------------|
| Button | `<button`, `onClick`, `disabled`, `className.*btn\|button` |
| IconButton | `<button.*aria-label`, icon-only patterns |
| TextInput | `<input type="text"`, `<input type="email"`, etc. |
| TextArea | `<textarea` |
| Select / Combobox | `<select`, custom dropdown patterns |
| Dialog / Modal | `role="dialog"`, `aria-modal`, focus-trap patterns |
| Menu / Dropdown | `role="menu"`, `aria-haspopup` |
| Tabs | `role="tab"`, `role="tablist"` |

#### Layout and feedback

| Primitive | What to grep for |
|-----------|-----------------|
| InlineAlert / Banner | `role="alert"`, `aria-live`, alert/error/warning class patterns |
| Loading state | spinner patterns, `aria-busy`, skeleton patterns |
| Empty state | empty-state patterns, zero-result layouts |
| Badge / Chip | tag/badge/chip class patterns |
| Panel / Card | card/panel class patterns, repeated border+shadow+padding combos |
| DisclosureStrip | `<details`, `aria-expanded` toggle patterns |

#### Behavior duplication (higher risk than visual similarity)

Grep across all components for:

```bash
# Focus trap implementations
grep -r 'focusTrap\|useFocusTrap\|trapFocus\|useEffect.*focus' src --include='*.tsx' --include='*.ts' -l

# Escape key handling
grep -r "key.*Escape\|keyCode.*27\|useKeydown" src --include='*.tsx' --include='*.ts' -l

# Outside-click dismissal
grep -r 'mousedown\|pointerdown.*outside\|useOutsideClick\|useClickAway' src --include='*.tsx' --include='*.ts' -l

# Validation / error presentation
grep -r 'error.*message\|errorText\|fieldError\|aria-describedby' src --include='*.tsx' -l
```

#### Accessibility drift

Flag inconsistencies in:
- `aria-modal` present/absent across similar dialogs
- `aria-labelledby` vs `aria-label` vs unlabelled for the same type of control
- `aria-busy` on loading states
- Focus management after open/close (dialogs, menus)
- Keyboard navigation: Enter/Space activation, arrow-key navigation in menus/tabs
- Icon-only buttons missing `aria-label`
- Inconsistent tab semantics (`role="tab"` used vs implicit)

#### Design drift

Flag inconsistencies in:
- Border radius across similar interactive elements
- Focus ring style/colour
- Hover/active state treatment
- Destructive action button styling
- Alert/error colour and icon usage
- Panel chrome (border, shadow, padding)
- Spacing scale usage (magic numbers vs design tokens)

### Step 4: Classify findings

For each finding, assign:

**Severity**
- `P0` — accessibility regression risk (broken keyboard support, missing ARIA, focus trap absent on modal)
- `P1` — high duplication with behaviour divergence; likely to cause bugs or UX drift
- `P2` — visual duplication without behaviour risk; good refactor candidate
- `P3` — noted similarity; abstraction not yet justified

**Abstraction verdict**
- `Extract` — should become a shared primitive; clear reuse case
- `Consolidate` — two or more near-identical implementations; pick one
- `Keep local` — domain-specific; abstracting would leak business logic into UI primitives
- `Watch` — only seen once or twice; revisit when a third instance appears

### Step 5: Produce the report

```markdown
## UI Component Review

**Framework:** <detected>
**Styling:** <detected>
**Existing shared layer:** <path(s) or "none">

---

### Findings (ordered by severity)

#### P0 — Accessibility risk
- `<file:line>` — <one-line description> — **Suggested fix:** <concrete action>

#### P1 — Behaviour duplication
- `<file:line>` — <one-line description>

#### P2 — Visual duplication
- `<file:line>` — <one-line description>

#### P3 — Noted / watch
- `<file:line>` — <one-line description>

---

### Suggested component set

Components worth extracting, in recommended migration order (highest risk/duplication first):

| Component | Current locations | Risk if not extracted |
|-----------|------------------|-----------------------|
| `Button` | ... | A11y drift, inconsistent disabled state |
| `Dialog` | ... | Focus trap missing in 2 of 3 implementations |
| ... | | |

---

### Do not abstract yet

| Component | Reason |
|-----------|--------|
| `<name>` | Domain-specific: <why> |
| `<name>` | Only one instance; wait for a second before extracting |

---

### Migration order

1. **`<Primitive>`** — extract first (zero feature coupling, highest duplication)
2. **`<Primitive>`** — ...
3. Feature area `<name>` — migrate after primitives are stable

---

### Tests

<Note whether tests were run. For a review-only pass: "No tests run — this is a read-only audit.">
```

## Edge cases

- **No frontend code found**: Report and stop — wrong directory or non-frontend repo.
- **Third-party component library already covers most primitives** (MUI, shadcn, etc.): Focus findings on drift *from* the library, not on re-extracting what it already provides.
- **Single-page / tiny app**: Flag if the overhead of a shared layer outweighs the duplication. Sometimes three slightly different buttons is fine.
- **Monorepo with a dedicated UI package**: Note it. Findings should target whether the UI package is being used consistently or bypassed.
- **CSS-only / no component framework**: Adjust the grep patterns; findings are CSS-class duplication and HTML structure duplication rather than component-tree duplication.
