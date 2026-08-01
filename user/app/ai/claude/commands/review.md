# /review — Code Review

<!--
  TUTORIAL — Commands with Arguments
  ═══════════════════════════════════════════════════════════════════════
  Usage examples:
    /review                        → reviews all uncommitted changes
    /review src/auth/token.go      → reviews a specific file
    /review 42                     → reviews PR #42 (uses gh CLI)
    /review --security             → focuses only on security issues
  
  $ARGUMENTS captures everything after /review and is injected below.
-->

Perform a structured code review.

## Scope
$ARGUMENTS

- If a file path is given: review that specific file against HEAD.
- If a PR number is given: `gh pr diff <number>` to get the diff.
- If `--security` flag: focus exclusively on security issues.
- If nothing given: `git diff HEAD` — all uncommitted changes.

## Review Process

Read ALL changed files completely before writing any findings. Don't comment file-by-file while reading — understand the full change first, then report.

Check in this order:

### 1. Correctness (highest priority)
- Does the logic actually do what it claims?
- Edge cases: empty inputs, null/nil, overflow, concurrent access, off-by-one?
- Are error paths handled or silently swallowed?

### 2. Security (OWASP Top 10 + stack-specific)
- Injection (SQL, command, path traversal, XSS)?
- Authentication/authorization bypasses?
- Secrets or sensitive data in code or logs?
- Insecure defaults (TLS, permissions, timeouts)?

### 3. Performance
- N+1 queries or loops with DB calls?
- Missing indexes on queried columns?
- Unbounded memory growth?
- Blocking calls in async contexts?

### 4. Code Quality
- Follows `~/.claude/rules/code-quality.md`?
- Unnecessary complexity or premature abstraction?
- Dead code, commented-out blocks?

### 5. Tests
- Critical paths covered?
- Tests verify behavior, not implementation?
- Missing edge case coverage?

## Output Format

Group findings by severity. Use this exact format for each finding:

```
[CRITICAL] file.go:45 — Description of the issue.
  Why it matters: concrete impact.
  Fix: specific suggested change.

[MAJOR] file.go:82 — Description.
  Fix: ...

[MINOR] file.go:12 — Description.

[NIT] file.go:7 — Optional style/preference note.
```

Severity definitions:
- **CRITICAL**: security vulnerability or correctness bug — must fix before merge
- **MAJOR**: significant quality issue, missing critical tests, performance problem at scale
- **MINOR**: should fix but not blocking
- **NIT**: optional, personal preference

End with:
- Overall verdict: `APPROVE` / `REQUEST CHANGES` / `NEEDS DISCUSSION`
- Top 3 must-fix items if any
