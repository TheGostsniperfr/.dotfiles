# /nix-rebuild — Safe NixOS Rebuild

<!--
  TUTORIAL — Commands that Encode Multi-Step Workflows
  ═══════════════════════════════════════════════════════════════════════
  This command wraps a risky multi-step operation in a safe, guided flow.
  It demonstrates how slash commands aren't just shortcuts — they can
  encode hard-won safety practices so you never skip steps under pressure.
  
  Usage:
    /nix-rebuild              → prompts for which host
    /nix-rebuild pc           → rebuilds the pc host
    /nix-rebuild workstation  → rebuilds the workstation host
    /nix-rebuild home         → runs home-manager switch only (no sudo)
-->

Guide a safe NixOS rebuild for: $ARGUMENTS

## Pre-flight Checks

Before anything else:

1. Check for uncommitted changes to nix files that would be excluded from the build:
   ```bash
   git -C ~/.dotfiles status --short -- '*.nix' flake.lock
   ```
   If there are uncommitted changes, warn the user — the build may not reflect current edits.

2. Verify the flake evaluates without errors (fast, no build):
   ```bash
   nix flake check ~/.dotfiles 2>&1 | head -30
   ```

## Determine Target

If no argument given or argument is ambiguous, ask: "Which target — `pc`, `workstation`, or `home` (home-manager only)?"

Known hosts: `pc`, `workstation`

## Dry Run First (mandatory for system targets)

For `pc` or `workstation`:
```bash
sudo nixos-rebuild dry-activate --flake ~/.dotfiles#<hostname> 2>&1
```

Show the user a summary of what will change (activated units, switched packages).
**Wait for explicit confirmation before proceeding to the actual switch.**

For `home` (home-manager only):
```bash
home-manager build --flake ~/.dotfiles 2>&1 | tail -20
```

## Apply

On confirmation:

**System rebuild:**
```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#<hostname> 2>&1
```

**Home-manager only:**
```bash
home-manager switch --flake ~/.dotfiles 2>&1
```

## Post-rebuild Health Check

After a successful switch:
```bash
systemctl --failed --no-legend
journalctl -p err --since "3 minutes ago" --no-pager | head -20
```

Report any failed units or recent errors. If found, help diagnose them.

## On Failure

If the rebuild fails:
1. Show the last 30 lines of output.
2. Identify the likely cause (derivation build failure, activation script error, etc.).
3. Suggest a fix or offer to investigate further.
4. Remind the user they can roll back with: `sudo nixos-rebuild switch --rollback`

## Safety Rules

- NEVER skip the dry-activate for system changes.
- NEVER use `--impure` unless the user explicitly requests it (and warn them it breaks reproducibility).
- NEVER suggest `--no-check` or bypassing flake evaluation.
