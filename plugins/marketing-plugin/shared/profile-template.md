# Marketing profile (per-app)

`marketing-init` writes this to `docs/marketing/profile.md` in the **app's own repo**. Every other skill reads it first to know which app it's working on, what the constraints are, and which tools are wired up. Keep it short and current — it's the single source of truth the skills key off.

The YAML frontmatter holds the structured fields skills parse; the prose below holds nuance for a human.

```yaml
---
app_name: <App>
one_liner: <the positioning sentence — what it is, who it's for, the wedge>
stage: <pre-launch | beta | launched>
lifecycle_phase: <readiness | research | positioning | plan | assets | launch | metrics | followup>

domains:
  marketing: <app.example.com>      # canonical marketing site (apex)
  app: <app.app.example.com>        # the product behind auth
  company: <company-site, if any>

drive_folder: <Drive path or folder id for living docs, e.g. Projects/<App>>

audience:
  icp: <who exactly — role, company size, context>
  where: [<subreddits>, <LinkedIn>, <communities>, <directories>]

competitors: [<named alternatives users actually compare against>]

constraints:
  time_per_week: <e.g. 30 min>
  budget: <e.g. NZ$50 total>
  visibility: <faceless brand-led | mix | build-in-public>

tooling:                            # declared here, NOT hardcoded in skills — swap freely
  listening: <e.g. apify>
  product_analytics: <e.g. posthog>
  images: <e.g. gemini + photoshop>
  email: <e.g. loops | mailerlite | resend | none-yet>
  scheduler: <e.g. buffer | typefully | none-yet>

links:                             # filled in as they exist
  growth_tracker: <Drive URL>
  landing_copy: docs/marketing/copy-landing-and-pricing.md
  research: docs/marketing/research-findings.md
---
```

## Notes (prose)

- What makes this app non-obvious, who it is really for, what you have learned that changes the plan.
- Anything a skill should know but that does not fit a field above.

> Never put secrets in this file (it lives in the repo). Tokens/keys go in the environment or a local file outside the repo — see `shared/tooling.md`.
