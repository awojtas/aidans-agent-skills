# AGENTS.md — `content-plugin`

Plugin-specific context for agents working in `plugins/content-plugin/`. The [root AGENTS.md](../../AGENTS.md) carries the repo-wide conventions for adding plugins and skills; this file covers what is distinctive about *this* plugin.

## What this plugin is

Content tooling — two skills:

- **`prose-humanize`** — rewrites AI-flavoured prose to sound authentically human. Pattern-catalogue-driven (vocabulary, punctuation, structure, tone).
- **`teams-to-confluence`** — converts Microsoft Teams chat content into structured Confluence pages.

## Integration assumptions

- **`teams-to-confluence`** assumes an MCP server for Confluence is wired and authenticated in the user's Claude Code environment. The skill does not bootstrap the MCP — it depends on the user having that configured.
- **`prose-humanize`** is content-only — no external integrations.

## Areas of attention

- Prose-quality work is hard to verify mechanically. Trust the skill's pattern catalogue over invented heuristics when editing. If a new pattern is added, it should be a clearly-recognisable AI tell, not a stylistic preference.
- Teams chat content is unstructured and varies per organisation. The `teams-to-confluence` skill should fail gracefully on chat content that doesn't fit common shapes (Q&A, decision threads, status updates) rather than producing low-confidence guesses.
