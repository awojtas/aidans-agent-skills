# AGENTS.md — `design-system-aurora-plugin`

Plugin-specific context for agents working in `plugins/design-system-aurora-plugin/`. The [root AGENTS.md](../../AGENTS.md) carries the repo-wide conventions for adding plugins and skills; this file covers what is distinctive about *this* plugin.

## What this plugin is

A design-system skill — the **Glass Aurora** design language. The skill steers UI-generation work in any project that installs it toward consistency with Aurora's principles when components, themes, or design tokens are being created or modified.

## Design principles maintained here

- **Glassmorphic cards** — translucent layers, subtle blur, layered depth.
- **Aurora gradient backgrounds** — long, soft colour transitions across the surface.
- **Neon-style focus / hover glows** — emphasis through colour bloom rather than borders.
- **Purple-cyan core palette** — with greys and ink for everything else; restraint outside the brand pair is the discipline.

## When editing the skill

The skill is essentially a *prompt* that nudges component-generation work toward the Aurora style. Edits should:

- Preserve the principle catalogue. Don't dilute by adding many overlapping styles — each new entry should be a concrete, named pattern with a clear reusable shape.
- Keep token names consistent (the same purple-cyan accent shouldn't appear as `--accent` in one place and `--brand` in another).
- Resist drift toward "modern" / "clean" / "minimal" — those are not design directions, they are smells per the UX role doc in `sdlc-plugin/skills/task-implement/references/role-ux-designer.md`.

## Single-skill caveat

The root `AGENTS.md` notes "a 1-skill plugin is a smell". This plugin is deliberately one skill for now — the bundle exists to grow if and when more design systems land. Not a smell, just a state. If a sibling design system arrives, the plugin theme is *design systems*, not Aurora specifically.
