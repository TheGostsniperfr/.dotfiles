{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "default";
      pane_frames = true;
      ui.pane_frames.rounded_corners = true;
    };
  };
}
