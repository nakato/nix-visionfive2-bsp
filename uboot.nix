{ buildUBoot
, fetchpatch
, fetchurl
, ubootTools
, opensbi
, spl_tool
, ...
}:
let
  version = "2023.04-rc3";
  src = fetchurl {
    url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
    hash = "sha256-qJDaub99znHoNneN6AJUuyF+ZBoqqPx4FxAqnC3eLZQ=";
  };
in
{
  visionFive2 = buildUBoot rec {
    defconfig = "starfive_visionfive2_defconfig";
    extraMeta.platforms = [ "riscv64-linux" ];

    inherit version src;

    extraPatches = [
      # Basic JH7110 support v3
      # https://patchwork.ozlabs.org/project/uboot/cover/20230303032432.7837-1-yanhong.wang@starfivetech.com/
      (fetchpatch {
        url = "https://patchwork.ozlabs.org/series/344525/mbox/";
        hash = "sha256-QD0fLd4hdYQhl4iX7MoHWT6O2Qkfcrhg1owtIxrg3Ic=";
      })

      # JH7110 PCIe
      # Not yet applied: Doesn't apply cleanly with v3 patch above, and not important to me yet.
    ];

    # StarFive need to add support to binman, use specific targets so build doesn't fail at binman.
    # extraMakeFlags = [ "u-boot.bin" "u-boot.dtb" "spl/u-boot-spl.bin" ];
    extraMakeFlags = [ "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin" ];

    postBuild = ''
      ${spl_tool}/bin/spl_tool -c -f spl/u-boot-spl.bin
    '';

    filesToInstall = [ "u-boot.itb" "spl/u-boot-spl.bin.normal.out" ];
  };

  ubootTools = ubootTools.overrideAttrs (oldAttrs: {
    inherit src version;
  });
}
