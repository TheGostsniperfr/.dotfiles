{ config, pkgs, userSettings, lib, ... }:

let
  cluster = import ../../vars/forge-k3s-lab/cluster-vars.nix;
  
  # On récupère dynamiquement le nom du noeud en cours de build
  hostName = config.networking.hostName; 
  
  # On extrait ses infos depuis le dictionnaire
  myNode = cluster.nodes.${hostName};
  
  # Logique : Suis-je le master initial ?
  isInitMaster = cluster.initMaster == hostName;
  
  # On récupère l'IP du master initial pour que les autres s'y connectent
  masterIp = cluster.nodes.${cluster.initMaster}.ip;
in
{
  imports =[
    ./hardware-configuration.nix
    ../../profiles/k3s/configuration.nix
  ];

  home-manager.users.${userSettings.username} = import ../../profiles/k3s/home.nix;

  # --- CONFIGURATION RESEAU ---
  networking.interfaces.${myNode.interface}.ipv4.addresses =[{
    address = myNode.ip;
    prefixLength = 24;
  }];

  # --- CONFIGURATION K3S ---
  services.k3s = {
    # server (master) ou agent (worker)
    role = myNode.role; 

    # true uniquement pour node-1, false pour les autres
    clusterInit = isInitMaster; 
    
    # Si je suis le master initial, pas d'URL. Sinon, je pointe vers le master 1.
    serverAddr = if isInitMaster then "" else "https://${masterIp}:6443";
    
    # On ajoute le flag de l'interface spécifique à ce noeud
    extraFlags = toString[
      "--flannel-iface ${myNode.interface}"
    ];
  };
}