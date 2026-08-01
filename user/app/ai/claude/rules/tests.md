# Testing Rules

<!--
  TUTORIAL — When Rules Override Each Other
  ═══════════════════════════════════════════════════════════════════════
  These are global testing preferences. A project-level CLAUDE.md can
  override specific rules (e.g., "this project uses pytest-bdd, not pytest").
  Project rules always win over global rules when they conflict.
-->

## Core Philosophy

- Tests verify **behavior**, not implementation details.
- If you can refactor the internals without changing any tests, the tests are right.
- Tests that test implementation details become a maintenance burden — they break on every refactor even when behavior is correct.

## Test Naming

- Names must read as sentences describing expected behavior:
  - `TestLogin_ReturnsError_WhenTokenIsExpired`
  - `should return 404 when user does not exist`
  - `validates email format before saving`
- Never: `TestFoo`, `test1`, `testCase3`

## Test Structure

Use Arrange / Act / Assert — separated visually with blank lines:
```
// Arrange
user := createTestUser()
token := generateExpiredToken()

// Act
result, err := auth.Login(user, token)

// Assert
assert.ErrorIs(t, err, ErrTokenExpired)
assert.Nil(t, result)
```

One primary assertion per test where possible. Multiple assertions make it hard to diagnose which one failed.

## Mocking Strategy

- **Integration tests**: prefer real dependencies — mocks mask real failures.
- **Unit tests**: mock only at natural seams (interfaces, not concrete types).
- Mock external services (HTTP APIs, email, payment) and time-dependent behavior.
- Never mock the database in integration tests — use a real test database.
- If mocking reveals an awkward interface, fix the interface.

## Coverage

- Chase coverage of **critical paths** and **error boundaries**, not total percentage.
- 100% coverage with shallow tests is worse than 60% coverage with deep tests.
- Untested code that cannot fail is acceptable.
- Untested code that can fail is not acceptable.

## Go-Specific

- Use `testify/assert` and `testify/require` (require stops the test on failure).
- Table-driven tests for multiple input variations:
  ```go
  tests := []struct{ name, input, expected string }{ ... }
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
- `t.Parallel()` on tests that don't share state.
- Integration tests in `_test` package (tests only the public API, as callers would see it).
- Use `t.TempDir()` for temp files — cleaned up automatically.

## C#/.NET-Specific

- Use xUnit (not MSTest or NUnit unless project already uses them).
- `[Theory]` + `[InlineData]` for parameterized tests.
- Use `FluentAssertions` for readable assertions.
- Avoid `async void` test methods — always `async Task`.
