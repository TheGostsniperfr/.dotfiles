{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rstudio
    rPackages.dplyr
    rPackages.ggplot2
    rPackages.cowplot
  ];
}