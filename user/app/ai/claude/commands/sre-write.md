# /sre-write — Phase 5: Document Generation

$ARGUMENTS — topic-slug [article|livrable|runbook|all]

Generate publication-quality documents from all pipeline phases.
Spawns the `research-writer` agent. Uses your existing document formats.

---

## Steps

1. Read `brief.yaml`, `meta.yaml`, `synthesis.md`, all deepdive files, all lab results.
2. Determine which documents to generate:
   - From `$ARGUMENTS` second word: article/livrable/runbook/all
   - If not specified, generate what `brief.yaml.deliverables` says is needed.
3. Generate each requested document.

---

## A. Research Article → `article.md`

Spawn `research-writer` with this task:

> Write a complete research article for: **<topic_name>**
> 
> Sources: brief.yaml, all deepdives, synthesis.md, all lab results.
> 
> Structure (do NOT leave TODOs or placeholders — if data is missing, write [DATA REQUIRED: <what>]):
>
> ```markdown
> # <topic_name> — Research Article
> *Version: 1.0 | Date: <today> | Author: Brian Perret | Status: Draft*
>
> ---
> > **TL;DR:** <2-3 sentences: what was studied, what was found, what to do>
>
> ---
>
> ## ADR Summary
> [Copy from synthesis.md ADR section — decision, rationale, consequences in ~200 words]
>
> ## 1. Context & Motivation
> Why this matters now. Current state. What changes if we do nothing.
> Ecosystem state: is the technology converging? Are there EoS pressures?
>
> ## 2. Landscape Overview
> [Comparison table from landscape.md]
> Shortlist rationale (why these were selected for deep dive).
>
> ## 3. Architecture Patterns
> Cross-cutting architectural patterns observed across implementations.
> Not per-implementation — the structural approaches that emerged.
>
> ## 4. Implementation Deep Dives
> For each implementation (one H3 section per):
> ### 4.N <Implementation Name>
> - Architecture overview (2-3 paragraphs)
> - CRD surface / API (key resources listed)
> - Feature coverage for this use case
> - Maturity assessment
> - Security model
> - Operational profile
> - Lab findings (if tested — what worked, what surprised, what failed)
> - Known limitations and open issues
>
> ## 5. Performance & Benchmarks
> Benchmark data collected. Source, date, conditions for each data point.
> If no benchmarks found: state clearly and explain what metrics matter.
>
> ## 6. Evaluation
> ### 6.1 Weighted Scoring Matrix
> [Full table from synthesis.md]
> ### 6.2 Feature Comparison
> [Full table from synthesis.md]
> ### 6.3 Security & Multi-tenancy Analysis
> Cross-implementation security comparison for the specific threat model.
>
> ## 7. Decision Guide
> ### 7.1 Choice Matrix
> [From synthesis.md — when to use which]
> ### 7.2 Risk Register
> [From synthesis.md — top risks with mitigations]
> ### 7.3 Migration Path
> [From synthesis.md — migration analysis]
>
> ## 8. Recommendation
> Concrete recommendation for the context in `brief.yaml`.
> Direct: "Use X because Y. The main trade-off is Z."
> Conditions under which the recommendation changes.
>
> ## 9. Implementation Guide
> For the recommended option: step-by-step implementation with key config decisions.
> Reference the lab IaC kit.
>
> ## Appendix A — Lab IaC Reference
> Key manifests or config snippets from the lab kit.
>
> ## Appendix B — Open Issues Tracker
> | Implementation | Issue | Severity | GitHub Link | Status |
>
> ## Appendix C — Version Compatibility Matrix
> | Implementation | K8s Min | K8s Max | Notes |
>
> ## Appendix D — References
> All sources with URLs and access dates.
> ```
>
> Save to: `~/.sre-research/<slug>/article.md`

---

## B. Livrable → `livrable.md`

Spawn `research-writer` with this task:

