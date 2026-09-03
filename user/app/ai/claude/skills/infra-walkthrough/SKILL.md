---
name: infra-walkthrough
description: Turns an internal system/infrastructure (already investigated or to be investigated) into an accessible, narrative-driven walkthrough doc that a teammate with zero prior context on this specific part of the stack can actually follow — one concrete story from start to finish, every piece of jargon defined inline the moment it first appears, closing analysis sections (edge cases, trade-offs, how other systems solve the same problem, quick-wins-vs-long-term roadmap), and a recap glossary + component map with external reference links at the end. Use when the user wants to explain or document how an existing internal system actually works, for a team with mixed backgrounds — onboarding docs, internal wiki pages, "how does X actually boot/deploy/route/authenticate" write-ups. Different from tech-debt-audit (finds problems in code) and the sre-research pipeline (compares external tools before a build-vs-buy decision) — this explains something that already exists and already works, for readers who need a real mental model of it, not experts skimming for gaps.
disable-model-invocation: true
---

# Infra Walkthrough

A Claude Code skill that turns "I read a bunch of repos and now understand this system" into a document someone else can actually learn from — not a dump of what was found, organized so a reader with zero context on this specific system can follow it start to finish.

When invoked via `/infra-walkthrough`, follow the protocol below. Everything from here through the `---` divider is the protocol Claude executes. The section after the divider is notes for future-you on why this skill is shaped the way it is.

---

## Why this skill exists

The default failure mode for infra docs written by an LLM (or by an engineer in a hurry) is a **catalog**: "Component A does X. Component B does Y. Component C talks to D via E." Every fact is true, every fact is cited, and a reader with no prior context still can't tell how any of it fits together, in what order things happen, or why any given piece exists at all. That's what happened on the first pass of the PIE boot doc: technically thorough, unreadable for anyone who hadn't already lived in that part of the infra.

This skill forces a different shape: **one concrete story, told in the order it actually happens, with every piece of jargon explained the moment it shows up and never before.**

## Governing principle: one story, not a catalog

Pick ONE concrete, chronological scenario and walk it start to finish. Every component gets introduced at the exact moment it enters that story, in the role it plays *at that moment* — never earlier, never as a disconnected inventory item dropped in because "it's part of the system."

If you already have research/findings from prior exploration, **reorganize them around this narrative** — don't just reformat a component list into prose with connective words. That produces the same catalog with sentences instead of bullets.

## Step 1 — Find the throughline

Before writing anything, identify the ONE scenario that will structure the entire document. State it explicitly in the doc's opening line: *"Ce document suit exactement ce qui se passe quand \<scénario concret\>."*

Reject throughlines that are still abstract. "Comment fonctionne le système X" is not a throughline. "Ce qui se passe entre l'appui sur le bouton power et l'écran de login" is — it has a start, an end, and a causal chain in between.

If the system genuinely has several important entry points (e.g. normal boot vs. first-time enrollment of a new machine), pick the most common/representative one as the spine, and cover the others as short "Variante" call-outs anchored to the chapter where they diverge — never as parallel throughlines competing for the reader's attention.

## Step 2 — Calibrate the reader

Default assumption unless told otherwise by the user: **the reader has general software engineering background (knows what an HTTP request is, what git is, what a database is, what DNS does at a basic level) but has never touched this specific system and does not know its internal jargon, its tool choices, or its internal service names.**

If the intended audience is stated (e.g. "for the whole team" vs. "for other infra people"), calibrate accordingly — but when in doubt, calibrate toward the less specialized reader. It costs a sentence to skip a definition the reader already knew; it costs the whole doc to assume one they didn't.

Never assume the reader knows:
- What an internal service or repo is *for* just because its name sounds familiar
- Domain acronyms, even ones that feel obvious inside the team
- Which of two similarly-named things is which (this matters a lot in infra: `dhcpd` vs `dhcp_kea`, `fleet-manager` the app vs `fleet.pie.cri.epita.fr` the URL, etc.)

## Step 3 — Write chapter by chapter, in the story's actual order

Structure = the chronological/causal steps of the throughline. Not "network layer, then app layer, then OS layer" — that's a catalog wearing a trenchcoat. Order chapters by **when they happen in the story**, even if that means the narrative jumps between repos or between OSI layers, because that is what is actually happening.

