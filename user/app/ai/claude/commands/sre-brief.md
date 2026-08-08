# /sre-brief — Phase 0: Research Brief Capture

$ARGUMENTS

First word = topic-slug. Remaining text = optional pre-filled context.

Capture the structured brief that drives every subsequent pipeline phase.
The brief defines criteria weights — these become the scoring rubric for synthesis.

---

## Steps

1. Extract `<slug>` from `$ARGUMENTS`.
2. Check if `~/.sre-research/<slug>/brief.yaml` already exists. If so, load it and offer to update.

3. Collect the following. Pre-fill from `$ARGUMENTS` context where possible, ask for the rest:

   **Topic name** — full descriptive title  
   e.g., "Kueue for GPU Job Scheduling with Team Quotas"

   **Goal** — the concrete decision to make  
   e.g., "Select and implement a batch queue scheduler for GPU workloads shared across 5 engineering teams with namespace-level quota isolation"

   **Current state** — what's in place today (or "none")

   **Cluster context:**
   - K8s version range (min to max across all target clusters)
   - CNI in use (Cilium/Calico/Flannel/etc)
   - GitOps tool (ArgoCD/Flux/none)
   - Monitoring stack (Prometheus+Grafana/Datadog/etc)
   - Number of clusters this change will roll out to
   - Team ownership model (platform team owns all vs app teams own namespaces)

   **Criteria weights** — rate each 1–5 (5 = most critical for your use case):
   - `performance` — throughput, latency, scale limits
   - `complexity` — operational burden (1=very complex, 5=very simple)
   - `security` — isolation guarantees, RBAC, multi-tenancy
   - `documentation` — docs quality and completeness
   - `maturity` — CNCF status, release stability, production adoption
   - `features` — completeness for your specific use case
   - `migration` — smoothness of migration path from current state

   **Deliverables needed** (yes/no for each):
   - Research article
   - Livrable (migration/deployment delivery document)
   - Runbook (operation sheet: commands, test matrix, rollback)

   **Decision deadline** (optional)

4. Write `~/.sre-research/<slug>/brief.yaml`:
   ```yaml
   topic_slug: <slug>
   topic_name: <full name>
   goal: <decision to make>
   current_state: <description or "none">
   context:
     k8s_version_range: "<min>-<max>"
     cni: <value>
     gitops: <value>
     monitoring: <value>
     cluster_count: <N>
     team_model: <description>
   criteria_weights:
     performance: <1-5>
     complexity: <1-5>
     security: <1-5>
     documentation: <1-5>
     maturity: <1-5>
     features: <1-5>
     migration: <1-5>
   deliverables:
     article: <true/false>
     livrable: <true/false>
     runbook: <true/false>
   deadline: <ISO date or null>
   created: <today ISO-8601>
   ```

5. Update `~/.sre-research/<slug>/meta.yaml`: set `phase: landscape`, `last_updated: <today>`.

6. Print a clean summary of the brief. Ask: "Does this look correct? Any changes?"

7. On confirmation: "Brief saved. Run `/sre-research continue <slug>` to start the landscape scan."
