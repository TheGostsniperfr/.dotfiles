# /explain — Explain Code

<!--
  TUTORIAL — Tailored Explanation Commands
  ═══════════════════════════════════════════════════════════════════════
  This command is persona-aware — it uses your profile from CLAUDE.md
  to calibrate the explanation level. A junior dev and a staff engineer
  should get very different explanations for the same code.
  
  Usage:
    /explain                              → explains the current file/context
    /explain src/scheduler/worker.go      → explains a specific file
    /explain the retry logic in line 45   → explains a specific section
    /explain why we use exponential backoff here
-->

Explain the code or concept: $ARGUMENTS

If no argument is given, explain the last piece of code we discussed or the current open file.

## Calibration

Tailor to my profile (from CLAUDE.md):
- I'm an experienced engineer — skip the basics entirely.
- I know Go, C#/.NET, Python, Kubernetes, NixOS — use analogies to these when helpful.
- Go deep on the WHY (design decisions, trade-offs) more than the WHAT (the code already shows that).
- If this code is part of a larger system, explain how it fits architecturally.

## Structure

1. **TL;DR** — one sentence: what does this do and why does it exist?

2. **Key design decisions** — what choices were made and why? What was the alternative?

3. **Execution flow** (for complex code) — walk through the data or control flow concisely. Use code references with line numbers.

4. **Non-obvious behaviors** — gotchas, edge cases, subtle invariants, implicit assumptions.

5. **If I were refactoring it** — only include this section if there's something genuinely notable (a real anti-pattern, a significant improvement opportunity). Skip if the code is fine.

## Format Notes

- Use file:line references when pointing to specific code: `src/auth/token.go:45`
- Keep it tight — a clear paragraph beats a bloated section with headers.
- If the question is about a concept (not specific code), give me the mental model, not a tutorial.
