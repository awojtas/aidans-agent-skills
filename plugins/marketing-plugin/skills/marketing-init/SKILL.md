---
name: marketing-init
description: 'Onboard an app into the marketing system. Scaffolds docs/marketing/ in the app''s own repo, writes the per-app profile.md (the single source of truth every other marketing skill reads), and creates the app''s living-docs folder (e.g. Google Drive) from shared templates. Use when starting marketing for a new app, "set up marketing for X", "marketing init", or whenever another marketing skill runs and no docs/marketing/profile.md exists yet.'
---

# Onboard an app into the marketing system

The entry point. Every other skill in this bundle reads `docs/marketing/profile.md`; this skill creates it. Run once per app (re-run to update the profile).

## When to use

- Starting marketing for an app for the first time.
- Any marketing skill needs a profile and none exists.

## Process

1. **Confirm app context interactively.** Ask only what you cannot infer from the repo (README, package metadata, deployed URL):
   - app name, marketing domain, app domain
   - who it's really for (ICP) and where they gather
   - named competitors users actually compare against
   - **constraints** — time per week, total budget, how visible the owner will be. These shape every later skill, so get them explicitly.
   - which tools are in play (listening, analytics, images, email, scheduler)
2. **Write `docs/marketing/profile.md`** in the app repo from `../../shared/profile-template.md`, filling the frontmatter from the answers. Leave unknowns as clearly-marked TODOs rather than guessing.
3. **Create living-docs folder** if a Drive-style tool is declared: make `Projects/<App>/` and copy the growth tracker (and any other templates) from the central "Marketing Templates" folder. Record the URLs in the profile's `links`.
4. **Add the lifecycle tracker** block (from `../../shared/marketing-lifecycle.md`) to the plan doc or README.
5. **Commit** the scaffold on a branch.

## Output

`docs/marketing/profile.md`, the living-docs folder, and a lifecycle tracker — enough that `marketing-status` and every phase skill can run.

## Guardrails

Never write secrets into `profile.md` (it lives in the repo). See `../../shared/tooling.md` and `../../shared/guardrails.md`.
