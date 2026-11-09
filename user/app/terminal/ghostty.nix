{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      window-padding-x = 10;
      window-padding-y = 8;
      window-padding-balance = true;
      background-opacity = 0.95;
      cursor-style = "bar";
      cursor-style-blink = false;
      mouse-hide-while-typing = true;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      shell-integration-features = "cursor,sudo,title";
    };
  };
}
