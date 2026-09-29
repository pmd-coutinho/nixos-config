{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
    hyprmod = {
      url = "github:BlueManCZ/hyprmod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    msi-ec = {
      url = "github:BeardOverflow/msi-ec";
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
        modules = [
          ./configuration.nix
          ./noctalia.nix
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    in
    {
      nixosConfigurations = {
        "pedrocoutinho-nixos" = mkSystem;
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
