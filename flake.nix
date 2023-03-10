{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = 
    { nixpkgs
    , self
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.riscv64-linux;
    in
    {
      formatter.riscv64-linux = pkgs.nixpkgs-fmt;

      packages.riscv64-linux =
      let
        # TODO: Make minimal config less minimal outside of the drivers sphere.
        VF2LinuxHeadMimimalStatic = pkgs.callPackage ./kernel/mainline.nix { };

        uboot = pkgs.callPackage ./uboot.nix {
          opensbi = self.packages.riscv64-linux.opensbiVisionFive2;
          spl_tool = self.packages.riscv64-linux.spl_tool;
        };
      in
      {
        linuxPackages_visionfive2 = VF2LinuxHeadMimimalStatic;
        # Convenience alias to kernel derivation
        linuxKernel_visionfive2 = VF2LinuxHeadMimimalStatic.kernel;

        opensbiVisionFive2 = pkgs.callPackage ./opensbi.nix { };

	spl_tool = pkgs.callPackage ./spl_tool.nix { };

        ubootVisionFive2 = uboot.visionFive2;
        ubootTools = uboot.ubootTools;
      };

      nixosConfigurations = {
        visionfive2 = nixpkgs.lib.nixosSystem {
          system = "riscv64-linux";
          specialArgs = { inherit self; vf2uboot = self.packages.riscv64-linux.ubootVisionFive2; };
          modules = [
            ./sd-image.nix
            ({self, lib, config, ...}: {
              boot.kernelPackages = self.packages.riscv64-linux.linuxPackages_visionfive2;
              # Can't include modules we don't have into initrd, so force these empty, we can boot without modules.
              # Remove once kernel building with real config.
              boot.initrd.availableKernelModules = lib.mkForce [];
              boot.initrd.kernelModules = lib.mkForce [];

              # CONFIG_DMIID doesn't exist on non-ACPI platforms
              system.requiredKernelConfig = lib.mkForce (builtins.map config.lib.kernelConfig.isEnabled
                [ "DEVTMPFS" "CGROUPS" "INOTIFY_USER" "SIGNALFD" "TIMERFD" "EPOLL" "NET"
                  "SYSFS" "PROC_FS" "FHANDLE" "CRYPTO_USER_API_HASH" "CRYPTO_HMAC"
                  "CRYPTO_SHA256" "AUTOFS4_FS" "TMPFS_POSIX_ACL"
                  "TMPFS_XATTR" "SECCOMP"
                ]);
            })
          ];
        };
      };
    };
}
