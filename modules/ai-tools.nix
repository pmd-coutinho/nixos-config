# AI tools: ChatGPT desktop, Codex, and OpenCode (CLI + desktop).
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

  # OpenCode v2 reached nixpkgs-unstable before nixos-unstable. Take it from
  # there (prebuilt in the binary cache) until nixos-unstable catches up, then
  # switch to pkgs and drop the nixpkgs-unstable input.
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
    unstablePkgs.opencode
    unstablePkgs.opencode-desktop
  ];
}
