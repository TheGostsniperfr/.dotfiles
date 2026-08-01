# Git Workflow Rules

<!--
  TUTORIAL — Rule Files
  ═══════════════════════════════════════════════════════════════════════
  Rule files are modular instruction sets loaded by Claude based on context.
  You can reference them explicitly in any prompt:
    "Follow @rules/git.md when creating this commit"
  Or Claude may pick them up automatically via skills that trigger on keywords
  like "commit", "branch", "PR", etc.

  Refine these over time — when Claude does something wrong with git,
  add a rule here so it never happens again.
-->

## Commit Messages — Conventional Commits Format

Format: `<type>(<scope>): <short description>`

Types:
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code restructure, no behavior change
- `perf` — performance improvement
- `test` — adding or fixing tests
- `docs` — documentation only
- `chore` — build, deps, tooling
- `ci` — CI/CD pipeline changes
- `style` — formatting, whitespace (no logic change)

Rules:
- Subject line: max 72 characters
- Present tense imperative: "add feature" not "added feature"
- Body: only when WHY is non-obvious — never summarize what the diff already shows
- Never add "Co-Authored-By" unless I explicitly ask

## Commit Behavior

- NEVER commit without explicit user request — always wait for approval
- NEVER use `--no-verify` to bypass hooks — fix the underlying issue instead
- NEVER force-push to `main` or `master`
- Before staging, always show `git diff --stat` so the user sees the scope
- Stage specific files by name — never `git add .` or `git add -A` blindly
- Check for accidentally staged `.env`, secrets, or large binaries before committing

## Branching Strategy

- Feature branches: `feat/<short-kebab-name>`
- Bug fix branches: `fix/<short-description>`
- Always branch from latest `main`/`master`
- Prefer rebase over merge to keep history linear
- Delete branches after merge

## Pull Requests

- PR title: same Conventional Commits format as commit messages
- PR body must include: Summary (bullet points), Test plan (checklist), Breaking changes if any
- Never self-approve — create the PR, let it be reviewed
- Link the related issue if one exists
