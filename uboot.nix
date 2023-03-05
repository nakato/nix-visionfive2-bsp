{ buildUBoot
, fetchpatch
, fetchurl
, ...
}:
buildUBoot rec {
  defconfig = "starfive_visionfive2_defconfig";
  extraMeta.platforms = ["riscv64-linux"];

  version = "2023.04-rc3";
  src = fetchurl {
    url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
    hash = "sha256-qJDaub99znHoNneN6AJUuyF+ZBoqqPx4FxAqnC3eLZQ=";
  };

  extraPatches = [
     # Basic JH7110 support
     # https://patchwork.ozlabs.org/project/uboot/cover/20230118081132.31403-1-yanhong.wang@starfivetech.com/
     # arch/riscv/Kconfig patch updated for ax25 -> andesv5 change
     ./patches/uboot-basic-jh7110.mbox
     # JH7110 PCIe
     # https://patchwork.ozlabs.org/project/uboot/cover/20230223105240.15180-1-minda.chen@starfivetech.com/
     (fetchpatch {
       url = "https://patchwork.ozlabs.org/series/343341/mbox/";
       hash = "sha256-8GTllhw7Nb3bIGQnAkCkKSyz89P3Ut+AGOwRxK+ieB4=";
    })
  ];

  # StarFive need to add support to binman, use specific targets so build doesn't fail at binman.
  extraMakeFlags = [ "u-boot.bin" "u-boot.dtb" ];

  filesToInstall = [ "u-boot.bin" "u-boot.dtb"];
}
