{ pkgs, lib, config, ... }:

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
      set -euo pipefail
      token=$(cat "${secretPath}")
      export OPENAPI_MCP_HEADERS="{\"Authorization\": \"Bearer ''${token}\"}"
      exec ${pkgs.nodejs_22}/bin/npx -y @notionhq/notion-mcp-server "$@"
    '';

  notionPerso  = mkNotionWrapper "perso"  "/run/secrets/notion_perso_token";
  notionEleves = mkNotionWrapper "eleves" "/run/secrets/notion_eleves_token";

  # code-review-graph (PyPI, not in nixpkgs) — local code-intelligence MCP
  # server used by the project-level .mcp.json in this repo's root.
  # nixpkgs' fastmcp is pinned to 3.2.3, one patch below the minimum this
  # package requires; 3.2.4 carries the CVE-2025-62800/62801/66416 fixes
  # upstream calls out, so we bump it rather than pin to the vulnerable one.
  pythonForCrg = pkgs.python313;
  fastmcp_3_2_4 = pythonForCrg.pkgs.fastmcp.overridePythonAttrs (old: {
    version = "3.2.4";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/9c/13/29544fbc6dfe45ea38046af0067311e0bad7acc7d1f2ad38bb08f2409fe2/fastmcp-3.2.4.tar.gz";
      hash = "sha256-CD7LdbRKQWnn/A9jL5S3gb2w/4d8azW5h3y7Vm/U1NE=";
    };
    # nixpkgs' fastmcp doesn't propagate griffelib; 3.2.4 needs it at runtime.
    dependencies = old.dependencies ++ [ pythonForCrg.pkgs.griffelib ];
    # Upstream's own test suite needs network fixtures unavailable in the
    # Nix sandbox; irrelevant here since we only consume the built wheel.
    doCheck = false;
  });
  codeReviewGraph = pythonForCrg.pkgs.buildPythonApplication rec {
    pname = "code-review-graph";
    version = "2.3.8";
    pyproject = true;
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/b0/45/b37d3a9bc11a93fa625eb910018aa09e160685002e92e3a533d48fda3bb1/code_review_graph-2.3.8.tar.gz";
      hash = "sha256-JF2e8kG0UoEXbPpAFHC6Sb8T5uAKmp/Icv2NG+DvAuA=";
    };
    build-system = [ pythonForCrg.pkgs.hatchling ];
    dependencies = with pythonForCrg.pkgs; [
      mcp
      fastmcp_3_2_4
      tree-sitter
      tree-sitter-language-pack
      pyyaml
      networkx
      watchdog
    ];
    # Upstream test suite expects a git worktree and network fixtures not
    # available in the Nix sandbox.
    doCheck = false;
    # code-review-graph pins tree-sitter-language-pack<1; nixpkgs carries
    # 1.4.1. Verified by smoke-testing a real build: the pin is upstream
    # being conservative, not an actual incompatibility.
    dontCheckRuntimeDeps = true;
    # code-review-graph parses files in worker subprocesses. The default
    # wrapper only mutates sys.path in the parent process (site.addsitedir);
    # spawned children don't inherit that, so tree_sitter_language_pack
    # silently fails to import there and every parser gets skipped. A real
    # PYTHONPATH env var propagates to children.
    makeWrapperArgs = [
      "--set" "PYTHONPATH" (pythonForCrg.pkgs.makePythonPath dependencies)
    ];
  };

  # nixpkgs' claude-code lags npm releases by days-to-weeks (someone has to
  # bump the derivation). We fetch Anthropic's own prebuilt binary directly —
  # same mechanism nixpkgs itself uses (downloads.claude.ai/claude-code-releases) —
  # so we can track npm's "latest" without waiting on a nixpkgs PR.
  # To bump: fetch https://downloads.claude.ai/claude-code-releases/latest and
  # .../<version>/manifest.json for the linux-x64 checksum.
  claudeCodeLatest = pkgs.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    version = "2.1.283";

    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/2.1.283/linux-x64/claude";
      sha256 = "1859583ce32920595c61ef868bee52e1b1594f7486db209935e01f1e5e804ae2";
    };

    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;
    strictDeps = true;

    nativeBuildInputs = [
      pkgs.installShellFiles
      pkgs.makeBinaryWrapper
      pkgs.autoPatchelfHook
    ];

    installPhase = ''
      runHook preInstall

      installBin $src

      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.alsa-lib ]} \
        --prefix PATH : ${lib.makeBinPath [ pkgs.procps pkgs.ripgrep pkgs.bubblewrap pkgs.socat ]}

      runHook postInstall
    '';

    meta = {
      description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      mainProgram = "claude";
      platforms = [ "x86_64-linux" ];
    };
  };

  # Claude Code plugins installed from their marketplaces on every switch.
  # The CLI does not install plugins that are only declared in settings.json (that
  # happens at interactive session start), so activation installs them explicitly.
  # To add one: append { marketplace; repo; plugin; } and rebuild.
  claudePlugins = [
    { marketplace = "noodle"; repo = "TheGostsniperfr/Noodle"; plugin = "noodle"; }
  ];

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
    "linear-server" = {
      type = "http";
      url = "https://mcp.linear.app/mcp";
    };
  });
