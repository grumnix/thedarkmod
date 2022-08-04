{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    thedarkmod_src.url = "https://www.thedarkmod.com/sources/thedarkmod.2.10.src.7z";
    thedarkmod_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, thedarkmod_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          default = thedarkmod;

          thedarkmod = pkgs.stdenv.mkDerivation {
            pname = "thedarkmod";
            version = "2.10";
            src = thedarkmod_src;
            unpackPhase = ''
              ${pkgs._7zz}/bin/7zz x $src
            '';
            patches = [ ./thedarkmod-fixes.patch ];
            cmakeFlags = [ "-DCOPY_EXE=OFF" ];
            installPhase = ''
              mkdir -p $out/bin/
              cp -v thedarkmod.x64 $out/bin/
            '';
            nativeBuildInputs = with pkgs; [
              cmake
              pkgconfig
            ];
            buildInputs = with pkgs; [
              mesa
              xorg.xorgproto
              xorg.libX11.dev
              xorg.libXext.dev
            ];
          };
        };
      }
    );
}
