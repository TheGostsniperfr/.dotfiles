# /sre-lab — Phase 3: Lab Kit Generation

$ARGUMENTS — topic-slug [implementation-slug or 'all']

Generate ready-to-run IaC manifests and test scripts for your remote cluster.
The lab kit is designed for human execution on the remote cluster — Claude generates
the kit, you run it, you fill in the results template.

---

## Steps

1. Read `brief.yaml`, `meta.yaml`, and all files in `deepdives/`.

2. Determine lab targets:
   - If second argument is provided, use it (single implementation or 'all').
   - Else if `meta.yaml.lab_targets` is set, use that.
   - Otherwise ask: "Which implementations to lab-test?"
   - Save to `meta.yaml.lab_targets`.

3. For each target implementation, generate the lab kit in `~/.sre-research/<slug>/lab/<impl-slug>/`:

   ### `README.md`
   ```markdown
   # Lab: <Implementation> — <topic_name>

   ## Prerequisites
   - Cluster: <K8s version range from brief>
   - Required: <existing components needed, e.g., "cert-manager >= 1.12">
   - Estimated time: <setup X min, tests Y min>

   ## Setup

   ### 1. Namespace & RBAC
   ```
   kubectl apply -f manifests/00-namespace-rbac.yaml
   ```

   ### 2. Install <implementation>
   ```
   <actual helm install or kubectl apply commands>
   ```

   ### 3. Verify installation
   ```
   kubectl get pods -n <namespace>
   kubectl get crd | grep <impl>
   ```

   ## Test Scenarios
   Run in order. Each scenario has its own script in `test-scenarios/`.

   | # | Scenario | Script | Expected outcome |
   |---|----------|--------|-----------------|
   | 1 | Basic setup | test-01-basic.sh | ... |
   | 2 | <use case feature> | test-02-<name>.sh | ... |
   ...

   ## Cleanup
   ```
   kubectl delete -f manifests/ --ignore-not-found
   helm uninstall <name> -n <namespace>
   ```
   ```

   ### `manifests/` — Kubernetes YAML files
   Generate these files (name them `00-namespace-rbac.yaml`, `01-install.yaml`, `02-demo-workload.yaml`, etc.):
   - Namespace + ServiceAccount + RBAC for the implementation
   - Installation manifests (Helm values file OR raw YAML) with sane production-leaning defaults
   - Demo workloads that exercise the key features from the brief
   - Any required CRDs if not bundled in the chart
   Base on the exact versions and config found in the deepdive for this implementation.

   ### `test-scenarios/` — Test scripts
   For each significant capability to validate, write a `test-NN-<name>.sh` script:
   - Applies the test workload or triggers the feature
   - Prints what to look for
   - Includes kubectl commands to verify expected state
   - Includes kubectl commands to clean up after the test
   Cover: happy path, quota/limit enforcement, failure recovery, edge cases from the deepdive.

   ### `results.md` — Results template (human fills this in)
   ```markdown
   # Lab Results: <Implementation>

   **Date:**
   **Cluster:**
   **K8s version:**
   **Tester:**

   ## Setup
   | Step | Duration | Issues encountered |
   |------|----------|--------------------|
   | Namespace + RBAC | | |
   | Install | | |
   | Verify | | |

   ## Test Results
   | # | Scenario | Expected | Observed | Status | Notes |
   |---|----------|----------|----------|--------|-------|
   | 1 | | | | ✅/❌/⚠️ | |
   ...

   ## Surprises / Undocumented Behavior

   ## Performance Observations
   (latency, throughput, resource usage under test load)

   ## Production Readiness Assessment
   Rate each 1–5 with notes:
   - Install experience:
   - Default config sanity:
   - Error messages clarity:
   - Observability (metrics/logs):
   - Upgrade experience (if tested):

   ## Verdict
   [ ] Recommended for production
   [ ] Viable with caveats (describe):
   [ ] Not recommended (reasons):

   ## Open Issues / Questions Raised
   ```

4. After generating all kits, print a summary:
   ```
   Lab kits generated:
   - ~/.sre-research/<slug>/lab/impl-a/
   - ~/.sre-research/<slug>/lab/impl-b/

   Next steps:
   1. Connect to your remote cluster
   2. For each kit: follow README.md → run test scripts → fill results.md
   3. When done: /sre-research continue <slug>
   ```

5. Update `meta.yaml`: `phase: lab_pending`, `last_updated: <today>`, `lab_kit_generated: <today>`.
