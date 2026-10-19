{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.umbriel.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default
    nautilus
    file-roller # archive manager; Nautilus "Open With" and "Compress…"
    _7zz-rar # 7-Zip with RAR support; File Roller's backend for 7z
    unar # File Roller's backend for RAR, including encrypted headers
    adw-gtk3
    nwg-look

    # Noctalia Screen Toolkit requirements.
    slurp
    grim
    hyprpicker
    (tesseract.override {
      enableLanguages = [
        "eng"
        "por"
      ];
    })
    imagemagick
    zbar
    curl
    jq
    ffmpeg
    bc
    coreutils # stat
    procps # pkill
    xdg-utils # xdg-open
    mpv
    pulseaudio # pactl; PipeWire remains the active audio server

    # Recording backends and optional Screen Toolkit integrations.
    gpu-screen-recorder
    wl-screenrec
    wf-recorder
    satty
    translate-shell
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  # A second greeter session beside Hyprland, with its screencast and
  # screenshot portal. start-umbriel runs it as a systemd user service, so it
  # needs no UWSM. Its config is Home Manager's (home/umbriel.nix).
  programs.umbriel.enable = true;

  # Use Noctalia's generated palette for Qt 5 and Qt 6 apps (see home/desktop.nix).
  # The NixOS qt5ct platform theme installs both qt5ct and qt6ct plugins.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # Noctalia's power profiles go through tuned-ppd. tuned's stock profiles
  # reach the EC through ACPI platform_profile, which this laptop lacks, so
  # each profile below also sets msi-ec's shift mode. 'turbo' stays unused:
  # msi-ec describes it as over-voltage and overclock. Performance keeps the
  # balanced base with EPP performance, instead of the server profile's
  # governor=performance + min_perf_pct=100, which pins every core at max turbo.
  services.tuned = {
    enable = true;
    profiles = {
      msi-powersave = {
        main.include = "powersave";
        sysfs."/sys/devices/platform/msi-ec/shift_mode" = "eco";
      };
      msi-balanced = {
        main.include = "balanced";
        sysfs."/sys/devices/platform/msi-ec/shift_mode" = "comfort";
      };
      msi-balanced-battery = {
        main.include = "balanced-battery";
        sysfs."/sys/devices/platform/msi-ec/shift_mode" = "eco";
      };
      msi-performance = {
        main.include = "balanced";
        cpu.energy_performance_preference = "performance";
        sysfs."/sys/devices/platform/msi-ec/shift_mode" = "comfort";
      };
    };
    ppdSettings = {
      profiles = {
        power-saver = "msi-powersave";
        balanced = "msi-balanced";
        performance = "msi-performance";
      };
      battery.balanced = "msi-balanced-battery";
    };
  };
  services.upower.enable = true;
  # Drive discovery and user mounting for Nautilus/Thunar.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  programs.noctalia = {
    enable = true;

    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      cursor.size = 24;
      keyboard.layout = "us";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
  };
}
