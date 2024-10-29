{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python312
    python312Packages.pip
    python312Packages.jupyter-core
    python312Packages.notebook
    python312Packages.numpy
    python312Packages.scipy
    python312Packages.matplotlib
    python312Packages.scikit-learn
    python312Packages.scikit-image
    stdenv.cc.cc.lib
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
}
