{
  description = "Nix flake for FreeShow AppImage with NixOS & Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    let
      overlay = final: prev: {
        freeshow = final.callPackage ./pkgs/freeshow.nix {};
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        packages = {
          freeshow = pkgs.freeshow;
          default = pkgs.freeshow;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.freeshow}/bin/freeshow";
          };
          freeshow = {
            type = "app";
            program = "${pkgs.freeshow}/bin/freeshow";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
          ];
        };
      }
    ) // {
      overlays = {
        default = overlay;
      };

      nixosModules = {
        freeshow = import ./modules/nixos/freeshow.nix;
      };

      homeManagerModules = {
        freeshow = import ./modules/home-manager/freeshow.nix;
      };
    };
}
