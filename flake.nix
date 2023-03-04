{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = 
    { nixpkgs
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.riscv64-linux;
    in
    {
      formatter.riscv64-linux = pkgs.nixpkgs-fmt;

      packages.riscv64-linux =
      let
        VF2LinuxHeadMimimalStatic = pkgs.callPackage ./vf2_linux_mainline_head.nix { };
        # TODO: Make minimal config less minimal outside of the drivers sphere.
      in
      {
        VF2KernelPackages = VF2LinuxHeadMimimalStatic;
        VF2Kernel = VF2LinuxHeadMimimalStatic.kernel;
      };
    };
}
