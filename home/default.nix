# Home Manager entry point for pedrocoutinho, wired in from configuration.nix.
# Only manage files that nothing else writes: Home Manager links them
# read-only, so GUI-edited configs (hyprland.lua via hyprmod, Noctalia
# settings and generated themes) stay out of here. niri's config.kdl
# qualifies: Noctalia's theme hook leaves it alone while it includes
# noctalia.kdl, which niri.nix keeps.
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./desktop.nix
    ./hyprland.nix
    ./niri.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    btop
    tmux
    yt-dlp
  ];

  # Same rule as system.stateVersion: set once, do not bump on upgrades.
  home.stateVersion = "26.05";
}
