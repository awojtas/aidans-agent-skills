# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that give it new tricks for common dev work.

## Getting started

Open Claude Code and run:

```
/plugin marketplace add awojtas/aidans-agent-skills
```

Then open `/marketplace` again, navigate to "Aidan's Agent Skills", and pick which plugins you want to install. Close and re-open Claude Code afterwards (skills don't hot-reload).

Plugins live under [`plugins/`](./plugins/) — browse the directory to see what's available. The marketplace browser shows each plugin's description and contents at install time; once installed, Claude Code auto-triggers the right skill based on what you ask for.

## Structure

- [`plugins/`](./plugins/) — the plugin bundles. Each `<name>-plugin/` directory has its own `plugin.json` and `skills/` subdirectory.
- [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) — the canonical registry of plugins exposed to the marketplace.
- [`.github/`](./.github/) — GitHub-side config (Copilot instructions, CI workflows).
- [`scripts/`](./scripts/) — utility scripts. See [`AGENTS.md`](./AGENTS.md) § *Background tooling* for the auto-commit script that may produce surprising commits in your local log.
- [`AGENTS.md`](./AGENTS.md) — the authoring guide for adding plugins, skills, and reference docs. Read this first if you're contributing.
- [`CLAUDE.md`](./CLAUDE.md) — Claude Code project context. Imports `AGENTS.md` so Claude sees the authoring guide.

## Contributing

Want to add a skill? Point your AI coding agent at this repo and tell it what you want to build. The [AGENTS.md](AGENTS.md) file has the full walkthrough — the agent can handle the scaffolding, file structure, and marketplace registration on its own.
