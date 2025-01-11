{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cargo
    jetbrains.rust-rover
  ]; 
}