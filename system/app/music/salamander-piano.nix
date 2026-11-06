{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "salamander-grand-piano";
  version = "3";

  src = fetchFromGitHub {
    owner = "sfzinstruments";
    repo = "SalamanderGrandPiano";
    rev = "3382bf9496bba2486f5ab0de55a264d1dfc38404";
    hash = "sha256-PpTh8QPHgtU6JGYKZkbBrIhlQMg+ykJBGlOzge9Qfl8=";
  };

  installPhase = ''
    mkdir -p $out/share/sounds/sfz/salamander
    cp -r . $out/share/sounds/sfz/salamander/
  '';
}
