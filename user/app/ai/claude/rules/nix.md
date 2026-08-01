# NixOS / Nix Rules

<!--
  TUTORIAL — Stack-Specific Global Rules
  ═══════════════════════════════════════════════════════════════════════
  Since you're on NixOS, these rules apply globally across all projects.
  They ensure Claude gives NixOS-native advice rather than generic Linux
  advice that would break reproducibility.

  Your dotfiles structure (for Claude's reference):
    ~/.dotfiles/
      flake.nix                    ← root flake, generates all host configs
      flake.lock                   ← pinned inputs (always commit this)
      hosts/<hostname>/            ← host-specific hardware + profile binding
      profiles/<name>/             ← reusable config sets (base, pc, workstation...)
      user/app/<category>/         ← home-manager app modules
      user/shell/                  ← shell config (zsh, bash, cli tools)
      system/                      ← system-level NixOS modules
      secrets/                     ← sops-encrypted secret files
    
  Active hosts: pc, workstation
  nixpkgs channel: nixos-26.05
  home-manager: release-26.05
-->

## Package Installation — Declarative Always

- ALWAYS check nixpkgs first: `nix search nixpkgs <name>` before any other approach.
- User packages: `home.packages = with pkgs; [ ... ];` in the relevant home-manager module under `user/app/`.
- System packages: `environment.systemPackages` in NixOS config (rare — prefer home-manager).
- Dev dependencies: `nix develop` with a project-level `flake.nix` devShell.
- NEVER suggest `apt`, `brew`, `pip install --user`, `npm install -g`, or manual binary installs.
- For packages not in nixpkgs: check NUR first, then write a custom derivation.

## Config File Management

- Prefer NixOS modules over editing files directly in `/etc` or `~`.
- Use `home.file."<path>".source = <src>;` for dotfiles managed by home-manager.
- Use `home.file."<path>" = { source = <src>; recursive = true; };` for directories.
- Use `xdg.configFile."<app>/config"` for XDG-compliant apps.
- Use `programs.<app>` home-manager modules when they exist (they're better than raw home.file).
- Mutable files (written at runtime by apps): use `home.activation` to copy, not symlink.

## Rebuilding — Safe Process

```bash
# Dry run first — always for system changes
sudo nixos-rebuild dry-activate --flake ~/.dotfiles#<hostname>

# Apply system + home-manager changes together
sudo nixos-rebuild switch --flake ~/.dotfiles#<hostname>

# Home-manager only (faster, no sudo)
home-manager switch --flake ~/.dotfiles#<username>@<hostname>

# Check for failures after rebuild
systemctl --failed
journalctl -xe --since "5 minutes ago"
```

- Always dry-activate before switching on system changes.
- If rebuild fails: check `journalctl -xe`, look for activation script errors.
- Roll back with: `sudo nixos-rebuild switch --rollback`

## Flakes Best Practices

- Always commit `flake.lock` — it's the reproducibility guarantee.
- Use `follows` to deduplicate nixpkgs instances: `inputs.X.inputs.nixpkgs.follows = "nixpkgs";`
- Prefer `nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"` over `nixos-unstable` in production.
- Test new derivations with `nix build .#<package>` before adding to a profile.
- Use `nix flake check` before pushing flake changes.

## Writing Derivations

```nix
# Minimal correct derivation
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.2.3";
  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # fill with nix-prefetch
  };
  meta.mainProgram = "my-tool";  # required for `nix run`
}
```

- Always include a real hash — never `lib.fakeHash` in committed code.
- Get hashes with: `nix-prefetch-url --unpack <url>` or let nix fail once to print the expected hash.
- Use language-specific builders: `buildGoModule`, `buildNpmPackage`, `buildPythonPackage`.

## Secrets — sops-nix

```nix
# In NixOS config
sops.secrets."my-secret" = {
  owner = userSettings.username;
};

# Reference in other options
environment.variables.MY_VAR = config.sops.secrets."my-secret".path;
# Or for services:
systemd.services.myservice.serviceConfig.EnvironmentFile = config.sops.secrets."my-secret".path;
```

- Never put plaintext secrets in any `.nix` file.
- Encrypt new secrets with: `sops ~/.dotfiles/secrets/<file>.yaml`
- Secrets files live in `~/.dotfiles/secrets/` and are age/gpg encrypted.

## Anti-Patterns — Never Do These

- `nix-env -i` — breaks reproducibility, use declarative config.
- `--impure` flag in committed scripts or CI.
- Mutating `/etc`, `/nix/store`, or system paths directly.
- `pkgs.callPackage` when a direct attribute path exists.
- Using `builtins.fetchurl` without a hash.
- Leaving `lib.fakeHash` or `lib.fakeSha256` in committed code.
