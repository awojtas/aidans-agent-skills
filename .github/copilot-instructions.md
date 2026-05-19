@../AGENTS.md

# Copilot Instructions

The line above imports `AGENTS.md` from the repo root into Copilot's context — that file is the canonical authoring guide for adding plugins, skills, and reference docs to this marketplace.

## Copilot-specific notes

- This is a Claude Code plugin marketplace. There is no application code, no build, and no test suite. Edits land directly via PR.
- The marketplace's update check only compares the `version` field in each `plugin.json` — bump the version with every plugin change or users won't see updates.
- See `AGENTS.md` § *Background tooling* for the `scripts/git-auto-commit.ps1` script. If you observe commits you didn't make, fetch and inspect before assuming the repo is corrupted.
