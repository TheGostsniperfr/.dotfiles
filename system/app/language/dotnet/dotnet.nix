{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.dotnet-sdk_7
    pkgs.dotnet-runtime_7 
  ];
}