# /new-feature — Plan-First Feature Implementation

<!--
  TUTORIAL — Plan Mode Pattern
  ═══════════════════════════════════════════════════════════════════════
  This command enforces a plan-before-code discipline.
  The single biggest mistake in AI-assisted coding is letting Claude
  jump straight to writing code before understanding the problem.
  
  This command creates a 4-phase gate: Understand → Plan → Approve → Implement.
  Claude cannot proceed to the next phase without your explicit go-ahead.
  
  Usage:
    /new-feature add JWT refresh token rotation
    /new-feature expose metrics endpoint for Prometheus scraping
    /new-feature add nix devShell for the project
-->

Implement this feature using a plan-first approach: **$ARGUMENTS**

---

## Phase 1 — Understand (read only, no code)

1. If the feature description is ambiguous, ask at most **2 clarifying questions**. Be specific — not "what do you want?" but "should this affect existing sessions or only new ones?"

2. Map the codebase impact:
   - Use `find` and `grep` to locate relevant files
   - Identify entry points, existing patterns, and interfaces this feature must fit
   - Note what already exists vs what's missing

3. Check for similar patterns in the codebase to follow.

**Stop here. Report what you found.**

---

## Phase 2 — Plan

Present a structured implementation plan:

```
## Implementation Plan: <feature name>

### Changes Required
- [ ] <file or module>: <what changes and why>
- [ ] <new file>: <purpose>
- [ ] <dependency>: <why needed>

### Sequence
1. <first step>
2. <second step>
...

### Test Strategy
- Unit tests: <what to test>
- Integration tests: <what to test>
- Manual verification: <what to check>

### Risks & Unknowns
- <anything uncertain or potentially risky>
```

**Wait for explicit approval before writing any code.**

---

## Phase 3 — Implement

After approval, implement step by step:
- One logical unit at a time (one file or one concern per step)
- After each significant step, run existing tests to catch regressions: `go test ./...` or equivalent
- Follow `~/.claude/rules/code-quality.md`, `~/.claude/rules/tests.md`, `~/.claude/rules/security.md`
- If you discover the plan needs adjustment, stop and explain before changing course

---

## Phase 4 — Verify & Close

After implementation:
1. Run the full test suite
2. Run `/review` on the changes
3. Summarize: what was built, what deviates from the plan (and why), what's left to do
