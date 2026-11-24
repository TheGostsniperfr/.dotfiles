{
  lib,
  stdenv,
  cmake,
  pkg-config,
  vulkan-headers,
  vulkan-loader,
  glfw,
  lz4,
  fontconfig,
  freetype,
  libpulseaudio,
  mpv-unwrapped,
  expat,
  wallpaper-engine-plugin,
}:

# The renderer's standalone GLFW viewer, built from the same source as the
# plugin. It renders a scene without Qt or plasmashell, so an artifact that
# shows here comes from the renderer and one that does not comes from the
# frame handoff to Plasma.
stdenv.mkDerivation {
  pname = "wallpaper-sceneviewer";
  inherit (wallpaper-engine-plugin) version src;

  sourceRoot = "${wallpaper-engine-plugin.src.name}/src/backend_scene/standalone_view";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ vulkan-headers vulkan-loader glfw lz4 fontconfig freetype libpulseaudio mpv-unwrapped expat ];

  cmakeFlags = [ (lib.cmakeBool "SCENE_VIEWER_ASAN" false) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 sceneviewer $out/bin/sceneviewer
    runHook postInstall
  '';

  meta = {
    description = "Standalone viewer for Wallpaper Engine scenes (renderer of the KDE plugin)";
    license = lib.licenses.gpl2Only;
    mainProgram = "sceneviewer";
    platforms = lib.platforms.linux;
  };
}
