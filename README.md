# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that give it new tricks for common dev work.

## Getting started

Open Claude Code and run:

```
/plugin marketplace add awojtas/aidans-agent-skills
```

Then open `/marketplace` again, navigate to "Aidan's Agent Skills", and pick which plugins you want to install. Close and re-open Claude Code afterwards (skills don't hot-reload).

Plugins live under [`plugins/`](./plugins/) — browse the directory to see what's available. The marketplace browser shows each plugin's description and contents at install time; once installed, Claude Code auto-triggers the right skill based on what you ask for.

## Contributing

Want to add a skill? Point your AI coding agent at this repo and tell it what you want to build. The [AGENTS.md](AGENTS.md) file has the full walkthrough — the agent can handle the scaffolding, file structure, and marketplace registration on its own.
