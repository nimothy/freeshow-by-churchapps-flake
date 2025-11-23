# FreeShow AppImage – Nix Flake

This flake packages **FreeShow** from the official AppImage and provides:

- A Nix package: `freeshow`
- A NixOS module: `programs.freeshow.enable`
- A Home Manager module: `programs.freeshow.enable`
- GitHub Actions CI that builds the flake
- An auto-update workflow that can bump the FreeShow version and sha256 and open a PR

## Repo layout

```text
.
├── flake.nix
├── pkgs
│   ├── freeshow.nix
│   ├── freeshow.desktop
│   └── freeshow-icon.svg
├── modules
│   ├── nixos
│   │   └── freeshow.nix
│   └── home-manager
│       └── freeshow.nix
├── scripts
│   └── update-appimage.sh
└── .github
    └── workflows
        ├── ci.yml
        └── update-appimage.yml
```

## Basic usage

### Run directly

```bash
nix run github:nimothy/freeshow-by-churchapps-flake
# or
nix run github:nimothy/freeshow-by-churchapps-flake#freeshow
```

### Install into a profile

```bash
nix profile install github:nimothy/freeshow-by-churchapps-flake#freeshow
freeshow
```

## NixOS module

In your system flake:

```nix
{
  inputs.freeshow.url = "github:nimothy/freeshow-by-churchapps-flake";

  outputs = { self, nixpkgs, freeshow, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        # Make the package and module available
        { nixpkgs.overlays = [ freeshow.overlays.default ]; }
        freeshow.nixosModules.freeshow
      ];
    };
  };
}
```

In `configuration.nix` (or an imported module):

```nix
{
  programs.freeshow.enable = true;
}
```

## Home Manager module

With a flake-based Home Manager setup:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    freeshow.url = "github:nimothy/freeshow-by-churchapps-flake";
  };

  outputs = { self, nixpkgs, home-manager, freeshow, ... }:
    let
      system = "x86_64-linux";
    in {
      homeConfigurations."nim@host" = home-manager.lib.homeManagerConfiguration {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ freeshow.overlays.default ];
        };

        modules = [
          ./home.nix
          freeshow.homeManagerModules.freeshow
        ];
      };
    };
}
```

In `home.nix`:

```nix
{
  programs.freeshow.enable = true;
}
```

## Desktop launcher & icon

This flake installs a `.desktop` file and SVG icon:

- `freeshow.desktop` in `share/applications`
- `freeshow.svg` in `share/icons/hicolor/scalable/apps`

Your desktop environment should then automatically pick up **FreeShow** in the app launcher menu.

## Updating the AppImage hash & version

There are two ways to update the hash/version.

### 1. Manually (one-off)

```bash
URL="https://github.com/ChurchApps/FreeShow/releases/download/v1.5.2/FreeShow-1.5.2-x86_64.AppImage"
nix-prefetch-url --type sha256 "$URL"
```

Copy the printed hash into `pkgs/freeshow.nix` as the `sha256` value.

### 2. Using the update script (recommended)

```bash
chmod +x scripts/update-appimage.sh
nix shell nixpkgs#jq nixpkgs#nix-prefetch-scripts -c ./scripts/update-appimage.sh
```

This will:

1. Query the latest FreeShow release from GitHub.
2. Find the `x86_64.AppImage` asset.
3. Compute the `sha256` with `nix-prefetch-url`.
4. Update `version` and `sha256` in `pkgs/freeshow.nix`.

### 3. GitHub Actions auto-update

The workflow `.github/workflows/update-appimage.yml` runs the same script on:

- A schedule (weekly), and
- Manual dispatch from the Actions tab.

It then uses `peter-evans/create-pull-request` to open a PR with the updated `version`
and `sha256`. You can use this repo as a **template** in GitHub to spin up your own
copy with the same automation.

## CI

`.github/workflows/ci.yml` runs on every push/PR and:

- Installs Nix
- Builds `. #freeshow`
- Runs `nix flake check`

You may want to run `scripts/update-appimage.sh` once locally and push the updated
`pkgs/freeshow.nix` so that the initial CI run passes.
