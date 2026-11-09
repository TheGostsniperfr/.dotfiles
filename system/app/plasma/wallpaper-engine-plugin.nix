{
  lib,
  mkKdeDerivation,
  fetchFromGitHub,
  pkg-config,
  vulkan-headers,
  libplasma,
  plasma5support,
  plasma-activities,
  kconfig,
  kcoreaddons,
  kpackage,
  knotifications,
  kcrash,
  kglobalaccel,
  ki18n,
  kxmlgui,
  kwindowsystem,
  qtwebchannel,
  qtwebengine,
  qtmultimedia,
  fontconfig,
  freetype,
  libpulseaudio,
  libglvnd,
  libgbm,
  lz4,
  mpv-unwrapped,
  vulkan-loader,
}:

# Maintained fork of catsout's plugin. The nixpkgs build of the original
# segfaults plasmashell under Qt 6.11 as soon as the wallpaper type is picked.
mkKdeDerivation rec {
  pname = "wallpaper-engine-kde-plugin";
  version = "1.5-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "CaptSilver";
    repo = "wallpaper-engine-kde-plugin";
    # Past v1.5 for the scene frame handoff and GPU sync fixes, which
    # cause particle artifacts and EGL crashes on NVIDIA.
    rev = "474dc8a3d41ce019dac4272f70b63fddf9bd26ec";
    hash = "sha256-W6xr0XVA16N5yf/hTEb9iN1AfAd/csQV5xFwJZ6ujXM=";
    fetchSubmodules = true;
  };

  extraNativeBuildInputs = [
    pkg-config
    vulkan-headers
  ];

  extraBuildInputs = [
    libplasma
    plasma5support
    plasma-activities
    kconfig
    kcoreaddons
    kpackage
    knotifications
    kcrash
    kglobalaccel
    ki18n
    kxmlgui
    kwindowsystem
    qtwebchannel
    qtwebengine
    qtmultimedia
    fontconfig
    freetype
    libpulseaudio
    libglvnd
    libgbm
    lz4
    mpv-unwrapped
    vulkan-loader
  ];

  extraCmakeFlags = [
    (lib.cmakeBool "USE_PLASMAPKG" false)
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  meta = {
    description = "KDE Plasma 6 wallpaper plugin for Wallpaper Engine scenes, videos and web wallpapers";
    homepage = "https://github.com/CaptSilver/wallpaper-engine-kde-plugin";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
