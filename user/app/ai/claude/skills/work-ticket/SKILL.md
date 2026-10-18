---
name: work-ticket
description: Write tickets a project manager or tech lead can act on, for Jira, Linear, Trello, Notion or GitHub issues. Covers forward tickets (work to do), retro tickets (work already done, reconstructed from commits/PRs) and bugs. Use when the user asks to write, draft, rewrite or backfill tickets/issues/cards, or to turn commits, PRs or notes into tickets. Drafts first, never creates in the tracker without approval.
---

# Work Ticket

A ticket is read by three people: the PM scanning a board, the tech lead deciding what depends on it, and someone in six months searching history. Write for all three in that order: the title serves the scanner, the first paragraph the lead, the rest the archaeologist.

## Principles

1. **Title = what, imperative, scannable.** "Add a Security tab to the CMP", not "Security" or "Phase 1". Under ~80 chars. No user-story phrasing ("As a…") in the title. Sources: Google eng-practices CL descriptions, Linear Method.
2. **Why before what.** First paragraph states the problem or need, in terms the PM understands. Source: GitLab "Problem to solve", Google "why".
3. **Write only what someone will use.** Every section must help someone decide, verify, or find something later. Delete sections that would be filler. Source: Linear Method ("write only as much as you need").
4. **State shortcomings.** Limitations, known gaps, and follow-ups are the highest-value lines for a lead. Never omit them to look finished. Source: Google eng-practices.
5. **Verifiable done.** Acceptance criteria are observable outcomes, as a checklist or Given/When/Then. For retro tickets, write "How to verify" instead: where to click or what to run to see it working. Source: Atlassian acceptance criteria / Definition of Done.
6. **Self-contained, then linked.** Enough context in the ticket that it reads without opening links, plus links for depth. Source: Google eng-practices.
7. **Dependencies are links, not prose.** Use the tracker's issue links (relates to, blocks / is blocked by, parent epic) so they show up on boards and in dependency views. Mention the key inline too when it explains the text ("consumes the scan reports from CNP-120").
8. **Only real personas.** List impacted users (dev, project admin, platform admin, security, finance…) only where the impact is concrete. A forced persona line erodes trust in the others. Source: GitLab "Intended users".
9. **Label with the team's taxonomy, never a new one.** Before labelling, list the labels already used in the project and reuse them, matching their spelling and language. Typical axes: team or pole, sprint or iteration, and 1-3 domains (security, observability, frontend…). A new label only when no existing one fits, and say so to the user. Labels are what PMs filter boards by, so an invented synonym (`secu` next to `securite`) hides the ticket.

## Templates

Default language: English. Use the tracker's markdown; keep headings as bold lines if the tracker renders headings too large.

### Retro ticket (work done, for PM / tech lead)

```
**Title**: <Imperative verb> <specific outcome>
Type: Task|Story · Parent: <epic> · Status: Review (the PM or tech lead moves it to Done)
Labels: <team>, <sprint>, <domain>[, <domain>] (from the project's existing labels)
Links: relates to <KEY>, is blocked by <KEY>, blocks <KEY>

**Why**
<1-3 sentences: the problem or need, and what triggered it.>

**What changed**
- <Capability now available, phrased as behaviour, not implementation.>
- <Inputs it consumes → outputs it produces, if it is a pipeline step. Name the ticket that produces each input.>

**Who benefits**
- <Persona>: <concrete thing they can now do or no longer need to do.>

**How to verify**
- [ ] <Observable check: page, command, alert, metric.>

**Limitations / follow-ups**
- <Known gap, shortcut taken, or deferred work, with the follow-up ticket key if one exists.>

**Unlocks** (optional)
- <Feature or ticket now possible because of this.>

**References**
- PRs: <repo#n, repo#n> (full URLs if the tracker has no dev integration)
- Docs: <link>
```

### Forward ticket (work to do)

Same as above, replacing "What changed" with **Scope** (in / explicitly out), "How to verify" with **Acceptance criteria**, and adding **Open questions** and **Decision needed from <role>** when relevant. Keep "Limitations" as **Risks**.

### Bug

Title states the symptom and where ("Frontend crashes when it starts before the backend"). Body: **Observed**, **Expected**, **Steps to reproduce**, **Environment/version**, **Impact** (who is blocked, workaround), **Suspected cause** only if verified.

## Workflow

1. **Gather facts.** For retro tickets: read the git log over the period (author filter, all branches, no merges), group commits into features by outcome, not by repo. Read the tracker to find existing tickets to update or link instead of duplicating, and collect the label taxonomy in use (count per label, which labels the user's own tickets carry). Note PR numbers.
2. **Propose the split** as a short list: one ticket per feature that a PM would recognise, with parent epic and links between them. Pipeline stages that another feature consumes get their own ticket so the consumer can link to them.
3. **Draft one example ticket** and get the format validated before writing the rest.
4. **Draft all tickets**, run the checklist below on each, show them.
5. **Create in the tracker only after explicit approval.** Then add issue links (they are separate API calls in Jira: `createIssueLink`), and remote/web links for PRs if no dev integration exists.

## Checklist before showing a ticket

- Title readable alone on a board, imperative, no jargon the PM doesn't share.
- First paragraph answers "why does this exist" without scrolling.
- Every input/dependency names the ticket that provides it, and that link exists as a tracker link.
- At least one verification step a non-author can perform.
- Limitations section present, or deliberately empty because there are none.
- Labels cover team, sprint and domain, all taken from labels already in the project.
- No secrets, internal hostnames with credentials, tokens, or kubeconfigs.
- Fits on one screen. If not, split the ticket or move detail to a linked doc.

## Tracker notes

- **Jira**: issue keys typed in text auto-link. PRs and commits appear in the Development panel only when the issue key is in the branch name, commit message or PR title (GitHub for Jira app); for retro tickets add PR URLs under References or as web links. Smart commits can comment/transition but cannot create issue links. Through the Atlassian MCP markdown converter, a `- [ ]` item containing inline code renders as an escaped bullet: keep checklist lines free of backticks. Set the epic with `additional_fields: {"parent": {"key": "<EPIC>"}}`, then transition after creation.
- **Linear**: titles carry the weight; description optional. Use relations (blocks/related) and attach PRs via the GitHub integration (key in branch name).
- **Trello**: title on the card, body in the description, dependencies as attached card links, acceptance criteria as a checklist.
- **Notion**: one page per ticket in a database; dependencies as a relation property, not text.

---

## Sources

- Google eng-practices, Writing good CL descriptions: https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- Linear Method, Write issues not user stories: https://linear.app/method/write-issues-not-user-stories
- Atlassian, Acceptance criteria: https://www.atlassian.com/work-management/project-management/acceptance-criteria
- Atlassian, Definition of Done: https://www.atlassian.com/agile/project-management/definition-of-done
- GitLab feature proposal template (Problem to solve / Intended users / Proposal): https://handbook.gitlab.com/handbook/product/product-processes/planning-with-gitlab/
- Anthropic knowledge-work-plugins, stakeholder-update (audience-tailored status): https://github.com/anthropics/knowledge-work-plugins
- openshift-eng/ai-helpers jira plugin (summary anti-patterns, secret scan before create): https://github.com/openshift-eng/ai-helpers
