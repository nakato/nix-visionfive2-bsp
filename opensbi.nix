{ fetchFromGitHub
, opensbi
, uboot
, ...
}:
let
  opensbiHead = opensbi.overrideAttrs (oldAttrs: {
    version = "1.3-pre";
    src = fetchFromGitHub {
      owner = "riscv-software-src";
      repo = "opensbi";
      rev = "4b28afc98bbe406e3ad6f4a97d0fe96a882e83a1";
      hash = "sha256-AoqMcKEZvFYfiFFOefhom6cinp1qvdxyzh+YzKQ1Vlk=";
    };

    # See https://github.com/starfive-tech/VisionFive2/blob/b5c6a9d6b49453f6aee49a5e30175f45dd32b3b7/Makefile#L279
    # Is this a temporary limitation, or a permanent flag that needs to be added to nixpkgs?
    makeFlags = oldAttrs.makeFlags ++ [ "FW_TEXT_START=0x40000000" ];
  });
in
opensbiHead.override {
  withPayload = "${uboot}/u-boot.bin";
  withFDT = "${uboot}/u-boot.dtb";
}
