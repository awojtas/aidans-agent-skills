# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that give it new tricks for common dev work.

## Getting started

Open Claude Code and run:

```
/plugin marketplace add awojtas/aidans-agent-skills
```

After that, open `/marketplace` again, navigate to "Aidan's Agent Skills", and pick which plugins you want to install. Close and re-open Claude Code afterwards (skills don't hot-reload).

## Plugins

| Plugin | What it does |
|--------|--------------|
| [`sdlc-plugin`](./plugins/sdlc-plugin/) | 21 skills for the full Software Development Lifecycle — bootstrap → solution design → platform stand-up → requirements → backlog planning → implementation, plus ad-hoc helpers for status, audit, backlog and production triage, and dev-loop fixes. |
| [`content-plugin`](./plugins/content-plugin/) | 2 skills for prose: humanise AI-sounding text and migrate Teams chats to Confluence pages. |
| [`design-system-aurora-plugin`](./plugins/design-system-aurora-plugin/) | The Glass Aurora design system — glassmorphism, aurora gradients, neon glows, purple-cyan palette. |

Individual skills are documented in their own `SKILL.md` files under each plugin's `skills/` folder. Once a plugin is installed, Claude Code auto-triggers the right skill based on what you ask for — no need to invoke by name, though every skill has a `/<slug>` slash command if you want to be explicit.

## Contributing

Want to add a skill? Point your AI coding agent at this repo and tell it what you want to build. The [AGENTS.md](AGENTS.md) file has the full walkthrough — the agent can handle the scaffolding, file structure, and marketplace registration on its own.
