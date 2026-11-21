---
name: "deep-dive-explainer"
description: "Use when the user asks for a deep dive, explainer or 'comprendre comment ça marche vraiment' on a technical topic, delivered as a researched, illustrated multi-part artifact series."
---

# Deep dive explainer

Goal: after reading, the user (an experienced SRE/engineer) has almost no questions left. They understand the mechanism, the trade-offs, the common failures, the market, and what is coming next. Write in the user's language (French by default for this user).

Style, structure and voice are fixed by `references/house-style.md` (the "Sous le capot" series the user rated as the target). Build pages from `assets/part-skeleton.html` + `assets/series.css` (+ `assets/components-extra.css` for org cards, classifier, labs, incident chains, horizon columns). Do not ask the user about format: it is that series.

## 1. Frame before building (always, first reply)

0. Scope the topic as a **field, not a project**. When the user names a tool or a pain from their own infra, treat it as the running example, never as the frame. The plan must map the whole domain (techniques, processes, organisations, tools, emerging categories) so the answer would still make sense if the named tool did not exist. The user's own case gets one short chapter at the end.
1. Read any existing artifact or doc the user points to, and note exactly what it explains badly (usually: says WHAT, not HOW or WHY).
2. Check how references structure the topic: book tables of contents (O'Reilly, Manning), official docs, well-known blog series, conference talks (KubeCon…), recent "year in review" posts. List themes the user did not mention but that experts consider essential.
3. Propose a plan: parts → chapters, with a one-line goal each. Map each element of the user's request to a chapter, and mark added chapters as *(nouveau)* with why.
4. Ask at most 2-3 questions, each with a default in parentheses (format: one artifact or one per part; length; depth of secondary topics). Say "réponds go" to accept defaults.
5. Always plan these recurring elements (the user values them):
   - a **running example** followed from start to finish;
   - **trade-offs** everywhere (gain / prix), plus a final **carte des trade-offs**;
   - **pannes réelles**: public post-mortems and recurring failure patterns, with the lesson;
   - a **« Cutting edge et horizon »** section (see §4).

## 2. Research

- Research in two waves before proposing the final plan. Wave 1 maps the domain. Wave 2, after the user sees the plan, goes wide on: niche practices that are little known but useful, first-hand accounts from large organisations (what they changed, what broke, what they refused to do, where they converge and disagree), and the community pulse (HN, Reddit, GitHub stars and release dates, talks, Thoughtworks Radar). Run the waves as parallel subagents with narrow briefs, and send any thin report back for a second pass.
- Recency: the user considers anything older than about 6 months as old in fast-moving fields. Prioritise the last 6 months, tag every older source with its date, and keep it only as the origin of an idea still alive.
- Verify maturity with data, not adjectives: stars, last release and date (GitHub API), CNCF level, named production users.
- Look up anything that describes the world now (versions, prices, companies, adoption, acquisitions) with web search, even if it feels known. Use the current date in queries.
- Prefer primary sources: official docs, design docs, changelogs, papers, post-mortems, SEC filings, the author's own blog.
- For every headline number ("7× faster", "10× less RAM"): find who measured, when, which versions, which workload, what is counted. Flag vendor-run or sponsored benchmarks and surveys. Say when a newer version changes the picture. If no independent recent data exists, say so and label your own estimate as an estimate.
- Verify internals at the level of data structures: what lives in RAM vs disk, file layout, encodings, flush intervals, flags. Run small computations yourself (e.g. bit patterns, formulas) rather than asserting them.
- Keep a source list per part; end every part with it, and give a "Sources:" list in chat.

## 3. Pedagogy (per chapter)

- Order: the problem → the naive solution → why it breaks → the real solution → what it costs.
- Define every term before its first use; a filterable glossary in part I; a "Vocabulaire" box where new terms cluster.
- Callout boxes, used consistently: **Modèle mental** (one sentence to remember), **Trade-off** (Ce qu'on gagne / Ce qu'on paie), **Piège classique** (concrete misuse + fix), **Vocabulaire**.
- Comparisons "X vs Y" as decision cards: question → how X does it → how Y does it → gain → prix.
- One diagram per mechanism that prose would make the reader assemble (data flow, before/after, lifecycle, index lookup). Label arrows. Caption states the claim.
- Interactive pieces where manipulating builds intuition: calculators (cardinality, SLO burn rate, TCO with user-entered prices, never invented vendor prices), labs (compression bit by bit), toys (index lookup with selectors). Open them in a realistic example state.
- Each part ends with a short quiz (answer + explanation), a teaser of the next part, and sources.
- Stories: for each real incident give date, duration, causal chain (as chips A → B → C), what happened, the lesson. Follow with a table of recurring failures (symptôme / cause / prévention) and a checklist.

## 4. Cutting edge et horizon (dedicated section, last part or end of each part)

Purpose: show what is new and what is coming, not just the standard.

- **Cutting edge now**: technologies that are real but not yet mainstream (e.g. eBPF-based collection, Cilium/Hubble, OTel profiles, new storage formats, AI agents). For each: what it is in 2 sentences, the mechanism that makes it a game changer, maturity signal (version 0.x/1.x, CNCF sandbox/incubating/graduated, who runs it in prod), and "à essayer si…".
- **Petites notes « ça existe »**: a compact list of names worth knowing, one line each, with a link.
- **Horizon**: 1-2 ans / 3-5 ans / plus loin. For each, the trend, the evidence today (funding, adoption, standards, papers), and an explicit confidence level (forte / moyenne / spéculative). Keep fact and speculation visibly separate.
- Research this with searches on recent releases, CNCF landscape/TOC moves, conference keynotes, papers and funding news from the last 12 months.

## 5. Building the artifacts

- Follow `references/house-style.md` for voice, page structure and components. Copy `assets/series.css` into every part unchanged except the accent colour.
- Run Artifact `quickstart` (intent "other") once; build hand-written HTML pages (explainer, interactive), one per part when the content exceeds ~1 h of reading.
- Design system shared by all parts (write it once, reuse the same `<style>`):
  - tokens on `:root` + dark mode blocks; teal accent, amber warning, red danger, violet trade-off; grey neutrals tinted toward the accent;
  - fonts: Bricolage Grotesque (display), Literata (body, long reading), JetBrains Mono (code, labels);
  - sticky top bar with links to all parts; sticky chapter rail on wide screens, `<details>` TOC on mobile; reading column ~720px with wide breakouts for figures and tables;
  - big chapter numbers, eyebrow with "Partie X sur N · lecture ≈ N min";
  - a hero that opens with the most characteristic artifact of the subject (the specimen line, the key number).
- SVG diagrams inline, viewBox-scaled, colors via CSS classes bound to tokens, `role="img"` + aria-label, wide ones in an `overflow-x:auto` box with a min-width.
- Copy rules: short direct sentences, no em-dash asides, no "not X but Y", numbers always with source and context.
- Check once before publishing: render desktop light and phone dark with Playwright, look at cropped screenshots, fix overlapping SVG labels and orphaned grid items, check zero horizontal overflow and no console errors. Then publish.
- Publish part by part and tell the user each time (SendUserMessage) so they can start reading. After the last part, replace "bientôt" placeholders with real cross-links in every part and republish.

## 6. Finish

In chat: the direct answer to the user's original question in a few lines, what each part contains (one line each), one natural next step, and sources. Do not recap the process.