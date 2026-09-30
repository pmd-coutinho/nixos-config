{ config, pkgs, ... }:

let
  # Noctalia generates the colour schemes; these files only point Qt at them.
  qtctConf = dir: ''
    [Appearance]
    color_scheme_path=${config.xdg.configHome}/${dir}/colors/noctalia.conf
    custom_palette=true
    icon_theme=Papirus-Dark
    standard_dialogs=default
    style=Fusion
  '';
in
{
  # Without an icon theme apps only find bare hicolor, so standard icons go
  # blank. Qt reads the theme from qtct (below); GTK and Noctalia read the
  # GNOME icon-theme key. Adwaita stays installed for GTK's symbolic fallbacks.
  home.packages = [
    pkgs.papirus-icon-theme
    pkgs.adwaita-icon-theme
  ];
  # Noctalia's tray flattens anything under a status/ directory into a
  # monochrome silhouette, which blanks full-colour hicolor tray icons such
  # as blueman's; Papirus ships proper panel/ variants for them.
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Papirus-Dark";

  xdg.configFile = {
    "qt5ct/qt5ct.conf".text = qtctConf "qt5ct";
    "qt6ct/qt6ct.conf".text = qtctConf "qt6ct";
  };

  programs.ghostty = {
    enable = true;
    # Ghostty is launched directly from Hyprland, not as a systemd service.
    systemd.enable = false;
    settings = {
      # Noctalia generates themes/noctalia; its hook leaves this file alone
      # as long as this line is present.
      theme = "noctalia";
      font-family = "CaskaydiaCove Nerd Font Mono";
      font-size = 14;
      window-padding-x = 12;
      window-padding-y = 10;
      # Spread leftover space evenly instead of piling it on the bottom/right.
      window-padding-balance = true;
    };
  };
}
