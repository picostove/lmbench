{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {self, nixpkgs}: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    src = let
        fs = pkgs.lib.fileset;
  sourceFiles = fs.difference ./. (
    fs.unions [
      (fs.maybeMissing ./result)
      ./flake.nix
      ./flake.lock
      ./package.nix
    ]
  );
      in fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };
            version = "3.0-g${self.shortRev or "dirty"}";
  in {
    packages.x86_64-linux.default = pkgs.callPackage ./package.nix {
      inherit src version;
    };
    packages.x86_64-linux.rv64 = pkgs.pkgsCross.riscv64.callPackage ./package.nix {
      inherit src version;
    };
    packages.x86_64-linux.rv64-static = pkgs.pkgsCross.riscv64.pkgsStatic.callPackage ./package.nix {
      inherit src version;
    };
  };
}
