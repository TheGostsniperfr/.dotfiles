# /commit — Smart Git Commit

<!--
  TUTORIAL — Slash Commands
  ═══════════════════════════════════════════════════════════════════════
  This file defines the /commit slash command.
  
  How it works:
  - File name (without .md) becomes the command: /commit
  - The content of this file becomes the prompt Claude receives
  - $ARGUMENTS is replaced with whatever the user typed after /commit
    Example: "/commit fix the auth race condition" → $ARGUMENTS = "fix the auth race condition"
  
  Commands are prompts — write them as instructions to Claude.
  They run in the current project context (Claude sees your open files, git state, etc.)
-->

Create a git commit following this project's conventions.

## Context from user
$ARGUMENTS

## Steps

1. Run `git status` to see what's changed. If nothing is staged, run `git diff` to see unstaged changes.

2. If nothing is staged, ask which files to stage before proceeding. Never stage everything blindly.

3. Run `git log --oneline -5` to understand the commit style used in this specific repo.

4. Run `git diff --staged` (or `git diff` if nothing is staged yet) to fully understand the changes.

5. Check for accidentally staged sensitive files:
   - `.env`, `*.key`, `*.pem`, `credentials.*`, `secrets.*`
   - Files with obvious passwords or tokens
   - Large binary files that shouldn't be committed
   Warn the user and stop if any are found.

6. Draft a commit message following Conventional Commits:
   - Format: `<type>(<scope>): <description>`
   - Subject: max 72 characters, present tense imperative
   - Body: only if WHY is non-obvious (the diff already shows WHAT)

7. Show the user:
   - Which files will be committed (from `--stat`)
   - The proposed commit message
   
   Wait for explicit approval. Do NOT commit automatically.

8. On approval, stage the files and commit.

## Rules
- Never use `--no-verify`
- Never force-push to main/master
- Follow `~/.claude/rules/git.md` for all git conventions
