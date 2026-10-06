{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  claudeDesktop = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default;

  chatgptDesktop =
    inputs.chatgpt-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        # The upstream "auto" hint still selects X11 under Hyprland. Force
        # native Wayland so fractional scaling remains sharp.
        postFixup =
          builtins.replaceStrings [ "--ozone-platform-hint=auto" ] [ "--ozone-platform=wayland" ]
            old.postFixup;
      });

  tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios;

  # OpenCode v2 isn't in nixpkgs yet, so build it from upstream's v2 branch.
  opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};

  opencode = opencodePkgs.opencode.overrideAttrs (old: {
    # Upstream generates shell completions by running the new binary, which
    # currently crashes. Skip them until that's fixed.
    postInstall = "";
    # Upstream builds the CLI as channel "prod", which registers the background
    # service in service-prod.json. The desktop client only looks for
    # service.json and spins on "loading" forever. Official releases use "latest".
    env = old.env // {
      OPENCODE_CHANNEL = "latest";
    };
  });

  # Upstream's nix/electron.nix still carries the Electron 42.10.1 checksums
  # while the desktop app pins 44.4.5, so build that version ourselves.
  opencodeElectron =
    (pkgs.callPackage (pkgs.path + "/pkgs/development/tools/electron/binary/generic.nix") { }) "44.4.5"
      {
        x86_64-linux = "04586a0ec46c3283fbdaef85530f561f71f0b5e136ad0cb9ef63683615609780";
        headers = "sha256-QPkX+99kArlQhhbgOZe+Hsk28G5cadkUy0G0cIDtEh8=";
      };

  opencodeDesktop =
    (opencodePkgs.opencode-desktop.override {
      inherit opencode;
      callPackage =
        fn: args: if baseNameOf fn == "electron.nix" then opencodeElectron else pkgs.callPackage fn args;
    }).overrideAttrs
      (old: {
        # The desktop inherits the CLI's env, but its own code expects "prod".
        env = old.env // {
          OPENCODE_CHANNEL = "prod";
        };
        # The desktop prebuild now reads the bundled CLI's version from a
        # package.json next to its binary, which upstream's derivation doesn't write.
        buildPhase =
          assert lib.hasInfix "\nbun run build\n" old.buildPhase;
          builtins.replaceStrings
            [ "\nbun run build\n" ]
            [
              ''

                echo '{"version":"${opencode.version}"}' > "$OPENCODE_CLI_DIST/$cli_package/package.json"
                bun run build
              ''
            ]
            old.buildPhase;
      });
in

{
  imports = [
    inputs.chatgpt-desktop.nixosModules.default
    ../modules/eset.nix
  ];

  # `false` drops ESET from the build; `sudo eset off` stops it without one.
  services.eset.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  # Rootful Docker daemon; access to its socket is limited to the work entry.
  virtualisation.docker = {
    enable = true;
    rootless.enable = false;
  };
  users.users.pedrocoutinho.extraGroups = [ "docker" ];

  # OpenVPN 3 provides its own CLI and D-Bus services. NetworkManager cannot
  # use it as a backend, so install NetworkManager's OpenVPN plugin separately
  # for VPN profiles managed through nmcli or a desktop network applet.
  programs.openvpn3.enable = true;
  # Build fixes for the openvpn3 stack; drop once nixpkgs catches up.
  # - gdbuspp builds with -Werror and trips a GCC 15 maybe-uninitialized
  #   false positive.
  # - openvpn3 pins C++17, but abseil 20260817 (via protobuf) needs C++20;
  #   its core then hits C++20 deprecation warnings under werror.
  nixpkgs.overlays = [
    (final: prev: {
      gdbuspp = prev.gdbuspp.overrideAttrs (old: {
        env = (old.env or { }) // {
          NIX_CFLAGS_COMPILE = "${old.env.NIX_CFLAGS_COMPILE or ""} -Wno-error=maybe-uninitialized";
        };
      });
      openvpn3 = prev.openvpn3.overrideAttrs (old: {
        mesonFlags = old.mesonFlags ++ [
          (lib.mesonOption "cpp_std" "c++20")
          (lib.mesonBool "werror" false)
        ];
      });
    })
  ];
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  # Let both clients install split-DNS routes for internal work domains without
  # racing to rewrite /etc/resolv.conf.
  services.resolved.enable = true;

  programs.chatgpt-desktop = {
    enable = true;
    package = chatgptDesktop;
    primaryRuntime.enable = true;
  };

  # VS Code extensions download unpatched .NET runtimes. Make ICU available
  # through nix-ld so SQLToolsService can initialize globalization support.
  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.icu ];
  };

  # Work-only additions to home/ (merged into the base Home Manager config).
  home-manager.users.pedrocoutinho = {
    imports = [ ../home/zed.nix ];
    programs.mise.enable = true;
    programs.starship.settings = {
      format = lib.mkForce "$directory$git_branch$git_status$mise$cmd_duration$line_break$character";
      mise = {
        disabled = false;
        symbol = "mise ";
      };
    };
    home.packages = with pkgs; [
      lazygit
      gh
    ];
  };

  # Work-only packages and settings belong here.
  environment.systemPackages = with pkgs; [
    slack
    lazydocker
    docker-compose
    docker-buildx
    jetbrains.rider
    dotnet-sdk_10
    codex
    claude-code
    claudeDesktop
    opencode
    opencodeDesktop
    pi-coding-agent
    omp
    tuios
    azure-cli
  ];
}