Each chapter:
1. Opens with one sentence anchoring where we are in the story (*"À ce stade, le poste a une IP mais pas encore de système d'exploitation."*).
2. Introduces only the terms/components that act at this point — resist the urge to mention something that only becomes relevant three chapters later.
3. Ends with a one-sentence handoff to the next chapter (*"Le firmware réseau a maintenant un binaire iPXE en mémoire — direction chapitre suivant."*).

## Step 4 — Define every term where it first appears (required template)

The first time any jargon term shows up — protocol name, tool name, internal service name, acronym, file format, internal hostname pattern — stop the narrative for a short inline callout using exactly this template. Never define the same term twice; after the first callout, just use the term.

```markdown
> **\<Terme\>** — \<1-2 phrases, langage courant, aucune connaissance préalable supposée\>.
> Ici, concrètement : \<son rôle PRÉCIS dans CE système — jamais une paraphrase du manuel\>.
> Où le trouver : \<repo/serveur/fichier/URL concret, avec chemin exact si possible\>.
```

Add a fourth line only when a genuinely confusable neighbor concept exists:

```markdown
> À ne pas confondre avec : \<terme voisin\> — \<différence en une phrase\>.
```

Rules:
- "Ici, concrètement" must never be interchangeable with the generic definition above it — it has to say what *this* deployment/config actually does, citing the real file or value when one exists (e.g. not "iPXE lets you boot over HTTP" but "ici, c'est le binaire que `pieboot-0` sert par TFTP avant de rediriger vers fleet-manager en HTTPS").
- If a term is genuinely common knowledge for the stated audience (e.g. "HTTP" for a room of backend engineers), skip the callout and just use the term — use judgment, don't insult the reader's actual baseline. But never skip anything specific to this stack: internal tool names, internal hostnames, less-common protocols, house jargon.
- Never let more than one undefined term slip into a single sentence. If a sentence needs three callouts, split it into three sentences.

## Step 5 — Diagrams

Diagrams are a supplement to the narrative, never a replacement — a diagram shows *sequence*, it doesn't explain *why* a step exists, and that's the narrative's job. Two kinds earn their place:

- **One overview diagram** near the top (after the plain-language summary, before chapter 1) — a Mermaid `sequenceDiagram` or `flowchart` giving a compact map of the whole throughline, so the reader has a spatial anchor before the prose starts.
- **One small diagram per chapter that resists being explained in prose alone** — typically the chapter with the trickiest mechanism (a protocol handshake with a twist, a filesystem assembled from two layers, a fan-out/fan-in between peers). Don't diagram every chapter — a diagram after every paragraph is as bad as a catalog; reserve them for the moments where seeing the shape of the thing genuinely beats reading about it. Place it right where the mechanism is described, not bundled at the end.

## Step 6 — Close with analysis: edge cases, trade-offs, prior art, roadmap

The narrative explains the happy path. A reader who's about to actually own or modify this system needs four more things, none of which belong inside the story itself (they'd break the chronological flow) but all of which belong in the document. Write these as their own sections, in this order, right after the last narrative chapter:

**Cas limites / Edge cases.** Reuse the `<details><summary>Q: ...</summary> ... </details>` collapsible Q&A format from the `sre-landscape` "Typical Questions" pattern — it's the right shape here too. For each question, label the answer's confidence explicitly: **vérifié dans le code** (you read the exact line), **déduit** (follows logically from a verified mechanism but you didn't observe it happen), or **non vérifié** (plausible but you have no evidence either way — say so, don't guess silently). Source edge-case questions from what the narrative's mechanisms actually imply, not a generic checklist — "what happens when the thing this chapter just described *doesn't* have what it needs" is the generator: no cache, no peers, no network, no matching inventory record, the coordinating service is down. Concrete numbers help ("30 postes, zéro cache, démarrent en même temps" beats "que se passe-t-il en cas de charge").

**Compromis / Trade-offs.** Name the design choices that were made and what was given up for them, in the form "chose X over Y, gained A, gave up B." Don't editorialize about whether the trade-off was right — the point is making implicit trade-offs explicit, not grading them. Pull real ones out of what you already found while researching (a `count = 1` in Terraform is a trade-off statement about redundancy whether anyone wrote it down as one or not) rather than inventing generic infra trade-offs that don't actually apply to this system.

