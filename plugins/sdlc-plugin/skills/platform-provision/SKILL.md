---
name: platform-provision
description: Provisions the runtime / cloud platforms an application needs to actually run and deploy — hosting providers, observability services, databases, auth providers, email senders, queues, anything the architecture names. Reads docs/architecture/ to inventory what needs to exist, then uses every channel available (connected MCP servers, installed CLIs, HTTP APIs) to stand it all up. Batches the bits only a human can do (sign-ups, billing, copying secrets out of dashboards) into a single checklist, then wires the resulting secrets into GitHub Actions and the platforms' env stores. Trigger phrases include "provision the platform", "stand up the stack", "set up the infrastructure", "wire up the cloud services", "spin up the runtime", "create the cloud resources", "bootstrap the platform".
---

Provisions the external platforms and services described in `docs/architecture/` and wires the resulting secrets into GitHub.

## What this skill does

Reads the architecture, works out what cloud platforms / SaaS products / observability tools / DBs / etc. need to exist, then uses whatever channels are available to create them. Anything a human has to do personally (sign up, pay, click through OAuth, copy a secret out of a UI) is batched into one checklist instead of dripped out one prompt at a time.

## Workflow

1. **Read `docs/architecture/`.** If it doesn't exist, stop and tell the user to run `/platform-design` first — provisioning without a recorded architecture is guessing.

2. **Inventory what needs to be provisioned.** Walk the architecture and list every external thing the system depends on to run, deploy, observe, or persist. Hosting, observability, databases, auth, email, queues, AI providers, CDN, analytics, search — anything. Don't restrict to a fixed catalogue: anything the architecture names is in scope.

3. **For each item, work out how to interact with it. Go and try.** Investigate every available channel:
   - Is there an **MCP server** connected that covers this platform? Check the tools available in the current session.
   - Is the platform's **CLI** installed locally and authenticated?
   - Is there an **HTTP API + a token** you can drive via WebFetch?

   Be assertive about trying. Don't bail because the first channel returns 401 — try a second. If nothing works, surface the platform as a human task in the checklist below.

4. **Provision what you can autonomously.** Create the project / org / dashboard / DB / whatever. Capture every output the human will care about later: resource IDs, regions, URLs, DSNs, project tokens, organization slugs. Record them as you go.

5. **Batch the human-only bits into a single checklist, and file it as a GitHub issue.** Some things are inherently human:
   - Creating an account in a new SaaS product
   - Agreeing to ToS or choosing a billing plan
   - OAuth / device-code flows
   - Copying a generated secret out of a UI that doesn't expose it via API

   Group them into a single checkbox checklist and **create a GitHub issue** in the repo via `gh issue create` — title `"Provisioning checklist — sign up for v1 platforms and bring back tokens"`, body as a Markdown task list (`- [ ]`) with one section per platform. Each item must name the exact dashboard URL, the exact page/field, and the exact env var name to bring back. Close the issue body with a fenced code block listing every env-var name the user is expected to paste back, so they have a single place to fill in. Show the issue URL to the user and have them work through it at their pace. Don't drip prompts in chat — the issue is the durable surface for the slow path.

   If the repo has no GitHub remote (rare — this skill normally runs after `/repo-bootstrap`), fall back to printing the checklist in chat and tell the user it would normally be a GitHub issue.

6. **Wire secrets in once the human returns.** When the human pastes secrets back:
   - GitHub Actions: `gh secret set <NAME>` (repo-level), or `gh secret set <NAME> --env <env>` for env-scoped.
   - Platform env vars: via that platform's MCP/CLI (e.g., its env-setting command for the deployed runtime).
   - Repo: append the variable name to a `.env.example` with a one-line comment explaining what it's for. **Never write the value into a file or commit.**

7. **Record what was done.** Append (or create) `docs/architecture/provisioning-log.md`:
   - Date, what got provisioned, which platform, IDs / URLs / regions.
   - Which secrets exist now, where they live (GH Actions repo vs env, platform env stores).
   - Which human-required tasks are still outstanding, if any.
   - A link to the provisioning-checklist GH issue created in Step 5, and whether it's still open. Close the issue (or note the remaining items inline) once provisioning is complete.

   This is the bridge between the architecture doc and the actual state of the cloud. Future skills (`/task-implement`, `/requirements-rework`, debugging sessions) read this to know what's real.

## Guardrails

- **Never write a secret value into any file, commit, or PR comment.** Secret stores only.
- **Don't invent integrations.** If the architecture doesn't name observability, don't add Sentry just because it's popular. Ask the user first.
- **Ask for tokens up front, not on first failure.** If you'll need tokens for several platforms, enumerate them and ask in one go.
- **One or two tries per channel, then move on.** Don't loop on a 4xx — surface it. The human can debug auth faster than you can.
- **If the architecture is vague** ("we need a database") **pause and ask the human to pick a specific service** before provisioning. You don't get to choose the architecture.

## Output

- `docs/architecture/provisioning-log.md` (created or appended).
- GitHub Actions secrets set for every value the deployed system will need.
- `.env.example` updated with the variable names (no values).
- A final report to the user: what was provisioned, what's still pending and why, and any access / billing questions still open.

## Lifecycle tracker

This skill owns the **Platform provisioned** stage of the SDLC lifecycle tracker kept at the bottom of the acted-on repo's `README.md`. See [`../../shared/lifecycle-tracker.md`](../../shared/lifecycle-tracker.md) for the block format, emoji legend, and create-or-update algorithm.

- **When this skill begins its substantive work** (after prerequisites pass), set the `Platform provisioned` line in the tracker to ⏳ (in progress). Create `README.md` and/or the tracker block first if either is missing.
- **When this skill completes successfully**, set the `Platform provisioned` line to ✅ (done).

Touch only the `Platform provisioned` line — leave every other stage exactly as found.
