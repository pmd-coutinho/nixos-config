{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  claudeDesktop = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default;

  tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios;
in

{
  # Swap for memory pressure (large .NET builds, Rider + Docker).
  # zram alone is capped at a fraction of RAM and was filling up completely;
  # a disk swapfile gives real overflow capacity, and zswap keeps a compressed
  # LRU cache of swapped pages in RAM so only cold pages hit the NVMe.
  # The swapfile lives on the top-level btrfs subvolume (no snapshots there),
  # and NixOS creates it with `btrfs filesystem mkswapfile` (NOCOW, uncompressed).
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # MiB
    }
  ];
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=25"
    "zswap.shrinker_enabled=1"
  ];
  # When the user session thrashes (stalled on memory >80% of the time for
  # 30s), kill the app causing it instead of freezing during a runaway build.
  systemd.oomd.enableUserSlices = true;
  # oomd kills whole cgroups, and the compositor's unit is the biggest leaf in
  # session.slice. Make it the last pick, so a runaway app goes first.
  systemd.user.services."wayland-wm@".serviceConfig.ManagedOOMPreference = "avoid";
  systemd.user.services.umbriel.serviceConfig.ManagedOOMPreference = "avoid";

  imports = [
    ../modules/ai-tools.nix
    ../modules/eset.nix
  ];

  # `false` drops ESET from the build; `sudo eset off` stops it without one.
  services.eset.enable = true;

  # Trust the ASP.NET Core dev cert (`dotnet dev-certs https`) for OpenSSL
  # clients: Kestrel, HttpClient, curl. Only the public cert is kept here; the
  # key stays in ~/.dotnet. Copy it again after a regenerate (expires 2027-09-25).
  security.pki.certificateFiles = [ ../certs/aspnet-dev.crt ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  # Rootful Docker daemon; access to its socket is limited to the work entry.
  virtualisation.docker = {
    enable = true;
    rootless.enable = false;
    # Start dockerd on first use through docker.socket instead of at boot.
    # Containers with a restart policy come back when something first touches
    # the socket.
    enableOnBoot = false;
    # Weekly `docker system prune`: stopped containers, dangling images,
    # unused networks, build cache, and anonymous volumes no container uses.
    # Named volumes (nopcommerce-mssql-*, ...) are kept.
    autoPrune = {
      enable = true;
      flags = [ "--volumes" ];
    };
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
    # omp's v18.11.0 tag was moved after nixpkgs pinned it, so the source hash
    # no longer matches and Hydra never cached a build. Drop once nixos-unstable
    # ships omp 18.11.1 or later.
    (final: prev: {
      omp = prev.omp.overrideAttrs (old: {
        src = old.src.overrideAttrs {
          outputHash = "sha256-pIAoAc3vE8nfVacsY+IEGcQVFCfMvVrK5qPcxi7NTho=";
        };
      });
    })
  ];
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  # Let both clients install split-DNS routes for internal work domains without
  # racing to rewrite /etc/resolv.conf.
  services.resolved.enable = true;

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
    claude-code
    claudeDesktop
    pi-coding-agent
    omp
    tuios
    herdr
    azure-cli
    bruno
  ];
}
