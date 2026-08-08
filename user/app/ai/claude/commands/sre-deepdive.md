# /sre-deepdive — Phase 2: Implementation Deep Dives

$ARGUMENTS — topic-slug

Produce a detailed technical sheet for each selected implementation.
Spawns one `research-scout` agent per implementation.

---

## Steps

1. Read `~/.sre-research/<slug>/brief.yaml` and `meta.yaml`.

2. Determine targets:
   - If `meta.yaml.deepdive_targets` is already set, use those.
   - Otherwise ask: "Which implementations should we deep-dive? (names from landscape.md, or 'all')"
   - Save the answer to `meta.yaml.deepdive_targets: [...]`.

3. For each implementation in the targets list:

   a. Check if `~/.sre-research/<slug>/deepdives/<impl-slug>.md` already exists. If so, skip with a note.

   b. Read `~/.sre-research/<slug>/landscape.md` first so the deepdive can reference the shared vocabulary section and reuse the same concept names.

   c. Build the research task for `research-scout`:

      ---
      **Task for research-scout:**

      Deep dive into **<implementation>** for the use case: <topic_name>
      Goal: <goal>

      ## Output document structure

      Save to: `~/.sre-research/<slug>/deepdives/<impl-slug>.md`

      Every deep-dive document MUST begin with these two mirrored sections so
      the file is self-contained for a reader jumping in without landscape.md.

      ### 1. How This Deep Dive Is Graded

      Reproduce the scoring rubrics used below so a reader understands what each
      1–5 score means:

      ```markdown
      ## How This Deep Dive Is Graded

      ### Documentation coverage (1–5)
      - 1 = README only or broken
      - 2 = Basic guides, many gaps, no examples
      - 3 = Most features covered, some gaps
      - 4 = Comprehensive, good examples, minor gaps
      - 5 = Excellent, task-oriented, API reference, tutorials

      ### Quickstart quality (1–5)
      - 1 = No quickstart or broken
      - 2 = Exists but incomplete or hard to follow
      - 3 = Works but requires troubleshooting
      - 4 = Works end-to-end with minor friction
      - 5 = Copy-paste, works first try, covers common variations

      ### API reference completeness (1–5)
      - 1 = No API reference
      - 2 = Partial coverage of CRDs / endpoints
      - 3 = All public CRDs documented, examples sparse
      - 4 = All CRDs + examples + field descriptions
      - 5 = Generated from source + examples + version-diff notes
      ```

      ### 2. Concept-to-Implementation Mapping

      A table showing how THIS specific tool implements each concept from the
      landscape vocabulary. This is what makes the deepdive readable stand-alone.

      ```markdown
      ## Concept-to-Implementation Mapping

      | Concept (from landscape vocab) | How <tool> implements it | Native? | Notes |
      |--------------------------------|--------------------------|---------|-------|
      | Gang scheduling                | Via JobSet CRD           | ⚠️ Indirect | Requires JobSet operator installed |
      | Fair sharing / DRF             | Cohort-based fair share  | ✅ Native | Single-level cohort only |
      | MIG                            | Via GPU Operator         | ⚠️ External | Delegates to nvidia-device-plugin |
      | ...                            | ...                      | ...     | ...   |
      ```

      Cover every concept listed in landscape.md's vocabulary section.

      ## Collect the following sections

      ### Architecture
      - Core design model (pull/push, controller pattern, CRD-based, etc.)
      - All Custom Resources (CRDs): list each with a one-line description
      - Component topology: which pods/controllers are deployed, resource footprint
      - Mermaid diagram: components + integration with K8s + integration with user's stack (ArgoCD, Prometheus, Cilium)

      ### Feature Matrix
      For each feature relevant to the use case (<features from brief>), mark as:
      Native | Via Extension | Planned (link to issue/PR) | Not Supported
      Be specific — "Native" means first-class CRD support, not a workaround.

      ### Maturity & Stability
      - Current stable version, date of last release (verify on GitHub Releases directly)
      - Release cadence and stability policy (semver? breaking-changes policy?)
      - CNCF graduation level with date
      - Open bugs labeled "bug" or "high-priority" in last 90 days (list top 5 with links)
      - Breaking changes in last 3 major versions (yes/no and examples)

      ### Documentation Quality
      - Official docs coverage: 1–5 using scale above + one-sentence justification
      - Quickstart / getting-started quality: 1–5 using scale above + justification
      - Production deployment guide existence: yes/no
      - API reference completeness: 1–5 using scale above + justification

      ### Performance
      - Published benchmark results (link, date, conditions)
      - Reported scale limits (node count, resource count, throughput numbers)
      - Known performance-sensitive configurations or anti-patterns

      ### Security & Multi-tenancy
      - RBAC model: how is access controlled?
      - Multi-tenancy isolation: namespace-level? Cluster-level? Hard boundaries?
      - Known CVEs or security advisories (link)
      - Secret handling approach

      ### Operational
      - Installation method: Helm chart / Operator / Manual YAML / Kustomize
      - Upgrade path quality (in-place upgrades? downtime?)
      - Observability: metrics exposed (Prometheus?), dashboards available?
      - Known production gotchas or common pitfalls (from GitHub issues, blog posts)

      Long configuration or YAML examples MUST be wrapped in `<details>` blocks
      with a one-line `<summary>` so the document skims quickly. Example:

      ```markdown
      <details>
      <summary>Example: ClusterQueue with cohort-based borrowing (28 lines)</summary>

      ```yaml
      apiVersion: kueue.x-k8s.io/v1beta1
      ...
      ```
      </details>
      ```

      ### Compatibility
      - Minimum K8s version
      - Known incompatibilities with CNIs, other controllers, or features in the brief context
      - Tested/validated against K8s versions: <k8s_version_range>

      ### How This Tool Is Used In Production

      2–3 real deployment stories with links and what specifically was hard/easy.
      Use `<details>` blocks for the long-form details so the doc skims quickly:

      ```markdown
      ## How This Tool Is Used In Production

      ### <Company / Project Name>
      **Scale:** <e.g. 10k+ GPUs, 500 daily users, 50 teams>
      **Stack:** <e.g. Kueue + JobSet + KubeRay on GKE>
      **Source:** [KubeCon talk / blog post](url) (YYYY-MM-DD)

      <details>
      <summary>What was hard, what was easy, what they'd do differently</summary>

      - Hard: <specific issue>
      - Easy: <specific win>
      - Would change: <specific pain point that led to a workaround>
      </details>
      ```

      Prefer conference talks (KubeCon, KubeCon China, PyTorch Conference), CNCF
      case studies, and engineering blog posts over vendor marketing. Skip if you
      can only find generic "we use X" mentions with no operational detail.

      ### Open Questions
      Things you could not verify from available sources. Mark with [UNVERIFIED].

      ### Sources
      [URL | Date accessed | Confidence: High/Medium/Low]
      ---

   d. Spawn `research-scout` agent for this implementation.
   e. Confirm the file was created before moving to the next implementation.

4. After all deep dives complete:
   - Read all deepdive files
   - Generate a cross-implementation comparison summary (5–10 line table across key dimensions)
   - Present it to the user

5. Update `meta.yaml`: `phase: deepdive_pending`, `last_updated: <today>`, `deepdive_completed: <today>`.

6. Tell the user:
   ```
   Deep dives complete. Files: ~/.sre-research/<slug>/deepdives/

   Review each implementation's deep dive, then run:
     /sre-research continue <slug>

   You'll specify which ones to generate lab kits for.
   ```
