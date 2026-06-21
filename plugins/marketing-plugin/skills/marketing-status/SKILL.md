---
name: marketing-status
description: 'Read where an app is in the marketing lifecycle and recommend the next concrete step. Scans the app''s profile, docs/marketing/ outputs, GitHub issues, and the growth tracker; flags unfinished or incongruous outputs; recommends the next skill (or re-running a prior one); and rebuilds the lifecycle tracker. The "I don''t know what to do next" orchestrator. Use when the user says "marketing status", "where am I with marketing", "what''s next", or feels lost in the process.'
---

# Marketing status / what's next

The orchestrator for the bundle, mirroring how an SDLC status skill works. For the "I'm not sure where I am" moment.

## When to use

Any time, to get oriented and get a recommended next action.

## Process

1. **Scan state:**
   - `docs/marketing/profile.md` (exists? complete?)
   - `docs/marketing/` outputs (research, positioning, plan, copy — present? finished, or stub/incongruous?)
   - the growth tracker (is it being filled?)
   - relevant GitHub issues (readiness gaps open/closed?)
   - the lifecycle tracker block
2. **Determine the current phase** from `../../shared/marketing-lifecycle.md` — which steps are done, in progress, not started.
3. **Spot problems:** a phase whose output looks unfinished or contradicts a later one; readiness gaps still open before a planned launch; a stale profile.
4. **Recommend one next step** — the next skill to run, or a prior one to re-run if its output is thin. Be concrete.
5. **Rebuild the lifecycle tracker** block from the scan.

## Output

A short "you are here → do this next" with the lifecycle tracker refreshed. No destructive changes; it reads and recommends.
