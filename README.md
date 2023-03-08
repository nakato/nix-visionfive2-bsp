# NixOS Flake for VisionFive 2

## Status

* Kernel
  * Based on master after the 6.2 release cycle.
  * Patches source from the [JH7110 Upstream Plan](https://rvspace.org/en/project/JH7110_Upstream_Plan)
  * See README.md in patches directory for details of what is currently pulled in.

* Uboot with OpenSBI
  * Boots; no boot scripting

## Todo/Issues

* Scripts to write the above onto system SPI/MMC and make SD image.

Issues:
* 8GB board will boot with 4GB of memory exposed due to how vendor uboot patches on-disk dtb with memory size change.
  * Workaround: Write patch to modify memory@40000000 `reg = <0x0 0x40000000 0x2 0x0>;`
  * Solution: Build uboot default boot command to patch the dtb being loaded by extlinux.conf dtbdir in memory.
    * Do not write the patched dtb back to the boot partition after editing it.  **frown**


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
            boot.kernelPackages = vf2Bsp.packages.riscv64-linux.VF2KernelPackages;
            # NOTICE: Vendor uboot looks for uboot env file at <BOOTPART>/boot/uEnv.txt and only looks for
            # "jh7110-visionfive-v2.dtb" by default. On a booted system this is `/boot/boot/uEnv.txt`
            # You want uboot to load jh7110-starfive-visionfive-2-v1.2a.dtb if your board has 1x1GbE and 1xFastEthernet.
            # You want uboot to load jh7110-starfive-visionfive-2-v1.3b.dtb if your board has 2x1GbE.
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
