{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
  gamingHelium = lib.hiPrio (
    pkgs.writeShellScriptBin "helium" ''
      exec ${helium}/bin/helium \
        --user-data-dir="''${XDG_CONFIG_HOME:-$HOME/.config}/net.imput.helium-gaming" \
        "$@"
    ''
  );
in
{
  # Chaotic Nyx provides this upstream-parity CachyOS kernel and its cache.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  hardware.nvidia.package = pkgs.nvidia_cachyos;

  # Compressed in-RAM swap; games don't need the disk swapfile work uses.
  zramSwap.enable = true;

  programs.steam = {
    enable = true;
    # Adds a "Steam (gamescope)" session to the greeter.
    gamescopeSession.enable = true;
    # Remote Play discovery/stream ports (UDP 27031-27036, TCP 27036-27037).
    remotePlay.openFirewall = true;
  };
  # Launch games with `gamemoderun %command%` for CPU governor/priority tweaks.
  programs.gamemode.enable = true;

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    # nixpkgs builds without CUDA by default, so NVENC can't dlopen
    # libcuda.so.1 and Sunshine silently falls back to libx264.
    package = pkgs.sunshine.override { cudaSupport = true; };
  };

  # Gaming-only packages and settings belong here.
  environment.systemPackages = with pkgs; [
    bottles
    gamingHelium
  ];
}
