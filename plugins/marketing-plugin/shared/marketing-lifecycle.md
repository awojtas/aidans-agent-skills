# Marketing lifecycle

The skills compose into a loop, not a one-way line. Research feeds the plan; metrics feed the next round of research. `marketing-status` reads where an app is and recommends the next step.

## The phases

1. **init** (`marketing-init`) — onboard the app: scaffold `docs/marketing/`, write `profile.md`, create the Drive folder from templates. Run once per app.
2. **readiness** (`marketing-readiness`) — is the app even ready to market? (live, onboarding, analytics, signup, pricing, OG tags, legal basics). Output: punch-list + issues. Nothing public ships until the essentials pass.
3. **research** (`marketing-research`) — ICP, where they gather, their exact language, competitor pain.
4. **positioning** (`marketing-positioning`) — the wedge, the enemy, the proof. Upstream of all copy.
5. **plan** (`marketing-plan`) — channels, budget, funnel, targets, calibrated to the profile's constraints.
6. **assets** (`marketing-assets`) — copy + visual specs + listings + launch kit.
7. **launch** (`marketing-launch`) — per-channel runbooks. Prepare-only for anything public.
8. **metrics** (`marketing-metrics`) — funnel + tracker ROI + periodic engagement pulls.
9. **followup** (`marketing-followup`) — the steady weekly engine, retros, double-down calls; recycle into research.

## The stages

The stage labels used in the tracker — exact strings that must match across all skills.

| Stage label | Owning skill |
|---|---|
| Init | `marketing-init` |
| Readiness | `marketing-readiness` |
| Research | `marketing-research` |
| Positioning | `marketing-positioning` |
| Plan | `marketing-plan` |
| Assets | `marketing-assets` |
| Launch | `marketing-launch` |
| Metrics | `marketing-metrics` |
| Follow-up | `marketing-followup` |

## Lifecycle tracker

The tracker lives at the **very bottom of the acted-on repo's `README.md`** — not in `docs/marketing/`. Each staged skill updates its own line as it runs; `marketing-status` rebuilds the whole block from a repo scan.

### The block

```markdown
<!-- marketing-lifecycle:start -->
## Marketing progress

- ⬜ Init — `marketing-init`
- ⬜ Readiness — `marketing-readiness`
- ⬜ Research — `marketing-research`
- ⬜ Positioning — `marketing-positioning`
- ⬜ Plan — `marketing-plan`
- ⬜ Assets — `marketing-assets`
- ⬜ Launch — `marketing-launch`
- ⬜ Metrics — `marketing-metrics`
- 🔁 Follow-up — `marketing-followup` (ongoing)

✅ done · ⏳ in progress · ⬜ not started · 🔁 recurring — maintained by the marketing-plugin skills.
<!-- marketing-lifecycle:end -->
```

The two `<!-- marketing-lifecycle:… -->` comment lines are the anchors. Never remove them — they are how every skill finds the block on the next run.

### Create-or-update algorithm

Target: `README.md` in the **root of the repo being acted on** (not the plugin repo).

1. **No `README.md`** → create it: an H1 with the repo/project name, a blank line, then the block — every stage ⬜ except any this run sets otherwise.
2. **`README.md` exists, no `<!-- marketing-lifecycle:start -->`** → append the block at the very bottom, preceded by one blank line. Every stage ⬜ except any this run sets.
3. **Block already present** → replace the content between the comment anchors in place; leave the block where it sits.

### A staged skill updates one line

A lifecycle skill touches **only its own stage's line**:

- When it begins its substantive work (after prerequisites pass) → set its line's emoji to ⏳.
- On successful completion → set its line's emoji to ✅ (or back to 🔁 for `Follow-up`, which is recurring and never permanently done).
- Every other line is left exactly as found. Never downgrade or re-evaluate another stage.

Writing the file is the requirement. Committing follows the skill's normal behaviour — if the skill already commits its other outputs, include `README.md` in that commit; if it makes no commits, leave the tracker edit as an unstaged working-tree change.

### `marketing-status` rebuilds every line

`marketing-status` already scans the full `docs/marketing/` state, so it has evidence for every stage. It writes **every** stage line from that scan, then stages only `README.md`, commits `docs: update marketing lifecycle tracker`, and pushes. If the block already matches the scan, it skips the commit. This makes `marketing-status` the way to reconcile the tracker when skills ran out of order or before the tracker existed.

## Scaling to the constraints

Read `profile.md` constraints and scale effort. 30 min/week + tiny budget ⇒ heavy automation, batched assets, a few high-leverage one-off launches, prepare-only. More time/budget ⇒ more channels, more frequent content, paid experiments. Never prescribe a daily-grind plan to someone who told you they have 30 minutes.
