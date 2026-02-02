{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.minikube
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.terraform
    pkgs.kubectx
    pkgs.kustomize
    pkgs.vault
  ];
}
