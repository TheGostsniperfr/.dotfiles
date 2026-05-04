{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nodejs
  ];

  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  home.activation.installGemini =
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"

      mkdir -p "$HOME/.npm-global"

      echo "Installing / updating gemini-cli..."
      ${pkgs.nodejs}/bin/npm install -g @google/gemini-cli@latest
    '';
}