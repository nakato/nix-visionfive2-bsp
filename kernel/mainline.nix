{ copyPathToStore
, fetchzip
, lib
, linuxKernel
, recurseIntoAttrs
, ...
}:
let
  src = fetchzip {
    url = "https://git.kernel.org/torvalds/t/linux-6.3-rc1.tar.gz";
    hash = "sha256-t+9z4zooZa6aSQB9YSCF0n8bWwhynH99wMq1bfIG+RE=";
  };

  # customPackage closure copied from: nixpkgs/pkgs/top-level/linux-kernels.nix
  customPackage = { version, src, modDirVersion ? lib.versions.pad 3 version, configfile, allowImportFromDerivation ? true, kernelPatches }:
    recurseIntoAttrs (linuxKernel.packagesFor (linuxKernel.manualConfig {
      inherit version src modDirVersion configfile allowImportFromDerivation kernelPatches;
    }));

  kernelPatches = [
    {
      name = "0001-clk-starfive-Factor-out-common-JH7100-and-JH7110-cod.patch";
      patch = ./patches/0001-clk-starfive-Factor-out-common-JH7100-and-JH7110-cod.patch;
    }
    {
      name = "0002-clk-starfive-Rename-clk-starfive-jh7100.h-to-clk-sta.patch";
      patch = ./patches/0002-clk-starfive-Rename-clk-starfive-jh7100.h-to-clk-sta.patch;
    }
    {
      name = "0003-clk-starfive-Rename-jh7100-to-jh71x0-for-the-common-.patch";
      patch = ./patches/0003-clk-starfive-Rename-jh7100-to-jh71x0-for-the-common-.patch;
    }
    {
      name = "0004-reset-Create-subdirectory-for-StarFive-drivers.patch";
      patch = ./patches/0004-reset-Create-subdirectory-for-StarFive-drivers.patch;
    }
    {
      name = "0005-reset-starfive-Factor-out-common-JH71X0-reset-code.patch";
      patch = ./patches/0005-reset-starfive-Factor-out-common-JH71X0-reset-code.patch;
    }
    {
      name = "0006-reset-starfive-Extract-the-common-JH71X0-reset-code.patch";
      patch = ./patches/0006-reset-starfive-Extract-the-common-JH71X0-reset-code.patch;
    }
    {
      name = "0007-reset-starfive-Rename-jh7100-to-jh71x0-for-the-commo.patch";
      patch = ./patches/0007-reset-starfive-Rename-jh7100-to-jh71x0-for-the-commo.patch;
    }
    {
      name = "0008-reset-starfive-jh71x0-Use-32bit-I-O-on-32bit-registe.patch";
      patch = ./patches/0008-reset-starfive-jh71x0-Use-32bit-I-O-on-32bit-registe.patch;
    }
    {
      name = "0009-dt-bindings-clock-Add-StarFive-JH7110-system-clock-a.patch";
      patch = ./patches/0009-dt-bindings-clock-Add-StarFive-JH7110-system-clock-a.patch;
    }
    {
      name = "0010-dt-bindings-clock-Add-StarFive-JH7110-always-on-cloc.patch";
      patch = ./patches/0010-dt-bindings-clock-Add-StarFive-JH7110-always-on-cloc.patch;
    }
    {
      name = "0011-clk-starfive-Add-StarFive-JH7110-system-clock-driver.patch";
      patch = ./patches/0011-clk-starfive-Add-StarFive-JH7110-system-clock-driver.patch;
    }
    {
      name = "0012-clk-starfive-Add-StarFive-JH7110-always-on-clock-dri.patch";
      patch = ./patches/0012-clk-starfive-Add-StarFive-JH7110-always-on-clock-dri.patch;
    }
    {
      name = "0013-reset-starfive-Add-StarFive-JH7110-reset-driver.patch";
      patch = ./patches/0013-reset-starfive-Add-StarFive-JH7110-reset-driver.patch;
    }
    {
      name = "0014-dt-bindings-timer-Add-StarFive-JH7110-clint.patch";
      patch = ./patches/0014-dt-bindings-timer-Add-StarFive-JH7110-clint.patch;
    }
    {
      name = "0015-dt-bindings-interrupt-controller-Add-StarFive-JH7110.patch";
      patch = ./patches/0015-dt-bindings-interrupt-controller-Add-StarFive-JH7110.patch;
    }
    {
      name = "0016-dt-bindings-riscv-Add-SiFive-S7-compatible.patch";
      patch = ./patches/0016-dt-bindings-riscv-Add-SiFive-S7-compatible.patch;
    }
    {
      name = "0017-riscv-dts-starfive-Add-initial-StarFive-JH7110-devic.patch";
      patch = ./patches/0017-riscv-dts-starfive-Add-initial-StarFive-JH7110-devic.patch;
    }
    {
      name = "0018-riscv-dts-starfive-Add-StarFive-JH7110-pin-function-.patch";
      patch = ./patches/0018-riscv-dts-starfive-Add-StarFive-JH7110-pin-function-.patch;
    }
    {
      name = "0019-riscv-dts-starfive-Add-StarFive-JH7110-VisionFive-2-.patch";
      patch = ./patches/0019-riscv-dts-starfive-Add-StarFive-JH7110-VisionFive-2-.patch;
    }
    {
      name = "0020-riscv-dts-starfive-Add-mmc-node.patch";
      patch = ./patches/0020-riscv-dts-starfive-Add-mmc-node.patch;
    }
    {
      name = "0021-dt-bindings-syscon-Add-StarFive-syscon-doc.patch";
      patch = ./patches/0021-dt-bindings-syscon-Add-StarFive-syscon-doc.patch;
    }
    {
      name = "0022-dt-bindings-net-snps-dwmac-Add-dwmac-5.20-version.patch";
      patch = ./patches/0022-dt-bindings-net-snps-dwmac-Add-dwmac-5.20-version.patch;
    }
    {
      name = "0023-net-stmmac-platform-Add-snps-dwmac-5.20-IP-compatibl.patch";
      patch = ./patches/0023-net-stmmac-platform-Add-snps-dwmac-5.20-IP-compatibl.patch;
    }
    {
      name = "0024-dt-bindings-net-snps-dwmac-Add-an-optional-resets-si.patch";
      patch = ./patches/0024-dt-bindings-net-snps-dwmac-Add-an-optional-resets-si.patch;
    }
    {
      name = "0025-dt-bindings-net-Add-support-StarFive-dwmac.patch";
      patch = ./patches/0025-dt-bindings-net-Add-support-StarFive-dwmac.patch;
    }
    {
      name = "0026-riscv-dts-starfive-jh7110-Add-ethernet-device-nodes.patch";
      patch = ./patches/0026-riscv-dts-starfive-jh7110-Add-ethernet-device-nodes.patch;
    }
    {
      name = "0027-net-stmmac-Add-glue-layer-for-StarFive-JH7110-SoC.patch";
      patch = ./patches/0027-net-stmmac-Add-glue-layer-for-StarFive-JH7110-SoC.patch;
    }
    {
      name = "0028-dt-bindings-net-starfive-jh7110-dwmac-Add-starfive-s.patch";
      patch = ./patches/0028-dt-bindings-net-starfive-jh7110-dwmac-Add-starfive-s.patch;
    }
    {
      name = "0029-net-stmmac-starfive_dmac-Add-phy-interface-settings.patch";
      patch = ./patches/0029-net-stmmac-starfive_dmac-Add-phy-interface-settings.patch;
    }
    {
      name = "0030-riscv-dts-starfive-jh7110-Add-syscon-to-support-phy-.patch";
      patch = ./patches/0030-riscv-dts-starfive-jh7110-Add-syscon-to-support-phy-.patch;
    }
    {
      name = "0031-riscv-dts-starfive-visionfive-2-v1.3b-Add-gmac-phy-s.patch";
      patch = ./patches/0031-riscv-dts-starfive-visionfive-2-v1.3b-Add-gmac-phy-s.patch;
    }
    {
      name = "0032-riscv-dts-starfive-visionfive-2-v1.2a-Add-gmac-phy-s.patch";
      patch = ./patches/0032-riscv-dts-starfive-visionfive-2-v1.2a-Add-gmac-phy-s.patch;
    }
    {
      name = "0033-riscv-dts-starfive-visionfive-2-Enable-gmac-device-t.patch";
      patch = ./patches/0033-riscv-dts-starfive-visionfive-2-Enable-gmac-device-t.patch;
    }
  ];

  kernelPackages = customPackage {
    inherit kernelPatches src;
    modDirVersion = "6.3.0-rc1";
    version = "6.3.0-rc1";
    configfile = copyPathToStore ./vf2_6.3-pre.config;
  };
in
kernelPackages
