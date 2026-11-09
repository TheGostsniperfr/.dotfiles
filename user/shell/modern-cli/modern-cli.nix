{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  # Provides `, <cmd>` to run any nixpkgs binary without installing it.
  programs.nix-index-database.comma.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$kubernetes$golang$python$cmd_duration$line_break$character";
      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
      };
      git_status.format = "([$all_status$ahead_behind]($style) )";
      kubernetes = {
        disabled = false;
        format = "[⎈ $context(/$namespace)]($style) ";
      };
      nix_shell.format = "[ $state]($style) ";
      cmd_duration.min_time = 2000;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      update_check = false;
      style = "compact";
      inline_height = 20;
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  # Empty disables fzf's Ctrl-R binding so atuin keeps it.
  home.sessionVariables.FZF_CTRL_R_COMMAND = "";

  programs.eza = {
    enable = true;
    enableBashIntegration = false;
    git = true;
    icons = "auto";
  };

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.lazygit.enable = true;

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
  };
}
