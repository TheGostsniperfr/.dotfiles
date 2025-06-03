{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.minikube
    pkgs.kubectl
    pkgs.kubernetes-helm
  ];

}
