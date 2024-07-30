{ pkgs, ... }:
let 

  # Shell Aliases :
  myAliases = {

    # Path shortcut
    NC = "cd /etc/nixos";
    HC = "cd && cd .config/home-manager";

    # Bash commands
    BC = "nvim ~/.bashrc";
    SC = "source ~/.bashrc";
    CC = "clear";

    ll = "ls -l";
    ".." = "cd ..";
    ep = "xdg-open ."; # open paht in file explorer

    # Update cmd aliases
    update = "sudo nixos-rebuild switch --flake ~/.dotfiles"; # update configuration file using flake
    hupdate = "home-manager switch --flake ~/.dotfiles"; # update home-manager file using flake
    fupdate = "nix flake update"; #update flake file
    allupdate = "fupdate && update && fupdate"; # update all

    # Git commands
    gs = "git status";
  };
  
in
{
  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };
}