**Comment font les autres / prior art.** A short comparison table: how do other known systems solve the same underlying problem, and how does this one differ. This requires actual web research (`WebSearch`/`WebFetch`) — don't reconstruct this from memory of "well-known" prior art without checking, and don't cite a company/project doing something similar unless you can name a real source for it. It's fine for this table to reveal the system under discussion is architecturally close to an existing pattern (e.g. "same squashfs+overlay idea as a Linux live-CD, with BitTorrent added for scale") — that's a genuinely useful thing for a reader to know, not a letdown.

**Si tu dois faire évoluer ce système / roadmap.** Split into quick wins (small effort, real value, grounded in a specific gap you actually found — a health check that only verifies TCP connect instead of the real protocol, a half-finished migration left with two parallel configs, an empty placeholder repo) and longer-term work (grounded the same way, not generic advice like "improve monitoring"). If Step 4's research surfaced a genuinely time-boxed fact (an upstream deprecation date, an EOL, a default flipping in a specific version), that belongs here as the most concrete, highest-priority long-term item — it's a rare case where the roadmap has an actual deadline instead of just a priority ranking.

## Step 7 — Close with a glossary + a component map

After the analysis sections:

- **Glossaire** — every term defined inline, alphabetized, one line each (a reminder pointer, not a full redefinition — link back to the chapter if the output format supports anchors). Add an external reference link per term when a stable one exists: Wikipedia for well-known concepts, an RFC or protocol spec (IETF datatracker, BitTorrent BEPs, etc.) over a blog post when one exists, or the project's own official site. Only link a URL you're actually confident is correct — for canonical, long-established standards (RFCs, Wikipedia titles for major protocols, official project domains) that's usually fine from what you already know; for anything less certain, verify with a fetch before writing it down rather than guessing a plausible-looking URL. A term with no good stable reference just gets no link — don't force one.
- **Carte des dépôts et services impliqués** — a table with columns: `Nom | Rôle en une phrase | Où le trouver (repo/serveur/URL) | Exploré en détail ?`. This is the "fields per item" pattern from the `research-scout`/`sre-*` pipeline, adapted: instead of comparing external candidate tools, it inventories the internal components actually touched by the story, so a reader can jump straight to source.

## Step 8 — Comprehension self-check before delivering

Reread the doc pretending to be the calibrated reader from Step 2. For each chapter ask: *if I stopped reading here, could I explain in my own words what happens at this step and why it's needed?* If not, that chapter is still a catalog entry wearing narrative punctuation — rewrite it.

Also check, mechanically:
- Does any sentence use an acronym or internal name before its callout box?
- Does any line say "X exists" or "X is configured for Y" without saying **where** X lives and **why** it matters at this point in the story?
- Is there a wall of unlabeled bullets that would read better as narrative prose explaining the causal chain between them?
- Could two adjacent chapters swap order without anything breaking? If yes, the "order" isn't actually following the story yet.

## Step 9 — Independent grading via a fresh subagent (required, not optional)

Self-review (Step 8) catches the mechanical stuff — undefined acronyms, missing "where does X live." It does not reliably catch tone breaks, flat chapters, or a callout box that quietly contradicts itself, because you're grading your own writing with your own blind spots. Spawn a fresh subagent (`general-purpose`, foreground — you need its verdict before the doc is done) with **no context from the writing process**, so it reads the doc exactly as a real reader would: cold.

Use this task verbatim, filling in the file path:

