# Security Rules

<!--
  TUTORIAL — Security as Non-Negotiable Rules
  ═══════════════════════════════════════════════════════════════════════
  Security rules are unlike quality rules — they're not preferences, they're
  hard stops. Claude should always flag violations regardless of context.
  
  These cover OWASP Top 10 and common footguns for your stack.
  Add project-specific threat model concerns to the project CLAUDE.md.
-->

## Absolute Prohibitions — Never Do These

- Never hardcode secrets, tokens, passwords, or API keys in source code.
- Never commit `.env` files, `*.key`, `*.pem`, credential files, or anything with a secret value.
- Never disable TLS certificate verification (`InsecureSkipVerify: true`, `verify=False`, `-k`).
- Never use `eval()` or dynamic code execution on any user-controlled input.
- Never store passwords in plain text — always hash with bcrypt, argon2, or scrypt.
- Never log sensitive data (passwords, tokens, PII, card numbers).

## Input Validation (OWASP Top 10)

- **SQL Injection**: always parameterized queries — never string concatenation into SQL.
- **XSS**: always escape/encode user content before rendering in HTML — never raw interpolation.
- **Command Injection**: never pass user input to `exec`, `os/exec`, `subprocess` without strict validation; prefer allowlists.
- **Path Traversal**: validate and sanitize file paths — block `../` traversal, use `filepath.Clean` and check prefix.
- **SSRF**: validate URLs before making outbound requests — block internal/private IP ranges.

## Secrets Management — NixOS Stack

- Use `sops-nix` for secrets (already configured in your dotfiles).
- Reference secrets via environment variables or sops secret paths, never inline values.
- For local dev: `.env` files are acceptable but must be in `.gitignore` and never committed.
- Kubernetes secrets: use sealed-secrets or external-secrets-operator — never raw base64 in manifests.

## Authentication & Authorization

- Verify authorization on **every** request — never assume the frontend enforced it.
- Check resource ownership — "user can access this endpoint" ≠ "user can access this specific record".
- Use short-lived tokens with refresh flows — avoid long-lived static API keys when possible.
- Implement rate limiting on authentication endpoints.

## Dependencies

- Flag dependencies with known CVEs — check `go mod audit`, `npm audit`, `safety check` (Python).
- Prefer minimal dependencies — each package is an attack surface.
- Pin versions in production (`go.sum`, `package-lock.json`, `poetry.lock`) — never floating ranges in prod.

## Code Review Red Flags

Always call out when reviewing:
- `chmod 777` or overly permissive file/directory permissions
- World-readable files containing sensitive config
- Missing authentication checks on admin or sensitive endpoints
- Race conditions in security-critical sections (token validation, permission checks)
- Unvalidated redirects (open redirect → phishing vector)
- Debug endpoints or verbose error messages left in production code
