{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Only for OpenCode v2 until nixos-unstable has it (see modules/ai-tools.nix).
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Only for azure-cli while its fabric dependency is broken by invoke 3
    # (see profiles/work.nix). The last nixos-unstable with invoke 2.2.1.
    nixpkgs-azure-cli.url = "github:NixOS/nixpkgs/fe13242281a67641c0102cdb1087f0ebe586c7df";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:poeck/claude-desktop-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chatgpt-desktop = {
      url = "github:danielbodart/chatgpt-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuios = {
      url = "github:Gaurav-Gosain/tuios";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };
    umbriel = {
      url = "github:noctalia-dev/umbriel";
      # Build against our nixpkgs so Umbriel's wlroots and mesa match the
      # system graphics stack. That gives up umbriel.cachix.org: Umbriel
      # compiles locally (a few minutes) whenever the two nixpkgs pins differ.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprmod = {
      url = "github:BlueManCZ/hyprmod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    msi-ec = {
      url = "github:BeardOverflow/msi-ec";
      flake = false;
    };
    msi-mux = {
      url = "github:hayatboj/msi-gpu-mux-switch/v0.5.0";
      flake = false;
    };
  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      mkSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./configuration.nix ];
      };
    in
    {
      nixosConfigurations = {
        "pedrocoutinho-nixos" = mkSystem;
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
