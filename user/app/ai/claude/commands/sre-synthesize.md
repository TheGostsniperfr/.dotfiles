# /sre-synthesize — Phase 4: Synthesis

$ARGUMENTS — topic-slug

Transform all collected research data into structured, actionable analysis.
Spawns the `research-analyst` agent. This is the intellectual core of the pipeline.

---

## Steps

1. Read `brief.yaml`, `meta.yaml`, all files in `deepdives/`, and all `lab/*/results.md` files.

2. Check lab results:
   - If no `results.md` files are filled in: warn the user.
   - Note which implementations are lab-validated vs desk-research-only.
   - Proceed regardless — mark unverified data clearly.

3. Build the synthesis task for the `research-analyst` agent:

   ---
   **Task for research-analyst:**

   Synthesize the SRE research on: **<topic_name>**

   Goal: <goal>
   Criteria weights (from brief): performance=<N>, complexity=<N>, security=<N>, documentation=<N>, maturity=<N>, features=<N>, migration=<N>
   Implementations analyzed: <list>
   Lab-tested implementations: <list or "none">

   Source files to read:
   - Brief: `~/.sre-research/<slug>/brief.yaml`
   - Deep dives: `~/.sre-research/<slug>/deepdives/*.md`
   - Lab results: `~/.sre-research/<slug>/lab/*/results.md` (if present)

   Produce the following sections in `~/.sre-research/<slug>/synthesis.md`:

   ---
   # Synthesis: <topic_name>
   *Date: <today> | Status: <Lab-validated / Desk-research only>*

   ## 1. Confidence Matrix
   Table showing what data is lab-validated vs desk-research vs inferred:
   | Implementation | Architecture | Features | Performance | Ops | Security |
   | Note: mark each cell: ✅ Lab-tested | 📄 Docs-verified | ❓ Inferred |

   ## 2. Weighted Scoring Matrix
   Score each implementation 1–5 on each criterion. Multiply by weight. Show totals.
   | Implementation | Perf×W | Complexity×W | Security×W | Docs×W | Maturity×W | Features×W | Migration×W | **Total** |
   Rules:
   - Reserve 5 for genuinely exceptional. 3 = adequate. 1 = serious problem.
   - Explain every score below 3 or above 4.
   - Mark lab-derived scores with [L], desk-research scores with [D].

   ## 3. Feature Comparison Table
   Side-by-side of all implementations vs all features relevant to the use case.
   | Feature | Impl A | Impl B | Impl C |
   | Mark: Native / Extension / Planned / Not Supported |

   ## 4. Choice Matrix (When to Use What)
   This must be prescriptive, not observational. Decision rules, not preferences.
   Format:
   **Use <Impl A> when:**
   - <specific condition 1>
   - <specific condition 2>
   **Avoid <Impl A> when:**
   - <specific condition>
   **Use <Impl B> when:**
   ...

   ## 5. Risk Register
   Per implementation, top 3–5 concrete risks:
   | Implementation | Risk | Severity | Signal/Evidence | Mitigation |
   Severity: Critical / High / Medium / Low
   Only include risks backed by evidence (GitHub issues, CVEs, benchmark data, known incidents).

   ## 6. Architecture Decision Record (ADR)
   Format:
   **Status:** Proposed / Accepted / Deprecated
   **Context:** What is the problem and why does it matter now?
   **Decision Drivers:** (numbered list from brief criteria)
   **Options Considered:** (one paragraph per implementation)
   **Decision:** <Recommended option or "Pending lab validation for X">
   **Rationale:** Why this over the others?
   **Consequences:** What changes operationally? What becomes harder?
   **Review Date:** <6 months from today>

   ## 7. SLO/SLI Impact Analysis
   For the top 2–3 implementations: what changes in your observability targets?
   - Latency impact during migration (with numbers where available)
   - Error budget consumption estimate for the cutover
   - New failure modes introduced (and corresponding SLO coverage needed)

   ## 8. Capacity Delta
   Resource overhead comparison:
   | Implementation | Control Plane CPUm | Control Plane MiB | Per-Node Overhead | Notes |
   Use benchmark data or documented resource requirements. Mark as [ESTIMATED] if not from actual data.

   ## 9. Migration Path Analysis
   For each implementation:
   - Migration strategy from current state (<current_state>)
   - Zero-downtime possible? If yes, how?
   - Rollback complexity (time, steps, risk)
   - Estimated migration effort (person-days, rough)

   ---

   Save to: `~/.sre-research/<slug>/synthesis.md`
   ---

4. Spawn `research-analyst` agent with the task above.

5. After completion, read `synthesis.md` and present to the user:
   - The weighted scoring matrix (top-level summary)
   - The ADR decision field
   - Any Critical risks found

6. Update `meta.yaml`: `phase: synthesis_pending`, `last_updated: <today>`, `synthesis_completed: <today>`.

7. Tell the user:
   ```
   Synthesis complete. Full output: ~/.sre-research/<slug>/synthesis.md

   Key things to verify:
   - Scoring matrix: do the scores match your judgment?
   - Choice matrix: are the decision rules correct for your context?
   - ADR: does the recommendation make sense?
   - Adjust anything in the file, then:

     /sre-research continue <slug>
   ```
