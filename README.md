# NixOS Flake for VisionFive 2

## Status

* Kernel
  * Based on 6.3-rc1
  * Patches source from the [JH7110 Upstream Plan](https://rvspace.org/en/project/JH7110_Upstream_Plan)
  * See README.md in patches directory for details of what is currently pulled in.

* Uboot with OpenSBI
  * Uses u-boot default boot scripts

* NixOS SD-Card image
  * Boot bug, deadlocks during boot.

## Todo

* Test uboot on SPI
* Scripts to write uboot to SPI
* Scripts to update uboot on MMC without needing to do so manually or create sd-image from scratch.
* Scripts to make the Kernel install on not-nixos.

## Issues

* 8GB board will boot with 4GB of memory exposed due to how vendor uboot patches on-disk dtb with memory size change.
  * Workaround: Write patch to modify memory@40000000 `reg = <0x0 0x40000000 0x2 0x0>;`
  * Solution: Build uboot default boot command to patch the dtb being loaded by extlinux.conf dtbdir in memory.
    * Do not write the patched dtb back to the boot partition after editing it.  **frown**
  * TODO: Confirm this issue is still present with upstream uboot.


## Usage

### NixOS

```
{
  inputs = {
    nixpkgs = ...;
    vf2Bsp.url = "github:nakato/nix-visionfive2-bsp/main";
    vf2Bsp.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixosConfigurations = {
      vf2 = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [
          ...
          {
            boot.kernelPackages = vf2Bsp.packages.riscv64-linux.linuxPackages_visionfive2;
            hardware.deviceTree.filter = "jh7110-starfive-visionfive-2-*.dtb";
          }
        ];
      };
    }
  };
}
```

### Independent build and dirty install

```
nix build .#VF2Kernel
KERNEL_RESULT=$(readlink result)
KERNEL_VERDIR=$(nix eval --raw '.#packages.riscv64-linux.VF2Kernel.modDirVersion')
cat ${KERNEL_RESULT}/Image | gzip > /boot/boot/vmlinuz-testing
mkdir -p /boot/dtbs/${KERNEL_VERDIR}/starfive
cp -r ${KERNEL_RESULT}/dtbs/starfive/* /boot/dtbs/${KERNEL_VERDIR}/starfive/
# jh7110-starfive-visionfive-2-v1.??.dtb -> jh7110-visionfive-v2.dtb
cp /boot/dtbs/${KERNEL_VERDIR}/starfive/jh7110-{starfive-visionfive-2-v1.XX,visionfive-v2}.dtb
ln -s ${KERNEL_RESULT}/lib/modules/${KERNEL_VERDIR} /lib/modules/${KERNEL_VERDIR}
```
