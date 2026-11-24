{ lib, buildGoModule, makeWrapper, libnotify, kdePackages, procps }:

buildGoModule {
  pname = "desk";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [ ./go.mod ./main.go ];
  };
  vendorHash = null;
  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/desk --suffix PATH : ${lib.makeBinPath [ libnotify kdePackages.qttools procps ]}
  '';
  meta.mainProgram = "desk";
}
