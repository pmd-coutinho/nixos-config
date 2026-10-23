{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Only for azure-cli while its fabric dependency is broken by invoke 3
    # (see profiles/work.nix). The last nixos-unstable with invoke 2.2.1.
    nixpkgs-azure-cli.url = "github:NixOS/nixpkgs/fe13242281a67641c0102cdb1087f0ebe586c7df";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Desktop, repackaged from Anthropic's apt index and prebuilt on
    # cache.numtide.com. No `follows`: llm-agents is built against its own
    # nixpkgs, so following ours would miss that cache and compile locally.
    llm-agents.url = "github:numtide/llm-agents.nix";
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
    # biri, a niri fork with extra features. It has no binary cache, so it
    # compiles locally either way; following our nixpkgs keeps its mesa in
    # step with the system graphics stack.
    biri = {
      url = "github:barrulus/biri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprmod = {
      url = "github:BlueManCZ/hyprmod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Run `nix flake update msi-control` to pick up new commits.
    msi-control = {
      url = "github:pmd-coutinho/msi-control";
      inputs.nixpkgs.follows = "nixpkgs";
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
