{
  # nix run --no-write-lock-file --impure github:guibou/nixGL#nixGLIntel ./thedarkmod.x64

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    # tdm_installer_src.url = "https://update.thedarkmod.com/zipsync/tdm_installer.linux64.zip";
    # tdm_installer_src.flake = false;

    # http://darkmod.taaaki.za.net/release/zipsync/release/release200/manifest.iniz

    thedarkmod_src.url = "https://www.thedarkmod.com/sources/thedarkmod.2.10.src.7z";
    thedarkmod_src.flake = false;

    darkradiant_src.url = "github:codereader/DarkRadiant?ref=3.0.0";
    darkradiant_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, thedarkmod_src, darkradiant_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          default = thedarkmod;

          tdm_installer = pkgs.stdenv.mkDerivation {
            name = "tdm_installer";
            src = pkgs.fetchzip {
              name = "tdm_installer";
              url = "https://update.thedarkmod.com/zipsync/tdm_installer.linux64.zip";
              sha256 = "sha256-myayxW9/OkPOIc+uCfdlULxr/3FRQAItbPiG8aMFcko=";
              stripRoot = false;
            };
            buildPhase = ''
              # do nothing
            '';
            installPhase = ''
              mkdir -p $out/bin/
              cp -v tdm_installer.linux64 $out/bin/
              chmod +x $out/bin/tdm_installer.linux64
            '';
          };

          tdm_installer_env = pkgs.buildFHSUserEnv {
            name = "tdm_installer";
            targetPkgs = pkgs: (with pkgs; [
              xorg.libX11
            ]) ++ [
              tdm_installer
            ];
            # runScript = "/usr/bin/tdm_installer.linux64";
          };

          thedarkmod_env = pkgs.buildFHSUserEnv {
            name = "thedarkmod_env";
            targetPkgs = pkgs: (with pkgs; [
              mesa
              xorg.libX11
            ]);
          };

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
              mkdir -p $out/share/thedarkmod/
              cp -v thedarkmod.x64 $out/bin/
              cp -rv ../glprogs $out/share/thedarkmod/
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

          darkradiant = pkgs.stdenv.mkDerivation {
            pname = "darkradiant";
            version = "3.0.0";
            src = darkradiant_src;
            nativeBuildInputs = with pkgs; [
              cmake
              pkgconfig
            ];
            buildInputs = with pkgs; [
              asciidoctor
              eigen
              freealut
              freetype
              ftgl
              glew
              glib
              # gtest
              libgit2
              libjpeg
              libpng
              libsigcxx
              libvorbis
              libxml2
              openal
              python
              wxGTK30
              xorg.libX11
              xorg.libXau
              zlib
            ];
          };
        };
      }
    );
}
