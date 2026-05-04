{ pkgs, ... }:

let
  ptAppImage = pkgs.stdenv.mkDerivation {
    name = "pt9-appimage";
    src = ./CiscoPacketTracer_900_Ubuntu_64bit.deb;
    
    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;
    
    nativeBuildInputs = [ pkgs.dpkg ];

    installPhase = ''
      mkdir -p $out
      dpkg -x $src temp_dir
      cp temp_dir/opt/pt/packettracer.AppImage $out/
    '';
  };

  packetTracer9 = pkgs.appimageTools.wrapType2 {
    pname = "packettracer9";
    version = "9.0.0";
    src = "${ptAppImage}/packettracer.AppImage";
    
    extraPkgs = pkgs: with pkgs; [
      libpng xorg.libxkbfile stdenv.cc.cc.lib alsa-lib dbus expat 
      fontconfig freetype glib libGL libdrm libglvnd libpulseaudio 
      libxkbcommon libxml2 libxslt nspr nss udev wayland zlib
      xorg.libICE xorg.libSM xorg.libX11 xorg.libXScrnSaver 
      xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext 
      xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender 
      xorg.libXtst xorg.libxcb xorg.xcbutilcursor xorg.xcbutilimage 
      xorg.xcbutilkeysyms xorg.xcbutilrenderutil xorg.xcbutilwm
    ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/cisco-pt9.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Cisco Packet Tracer 9 (Offline)
Exec=packettracer9 %f
MimeType=application/x-pkt;application/x-pka;application/x-pkz;
Terminal=false
Categories=Network;
EOF
    '';
  };

in
{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      packettracer9 = {
        executable = "${packetTracer9}/bin/packettracer9";
        desktop = "${packetTracer9}/share/applications/cisco-pt9.desktop";
        extraArgs = [
          "--net=none"
          "--noprofile"
        ];
      };
    };
  };
}