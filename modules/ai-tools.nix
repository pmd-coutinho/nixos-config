# AI tools: ChatGPT desktop, Codex, and OpenCode (CLI + desktop).
{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  chatgptDesktop =
    inputs.chatgpt-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        # The upstream "auto" hint still selects X11 under Hyprland. Force
        # native Wayland so fractional scaling remains sharp.
        postFixup =
          builtins.replaceStrings [ "--ozone-platform-hint=auto" ] [ "--ozone-platform=wayland" ]
            old.postFixup;
      });

  # OpenCode v2 isn't in nixpkgs yet, so build it from upstream's flake.
  opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};

  # Upstream's installPhase runs one `cp -R` per node_modules directory,
  # including the ones nested inside node_modules/.bun that the top-level copy
  # already covers, so every file is written twice (slow with ESET scanning
  # each write). Pruning at the first node_modules gives the same output; the
  # fixed-output hash fails the build if it ever doesn't.
  node_modules = opencodePkgs.opencode.node_modules.overrideAttrs (old: {
    installPhase =
      assert lib.hasInfix "-name node_modules -exec" old.installPhase;
      builtins.replaceStrings [ "-name node_modules -exec" ] [ "-name node_modules -prune -exec" ]
        old.installPhase;
  });

  # Upstream builds the CLI as channel "prod", which registers the background
  # service in service-prod.json. The desktop client only looks for
  # service.json and spins on "loading" forever. Official releases use "latest".
  opencode = (opencodePkgs.opencode.override { inherit node_modules; }).overrideAttrs (old: {
    env = old.env // {
      OPENCODE_CHANNEL = "latest";
    };
  });

  # The desktop inherits the CLI's env, but its own code expects "prod".
  opencodeDesktop =
    (opencodePkgs.opencode-desktop.override { inherit opencode; }).overrideAttrs
      (old: {
        env = old.env // {
          OPENCODE_CHANNEL = "prod";
        };
      });
in

{
  imports = [ inputs.chatgpt-desktop.nixosModules.default ];

  programs.chatgpt-desktop = {
    enable = true;
    package = chatgptDesktop;
    primaryRuntime.enable = true;
  };

  environment.systemPackages = [
    pkgs.codex
    opencode
    opencodeDesktop
  ];
}
