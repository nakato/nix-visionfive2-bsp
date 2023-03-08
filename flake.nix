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
        VF2LinuxHeadMimimalStatic = pkgs.callPackage ./vf2_linux_mainline_head.nix { };
        uboot = pkgs.callPackage ./uboot.nix {
          opensbi = self.packages.riscv64-linux.opensbiVisionFive2;
          spl_tool = self.packages.riscv64-linux.spl_tool;
        };
      in
      {
        VF2KernelPackages = VF2LinuxHeadMimimalStatic;
        VF2Kernel = VF2LinuxHeadMimimalStatic.kernel;

        opensbiVisionFive2 = pkgs.callPackage ./opensbi.nix { };

	spl_tool = pkgs.callPackage ./spl_tool.nix { };

        ubootVisionFive2 = uboot.visionFive2;
        ubootTools = uboot.ubootTools;
      };
    };
}
