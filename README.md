# Aidan's Agent Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that extend its capabilities for common development tasks.

## Using with Claude Code

1. Open Claude Code
2. Run:
   ```
   /plugin marketplace add awojtas/aidans-agent-skills
   ```

## Skills

### Build Fixer (`/build-fixer`)

Iteratively fixes build errors and lint warnings until your project compiles cleanly.

**Supported ecosystems:** .NET, Node.js (npm/pnpm/yarn/bun), Rust, Go, Java (gradle/maven), Make, and more.

**What it does:**

- Auto-detects your build command from project files
- Runs the build, classifies errors as fixable vs. environment-level
- Fixes code errors in a loop (type errors, syntax issues, unused variables, etc.)
- Stops when the build passes or no more progress can be made
- Reports results with troubleshooting suggestions for any remaining issues

**Trigger it** by asking Claude to fix build errors, resolve compilation failures, or clean up lint warnings — or just paste your build output.
