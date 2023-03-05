{ fetchFromGitHub
, lib
, stdenv
, ...
}:
stdenv.mkDerivation {
  name = "spl_tool";
  version = "20230301-8c5acc4";
  src = fetchFromGitHub {
    owner = "starfive-tech";
    repo = "Tools";
    rev = "8c5acc4e5eb7e4ad012463b05a5e3dbbfed1c38d";
    hash = "sha256-Kf9+68lsctVcG765Tv9R6g1Px8RCHUKzbIg23+o9E3g=";
  };

  sourceRoot = "source/spl_tool";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp spl_tool $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/starfive-tech/Tools/tree/master/spl_tool";
    description = "spl_tool prepares spl binary for JH7110";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