> Tu vas jouer deux rôles successifs pour évaluer un document technique interne, situé ici : `<path>`.
>
> Contexte : c'est un document interne qui explique comment fonctionne un système interne, pour une équipe dont les membres n'ont pas tous travaillé sur cette partie du système. L'auteur a délibérément essayé de suivre un principe : raconter UN SEUL fil narratif chronologique plutôt qu'un catalogue de composants, et expliquer chaque terme technique au moment précis où il apparaît dans le récit, jamais avant.
>
> Ta tâche : lis le document en entier, puis évalue-le honnêtement et sans complaisance, comme si c'était un devoir à noter. Ne sois PAS gentil par défaut — le but est d'améliorer le document, pas de rassurer son auteur. Si une section est mauvaise, dis-le clairement et explique pourquoi.
>
> **Rôle 1 — la nouvelle personne qui découvre.** Lis comme quelqu'un avec un bagage général en informatique mais aucune connaissance de ce système précis. À chaque chapitre : est-ce que je comprends vraiment ou est-ce que je fais semblant parce que la prose est fluide ? Un terme utilisé avant d'être expliqué ? Un saut logique ? Un moment où je m'ennuie ? Note chaque chapitre sur 20 avec justification précise, et une citation exacte pour tout ce qui est sous 16/20.
>
> **Rôle 2 — le professeur qui corrige la copie.** Note sur 20 chacun, avec justification : (1) clarté et ancrage concret des explications de termes, (2) fluidité / fil narratif réel vs. liste déguisée, (3) impact / intérêt — y a-t-il des moments "je ne savais pas que ça marchait comme ça" ?, (4) utilité pratique — ce doc m'aiderait-il concrètement demain ?, (5) structure et rythme.
>
> Réponds en français, structuré : note globale /20 + synthèse honnête, notes par chapitre avec citations, notes par critère avec justification, top 5 des problèmes les plus impactants (passage exact cité, pourquoi c'est un problème, suggestion concrète), et une section obligatoire "ce qui fonctionne vraiment bien et qu'il ne faut pas changer" (si elle est vide, la relecture n'a pas assez cherché).

## Step 10 — Apply the fixes, verified against source

Work through the top 5 (or however many surfaced) in order of impact. For each one:

1. **Don't paste the reviewer's suggested rewrite blindly.** If the fix implies a factual claim (a file path, a mechanism, a "where does X live"), go verify it against the actual source before writing it down — the reviewer graded the prose, not the facts, and it may have proposed a plausible-sounding fix that isn't quite what the code does. Grep the repo, read the file, confirm. This is frequently where you find something better than what you had (a real file path where you'd written "not identified," a genuinely interesting mechanism the first pass missed) — a review pass is also a second research pass, not just a copy-editing pass.
2. If a flagged issue is a tone/register break (the narrative voice slipping into addressing the reader directly, a meta-aside about the writing process itself), just cut it — that content usually belongs in the "Limites de cette investigation" section instead, if it belongs in the doc at all. Check whether the same point already exists there before adding it, to avoid the duplication this exact failure mode tends to produce.
3. Leave the "what works, don't touch" section alone. Don't rebalance a chapter that scored well just because you're in an editing mood.

Re-running Step 9 after fixes is optional, not required — offer it to the user rather than doing it automatically, since it costs another full subagent pass and the marginal fixes get smaller each round.

## Rules

- No jargon-first sentences. Never open a chapter with an acronym before it has been introduced.
- No component catalog, ever, even disguised as prose. If you catch yourself writing "there are N services: A, B, C, D" without each one entering the story on its own terms, restructure.
- Cite concrete sources for every factual claim — `repo/path/to/file:line`, or `nom-du-service (chemin du manifeste k8s / fichier de conf)`. Same discipline as `tech-debt-audit`: a claim without a source is a vibe.
- Prefer one coherent narrative doc over several fragmented ones, unless the user explicitly wants a split (e.g. one doc per audience).
- Keep code/config excerpts short and only when they anchor a specific claim on screen — this is an explainer, not a reference manual. Link/cite the file instead of pasting it wholesale.
- If parts of the system were investigated but access was denied, ruled out, or left unverified, say so plainly in the glossary/map table rather than silently omitting them — an honest gap is more useful than an invisible one.
- Same discipline applies to Step 6's analysis sections: label edge-case answers by confidence (vérifié / déduit / non vérifié), verify prior-art claims with actual web research instead of memory, and never link an external reference URL you're not genuinely confident is correct.

---

# Notes for future-you

## Why not just reuse the `sre-*` pipeline?

