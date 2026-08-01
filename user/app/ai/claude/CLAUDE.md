# Brian's Global Claude Configuration

<!--
  TUTORIAL — CLAUDE.md (Global)
  ═══════════════════════════════════════════════════════════════════════
  This file is read by Claude at the start of EVERY conversation,
  across ALL projects. It's your permanent global system prompt.

  Rules:
  - Keep it under 100 lines — it's a router, not an encyclopedia.
  - Project-specific rules belong in the project's own CLAUDE.md.
  - Don't document code here — it goes in per-project CLAUDE.md.
  - This file is symlinked from your dotfiles, managed by home-manager.

  Location hierarchy (highest to lowest priority):
    ~/.claude/CLAUDE.md         ← this file (global, all projects)
    <project>/.claude/CLAUDE.md ← project-level (git-tracked with project)
    <project>/CLAUDE.md         ← project-level alternative
-->

## Profile

- **Name**: Brian Perret
- **Email**: brianperret.pro@gmail.com
- **Role**: Software Engineer / DevOps / Infrastructure
- **Primary Stack**: Go, C#/.NET, Python, Nix/NixOS, Kubernetes, OpenStack
- **OS**: NixOS — always suggest Nix-native solutions first (packages, home-manager modules, nix shells)
- **Language**: French speaker, but always respond in **English** unless I write in French first

## Communication Style

- Be concise. No filler, no trailing summaries of what you just did.
- No emojis unless I ask.
- I'm an experienced engineer — skip basics, don't over-explain.
- When something is ambiguous, ask ONE clarifying question, not a list.
- For exploratory questions: give a recommendation + the main tradeoff in 2-3 sentences. Don't implement until I agree.

## Coding Preferences

- Default scripting language: Go or Bash (Bash only for simple glue)
- Config management: always NixOS/home-manager when possible, never `apt`/`brew`/manual
- No comments explaining WHAT code does — only WHY if it would surprise a future reader
- No unnecessary abstractions — solve the problem at hand
- Prefer reading specific lines over entire large files
- Validate at system boundaries, trust internal invariants

## Global Rules (modular files)

<!--
  TUTORIAL — Modular Rules
  ═══════════════════════════════════════════════════════════════════════
  Instead of cramming all rules here, we keep them in separate files.
  This lets you refine git rules without touching security rules, etc.
  Claude picks these up from ~/.claude/rules/ — you can reference them
  explicitly in a prompt: "follow @rules/git.md for this commit".
  Skills can also auto-load them based on detected context keywords.
-->

- **Git workflow**: see `~/.claude/rules/git.md`
- **Code quality**: see `~/.claude/rules/code-quality.md`
- **Testing**: see `~/.claude/rules/tests.md`
- **Security**: see `~/.claude/rules/security.md`
- **NixOS / Nix**: see `~/.claude/rules/nix.md`

## Custom Commands

<!--
  TUTORIAL — Slash Commands
  ═══════════════════════════════════════════════════════════════════════
  Commands in ~/.claude/commands/*.md become /command-name slash commands.
  Type them in any conversation. $ARGUMENTS captures anything you type after.
  Example: /commit fix the auth bug
-->

- `/commit` — smart git commit with diff review + conventional message
- `/review [file or PR]` — structured code review (CRITICAL/MAJOR/MINOR/NIT)
- `/explain [target]` — explain code tailored to my experience level
- `/nix-rebuild [hostname]` — safe NixOS rebuild with dry-activate first
- `/new-feature <description>` — plan-then-implement workflow for new features

## Workflow

- After completing any code review (inline or via `/review`), always ask: "Do you want me to commit, push, and open a MR/PR?"

## Agents

<!--
  TUTORIAL — Specialized Agents
  ═══════════════════════════════════════════════════════════════════════
  Agents in ~/.claude/agents/*.md are specialized Claude instances with
  their own model, tools, and persona. The main Claude spawns them for
  specific tasks. They are isolated — they can't see the main conversation.
  
  Useful for:
  - Parallel work (multiple agents on different tasks simultaneously)
  - Isolation (agent reads code without polluting main context)
  - Specialization (code-reviewer uses Opus for deep reasoning)
-->

- `code-reviewer` — Opus-powered thorough code review agent
- `explorer` — Fast Sonnet read-only codebase mapping agent
- `nix-expert` — NixOS/Nix specialist with full dotfiles context
