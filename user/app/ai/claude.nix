{ pkgs, pkgs-unstable, lib, config, ... }:

#
# TUTORIAL — Managing Claude Code Config with Home Manager
# ══════════════════════════════════════════════════════════════════════════
# Claude Code reads its config from ~/.claude/ at startup. We manage most
# of this directory declaratively via home-manager, keeping it version-
# controlled in your dotfiles.
#
# Two strategies are used depending on whether the file is mutable or not:
#
#   Read-only files (Claude reads, never writes):
#     → home.file with source = ./claude/...
#     → Creates a symlink to the nix store (read-only, reproducible)
#     → Files: CLAUDE.md, rules/, commands/, agents/
#
#   Mutable files (Claude Code writes to them at runtime):
#     → home.activation copies the template once; never overwrites after that
#     → Files: settings.json (Claude writes permissions/hooks to it)
#
# The claude/ subdirectory next to this file contains all the actual config:
#   claude/CLAUDE.md            ← global system prompt / profile
#   claude/settings.json        ← template (copied once to ~/.claude/)
#   claude/rules/*.md           ← modular rule files (git, security, nix…)
#   claude/commands/*.md        ← custom slash commands (/commit, /review…)
#   claude/agents/*.md          ← specialized sub-agent definitions
#
# MCP Servers (mcpServers in settings.json)
# ══════════════════════════════════════════
# MCP servers are managed declaratively here. home.activation.claudeMcpServers
# overwrites the mcpServers key in settings.json on every rebuild.
# Tokens are read at MCP startup time from sops secrets in /run/secrets/.
# To add a new MCP server: add a wrapper below and rebuild.
#

let
  # Creates a wrapper script that injects the Notion API token from a sops
  # secret file before launching the MCP server.
  mkNotionWrapper = name: secretPath:
    pkgs.writeShellScriptBin "notion-mcp-${name}" ''
      token=$(cat "${secretPath}")
      export OPENAPI_MCP_HEADERS="{\"Authorization\": \"Bearer ''${token}\"}"
      exec ${pkgs.nodejs_22}/bin/npx -y @notionhq/notion-mcp-server "$@"
    '';

  notionPerso  = mkNotionWrapper "perso"  "/run/secrets/notion_perso_token";
  notionEleves = mkNotionWrapper "eleves" "/run/secrets/notion_eleves_token";

  # Written to the Nix store so activation can read it without quoting issues.
  mcpConfigFile = pkgs.writeText "claude-mcp-servers.json" (builtins.toJSON {
    "notion-perso" = {
      command = "${notionPerso}/bin/notion-mcp-perso";
      args = [];
    };
    "notion-eleves" = {
      command = "${notionEleves}/bin/notion-mcp-eleves";
      args = [];
    };
  });
in

{
  home.packages = with pkgs; [
    pkgs-unstable.claude-code
    claude-monitor
    notionPerso
    notionEleves
  ];

  # ── Read-only config (symlinked from nix store) ────────────────────────

  # Global CLAUDE.md — your permanent system prompt to Claude.
  # Edit ~/.dotfiles/user/app/ai/claude/CLAUDE.md, then rebuild home-manager.
  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;

  # Modular rule files — referenced as @rules/git.md in prompts.
  # Each file = one concern (git, security, tests, nix…). Edit independently.
  home.file.".claude/rules" = {
    source = ./claude/rules;
    recursive = true;
  };

  # Custom slash commands — each .md file becomes a /command-name command.
  # Usage: /commit, /review, /explain, /nix-rebuild, /new-feature
  home.file.".claude/commands" = {
    source = ./claude/commands;
    recursive = true;
  };

  # Specialized agents — spawned by the orchestrator for specific tasks.
  # code-reviewer (Opus), explorer (Sonnet, read-only), nix-expert (Opus)
  home.file.".claude/agents" = {
    source = ./claude/agents;
    recursive = true;
  };

  # ── Mutable config (copied once, then user-owned) ──────────────────────

  # settings.json is written to by Claude Code (permissions, hooks, env…).
  # Strategy: copy the dotfiles template on first activation only.
  # To reset to template: rm ~/.claude/settings.json && home-manager switch
  #
  # TUTORIAL — home.activation
  # ════════════════════════════
  # home.activation runs shell scripts after home-manager's writeBoundary.
  # Use $DRY_RUN_CMD prefix on commands that change state — this makes them
  # print-only during `home-manager build` (dry runs) and execute normally
  # during `home-manager switch`.
  # entryAfter ["writeBoundary"] ensures symlinks are already in place first.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_SRC="${config.home.homeDirectory}/.dotfiles/user/app/ai/claude/settings.json"
    SETTINGS_DST="${config.home.homeDirectory}/.claude/settings.json"

    if [ ! -f "$SETTINGS_DST" ]; then
      echo "Claude Code: initializing settings.json from dotfiles template..."
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.claude"
      $DRY_RUN_CMD cp "$SETTINGS_SRC" "$SETTINGS_DST"
    fi
  '';

  # Overwrites the mcpServers key on every rebuild — manage all MCP servers here.
  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "claudeSettings" ] ''
    SETTINGS="${config.home.homeDirectory}/.claude/settings.json"
    if [ -f "$SETTINGS" ]; then
      tmpfile=$(mktemp)
      ${pkgs.jq}/bin/jq --slurpfile mcp "${mcpConfigFile}" '.mcpServers = $mcp[0]' "$SETTINGS" > "$tmpfile"
      $DRY_RUN_CMD mv "$tmpfile" "$SETTINGS"
    fi
  '';
}