> Write a delivery document (livrable) for: **<topic_name>**
>
> This documents what will be/was done during the migration or deployment.
> French section headers. Technical terms stay in English.
>
> ```markdown
> # Livrable : <Migration/Deployment Description>
>
> ## 1. Phase Préparatoire & Architecture
> What was researched and validated. Architecture chosen and why.
> Reference the research article for details.
>
> ## 2. Déploiement de l'Infrastructure
> What is being deployed. Configuration choices. NodePorts, namespaces, etc.
>
> ## 3. Standardisation & Configuration
> Helm charts, templates, abstractions created. Key configuration parameters.
>
> ## 4. Décommissionnement & Bascule
> What is being removed. The cutover mechanism. Impact window.
>
> ## 5. Plan de Validation
> Test matrix per category:
> | ID | Cas de test | Commande / Protocole | Résultat Attendu | Résultat Constaté | Statut |
>
> ### 5.1 Catégorie 1: <Primary function>
> ### 5.2 Catégorie 2: <Secondary function>
> ...
>
> ## 6. Impact & Procédure de Rollback
> **Impact:** [service interruption window, affected systems]
> **Rollback steps:** numbered, with exact commands
>
> ## 7. Liste des Merge Requests
> [Grouped by type]
> ```
>
> Save to: `~/.sre-research/<slug>/livrable.md`

---

## C. Runbook → `runbook.md`

Spawn `research-writer` with this task:

> Write an operation runbook (feuille de route) for: **<topic_name>**
>
> This is the document used ON the day of the operation. Every step must be executable.
> No ambiguity. Exact commands, not descriptions of commands.
>
> ```markdown
> # Feuille de Route : <Operation Name>
>
> ## Informations Générales
> - **Date de l'opération :** [À remplir]
> - **Opérateur :** Brian
> - **Reviewer :** [À remplir]
> - **Impact attendu :** [e.g., "Interruption < 5 min lors de la bascule"]
> - **Durée estimée :** [X heures]
>
> ## Timeline
> | Heure | Phase | Responsable |
> |-------|-------|-------------|
> | T-15min | Préparatifs | Opérateur |
> | T-0 | Exécution | Opérateur |
> | T+Xmin | Validation | Opérateur + Reviewer |
> | T+Ymin | Clôture | Opérateur |
>
> ## Phase 1 : Préparatifs & Communication (T-15 min)
> - [ ] **1.1 - Sanity check pré-opération :**
>   ```bash
>   kubectl get nodes && kubectl get pods -A | grep -v Running
>   ```
> - [ ] **1.2 - Notification :** Informer l'équipe du début de l'opération.
>
> ## Phase 2 : Exécution
> [Numbered steps with exact commands. Each step as a checkbox.]
>
> ## Phase 3 : Plan de Validation
> ### Catégorie 1 : <Primary check>
> *Objectif : ...*
> | ID | Cas de test | Commande | Résultat Attendu | Résultat Constaté | Statut |
>
> ## Phase 4 : Clôture ou Déclenchement du Repli
> - [ ] Si 100% des tests OK : Notifier l'équipe. Opération réussie.
> - [ ] Si anomalie persistante : Déclencher le plan de rollback.
>
> ## Plan de Rollback
> *Durée estimée : < X minutes*
>
> ### Étape 1 : [Action]
> ```bash
> # exact commands
> ```
> ### Étape 2 : Vérification du retour à l'état stable
> ```bash
> # verification commands
> ```
> ```
>
> Save to: `~/.sre-research/<slug>/runbook.md`

---

## After generation

4. Update `meta.yaml`: `phase: write_pending`, `last_updated: <today>`, `write_completed: <today>`.

5. List all generated files with their paths.

6. Tell the user:
   ```
   Documents generated. Review each one:
   - article.md → check sections 6-8 especially (scoring, recommendation, decision guide)
   - livrable.md → fill in the test matrix "Résultat Constaté" and "Statut" columns
   - runbook.md → fill in Date, Reviewer, verify all commands are current

   When satisfied: /sre-research continue <slug>
   ```
