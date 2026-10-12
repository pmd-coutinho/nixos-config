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
  umbriel = lib.getExe config.programs.umbriel.package;
  steam = lib.getExe config.programs.steam.package;
  setsid = lib.getExe' pkgs.util-linux "setsid";

  # Stream only the laptop panel: externals are disabled for the session and
  # restored afterwards, by whichever compositor is running. Hyprland matches
  # monitors by description (commas dropped) and `hyprctl reload` restores
  # them from hyprland.lua. Umbriel takes the names from `umbriel outputs`;
  # its disable is temporary, so each output is enabled again by name.
  # Once Hyprland is gone, an Umbriel virtual output (`umbriel output-create`)
  # sized to the client is the nicer target than the laptop panel.
  externalMonitors = [
    {
      hyprland = "GIGA-BYTE TECHNOLOGY CO. LTD. M28U 22010B004763";
      umbriel = "GIGA-BYTE TECHNOLOGY CO., LTD. M28U 22010B004763";
    }
    {
      hyprland = "Huawei Technologies Co. Inc. HUAWEI AD80HW";
      # Its EDID serial is blank spaces, so the connector is the safer name.
      umbriel = "HDMI-A-2";
    }
  ];
  umbrielMsg = action: "${umbriel} msg ${lib.escapeShellArg action} || true";
  # The Umbriel check asks the compositor itself, so a stale socket or
  # environment variable left by an earlier session can't fool it. Each
  # branch is a list of command lines.
  prepScript =
    name:
    { umbrielCmds, hyprlandCmds }:
    pkgs.writeShellScript "sunshine-${name}" ''
      if ${umbriel} outputs >/dev/null 2>&1; then
      ${lib.concatStringsSep "\n" umbrielCmds}
      else
      ${lib.concatStringsSep "\n" hyprlandCmds}
      fi
    '';
  disableExternals = prepScript "disable-externals" {
    # The lid event may have taken the panel out of the desktop.
    umbrielCmds = [
      (umbrielMsg "output-enable:eDP-1")
    ]
    ++ map (m: umbrielMsg "output-disable:${m.umbriel}") externalMonitors;
    hyprlandCmds = map (
      m: ''${hyprctl} eval "hl.monitor({output='desc:${m.hyprland}', disabled=true})" || true''
    ) externalMonitors;
  };
  # Umbriel keeps a disable until something enables the output again, so if
  # Sunshine dies mid-stream the externals stay off; bring them back with
  # `umbriel msg output-enable:<name>` (names as above).
  restoreExternals = prepScript "restore-externals" {
    # If the lid is still closed, take the panel back out as lid_close in
    # home/umbriel.nix would, but only once an external is on again.
    umbrielCmds = map (m: umbrielMsg "output-enable:${m.umbriel}") externalMonitors ++ [
      ''
        if ${lib.getExe pkgs.gnugrep} -qs closed /proc/acpi/button/lid/*/state \
          && ${umbriel} outputs --json \
            | ${lib.getExe pkgs.jq} -e 'any(.[]; .enabled and .name != "eDP-1")' >/dev/null; then
          ${umbrielMsg "output-disable:eDP-1"}
        fi''
    ];
    hyprlandCmds = [ "${hyprctl} reload" ];
  };

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
      # Hyprland's and Umbriel's screencopy both work; pinning it skips the
      # failing portal and KMS probes at startup.
      capture = "wlr";
      encoder = "nvenc";
      global_prep_cmd = builtins.toJSON [
        {
          do = "${disableExternals}";
          undo = "${restoreExternals}";
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
