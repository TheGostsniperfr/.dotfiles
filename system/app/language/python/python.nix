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
    libX11
    libXext
    libXrender
    libXinerama
    libXcursor
    libXi
    glib        

    stdenv.cc.cc.lib
  ];

environment.sessionVariables = {
    LD_LIBRARY_PATH = [  
      (pkgs.lib.makeLibraryPath[
        pkgs.libGL
        pkgs.libGLU
        pkgs.libX11
        pkgs.libXext
        pkgs.libXrender
        pkgs.libXinerama
        pkgs.libXcursor
        pkgs.libXi
        pkgs.glib      
        pkgs.stdenv.cc.cc.lib
      ])
    ];  
  };
}
