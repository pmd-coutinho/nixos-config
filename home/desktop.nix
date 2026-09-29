{ config, ... }:

let
  # Noctalia generates the colour schemes; these files only point Qt at them.
  qtctConf = dir: ''
    [Appearance]
    color_scheme_path=${config.xdg.configHome}/${dir}/colors/noctalia.conf
    custom_palette=true
    standard_dialogs=default
    style=Fusion
  '';
in
{
  xdg.configFile = {
    "qt5ct/qt5ct.conf".text = qtctConf "qt5ct";
    "qt6ct/qt6ct.conf".text = qtctConf "qt6ct";
  };
}
