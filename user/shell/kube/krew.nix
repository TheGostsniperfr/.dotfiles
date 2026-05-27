# user/shell/kube/krew.nix
{ pkgs, lib, ... }:

{
  # Install the base krew package (provides the standalone 'krew' binary)
  home.packages = [ pkgs.krew ];

  # Add the Krew binary directory to the user's PATH so kubectl can find the plugins
  home.sessionPath = [
    "$HOME/.krew/bin"
  ];

  # Run this script automatically after each home-manager activation (e.g., during 'update')
  home.activation.installKrewPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Add required dependencies to the temporary activation PATH
    export PATH="${pkgs.krew}/bin:${pkgs.kubectl}/bin:${pkgs.git}/bin:$PATH"
    export PATH="$HOME/.krew/bin:$PATH"

    echo "🔄 Updating Krew index..."
    # Use standalone 'krew' binary since 'kubectl krew' might not exist yet on a fresh install
    krew update || true

    echo "📦 Installing Krew Plugins..."
    # Install 'krew' first to create the 'kubectl-krew' binary, then install the other plugins
    krew install krew resource-capacity modify-secret get-all || true
  '';
}