in

{
  home.packages = with pkgs; [
    claudeCodeLatest
    claude-monitor
    notionPerso
    notionEleves
    codeReviewGraph
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

  # User-invoked skills — each skills/<name>/SKILL.md becomes a /<name> skill.
  home.file.".claude/skills" = {
    source = ./claude/skills;
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

  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CONFIG="${config.home.homeDirectory}/.claude.json"
    if [ -f "$CONFIG" ]; then
      tmpfile=$(mktemp)
      ${pkgs.jq}/bin/jq --slurpfile mcp "${mcpConfigFile}" '.mcpServers = $mcp[0]' "$CONFIG" > "$tmpfile"
      $DRY_RUN_CMD mv "$tmpfile" "$CONFIG"
    fi
  '';

  # Installs claudePlugins if missing, then declares them in settings.json with
  # auto-update. Idempotent, and non-fatal offline: a failed install retries next switch.
  home.activation.claudePlugins = lib.hm.dag.entryAfter [ "claudeSettings" ] ''
    SETTINGS="${config.home.homeDirectory}/.claude/settings.json"
    export PATH="${lib.makeBinPath [ pkgs.git pkgs.coreutils pkgs.gnugrep ]}:$PATH"
    # Public repos: clone over HTTPS and skip the SSH probe, which needs known_hosts.
    export CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1
    claude="${claudeCodeLatest}/bin/claude"
    installed="$($claude plugin list 2>/dev/null || true)"
    ${lib.concatMapStrings (p: ''
      if ! grep -q "${p.plugin}@${p.marketplace}" <<<"$installed"; then
        $DRY_RUN_CMD $claude plugin marketplace add ${p.repo} >/dev/null 2>&1 || true
        $DRY_RUN_CMD $claude plugin install ${p.plugin}@${p.marketplace} >/dev/null 2>&1 \
          || echo "Claude Code: could not install ${p.plugin}@${p.marketplace}, will retry next switch"
      fi
      if [ -f "$SETTINGS" ]; then
        tmpfile=$(mktemp)
        ${pkgs.jq}/bin/jq '.extraKnownMarketplaces["${p.marketplace}"] = {"source":{"source":"github","repo":"${p.repo}"},"autoUpdate":true}
          | .enabledPlugins["${p.plugin}@${p.marketplace}"] = true' "$SETTINGS" > "$tmpfile" \
          && $DRY_RUN_CMD mv "$tmpfile" "$SETTINGS" \
          || rm -f "$tmpfile"
      fi
    '') claudePlugins}
  '';
}
