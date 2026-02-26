{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.minikube
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.terraform
    pkgs.ansible
    pkgs.kubectx
    pkgs.kubeswitch
    pkgs.kustomize
    pkgs.vault
  ];
}
