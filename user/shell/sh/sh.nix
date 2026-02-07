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
    BC = "vim ~/.bashrc";
    SC = "source ~/.bashrc";
    CC = "clear";

    ll = "ls -l";
    ".." = "cd ..";
    # ep = "xdg-open ."; # open path in file explorer
    lc = "nix-shell -p criterion";

    k = "kubectl";
    kw = "watch kubectl";

    # SSH alias
    sshmaster = "ssh master-node@192.168.1.73";
    sshworker01 = "ssh worker-01@192.168.1.168";


    # Update cmd aliases
    update = "sudo nixos-rebuild switch --flake ~/.dotfiles"; # update configuration file using flake
    hupdate = "home-manager switch --flake ~/.dotfiles"; # update home-manager file using flake
    fupdate = "nix flake update"; #update flake file
    allupdate = "fupdate; update; fupdate"; # update all

    # Git commands
    gs = "git status";
    gpp = "git pull";
    gp = "git push";
    ga = "git add .";
    # gc = "git commit -m " + curl -s "https://whatthecommit.com/index.txt" 

    # Epita tool alias : 
    aepita = "cd ~/Documents/aepita/";
    lmounette = "source ~/Documents/aepita/pyenv/mounette/bin/activate";
    lcms = "source ~/Documents/aepita/pyenv/cms/bin/activate";
    spyenv = "deactivate";
    apc="cd /home/brian/Documents/aepita/ing1/piscine/epita-ing-assistants-acu-piscine-2027-brian.perret";
    infra="cd ~/Documents/arffornia/infra";
    epimac="cd ~/Documents/epimac";

    # Epita SM alias:
    initepita = "bash ~/afs/.dotfiles/profiles/epita/init.sh";

    # Arffornia alias:
    arffornia = "cd ~/Documents/arffornia/";

    # === LinOffice Aliases ===
    linoffice = "bash ~/.local/bin/linoffice/linoffice.sh";
    loffice-stop = "linoffice --stopcontainer";
    # loffice-reset = "linoffice reset"; 

    word = "linoffice word";
    excel = "linoffice excel";
    ppt = "linoffice powerpoint";
    outlook = "linoffice outlook";
  };
  
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myAliases;

    initExtra = ''
      # kubectl Autocompletion
      source <(kubectl completion bash)
      complete -F __start_kubectl k
    '';
  };

  home.sessionVariables = {
    PGDATA = "~/postgres_data";
    PGHOST = "/run/postgresql";
    
    GTK_IM_MODULE="fcitx";
    QT_IM_MODULE="fcitx";
    XMODIFIERS="@im=fcitx";
    SDL_IM_MODULE="fcitx";
    GLFW_IM_MODULE="ibus";
  };
}