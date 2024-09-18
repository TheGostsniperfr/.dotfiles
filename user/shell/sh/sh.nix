{ pkgs, ... }:
let 

  # Shell Aliases :
  myAliases = {

    # Path shortcut
    NC = "cd /etc/nixos";
    HC = "cd && cd .config/home-manager";
    CF = "cd ~/.dotfiles";
    CCF = "code ~/.dotfiles";

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

    # Epita tool alias : 
    aepita = "cd ~/Documents/aepita/";
    lmounette = "source ~/Documents/aepita/pyenv/mounette/bin/activate";
    lcms = "source ~/Documents/aepita/pyenv/cms/bin/activate";
    spyenv = "deactivate";

  };
  
in
{
  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };
}