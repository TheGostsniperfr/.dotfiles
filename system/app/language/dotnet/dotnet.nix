{ pkgs, ... }:

{
  environment.systemPackages = [
    # pkgs.dotnet-sdk_7
    # pkgs.dotnet-runtime_7 
    pkgs.dotnet-sdk_8
    pkgs.dotnet-runtime_8
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-7.0.410"
    "dotnet-runtime-7.0.20"
  ];
}