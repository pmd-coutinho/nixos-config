{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.nixosModules.default
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

  # Use Noctalia's generated palette for Qt 5 and Qt 6 apps (see home/desktop.nix).
  # The NixOS qt5ct platform theme installs both qt5ct and qt6ct plugins.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  services.tuned.enable = true;
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
