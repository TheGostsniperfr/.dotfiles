{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python312.withPackages (ps: with ps; [
      pip
      jupyter-core
      notebook
      numpy
      scipy
      matplotlib
      scikit-learn
      scikit-image
      
      pyside6
      requests
      python-dotenv
    ]))

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
