# /sre-landscape — Phase 1: Landscape Scan

$ARGUMENTS — topic-slug

Identify and shortlist the top implementations for the research topic.
Spawns the `research-scout` agent to conduct the web research.

---

## Steps

1. Read `~/.sre-research/<slug>/brief.yaml`. If missing, tell user to run `/sre-brief <slug>` first.

2. Build the research task for the `research-scout` agent (fill in values from `brief.yaml`):

   ---
   **Task for research-scout:**

   Research the landscape of implementations for: **<topic_name>**

   Goal: <goal>
   Cluster context: K8s <k8s_version_range>, CNI: <cni>, GitOps: <gitops>, <cluster_count> clusters

   ## Grading scales — apply consistently across all candidates

   These rubrics MUST appear both in the task brief (here) and mirrored inside the
   final output document under a "How This Document Is Graded" section, so a reader
   opening `landscape.md` cold understands what each score means.

   **Documentation quality (1–5):**
   - 1 = No docs, README only, or docs are broken/outdated
   - 2 = Basic README + sparse guides, many gaps, no examples
   - 3 = Decent docs, most features covered, some gaps, usable with effort
   - 4 = Comprehensive, well-organized, good examples, minor gaps
   - 5 = Excellent: task-oriented guides, API reference, tutorials, actively maintained, covers edge cases

   **Maturity (1–5):**
   - 1 = Experimental / proof-of-concept, breaking changes expected
   - 2 = Active development, not production-recommended
   - 3 = Usable in production with caution, some instability signals
   - 4 = Stable, in production at multiple known organizations, regular releases
   - 5 = Battle-hardened, CNCF Graduated or equivalent, years of production use, clear SLAs

   **Community (1–5):**
   - 1 = Single maintainer or abandoned
   - 2 = Small team (<5 active contributors), low activity
   - 3 = Active small community, regular releases, some outside contributors
   - 4 = Healthy community, 50+ contributors, multiple organizations involved
   - 5 = Large ecosystem, hundreds of contributors, vendor backing, conferences, SIG/WG

   ## Key Vocabulary section — REQUIRED enriched format

   Before the comparison table, write a "Key Concepts & Vocabulary" section that
   introduces every domain-specific term needed to understand the rest of the
   document. This is not a glossary of one-line definitions — each entry MUST
   follow this exact template:

   ```markdown
   ### <Concept Name>

   **Definition** — 2–3 plain-language sentences.

   **Why it matters:** 1–2 sentences on the concrete problem this solves.

   <details>
   <summary>Real-world example — click to expand</summary>

   A worked scenario (5–15 lines) with concrete numbers (GPU count, node count,
   team count, etc.) showing:
   - the situation before the concept is applied
   - what fails / what is inefficient without it
   - what changes when it is applied
   - one gotcha or subtlety worth noting
   </details>

   **Commonly confused with — <Other Concept>:**
   *(include this block only when a near-neighbor concept exists)*
   - Difference in 1 sentence.
   - Choose **<Concept A>** when: <specific scenario>
   - Choose **<Concept B>** when: <specific scenario>
   - Common misconception: <one sentence>

   **Biggest trade-off:** 1 sentence.

   **When to use it:** <scenario>
   **When to avoid it:** <scenario>

   **Who supports it:** Kueue ✅ · Volcano ✅ · KAI ⚠️ (via X) · YuniKorn ❌

   > 📖 Further reading (multiple angles):
   > - [Title 1](url) — theoretical foundation / official spec
   > - [Title 2](url) — production experience report or post-mortem
   > - [Title 3](url) — hands-on tutorial or reference implementation
   ```

   **Reviewer checklist** — apply to EVERY vocabulary entry before publishing:
   - What question would a reader naturally ask after reading this? Is it answered?
   - Is there another concept people commonly confuse with this one? If yes → include the "Commonly confused with" block.
   - What is the biggest trade-off? Is it stated?
   - In what scenario would I recommend this? When would I avoid it?
   - At least 2 further-reading links from *different angles* (spec + experience report, tutorial + comparison post, etc.) — never 3 links from the same source or blog.

   ## Concept coverage for GPU/CPU scheduling topics

   Cover ALL of the following (adapt for other domains):
   - Gang scheduling
   - Fair sharing / DRF (Dominant Resource Fairness)
   - Preemption (differentiate eviction vs suspension)
   - Hierarchical queues / cohorts / quota borrowing / lending
   - MIG (Multi-Instance GPU) — NVIDIA hardware GPU partitioning
   - Time-slicing — temporal GPU sharing (no memory isolation)
   - MPS (Multi-Process Service) — NVIDIA CUDA shared context
   - Fractional GPU — requesting <1 GPU unit
   - Bin packing vs spread scheduling
   - DRA (Dynamic Resource Allocation) — new K8s API (GA in 1.32)
   - Topology-aware scheduling (NVLink, NVSwitch, NUMA, rack awareness)
   - Greedy vs balanced placement policies
   - Job suspension / admission control (vs pod-level scheduling)

   For non-GPU topics, identify and explain the equivalent domain-specific vocabulary.

   End the vocabulary section with a feature comparison matrix:
   ```
   | Feature | Candidate A | Candidate B | Candidate C |
   |---------|-------------|-------------|-------------|
   | ...     | ✅ Native   | ⚠️ Via X   | ❌          |
   ```

   ## Typical Questions section — REQUIRED

   After the vocabulary + feature matrix, add a "Typical Questions" section with
   at least 4–6 questions covering the topic's known gotchas. Each Q&A must use
   the `<details>` collapsible format so the doc skims quickly:

   ```markdown
   ## Typical Questions

   <details>
   <summary>Q: If a workload needs 42 GPUs and each rack has only 40, should the scheduler pack 40+2 or balance 21+21?</summary>

   No universally optimal answer. Greedy packing minimizes the number of topology
   domains used, which can be preferable for scenarios that benefit from locality.
   Balanced placement (21+21) distributes pods evenly and may improve communication
   patterns for AllGather-heavy workloads. The scheduler cannot know the workload's
   communication pattern, so users or higher-level job launchers must provide
   topology preferences. Kueue offers both greedy and balanced placement policies.

   **Who decides?** The scheduler can only optimize using what it knows (resource
   availability + topology). It generally does not know the workload's
   communication pattern, so the decision is pushed to the user via
   `PodSetTopologyRequest` or equivalent hints.
   </details>
   ```

   Suggested question themes for GPU scheduling (pick 4–6 most relevant):
   - Topology placement (greedy vs balanced, who decides)
   - Quota borrowing edge cases (what happens when the lender needs its quota back)
   - Preemption vs eviction (does the checkpoint survive? does GPU memory get flushed?)
   - Gang scheduling deadlocks (two gangs each holding half the quota)
   - Fractional GPU isolation semantics (can one fraction OOM another? memory guarantees?)
   - What happens when a job outlives its LocalQueue (namespace deletion)
   - Multi-scheduler pod routing (which scheduler picks up a pod, based on what)

   ## How Big Companies Do It — REQUIRED

   Before the preliminary recommendation, add a "How Big Companies Do It" section
   showing verified adoption + rationale:

   ```markdown
   ## How Big Companies Do It

   | Company | Stack Choice | Why | Source |
   |---------|--------------|-----|--------|
   | Google | Kueue (GKE) | First-class GKE integration, kubernetes-sigs governance | [link](url) |
   | Apple | Kueue + JobSet | Distributed ML training | [KubeCon EU 2025](url) |

   **What this tells us:** 2–3 sentences on patterns visible from adoption data
   (e.g., "Kueue dominates hyperscaler-native stacks; Volcano dominates Chinese AI
   clouds and enterprise HPC; KAI Scheduler is emerging as NVIDIA's default for AI
   cloud offerings") — plus one sentence on what this means for our decision.
   ```

   Verify every source link. Prefer conference talks, official blog posts, or
   CNCF case studies over vendor marketing pages.

   ## Architecture diagrams (REQUIRED for each candidate)

   For each candidate, produce a Mermaid diagram (`graph TD` or `sequenceDiagram`)
   showing:
   - Main components of the tool
   - How it integrates with K8s (API server, scheduler, kubelet, CRDs)
   - How it integrates with other tools in the user's stack (ArgoCD, Prometheus, etc.)
   - The flow of a job/request from submission to execution

   Label every arrow with the action or protocol (e.g., `--watches CRDs-->`,
   `--admits Job-->`, `--scrapes /metrics-->`).

   ## What to collect per candidate

   1. Full name, GitHub URL, official docs URL
   2. One-sentence description of what it is and its core approach
   3. CNCF status: Sandbox / Incubating / Graduated / Not in CNCF
   4. **Verified** latest release: check the GitHub Releases page directly — do
      not rely on cached knowledge. Record: version tag, release date, and cadence
      (average time between last 3 releases).
   5. GitHub stars (check directly on GitHub)
   6. Core architecture model (3–4 sentences: components, integration pattern, job lifecycle)
   7. Documentation score (1–5 using scale above + one-sentence justification)
   8. Maturity score (1–5 with justification)
   9. Community score (1–5 with justification)
   10. Known limitations and compatibility notes — list issues with ANY stack
       (Cilium, Calico, Flannel, ArgoCD, Flux, specific K8s versions, GPU
       operators). Label each: `[Stack: X]`. Frame these as "known issue with X"
       not as "risk for you" — the reader can decide relevance to their stack.
   11. Adoption signals with URLs and verified dates

   ## Also search for

   - Existing benchmarks comparing these tools (link + date + methodology)
   - Production incident reports or post-mortems mentioning these tools
   - Getting-started guides for vanilla K8s <k8s_version_range> with <cni>

   ## Output structure — final document skeleton

   Save to: `~/.sre-research/<slug>/landscape.md`

   ```markdown
   # Landscape: <topic_name>
   *Generated: <date>*

   ## How This Document Is Graded

   All numerical scores use the following rubrics. A score without a rubric is meaningless.

   ### Documentation (1–5)
   - 1 = No docs, README only, or broken/outdated
   - 2 = Basic README + sparse guides, many gaps
   - 3 = Decent docs, most features covered, usable with effort
   - 4 = Comprehensive, well-organized, good examples, minor gaps
   - 5 = Excellent: task-oriented guides, API reference, tutorials, actively maintained

   ### Maturity (1–5)
   - 1 = Experimental / PoC
   - 2 = Active development, not production-recommended
   - 3 = Usable in production with caution
   - 4 = Stable, production at multiple known orgs, regular releases
   - 5 = Battle-hardened, CNCF Graduated or equivalent, years of production

   ### Community (1–5)
   - 1 = Single maintainer or abandoned
   - 2 = Small team (<5 active contributors)
   - 3 = Active small community, some outside contributors
   - 4 = Healthy community, 50+ contributors, multiple orgs
   - 5 = Large ecosystem, hundreds of contributors, vendor backing

   ---

   ## Key Concepts & Vocabulary

   [enriched entries following the template]

   ### Feature Comparison Matrix
   | Feature | Tool A | Tool B | Tool C |
   |---------|--------|--------|--------|

   ---

   ## Typical Questions

   [4–6 Q&A blocks using <details>]

   ---

   ## How Big Companies Do It

   [adoption table + "What this tells us" paragraph]

   ---

   ## Candidate Overview

   | Name | CNCF | Stars | Latest Release | Release Date | Cadence | Docs | Maturity | Community | Eliminated |
   |------|------|-------|---------------|--------------|---------|------|----------|-----------|------------|

   ---

   ## Per-Candidate Analysis

   ### <Name>
   **Links:** [GitHub](...) · [Docs](...)
   **CNCF:** ... | **Stars:** ... | **Latest release:** vX.Y.Z (YYYY-MM-DD) | **Cadence:** ~X weeks

   **Summary:** ...

   **Architecture:**
   <3–4 sentences>

   ```mermaid
   graph TD
     ...
   ```

   **Key features:**
   - <feature>: <explanation>

   **Known limitations & compatibility notes:**
   - [Stack: X] <issue>

   **Adoption signals:**
   - [Source](url) — description (YYYY-MM-DD)

   > 📖 Further reading:
   > - [Title 1](url) — angle
   > - [Title 2](url) — angle

   ---

   ## Eliminated from Further Deep-Dive

   | Tool | Reason |
   |------|--------|

   ---

   ## Benchmarks & Performance Data

   | Source | Date | Methodology | Key Finding |
   |--------|------|-------------|-------------|

   ---

   ## Preliminary Recommendation

   **Top candidates for deep-dive (ranked):**
   1. **<Name>** — <2-sentence rationale>

   **Key open questions to resolve in deep-dive:**
   - ...

   ---

   ## Sources
   | URL | Accessed | Notes |
   |-----|----------|-------|
   ```
   ---

3. Spawn the `research-scout` agent with the task above.

4. After the agent completes, read `landscape.md` and present to the user:
   - The candidate overview table
   - The eliminated tools section
   - The preliminary recommendation

5. Update `meta.yaml`: `phase: landscape_pending`, `last_updated: <today>`, `landscape_completed: <today>`.

6. Tell the user:
   ```
   Landscape scan complete. Full results: ~/.sre-research/<slug>/landscape.md

   Review the full document, then run:
     /sre-research continue <slug>

   You'll be asked which implementations to deep-dive.
   ```
