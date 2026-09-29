# Home Manager entry point for pedrocoutinho, wired in from configuration.nix.
# Only manage files that nothing else writes: Home Manager links them
# read-only, so GUI-edited configs (hyprland.lua via hyprmod, Noctalia
# settings and generated themes) stay out of here.
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./desktop.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.packages = with pkgs; [
    btop
    tmux
  ];

  # Same rule as system.stateVersion: set once, do not bump on upgrades.
  home.stateVersion = "26.05";
}
