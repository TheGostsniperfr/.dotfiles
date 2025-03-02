{ config, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "DejaVu Sans Mono" "IPAGothic" ];
    sansSerif = [ "DejaVu Sans" "IPAPGothic" ];
    serif = [ "DejaVu Serif" "IPAPMincho" ];
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
