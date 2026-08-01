# Code Quality Rules

<!--
  TUTORIAL — Global vs Project Rules
  ═══════════════════════════════════════════════════════════════════════
  Rules in this file apply globally to all projects.
  Language-specific or project-specific rules belong in the project's
  own CLAUDE.md (or .claude/rules/) and override these.

  Over time, this file should reflect your hard-won preferences —
  the things Claude gets wrong repeatedly until you write them down.
-->

## General Principles

- Solve the problem at hand. No over-engineering, no premature abstraction.
- Three similar lines is better than a wrong abstraction.
- No half-finished implementations — if something is incomplete, say so explicitly rather than leaving a TODO.
- Delete dead code completely — never comment it out as a "backup".
- No backwards-compatibility shims for code that has no external consumers.

## Comments

Default: **no comments**.

Only write a comment when the WHY is non-obvious:
- A hidden constraint or external requirement
- A subtle invariant that would surprise a reader
- A deliberate workaround for a known bug with a link or reference
- Counter-intuitive behavior that looks like a bug but isn't

Never write:
- Comments explaining WHAT the code does (the code already says that)
- Comments referencing the current task, PR, or caller ("used by X", "added for issue #123")
- Multi-paragraph docstrings or comment blocks
- `// TODO` without an owner and a deadline

## Error Handling

- Validate at system boundaries: HTTP handlers, CLI arg parsing, env var loading, external API calls.
- Trust internal code — don't re-validate inside pure functions or between modules you control.
- Fail fast and loudly on truly unexpected states — silent failures are worse than crashes.
- No swallowing errors with empty catch blocks.

## Naming

- Names are self-documenting — if you need a comment to explain a name, rename it.
- Prefer explicit over terse: `userAuthToken` not `t`, `maxRetryCount` not `n`.
- Booleans: name as assertions — `isEnabled`, `hasPermission`, `canRetry`.
- Functions/methods: verb phrases — `fetchUser`, `validateToken`, `buildConfig`.

## Go-Specific

- Return errors, don't panic in library code (panics are acceptable in `main` for unrecoverable startup failures).
- Use `context.Context` for cancellation and timeouts — always the first parameter.
- Wrap errors with context: `fmt.Errorf("operationName: %w", err)`.
- Avoid goroutine leaks — always ensure goroutines can be cancelled.
- Prefer `errors.Is` / `errors.As` over string matching for error checks.
- Table-driven tests with `t.Run` for subtests.

## C#/.NET-Specific

- `async/await` consistently — never `.Result` or `.Wait()` on async code (deadlock risk).
- Enable nullable reference types: `<Nullable>enable</Nullable>`.
- Prefer `record` for immutable data transfer objects.
- `IDisposable`: always use `using` declarations, never manual `Dispose()` calls.
- Avoid `dynamic` — use generics or interfaces instead.

## Python-Specific

- Type hints on all function signatures.
- Prefer `dataclasses` or `pydantic` over raw dicts for structured data.
- Context managers (`with`) for resources — never manual open/close.
- Avoid mutable default arguments (`def f(lst=[])` is a classic footgun).
