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
    adw-gtk3
    nwg-look
    btop
    tmux

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

  # Use Noctalia's generated palette for both Qt 5 and Qt 6 applications.
  # The NixOS qt5ct platform theme installs both qt5ct and qt6ct plugins.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  environment.etc = {
    "xdg/qt5ct/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=/home/pedrocoutinho/.config/qt5ct/colors/noctalia.conf
      custom_palette=true
      standard_dialogs=default
      style=Fusion
    '';

    "xdg/qt6ct/qt6ct.conf".text = ''
      [Appearance]
      color_scheme_path=/home/pedrocoutinho/.config/qt6ct/colors/noctalia.conf
      custom_palette=true
      standard_dialogs=default
      style=Fusion
    '';
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
