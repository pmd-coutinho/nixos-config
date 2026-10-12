# AI tools shared by the work and gaming profiles: ChatGPT desktop, Codex,
# and OpenCode (CLI + desktop).
{
  inputs,
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

  # Upstream builds the CLI as channel "prod", which registers the background
  # service in service-prod.json. The desktop client only looks for
  # service.json and spins on "loading" forever. Official releases use "latest".
  opencode = opencodePkgs.opencode.overrideAttrs (old: {
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
