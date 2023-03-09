{ config, lib, pkgs, vf2uboot, ... }:
with lib;
let
  rootfsImage = pkgs.callPackage (pkgs.path + "/nixos/lib/make-ext4-fs.nix") {
    storePaths = config.system.build.toplevel;
    compressImage = false;
    volumeLabel = "root";
  };
in {
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  # Should be able to use systemd-boot or grub on these boards, but extlinux
  # is the easiest to use here.
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems = {
    "/boot" = {
      device = "/dev/by-uuid/2178-694E";
      fsType = "vfat";
      options = [ "nofail" "noauto" ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };
  };
  system.stateVersion = "23.05";

  system.build.sdImage = pkgs.callPackage (
    { stdenv, dosfstools, e2fsprogs, gptfdisk, mtools, libfaketime, util-linux, zstd, uboot }: stdenv.mkDerivation {
      name = "nixos-visionfive2-sd";
      nativeBuildInputs = [
        dosfstools e2fsprogs gptfdisk libfaketime mtools util-linux
        # zstd
      ];
      buildInputs = [ uboot ];
      imageName = "nixos-visionfive2-sd";
      compressImage = false;

      buildCommand = ''
        # 512MB should provide room enough for a couple of kernels
        bootPartSizeMB=512
        root_fs=${rootfsImage}

        mkdir -p $out/nix-support $out/sd-image
        export img=$out/sd-image/nixos-visionfive2-sd.raw

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
        echo "file sd-image $img" >> $out/nix-support/hydra-build-products

        ## Sector Math
        # SPL size is 4096 and starts at 4096 to give an easy alignment on 2MB boundary
        splStart=4096
        splEnd=8191
        # OpenSBI + U-boot: 4MB
        ubootStart=8192
        ubootEnd=16383
        # End staticly sized partitions

        bootSizeBlocks=$((bootPartSizeMB * 1024 * 1024 / 512))
        bootPartStart=$((ubootEnd + 1))
        bootPartEnd=$((bootPartStart + bootSizeBlocks - 1))

        rootSizeBlocks=$(du -B 512 --apparent-size $root_fs | awk '{ print $1 }')
        rootPartStart=$((bootPartEnd + 1))
        rootPartEnd=$((rootPartStart + rootSizeBlocks - 1))

        # Image size is firmware + boot + root + 100s
        # Last 100s is being lazy about GPT backup, which should be 36s is size.

        imageSize=$((ubootEnd + 1 + bootSizeBlocks + rootSizeBlocks + 100))
        imageSizeB=$((imageSize * 512))

        truncate -s $imageSizeB $img

        # Create a new GPT data structure
        sgdisk -o $img
        # JH7110 bootrom looks for the next stage via GPT typecode
        # NOTICE: There's a gotcha here, the type-code is the same as SiFive uses, but is backwards.
        sgdisk -n 1:$splStart:$splEnd -t 1:2E54B353-1271-4842-806F-E436D6AF6985 $img
        # Documentation says next stage, OpenSBI+U-Boot requires the following type-code, but AFAICT u-boot
        # is simply loading the second partition.  I don't think we hand control back to bootrom for it to boot
        # this stage.
        sgdisk -n 2:$ubootStart:$ubootEnd -t 2:BC13C2FF-59E6-4262-A352-B275FD6F7172 $img

        # EFI Firmware Partition
        # We're not actually using it in EFI mode, but you could, so give it the ESP typecode.
        sgdisk -n 3:$bootPartStart:$bootPartEnd -t 3:C12A7328-F81F-11D2-BA4B-00A0C93EC93B $img

        sgdisk -n 4:$rootPartStart:$rootPartEnd -t 4:0FC63DAF-8483-4772-8E79-3D69D8477DE4 $img

        # Copy firmware
        dd conv=notrunc if=${uboot}/u-boot-spl.bin.normal.out of=$img seek=4096
        dd conv=notrunc if=${uboot}/u-boot.itb of=$img seek=8192

        # Create vfat partition for ESP and in this case populate with extlinux config and kernels.
        truncate -s $((bootSizeBlocks * 512)) bootpart.img
        mkfs.vfat --invariant -i 0x2178694e -n ESP bootpart.img
        mkdir ./boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./boot
        # Reset dates
        find boot -exec touch --date=2000-01-01 {} +
        cd boot
        for d in $(find . -type d -mindepth 1 | sort); do
          faketime "2000-01-01 00:00:00" mmd -i ../bootpart.img "::/$d"
        done
        for f in $(find . -type f | sort); do
          mcopy -pvm -i ../bootpart.img "$f" "::/$f"
        done
        cd ..

        fsck.vfat -vn bootpart.img
        dd conv=notrunc if=bootpart.img of=$img seek=$bootPartStart

        # Copy root filesystem
        dd conv=notrunc if=$root_fs of=$img seek=$rootPartStart
      '';
    }
  ) { uboot = vf2uboot; };
}
