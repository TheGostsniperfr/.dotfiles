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

    # OpenCV runtime deps
    libGL
    libGLU
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    glib        

    stdenv.cc.cc.lib
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libGL
      pkgs.libGLU
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXinerama
      pkgs.xorg.libXcursor
      pkgs.xorg.libXi
      pkgs.glib      
      pkgs.stdenv.cc.cc.lib
    ];
  };
}
