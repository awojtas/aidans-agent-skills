---
name: idea-initial-sketch
description: Turns a vague app idea line item into an initial product sketch with research grounding. Use when the user gives a rough app idea and wants it fleshed out before formal requirements. Forms an initial interpretation, asks concise clarification questions including target platform unless already clear, uses background agents for competitor/substitute research, real user complaint and pain-signal research, and app-name conflict checks, asks any follow-up questions created by the research, then produces a 1-2 page markdown sketch, a 2-3 sentence restart summary, and a candidate app name that does not obviously conflict with an existing product.
---

Creates a lightweight, research-informed product sketch from a vague app idea. This is **pre-requirements**: enough to decide whether the idea has a credible wedge and to seed a later requirements brief, not enough to specify the product.

## When to use this skill vs others

- **Vague app idea, needs shaping and validation?** This skill.
- **User already has a solution design and wants engineering framing?** Use `/solution-design`.
- **User wants formal requirements from a design?** Use `/requirements-create-from-design`.
- **User only wants a quick snappy brief without research?** Do a short product brief instead of this full workflow.

## Workflow

1. **Capture the raw idea.** Preserve the user's wording. If it includes tags like `#mobilewebsite`, `#macosnativeapp`, or `#lightroom`, treat those as platform/context hints.

2. **Create the first interpretation.** In 3-6 bullets, state what the app might be:
   - the user/job-to-be-done
   - the likely platform(s)
   - the core workflow
   - the obvious value proposition
   - the riskiest assumption

3. **Ask first clarification questions.** Ask only what is needed before research. Always clarify platform unless the user clearly provided it. Prefer 3-6 focused questions, covering:
   - target user and situation
   - target platform(s)
   - input/output workflow
   - whether this is a standalone app, plugin, website, or companion tool
   - whether the user expects paid, free, internal, or open-source use

4. **Launch background research agents.** If background/sub-agents are available, run research in parallel instead of doing it all in the main thread. Keep the main thread responsible for synthesis and user interaction. Use three bounded research tasks:

   - **Market researcher** — direct competitors, adjacent substitutes, manual workarounds, platform-native features, pricing, reviews, positioning, and feature gaps.
   - **Pain researcher** — complaints, forum threads, Reddit posts, app-store reviews, support communities, workflow discussions, and evidence that people pay or spend time to solve the problem.
   - **Naming researcher** — exact and close-variant name conflicts across app stores, web search, domains, GitHub, and close competitors.

   Give each agent the raw idea, the current interpretation, any clarified platform/user constraints, and a request for concise findings with links. Do not ask agents to write the final sketch.

5. **Research the market.** Use the market research agent's output, plus any quick main-thread checks needed to resolve contradictions. Look for:
   - direct competitors
   - adjacent substitutes and manual workarounds
   - platform-native features that already solve part of it
   - pricing, reviews, positioning, and feature gaps
   - whether the proposed name or close variants already exist

6. **Research pain signals.** Use the pain research agent's output, plus any quick main-thread checks needed to resolve contradictions. Search for complaints, forum threads, reviews, Reddit posts, app-store reviews, support tickets, blog posts, and workflow discussions. The goal is to decide whether the idea solves a real pain or is just a nice-to-have. Look for:
   - repeated frustration
   - paid workaround behaviour
   - time-consuming manual workflows
   - risk, money loss, missed outcomes, or professional pain
   - users explicitly asking for the capability

7. **Check naming conflicts.** Use the naming research agent's findings before proposing a candidate name. If the initial best name is already used by a close competitor or a confusing adjacent product, choose another name and mention the conflict briefly.

8. **Synthesize the wedge.** Identify:
   - what existing options do well
   - what they do poorly or omit
   - the strongest unique selling proposition
   - the likely buyer/user segment
   - why someone would switch, pay, or adopt it
   - any reason the idea may not be worth building

9. **Ask second clarification questions.** Research often changes the shape of the idea. Ask concise follow-ups only for decisions that materially affect the sketch, such as:
   - choosing between two viable product shapes
   - narrowing the target segment
   - deciding whether to compete directly or become a companion/workflow layer
   - confirming monetisation or distribution constraints

10. **Generate the outputs.**

## Output format

Produce three outputs.

### 1. Initial Sketch Markdown

Write a 1-2 page markdown document with these sections:

```markdown
# <Candidate App Name>

## Raw Idea
<One short quote/paraphrase of the user's original line item.>

## Product Shape
<What the app is, who it is for, and the core workflow.>

## Target Users
<Primary and secondary users.>

## Problem And Pain
<The pain this solves, including evidence from research. Be clear if the pain signal is weak.>

## Existing Options
<Competitors, substitutes, and current workarounds with links.>

## USP
<Why this app would be used instead of existing options.>

## Core Capabilities
<5-8 capability-level bullets. Avoid formal requirement language.>

## Platform And Distribution
<Likely platform, install/distribution path, and key platform constraints.>

## Monetisation Fit
<Whether users might pay and why. State uncertainty.>

## Risks And Open Questions
<The hard parts, weak assumptions, and decisions still needing owner input.>

## Research Sources
<Short source list with links.>
```

### 2. Restart Summary

Write a 2-3 sentence summary that can restart a future conversation. It should name the app concept, user, platform, key workflow, and USP.

### 3. Candidate Name

Suggest one app name and briefly explain why it fits. Before naming, search the web for obvious conflicts. If conflicts exist, pick a different name or state the risk.

## Research guidance

- Prefer current, primary, or near-primary sources: official app sites, app stores, documentation, product pages, public issue trackers, forums, Reddit, support communities, and review pages.
- Cite sources with links in the final sketch.
- Do not overclaim from thin evidence. Label inferences clearly.
- For naming, search exact name plus category terms. Avoid names already used by a close competitor in the same space.
- Treat background-agent findings as inputs, not final truth. The main agent must reconcile conflicts, discard weak evidence, and cite only sources it is comfortable standing behind.
- If background agents are not available, do the same research sequentially in the main thread and state that limitation if relevant.

## Guardrails

- **Do not jump straight to requirements.** Stay at concept and brief level.
- **Do not pretend research is complete.** This is quick validation, not a market study.
- **Do not ask broad brainstorming questions.** Ask only decisions that change the product shape.
- **Do not bury a weak pain signal.** If people are not complaining or paying for workarounds, say so.
- **Do not copy competitor wording.** Summarise and cite.
- **Do not output more than 2 pages for the sketch unless the user explicitly asks for depth.**

## Final response to user

After producing the outputs, end with:

- the strongest reason to continue
- the strongest reason to pause or narrow the idea
- the best next step, usually turning the sketch into a succinct requirements brief or running a deeper validation pass
