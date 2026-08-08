# user/shell/kube/krew.nix
{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.krew ];

  home.sessionPath = [
    "$HOME/.krew/bin"
  ];

  home.activation.installKrewPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.krew}/bin:${pkgs.kubectl}/bin:${pkgs.git}/bin:$PATH"
    export PATH="$HOME/.krew/bin:$PATH"

    if [ ! -d "$HOME/.krew/store/resource-capacity" ]; then
      echo "Updating Krew index..."
      krew update || true

      echo "Installing Krew Plugins..."
      krew install krew resource-capacity modify-secret get-all || true
    fi
  '';
}
