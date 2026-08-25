{
  stdenv,
  lib,
  fetchurl,
  rpm,
  cpio,
  glib,
  gusb,
  pixman,
  libgudev,
  nss,
  libfprint,
  cairo,
  pkg-config,
  autoPatchelfHook,
  makePkgconfigItem,
  copyPkgconfigItems,
}:

let
  libso = "libfprint-2.so.2.0.0";

  # fprintd >= 1.94.5 requires libfprint >= 1.94.9 at configure time, but the blob
  # is 1.94.4. Every fp_* symbol fprintd links against is present, so only the
  # advertised version needs to change.
  pkgConfigVersion = "1.94.10";
in
stdenv.mkDerivation rec {
  pname = "libfprint-focaltech-2808-a658";
  version = "1.94.4";

  # Mirror of the FocalTech RPM: the vendor repo (ftfpteams) now returns HTTP 451,
  # which is why nixpkgs dropped this package. Hash matches the one nixpkgs pinned.
  src = fetchurl {
    url = "https://raw.githubusercontent.com/vladejj/Debian-and-Fedora-fingerprin-setup-for-a658-sensor/034193c48cf1b5503b838b4a9b013479ac50bf29/drivers/fedora/libfprint-2-2-${version}%2Btod1-FT9366_20240627.x86_64.rpm";
    hash = "sha256-MRWHwBievAfTfQqjs1WGKBnht9cIDj9aYiT3YJ0/CUM=";
  };

  nativeBuildInputs = [
    rpm
    cpio
    pkg-config
    autoPatchelfHook
    copyPkgconfigItems
  ];

  buildInputs = [
    stdenv.cc.cc
    glib
    gusb
    pixman
    nss
    libgudev
    libfprint
    cairo
  ];

  unpackPhase = ''
    runHook preUnpack

    rpm2cpio $src | cpio -idmv

    runHook postUnpack
  '';

  pkgconfigItems = [
    (makePkgconfigItem rec {
      name = "libfprint-2";
      version = pkgConfigVersion;
      inherit (meta) description;
      cflags = [ "-I${variables.includedir}/libfprint-2" ];
      libs = [
        "-L${variables.libdir}"
        "-lfprint-2"
      ];
      variables = rec {
        prefix = "${placeholder "out"}";
        includedir = "${prefix}/include";
        libdir = "${prefix}/lib";
      };
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm444 usr/lib64/${libso} -t $out/lib

    ln -s -T $out/lib/${libso} $out/lib/libfprint-2.so
    ln -s -T $out/lib/${libso} $out/lib/libfprint-2.so.2

    # The blob ships no headers or typelib; reuse upstream libfprint's.
    cp -r ${libfprint}/lib/girepository-1.0 $out/lib
    cp -r ${libfprint}/include $out

    runHook postInstall
  '';

  meta = {
    description = "FocalTech FT9366 fingerprint driver for 0x2808:0xa658";
    homepage = "https://github.com/vladejj/Debian-and-Fedora-fingerprin-setup-for-a658-sensor";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