`sre-research` (brief → landscape → deepdive → synthesize → write → publish) is built to answer "which of these several *external* tools should we adopt," which is fundamentally a comparison problem: candidates, scoring rubrics, elimination criteria, a recommendation. Its "Key Concepts & Vocabulary" template (`sre-landscape.md`) is genuinely the right shape for *defining a term in isolation* — that's where this skill's Step 4 callout template comes from, simplified down (no "when to use / when to avoid", no "who supports it" — this isn't comparing candidates, there's exactly one system and it's already the answer).

What `sre-research` doesn't give you is a narrative spine — its landscape/deepdive docs are intentionally structured as parallel per-candidate sections, because the reader is comparing, not following a sequence of events. Infra walkthroughs are the opposite: there's no comparison, there's a **sequence**, and the whole value of the doc is making that sequence legible to someone who's never seen it.

## What triggered writing this

First pass at documenting how EPITA's PIE (student lab machines) boot produced a doc that was accurate and well-sourced (every claim had a repo path) but landed as a wall of independently-true facts: "TFTP does X. fleet-manager does Y. PowerDNS syncs Z." Feedback was blunt and correct: unreadable for anyone who hadn't already worked on that part of the infra, and if the doc ever gets shared with the wider team, most of them will be in exactly that position. The fix isn't "add more explanation" bolted onto the same structure — it's restructuring around a single story (a machine powers on, N steps later a student is logged in) and never introducing a term before the story needs it.

## Calibration knob

If a future run feels like it's over-explaining for a specific audience (e.g. writing for the infra team itself about their own system), it's fine to say so up front: *"audience: infra team, they know Kubernetes/DHCP/DNS cold, skip those callouts, only define what's specific to this system."* The skill defaults to the least-specialized plausible reader because that failure mode (under-explaining) is much harder to notice and fix after the fact than the other one (a few callouts an expert reader skims past in two seconds).

## Why Step 9 is a separate subagent instead of "reread it yourself harder"

Ran both on the PIE boot doc: Step 8 self-review caught the mechanical stuff (an undefined acronym, a missing "where does X live") but missed a paragraph where the narrative voice broke and started addressing the reader as "tu" mid-chapter, missed a callout box that promised vocabulary ("vues", "modèles") the doc never actually used again, and rated the whole thing "looks done" — because it was reading with the memory of having just written it. A fresh subagent with zero context caught all three in one pass and handed back an actual grade (16/20) with citations, which is a far more honest signal than the author's own "looks good to me." The cost is one subagent call; the alternative is shipping a doc with a tone break the author is structurally unable to see.

The dual-role framing (newcomer *and* professor) matters too — a newcomer-only review tends to just report confusion without saying *why* it's happening or *how bad* it is; a professor-only review tends to grade prose quality without checking whether a total outsider would actually follow the story. Together they cover both "does this work" and "is this good."

## Diagram lesson from the same run

First pass had a single big overview diagram and nothing else. Second pass added three more, each anchored to the one chapter whose mechanism genuinely resists being explained in prose alone: a two-round DHCP handshake with a twist, a peer-to-peer download with a fallback path, a filesystem assembled from two layers. None of the other seven chapters needed one — they're causal chains a sentence can carry fine. That ratio (roughly one diagram per "this is genuinely spatial/stateful" chapter, not one per chapter) is probably the right default; recalibrate if a future system is unusually diagram-heavy by nature (e.g. a networking topology doc).

## Where Step 6 (edge cases / trade-offs / prior art / roadmap) came from

Third round of feedback on the same PIE boot doc, after the narrative itself was already reading well: "checker les compromis, checker s'il existe d'autres architectures, c'est quoi le state of the art, si je dois éditer/améliorer ce système quels seraient les quick wins vs le long terme, ajoute une section sur les edge cases (ex: 30 postes sans cache, ça sature la bande passante centrale ou pas?), et pour le glossaire je veux des liens externes." None of this was wrong to want — a narrative that only explains the happy path is a good *introduction* but a thin *reference* for someone who has to actually operate or change the system next month. Two things fell out of doing this for real, worth remembering:

1. **A review pass is a second research pass, not just editing.** Answering "what's the prior art" properly required actual web searches (Twitter's Murder, NixOS's systemd-stage-1 timeline, Dragonfly), and answering "does the tracker have redundancy" required going back into a repo already explored and grepping for something specific (`bttrack`) that the first pass's keyword searches had walked right past. The trade-offs and edge-case sections are only as good as the research underneath them — write them from what you can actually cite, not from what sounds plausible for "this kind of system."
2. **The user's own naive question is often the best edge case.** "30 postes, zéro cache, en même temps — ça sature la bande passante centrale ?" is a better prompt for this section than any generic checklist ("what about failure modes") because it's concrete enough to force a real mechanistic answer instead of a hand-wave. When calibrating this step for a new system, prefer whatever concrete "what if" the requester already has in mind over inventing a comprehensive-looking list from scratch.
