# /sre-research — SRE Research Pipeline Orchestrator

$ARGUMENTS

Master entry point for the SRE research pipeline. Drives the full workflow
from brief capture to Notion publication with mandatory human-in-the-loop checkpoints.

## Pipeline overview

```
[0-brief] → [1-landscape] → ★REVIEW → [2-deepdive] → ★REVIEW → [3-lab] → ★REVIEW → [4-synthesize] → ★REVIEW → [5-write] → ★REVIEW → [6-publish]
```

All state lives in `~/.sre-research/<slug>/`. Never skip a ★REVIEW.

## Usage

- `/sre-research new <slug>` — Start a new research project
- `/sre-research status` — Show all projects and current phases
- `/sre-research continue <slug>` — Resume from current phase after human review
- `/sre-research <phase> <slug>` — Jump to a specific phase (brief/landscape/deepdive/lab/synthesize/write/publish)

---

## Steps

Parse the first word of `$ARGUMENTS` to determine action.

### Action: `new <slug>`

1. `mkdir -p ~/.sre-research/<slug>`
2. Write `~/.sre-research/<slug>/meta.yaml`:
   ```yaml
   topic_slug: <slug>
   created: <today ISO-8601>
   last_updated: <today ISO-8601>
   phase: brief
   deepdive_targets: []
   lab_targets: []
   human_decisions: {}
   notion_urls: {}
   ```
3. Tell the user: "Starting `<slug>`. Entering brief capture now."
4. Execute the `/sre-brief` command logic with `<slug>`.

### Action: `status`

1. `ls ~/.sre-research/` to list all project directories.
2. For each directory, read `meta.yaml` and `brief.yaml` (if exists).
3. Print a table:
   ```
   SLUG                   TOPIC                              PHASE              UPDATED
   kueue-gpu-quotas       Kueue GPU Job Scheduling           synthesize_pending 2026-08-01
   kata-gitlab-runner     GitLab Runner + Kata Containers    landscape_pending  2026-08-03
   ```
4. For any project in a `_pending` phase, remind: "Run `/sre-research continue <slug>` after reviewing."

### Action: `continue <slug>`

1. Read `~/.sre-research/<slug>/meta.yaml`.
2. Act based on `phase` field:

   | phase               | action                                                                                    |
   |---------------------|-------------------------------------------------------------------------------------------|
   | `brief`             | Run brief capture (see `/sre-brief`)                                                      |
   | `landscape_pending` | Ask: "Have you reviewed `landscape.md`? Which implementations to deep-dive? (list names)" |
   | `deepdive`          | Run deepdive for targets not yet completed                                                |
   | `deepdive_pending`  | Ask: "Which implementations to lab-test? (list names or 'all')"                          |
   | `lab`               | Run lab kit generation                                                                    |
   | `lab_pending`       | Ask: "Have you filled in all `results.md` files? Ready to synthesize?"                   |
   | `synthesize`        | Run synthesis phase                                                                       |
   | `synthesis_pending` | Ask: "Review `synthesis.md`. Any scores to adjust? Ready to write documents?"            |
   | `write`             | Run write phase (ask: article/livrable/runbook/all)                                      |
   | `write_pending`     | Ask: "Docs look good? Ready to publish to Notion?"                                       |
   | `publish`           | Run Notion publish                                                                        |
   | `published`         | Show Notion URLs from `meta.yaml`. Offer to update specific documents.                   |

3. After getting human confirmation at any `_pending` phase:
   - Save human answers to `meta.yaml.human_decisions`
   - Advance to the next phase

### Action: `<phase> <slug>`

Execute the named phase directly. Valid values: `brief`, `landscape`, `deepdive`, `lab`, `synthesize`, `write`, `publish`.

Read `brief.yaml` and `meta.yaml` then follow the instructions from the corresponding `/sre-<phase>` command.
