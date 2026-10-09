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

  # gamemode runs this as the user when the first game starts and the last
  # one exits. The power profile is left alone: performance clocks made the
  # laptop overheat and power off mid-game.
  gamemodeNotify = pkgs.writeShellApplication {
    name = "gamemode-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      case "$1" in
        start) notify-send --app-name=GameMode --icon=input-gaming "GameMode on" ;;
        end) notify-send --app-name=GameMode --icon=input-gaming "GameMode off" ;;
      esac
    '';
  };

  # The BIOS sets the CPU's long- and short-term power limits (PL1/PL2) to
  # 220 W, far more than this chassis can shed next to a 175 W GPU. Clip them
  # on both RAPL interfaces (the lower one wins), only ever lowering, so
  # thermald can still throttle further.
  cpuPowerCap = {
    longTermWatts = 65;
    shortTermWatts = 100;
  };
  clipCpuPower = pkgs.writeShellApplication {
    name = "clip-cpu-power";
    text = ''
      clip() {
        local file=$1 max=$(($2 * 1000000))
        [[ -e $file ]] || return 0
        if (($(<"$file") > max)); then
          echo "$max" >"$file"
          echo "$file: clipped to $2 W"
        fi
      }
      for zone in /sys/class/powercap/intel-rapl:0 /sys/class/powercap/intel-rapl-mmio:0; do
        clip "$zone/constraint_0_power_limit_uw" ${toString cpuPowerCap.longTermWatts}
        clip "$zone/constraint_1_power_limit_uw" ${toString cpuPowerCap.shortTermWatts}
      done
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
  # Launch games with `gamemoderun %command%`: a nicer priority for as long
  # as the game runs.
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        # gamemode switches to the performance governor by default; keep the
        # usual one (intel_pstate's powersave, which follows the power
        # profile) for the same reason as above.
        desiredgov = "powersave";
      };
      custom = {
        start = "${lib.getExe gamemodeNotify} start";
        end = "${lib.getExe gamemodeNotify} end";
      };
    };
  };

  # Re-clipped every minute: the EC or thermald may raise the limits again
  # (e.g. on AC or resume). Lift the cap until reboot, e.g. with an external
  # cooler: `systemctl stop clip-cpu-power.timer`, then write the old values
  # back to the constraint_*_power_limit_uw files.
  systemd.services.clip-cpu-power = {
    description = "Clip the CPU's RAPL power limits";
    after = [ "thermald.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe clipCpuPower;
    };
  };
  systemd.timers.clip-cpu-power = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
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
