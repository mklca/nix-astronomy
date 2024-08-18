{
  description = "computational astronomy packages";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        self',
        ...
      }: {
        packages = {
          naif-spice = pkgs.callPackage ./extern/naif-spice {
            csh = self'.packages.tcsh-csh-stub;
            gfortran = pkgs.gfortran14;
            stdenv = pkgs.gcc14Stdenv;
          };

          tcsh-csh-stub = pkgs.callPackage ./extern/tcsh-csh-stub {};
        };
      };
    };
}
