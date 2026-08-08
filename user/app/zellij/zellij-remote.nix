{ lib, ... }:
{
  programs.zellij.enableBashIntegration = true;

  # Override the module default ("false") to auto-attach to existing sessions on SSH
  home.sessionVariables.ZELLIJ_AUTO_ATTACH = lib.mkForce "true";
}
