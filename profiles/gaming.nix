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
  imports = [ ./common.nix ];

  # Chaotic Nyx provides this upstream-parity CachyOS kernel and its cache.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
  hardware.nvidia.package = lib.mkForce pkgs.nvidia_cachyos;

  programs.steam = {
    enable = true;
    # Adds a "Steam (gamescope)" session to the greeter.
    gamescopeSession.enable = true;
  };
  # Launch games with `gamemoderun %command%` for CPU governor/priority tweaks.
  programs.gamemode.enable = true;

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Gaming-only packages and settings belong here.
  environment.systemPackages = with pkgs; [
    bottles
    gamingHelium
  ];
}
