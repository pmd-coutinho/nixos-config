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

  # gamemode runs these as the user when the first game starts and the last
  # one exits. They go through the power-profiles D-Bus API (served by
  # tuned-ppd) so Noctalia's indicator stays in sync, and put back whatever
  # profile was active before.
  powerProfile = pkgs.writeShellApplication {
    name = "gamemode-power-profile";
    runtimeInputs = [
      pkgs.systemd
      pkgs.libnotify
    ];
    text = ''
      bus=(org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles)
      saved="$XDG_RUNTIME_DIR/gamemode-power-profile"
      set_profile() { busctl --system set-property "''${bus[@]}" ActiveProfile s "$1"; }

      case "$1" in
        start)
          busctl --system get-property "''${bus[@]}" ActiveProfile | cut -d'"' -f2 >"$saved"
          set_profile performance
          notify-send --app-name=GameMode --icon=input-gaming "GameMode on" "Power profile: performance"
          ;;
        end)
          set_profile "$(cat "$saved" 2>/dev/null || echo balanced)"
          rm -f "$saved"
          notify-send --app-name=GameMode --icon=input-gaming "GameMode off" "Power profile restored"
          ;;
      esac
    '';
  };
in
{
  imports = [
    ../modules/ai-tools.nix
    ../modules/sunshine.nix
  ];

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
    # Selectable per game under Properties > Compatibility.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # `protontricks <appid> <verb>` for the per-prefix fixes ProtonDB suggests.
    protontricks.enable = true;
  };
  # Launch games with `gamemoderun %command%`: performance governor and power
  # profile, plus a nicer priority, for as long as the game runs.
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      custom = {
        start = "${lib.getExe powerProfile} start";
        end = "${lib.getExe powerProfile} end";
      };
    };
  };

  # sched_ext scheduler built for gaming latency (Steam Deck); it also steers
  # frame-critical threads to P-cores. `systemctl stop scx` falls back to the
  # kernel's default scheduler without a reboot.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  # Xbox Series controller over Bluetooth: working rumble (incl. triggers),
  # paddles and battery reporting. The PS5 DualSense needs nothing extra:
  # the kernel's hid-playstation driver and Steam Input cover it.
  hardware.xpadneo.enable = true;

  # NVIDIA trims its shader cache at ~1 GB, so switching between big games
  # means recompiling shaders (stutter). Keep everything.
  environment.sessionVariables.__GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";

  # Gaming-only packages and settings belong here.
  environment.systemPackages = with pkgs; [
    bottles
    gamingHelium
    # FPS/frametime overlay: `mangohud %command%` in a game's launch options.
    mangohud
  ];
}
