# House style: the "Sous le capot" series

Reference series the user rated as the target: "Observabilité, sous le capot" (I. Les données, II. Le moteur, III. La production, IV. Le marché) and the field report "Horizon, sous le capot". Re-read one of them with Artifact `read` before writing a new series if they are reachable:
- I: https://claude.ai/artifact/Jn5ze9zFt5m7CrS1fpZNey
- IV: https://claude.ai/artifact/WXPMVC6cR8yNqxy9cVzPMU
- Horizon: https://claude.ai/artifact/MjUrkDJjCaeeQ4t8kRtQ34

Start every page from `assets/part-skeleton.html` with `assets/series.css` pasted in. Change only the accent colour per series.

## Voice

- French, tutoiement, peer to peer. The reader is a senior SRE: no "imagine que…", no hand-holding, no teasing a simple thing as if it were a mystery.
- Short declarative sentences. One idea per sentence. Bold the one phrase per paragraph that carries the point.
- Concrete before abstract. Every chapter starts from a real object: a line of `/metrics`, a request `POST /checkout` of client `c-4821` that took 1.8 s, a commit count measured on the repo. Abstractions come after the reader has seen the thing.
- Address the reader's real question by name: « Ce qui répond à ta question : … », « Ton serveur à 350 mods ».
- Honest about limits. Say where a tool loses, where a benchmark is vendor-run, what is still v0.x, what you could not verify. "Les chiffres, honnêtement" is a section title, not a disclaimer at the bottom.
- Say what you measured yourself versus what a source claims ("Ce que j'ai mesuré moi-même sur le dépôt, le 16 novembre").
- No em-dashes, no "not X but Y" constructions, no rhetorical teasers, no filler conclusions.

## Page structure

1. Top bar: series brand + one pill per part (current part filled, future parts dashed "bientôt").
2. Hero:
   - eyebrow `Partie X sur N · THÈME · lecture ≈ N min` (or `Papier de terrain · état au <date>`);
   - H1 is a claim or a striking fact, never a topic label ("Une ligne de texte, des millions de séries", "Tout le monde veut stocker ta télémétrie");
   - lede: the concrete thing we follow and the questions this part answers; part IV opens on three hard market facts with amounts and dates;
   - a specimen (annotated line, stat grid, or "La thèse en une phrase" mental box);
   - hero-meta: "Pour : …", "Prérequis : …".
3. Chapters numbered continuously across the whole series (part IV starts at 16). Chapter head: big number, H2, one muted line saying what the chapter gives.
4. Chapter 1 of part I is always "Carte et vocabulaire": one map diagram where every box carries the part/chapter that explains it, then a filterable glossary (search + theme chips, each term with definition, example, and where it is explained).
5. Inside a chapter, the order is: the problem → the naive solution → why it breaks → the real mechanism → what it costs. Close each big idea with one callout.
6. End of every part: quiz "Vérifie que c'est acquis" (6 questions, 3 options, explanation shown on click starting with "Exact." or "Pas tout à fait."), then the dark "next" box teasing the concrete mechanisms of the next part, then "Sources de cette partie" as `Org · titre (date)` links.

## Components and when to use them

- **Modèle mental** (accent box, big display text): one sentence the reader should still remember in a month. At most one or two per chapter.
- **Trade-off** (violet box, 2×2 grid): option A gain / ce qu'on paie, option B gain / ce qu'on paie. Use for every real choice.
- **Piège classique** (red box): a concrete misuse with the exact command or config, why it hurts, the fix.
- **Pourquoi c'est game changer** (idea box): only for a mechanism that changes how a problem is solved.
- **Vocabulaire** box where several new terms cluster.
- Signal/option cards with a one-line italic question they answer ("« Est-ce que ça va, et depuis quand ça ne va plus ? »") and a cost meter.
- Tables of recurring failures: `symptôme / pourquoi c'est tentant / cardinalité ou impact / où mettre l'info à la place`. Always a "what to do instead" column.
- Ordered remedies "du moins cher au plus cher".
- "Le débat" section: present the opposite school fairly (who defends it, their argument, where they are right), then a trade-off box and a mental model that reconciles.
- Market chapters: player cards (name, tag, 2-3 sentences with sourced numbers and dates, a mono `fact` line with licence/model); trend cards each with a "Pourquoi" block; a "ce qui décline → remplacé par → pourquoi" table; "Signaux pour migrer" and "Piège · migrer pour la mode".
- Interactive pieces open in a realistic state: calculators with a visible formula, KPIs that turn red past a threshold, and a verdict sentence that changes with the result.
- Final trade-off map (filterable cards: option A vs B, the axis, the rule of thumb, the chapter reference) and "Dix règles d'or".

## Diagrams

- One diagram per mechanism the prose would make the reader assemble. Hero-quality diagrams for the central loop of the topic.
- Inline SVG, viewBox-scaled, `minw` class for wide ones inside an `overflow-x:auto` frame, colours only through classes bound to tokens (`s-acc`, `s-warn`, `s-bad`, `s-trade`, `f-muted`…), `role="img"` and a full-sentence aria-label.
- Show what is lost and what is kept, or before/after, side by side. Label arrows.
- Caption starts with a bold claim, then one or two sentences of reading guidance.

## Numbers

- Every number has who measured it, when, on what, and a link. Vendor and sponsored numbers are flagged in the sentence ("sondage du Register, sponsorisé par un éditeur").
- Dates are absolute. State "état au <date>" on anything that moves.
- When sources conflict, show both and say which you trust and why.
