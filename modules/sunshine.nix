# Sunshine game streaming (gaming entry only). Settings and apps are declared
# here, so the web UI can still pair clients but can't change either; state
# and pairing stay in ~/.config/sunshine.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # nixpkgs builds without CUDA by default, so NVENC can't dlopen
  # libcuda.so.1 and Sunshine silently falls back to libx264.
  sunshine = pkgs.sunshine.override { cudaSupport = true; };

  hyprctl = lib.getExe' config.programs.hyprland.package "hyprctl";
  steam = lib.getExe config.programs.steam.package;
  setsid = lib.getExe' pkgs.util-linux "setsid";

  # Stream only the laptop panel: externals are disabled for the session and
  # `hyprctl reload` restores them from hyprland.lua afterwards.
  externalMonitors = [
    "GIGA-BYTE TECHNOLOGY CO. LTD. M28U 22010B004763"
    "Huawei Technologies Co. Inc. HUAWEI AD80HW"
  ];
  disableExternals = pkgs.writeShellScript "sunshine-disable-externals" ''
    ${lib.concatMapStrings (desc: ''
      ${hyprctl} eval "hl.monitor({output='desc:${desc}', disabled=true})" || true
    '') externalMonitors}
  '';

  # Moonlight shows portrait 2:3 box art and Sunshine only reads PNG.
  cover =
    name: image:
    pkgs.runCommand "${name}-cover.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
      magick ${image} -resize 600x900 -background black -gravity center -extent 600x900 $out
    '';

  steamGame = name: appId: image: {
    inherit name;
    detached = [ "${setsid} ${steam} steam://rungameid/${toString appId}" ];
    image-path = "${cover name image}";
  };
in
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    package = sunshine;

    settings = {
      output_name = "eDP-1";
      # Hyprland's screencopy works; pinning it skips the failing portal and
      # KMS probes at startup.
      capture = "wlr";
      encoder = "nvenc";
      global_prep_cmd = builtins.toJSON [
        {
          do = "${disableExternals}";
          undo = "${hyprctl} reload";
        }
      ];
    };

    applications = {
      env.PATH = "$(PATH):$(HOME)/.local/bin";
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Steam Big Picture";
          detached = [ "${setsid} ${steam} steam://open/bigpicture" ];
          prep-cmd = [
            {
              do = "";
              undo = "${setsid} ${steam} steam://close/bigpicture";
            }
          ];
          image-path = "steam.png";
        }
        (steamGame "Deadlock" 1422450 (
          pkgs.fetchurl {
            url = "https://cdn.cloudflare.steamstatic.com/steam/apps/1422450/library_600x900_2x.jpg";
            hash = "sha256-S0lTR2LOUfGrPBwgWobu/+V6qCgGiQhimXW/WU220hw=";
          }
        ))
        # The playtest has no portrait art, so its store header is letterboxed.
        (steamGame "March of Giants" 3643930 (
          pkgs.fetchurl {
            url = "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3643930/a4878aeea6c183d70864d91b6b1aea5a26169775/header.jpg";
            hash = "sha256-IWv+R8FXwZzc3skPzmgpJDaG1ggB5PMIVROVwb/q66s=";
          }
        ))
      ];
    };
  };
}
