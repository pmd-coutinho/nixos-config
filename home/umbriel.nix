# Umbriel, the Noctalia team's scrolling compositor, as a second session beside
# Hyprland (noctalia.nix enables it). This ports the hand-edited Hyprland setup
# (~/.config/hypr: hyprland.lua, hyprmod's hyprland-gui.lua, and hyprtasking
# from home/hyprland.nix) and uses what Umbriel has built in instead: the
# scrolling layout, overview, tab groups, scratchpad, named per-output
# workspaces and lid events.
#
# Home Manager owns config.toml. Noctalia's theme template writes the colours
# to noctalia.toml beside it, and its hook leaves config.toml alone as long as
# "noctalia.toml" stays the last optional include. Colours therefore stay out
# of this file: the including file wins, so any set here would freeze them.
#
# Check a change with `umbriel config validate -c <file>`; it fails on
# warnings too. Most settings reload on switch; autostart, environment and
# the xwayland settings need a new session. Gestures are built in: a
# vertical three-finger swipe switches workspaces (Hyprland's was
# horizontal), a horizontal one scrolls the strip, and four fingers open the
# overview as hyprtasking did.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  umbriel = lib.getExe config.programs.umbriel.package;
  effects = "${config.programs.umbriel.package}/share/umbriel/effects";
  playerctl = lib.getExe pkgs.playerctl;

  # Umbriel repeats a held bind; Hyprland didn't. Spawns, toggles and anything
  # that sends the focused window away must not, or a held key would also send
  # away each window that focus lands on next.
  once = action: {
    inherit action;
    repeat = false;
  };
  # Media keys also work on the lock screen; toggles don't repeat.
  locked = action: {
    inherit action;
    allow_when_locked = true;
  };
  lockedOnce = action: locked action // once action;
  msg = command: "spawn:noctalia msg ${command}";

  # Undocked, logind suspends on lid close, and disabling the panel would
  # leave no output at all. Only hand its windows to the externals when one
  # of them is on.
  lidClose = pkgs.writeShellScript "umbriel-lid-close" ''
    if ${umbriel} outputs --json \
      | ${lib.getExe pkgs.jq} -e 'any(.[]; .enabled and .name != "eDP-1")' >/dev/null; then
      exec ${umbriel} msg output-disable:eDP-1
    fi
  '';

  # Hyprland's workspaces 1-10 by key (0 is 10), named as its default_name
  # rules did; unnamed ones keep their number. All-digit names are quoted,
  # or the selector would mean a position on the focused output.
  workspaceNames = [
    "web"
    "code"
    "chat"
    "game"
    "design"
    "6"
    "7"
    "8"
    "9"
    "10"
  ];
  selector = name: if builtins.match "[0-9]+" name != null then ''"${name}"'' else name;
  workspaceBinds = lib.mergeAttrsList (
    lib.imap1 (
      i: name:
      let
        key = toString (lib.mod i 10);
        workspace = selector name;
      in
      {
        "Mod+${key}" = "workspace-switch:${workspace}";
        "Mod+Shift+${key}" = "window-move-to-workspace:${workspace}";
        "Mod+Ctrl+${key}" = once "window-move-to-workspace-silent:${workspace}";
      }
      # The built-in keypad binds switch by position; give them the same names.
      // lib.optionalAttrs (i < 10) {
        "Mod+KP_${key}" = "workspace-switch:${workspace}";
        "Mod+Shift+KP_${key}" = "window-move-to-workspace:${workspace}";
      }
    ) workspaceNames
  );

  # Placement by workspace name; names are unique, so they find their output.
  placeOn = workspace: apps: {
    match.app_id = apps;
    default_workspace = workspace;
  };
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  # Noctalia writes a stub config.toml when none exists (one is there from
  # before this file, and rolling back to a generation without it makes
  # another). Replace it instead of failing on an existing .hm-backup; the
  # stub only holds the include below.
  xdg.configFile."umbriel/config.toml".force = true;

  programs.umbriel = {
    enable = true;
    settings = {
      include = {
        # Bundled effect presets; nothing uses them until a bind below does.
        files = [
          "${effects}/border/pulse/effect.toml"
          "${effects}/cursor/trail/effect.toml"
        ];
        optional.files = [ "noctalia.toml" ];
      };

      general = {
        autostart = [ "noctalia" ];
        mod_key = "Super";
        xwayland = true;
        # X11 apps see the M28U at 3840x2160 instead of being upscaled from
        # its 1.5 scale: sharp, but X11 apps that don't scale themselves look
        # smaller there than under Hyprland.
        xwayland_native_resolution = true;
        show_cheatsheet = false;
        focus_on_activate = false;
        # Hyprland's suppress-maximize rule only partly carries over: Umbriel
        # ignores the maximize a window asks for while opening (this option's
        # default), but honours later requests, such as double-clicking a
        # Chromium tab strip, as a full-width column. No rule can block those.
        honor_restored_maximize = false;
      };

      # Hyprland set these with hl.env. Umbriel exports XCURSOR_* itself from
      # input.cursor below.
      environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      # With an external on, closing the lid moves the panel's windows onto
      # the externals; opening it brings them back. The panel's workspaces
      # stay on it while it is off, so Mod+1-4 (focus goes there too),
      # Mod+Shift+1-4 and new Slack or AyuGram windows land out of
      # sight until the lid opens, as under Hyprland, which kept the panel on
      # behind the closed lid.
      events = {
        lid_close = "${lidClose}";
        lid_open = "${umbriel} msg output-enable:eDP-1";
      };

      # `umbriel outputs` shows each monitor's connector and "Config name".
      # The M28U is matched by monitor, so it keeps its settings on any port;
      # the Huawei's EDID serial is blank spaces, so it goes by connector.
      # Positions are Hyprland's layout moved to start at 0,0. Unlike
      # Hyprland, an unplugged monitor takes its workspaces with it: its
      # windows move to the active workspace of another enabled output (the
      # panel when undocked) until it returns, and its Mod+N binds do nothing
      # meanwhile.
      output = {
        eDP-1 = {
          mode = "1920x1200@144";
          position = [
            0
            1080
          ];
          scale = 1.0;
          vrr = "fullscreen";
          workspaces = lib.sublist 0 4 workspaceNames;
        };
        "GIGA-BYTE TECHNOLOGY CO., LTD. M28U 22010B004763" = {
          mode = "3840x2160@144";
          position = [
            1920
            0
          ];
          scale = 1.5;
          vrr = "fullscreen";
          workspaces = lib.sublist 4 4 workspaceNames;
        };
        HDMI-A-2 = {
          mode = "1920x1080@60";
          position = [
            0
            0
          ];
          scale = 1.0;
          workspaces = lib.sublist 8 2 workspaceNames;
        };
      };

      input = {
        keyboard = {
          layout = "us";
          numlock_toggle = false;
        };
        touchpad = {
          tap = true;
          natural_scroll = false;
        };
        mouse.sensitivity = 0.0;
        focus.follows_mouse = true;
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          # Hyprland warps the pointer to a window focused from the keyboard
          # (cursor:no_warps is off). Without it the pointer stays behind and
          # follows_mouse refocuses whatever is under it on the next nudge.
          follows_focus = true;
        };
      };

      layout = {
        mode = "scrolling";
        gap = 6;
        extent_presets = [
          0.333
          0.5
          0.667
        ];
        scrolling.default_extent_fraction = 0.5;
        dwindle.preserve_split = true;
        master.new_becomes_master = true;
      };

      workspaces.back_and_forth = false;

      # Blur passes 3 and radius 5 are hyprmod's values and also Umbriel's
      # defaults, as are the rest of this block; they are spelled out so the
      # port reads on its own.
      appearance = {
        prefer_no_csd = true;
        border_width = 2;
        corner_radius = 20;
        blur = {
          enabled = true;
          optimized = true;
          passes = 3;
          radius = 5;
          noise = 0.02;
          brightness = 0.9;
          contrast = 0.9;
          saturation = 1.1;
        };
      };

      # Off, as hyprmod had Hyprland's. The scratchpad's dim backdrop stays.
      animation.enabled = false;

      hot_corners.top_left = {
        enabled = true;
        delay_ms = 500;
        action = "overview-open";
      };

      # Every matching rule applies in order, and later values win.
      window_rule = [
        # Translucent windows blur what is behind them, other windows included
        # (Hyprland's blur without xray). `blur_optimized = true` blurs only
        # the wallpaper, which is cheaper. Opacity is hyprmod's; fullscreen
        # windows stay opaque.
        {
          blur = true;
          blur_optimized = false;
        }
        {
          match.is_focused = false;
          opacity = 0.95;
        }
        {
          match.is_focused = true;
          opacity = 0.98;
        }
        # Close to Hyprland's fullscreen_on_one_column: a lone tiled window
        # takes the full width and returns to its own when another one joins.
        # Umbriel counts windows, not columns, so a column of two stacked or
        # tabbed windows keeps its own width.
        {
          match.is_alone = true;
          default_scrolling_extent = 1.0;
        }
        {
          match.app_id = "^dev[.]noctalia[.]Noctalia$";
          default_floating = true;
          default_floating_size_px = {
            width = 1080;
            height = 920;
          };
        }
        {
          match.app_id = "^dev[.]noctalia[.]UmbrielSharePicker$";
          default_floating = true;
          default_floating_size_px = {
            width = 800;
            height = 600;
          };
        }
        {
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          default_floating = true;
          default_position = {
            anchor = "bottom_right";
            x = 20;
            y = 20;
          };
        }

        (placeOn "web" "^slack$")
        (placeOn "code" "^com[.]ayugram[.]desktop$")
        (placeOn "design" "^com[.]mitchellh[.]ghostty$")
        (placeOn "6" "^code$")
        (placeOn "7" "^jetbrains-rider$")
        (placeOn "8" "^(keepassxc|org[.]keepassxc[.]KeePassXC)$")
        (placeOn "9" "^helium$")
        # Hyprland also sent incognito windows to 8 by initial_title. Umbriel
        # re-checks opening rules on the first title a window sets after it
        # appears, so a window that opens with the incognito title would jump
        # to 9 on its first navigation. Before adding the rule below, check
        # with `umbriel subscribe windows` that Helium's incognito window
        # appears untitled and only then reports this title.
        # {
        #   match.app_id = "^helium$";
        #   match.title = "^New Incognito Tab - Helium$";
        #   default_workspace = "8";
        # }
      ];

      # Noctalia draws translucent surfaces and animates them itself (layer
      # animations are off by default).
      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher|desktop-widget-.+)$";
          blur = true;
          blur_popups = true;
          blur_ignore_alpha = 0.5;
          blur_optimized = false;
        }
      ];

      # These add to Umbriel's built-in binds, replacing any with the same
      # chord; built-ins can't be removed. Unused ones left over are harmless:
      # Mod+H/L focus, Mod+Shift+H/J/K/L move, Mod+Period and
      # Mod+Ctrl+Comma/Period consume, Mod+M maximize to edges, Mod+F1 focus
      # next. Mod+left-drag moves and Mod+right-drag resizes without a bind.
      keybinds = {
        # Apps and session
        "Mod+T" = once "spawn:ghostty";
        "Mod+E" = once "spawn:nautilus";
        "Mod+Q" = once "window-close";
        "Mod+Space" = once (msg "panel-toggle launcher");
        "Mod+S" = once (msg "panel-toggle control-center");
        "Mod+Comma" = once (msg "settings-toggle");
        # Press again to move on; releasing Alt picks the window.
        "Alt+Tab" = once (msg "window-switcher hold");
        # Umbriel's own cheatsheet: the Noctalia plugin only reads Hyprland's.
        "Mod+K" = once "cheatsheet-toggle";
        # The built-in Mod+Escape asks to quit the session; this opens
        # Noctalia's session menu instead.
        "Mod+Escape" = once (msg "panel-toggle session");
        # Way out when a game or remote desktop inhibits shortcuts.
        "Mod+Shift+Escape" = once "shortcuts-inhibit-toggle" // {
          allow_when_inhibited = true;
        };

        # Media
        "XF86AudioRaiseVolume" = locked (msg "volume-up");
        "XF86AudioLowerVolume" = locked (msg "volume-down");
        "XF86AudioMute" = lockedOnce (msg "volume-mute");
        "XF86AudioMicMute" = lockedOnce "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = locked (msg "brightness-up");
        "XF86MonBrightnessDown" = locked (msg "brightness-down");
        # playerctl isn't installed, so Hyprland's media binds do nothing.
        "XF86AudioNext" = lockedOnce "spawn:${playerctl} next";
        "XF86AudioPrev" = lockedOnce "spawn:${playerctl} previous";
        "XF86AudioPlay" = lockedOnce "spawn:${playerctl} play-pause";
        "XF86AudioPause" = lockedOnce "spawn:${playerctl} play-pause";

        # Window state
        "Mod+V" = once "window-toggle-floating";
        # Pin above the layout; Hyprland had pseudotile here.
        "Mod+P" = once "window-toggle-pinned";
        # Cycles scrolling, dwindle and master for this workspace.
        "Mod+J" = once "workspace-set-layout:toggle";
        # Half-width column to full width and back, like colresize 0.5/1.0.
        "Mod+F" = once "window-toggle-maximize";
        "Mod+Shift+F" = once "window-toggle-fullscreen";
        "Mod+Ctrl+F" = once "window-toggle-maximize-to-edges";
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Shift+R" = "window-cycle-primary-extent-back";
        "Mod+Minus" = "window-modify-primary-extent:-0.1";
        "Mod+Equal" = "window-modify-primary-extent:0.1";
        "Mod+Shift+Minus" = "window-modify-secondary-extent:-0.1";
        "Mod+Shift+Equal" = "window-modify-secondary-extent:0.1";
        "Mod+C" = "column-center";
        # Tab groups: the column's stacked windows become tabs.
        "Mod+W" = once "column-toggle-tabbed";
        "Mod+Alt+Left" = "column-focus-tab-previous";
        "Mod+Alt+Right" = "column-focus-tab-next";
        # Held, these would flip between joining and leaving the column.
        "Mod+BracketLeft" = once "window-consume-or-expel-left";
        "Mod+BracketRight" = once "window-consume-or-expel-right";

        # Focus and move, crossing to the next monitor at the edge
        "Mod+Left" = "window-focus-or-output-left";
        "Mod+Right" = "window-focus-or-output-right";
        "Mod+Up" = "window-focus-or-output-up";
        "Mod+Down" = "window-focus-or-output-down";
        "Mod+Shift+Left" = "window-move-or-output-left";
        "Mod+Shift+Right" = "window-move-or-output-right";
        "Mod+Shift+Up" = "window-move-or-output-up";
        "Mod+Shift+Down" = "window-move-or-output-down";
        "Mod+Home" = "column-focus-first";
        "Mod+End" = "column-focus-last";
        "Mod+Tab" = once "workspace-focus-last";
        "Mod+Ctrl+Up" = "workspace-previous";
        "Mod+Ctrl+Down" = "workspace-next";
        "Mod+Ctrl+Shift+Up" = "window-move-to-workspace-previous";
        "Mod+Ctrl+Shift+Down" = "window-move-to-workspace-next";
        # Hyprland's e+1/e-1 walked every workspace on every monitor and
        # wrapped; these stay on the monitor under the pointer and stop at
        # its ends.
        "Mod+WheelDown" = {
          action = "workspace-next";
          cooldown_ms = 150;
        };
        "Mod+WheelUp" = {
          action = "workspace-previous";
          cooldown_ms = 150;
        };
        "Mod+Shift+WheelDown" = "window-focus-right";
        "Mod+Shift+WheelUp" = "window-focus-left";
        "Mod+MouseMiddle" = "layout-scroll-drag";

        # Overview (hyprtasking's Mod+O) and the scratchpad
        "Mod+O" = once "overview-toggle";
        "Mod+Grave" = "scratchpad-toggle";
        "Mod+Shift+Grave" = once "window-toggle-scratchpad";

        # Effects, off until asked for. The border pulse goes on the focused
        # window only; the cursor trail is session-wide.
        "Mod+Alt+E" = once "effect-border-set:pulse";
        "Mod+Alt+Shift+E" = once "effect-border-reset";
        "Mod+Alt+C" = once "effect-cursor-set:trail";
        "Mod+Alt+Shift+C" = once "effect-cursor-reset";
      }
      // workspaceBinds;
    };
  };
}
