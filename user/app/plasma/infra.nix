{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.infra;
  system = pkgs.stdenv.hostPlatform.system;

  infraWorkspace = inputs.vicinae.lib.${system}.mkVicinaeExtension {
    pname = "infra-workspace";
    version = "0.1.0";
    src = lib.fileset.toSource {
      root = ./infra-workspace;
      fileset = lib.fileset.unions [
        ./infra-workspace/package.json
        ./infra-workspace/package-lock.json
        ./infra-workspace/tsconfig.json
        ./infra-workspace/src
        ./infra-workspace/assets
      ];
    };
  };

  infraCli = pkgs.writeShellApplication {
    name = "infractx";
    runtimeInputs = [ pkgs.jq pkgs.kubectl ];
    text = ''
      config="''${XDG_CONFIG_HOME:-$HOME/.config}/infra/infras.json"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/infra"
      mkdir -p "$state"

      case "''${1:-current}" in
        current) cat "$state/current" 2>/dev/null || jq -r '.infras | keys[0]' "$config" ;;
        list) jq -r '.infras | to_entries[] | "\(.key)\t\(.value.env)\t\(.value.kube // "")"' "$config" ;;
        set)
          name="''${2:?usage: infractx set <name>}"
          jq -e --arg n "$name" '.infras[$n]' "$config" >/dev/null || { echo "unknown infra: $name" >&2; exit 1; }
          echo "$name" > "$state/current"
          ctx="$(jq -r --arg n "$name" '.infras[$n].kube // empty' "$config")"
          [ -n "$ctx" ] && kubectl config use-context "$ctx" >/dev/null
          echo "$name"
          ;;
        # Called after kubeswitch: follow the context of this shell without
        # touching the global kube config.
        sync)
          ctx="$(kubectl config current-context 2>/dev/null || true)"
          name="$(jq -r --arg c "$ctx" '.infras | to_entries[] | select(.value.kube == $c) | .key' "$config" | head -n1)"
          [ -n "$name" ] && echo "$name" > "$state/current"
          ;;
        *) echo "usage: infractx [current|list|set <name>|sync]" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  options.infra = {
    infras = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
        options = {
          title = lib.mkOption { type = lib.types.str; };
          env = lib.mkOption { type = lib.types.enum [ "prod" "preprod" "staging" "dev" "lab" ]; };
          kube = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          links = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = { }; };
        };
      });
      default = { };
      description = "Infrastructures for the Vicinae Infra Workspace. No secrets: URLs, context names and token file paths only.";
    };
    gitlab = lib.mkOption {
      type = (pkgs.formats.json { }).type;
      default = { host = "gitlab.com"; tokenFile = "/run/secrets/gitlab_com_token"; };
    };
    runbooks = lib.mkOption {
      type = (pkgs.formats.json { }).type;
      default = { dirs = [ "~/.sre-research" ]; };
    };
  };

  config = {
    home.packages = [ infraCli ];
    programs.vicinae.extensions = [ infraWorkspace ];

    xdg.configFile."infra/infras.json".text = builtins.toJSON {
      infras = lib.mapAttrs (_: i: lib.filterAttrs (_: v: v != null) i) cfg.infras;
      inherit (cfg) gitlab runbooks;
    };

    # Contexts come from ~/.kube/config. Fill `links` per infra; the order
    # here is the order in the launcher after the active one.
    infra.infras = {
      talos-prod = { title = "Talos prod"; env = "prod"; kube = "oidc@talos-prod"; };
      talos-preprod = { title = "Talos preprod"; env = "preprod"; kube = "oidc@talos-preprod"; };
      talos-nfra = { title = "Talos nfra"; env = "prod"; kube = "oidc@talos-nfra"; };
      talos-demo = { title = "Talos demo"; env = "lab"; kube = "admin@talos-demo"; };
      ubsi-prod = { title = "UBSI prod"; env = "prod"; kube = "admin@ubsi-prod"; };
      ubsi-staging = { title = "UBSI staging"; env = "staging"; kube = "admin@ubsi-staging"; };
      istor-prod = { title = "3-Istor prod"; env = "prod"; kube = "3-istor-prod@kubernetes"; };
      istor-lab = { title = "3-Istor lab"; env = "lab"; kube = "lab-3-istor-prod@kubernetes"; };
      epimac-prod = { title = "Epimac prod"; env = "prod"; kube = "epimac-prod@kubernetes"; };
      main-k8s = { title = "Main k8s"; env = "prod"; kube = "main-k8s-admin@kubernetes"; };
      pae = { title = "PAE"; env = "dev"; kube = "pae-admin"; };
      runtime-bench = { title = "Runtime bench"; env = "lab"; kube = "runtime-bench"; };
    };
  };
}
