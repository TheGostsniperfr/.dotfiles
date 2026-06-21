{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (rstudioWrapper.override {
      packages = with rPackages; [
        dplyr
        ggplot2
        cowplot
        corrplot
        FactoMineR
      ];
    })
  ];
}