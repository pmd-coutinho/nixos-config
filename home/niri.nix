# biri (a niri fork) as a second session beside Hyprland (noctalia.nix
# enables it). The config is biri's own default config.kdl, read from the
# flake input so it follows upstream, with a few lines swapped for the apps
# installed here. Additions, mostly biri-only features, live in biri.kdl,
# which config.kdl includes after the defaults so its binds win. Check a
# change with `niri validate`.
{ inputs, lib, ... }:

let
  # Each swap must still match after `nix flake update biri`; fail the build
  # rather than silently keep the upstream line.
  swap =
    text: from: to:
    if lib.hasInfix from text then
      lib.replaceStrings [ from ] [ to ] text
    else
      throw "home/niri.nix: biri's default config no longer contains ${from}";

  swaps = [
    [
      ''spawn-at-startup "waybar"''
      ''spawn-at-startup "noctalia"''
    ]
    [
      ''Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }''
      ''Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }''
    ]
    [
      ''Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }''
      ''Mod+Space hotkey-overlay-title="Open the Noctalia Launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }''
    ]
    [
      ''Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }''
      ''Super+Alt+L hotkey-overlay-title="Lock the Screen" { spawn-sh "noctalia msg session lock"; }''
    ]
    # brightnessctl isn't installed; Noctalia also shows its OSD.
    [
      ''XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }''
      ''XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }''
    ]
    [
      ''XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }''
      ''XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }''
    ]
  ];

  defaultConfig = builtins.readFile "${inputs.biri}/resources/default-config.kdl";
in
{
  # Replaces the one-line stub Noctalia wrote before this file existed.
  xdg.configFile."niri/config.kdl" = {
    force = true;
    # Noctalia's theme template writes the colours to noctalia.kdl and appends
    # this include to config.kdl if it is missing, which would fail on a
    # read-only file. Keep it last so its colours win.
    text = ''
      ${lib.foldl' (text: s: swap text (builtins.elemAt s 0) (builtins.elemAt s 1)) defaultConfig swaps}

      include "biri.kdl"
      include optional=true "noctalia.kdl"
    '';
  };

  xdg.configFile."niri/biri.kdl".text = ''
    // Noctalia's recommended niri settings: its settings window floats, and
    // notification actions can raise the window they came from.
    window-rule {
        match app-id=r#"^dev\.noctalia\.Noctalia$"#
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
    }
    debug {
        honor-xdg-activation-with-invalid-serial
    }

    // Picture-in-picture follows you across workspaces and stays above
    // fullscreen video.
    window-rule {
        match title="^(Picture-in-Picture|Picture in picture)$"
        open-sticky true
        float-above-fullscreen true
    }

    // A scratchpad: a workspace that stays out of the strip and the
    // overview until Mod+Grave shows it.
    workspace "scratch" {
        hidden true
    }

    // Mod+scroll zooms the overview, opening it from the first notch and
    // closing it past 0.5. Zooming out past 0.48 brings in the other
    // monitors as a carousel; at 0.18 the whole ring is in view.
    overview {
        zoom-presets 0.5 0.3 0.18
        consolidated-carousel {
            reveal-zoom 0.48
            assembled-zoom 0.22
        }
    }

    // Colour filters for one monitor at a time, off until cycled. Noctalia's
    // night light covers every monitor at once.
    output-shaders {
        preset "warm" {
            preset "temperature" kelvin=4000
        }
        preset "mono" {
            preset "grayscale"
        }
    }

    binds {
        Mod+Grave hotkey-overlay-title="Show/Hide the Scratchpad" { toggle-workspace-visibility "scratch" focus=true; }
        Mod+Shift+Grave hotkey-overlay-title="Send Window to the Scratchpad" { move-window-to-workspace "scratch" focus=false; }
        // Floats the window if it isn't already.
        Mod+P hotkey-overlay-title="Pin Window to All Workspaces" { toggle-window-sticky; }

        // Replace the default workspace scrolling; Mod+Page_Up/Down and
        // Mod+U/I still switch workspaces.
        Mod+WheelScrollUp   cooldown-ms=150 { overview-zoom-in; }
        Mod+WheelScrollDown cooldown-ms=150 { overview-zoom-out; }

        Mod+F9 hotkey-overlay-title="Toggle Touchpad" { toggle-touchpad; }
        Mod+F10 hotkey-overlay-title="Toggle Disable-While-Typing" { toggle-dwt; }

        Mod+G hotkey-overlay-title="Cycle Monitor Colour Filter" { cycle-output-shader; }
        Mod+Shift+G { toggle-output-shader; }
    }
  '';
}
