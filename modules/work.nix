{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # Without llm-agents' bubblewrap wrapper: in its user namespace root-owned
  # files show as nobody, so ssh (and with it git push) and sudo fail for
  # everything started from the app, Claude Code sessions included. nix-ld
  # covers the generic-linux binaries the app downloads. Cowork's VM needs
  # the wrapper's firmware paths, so it doesn't work this way.
  claudeDesktop = llmAgents.claude-desktop.unwrapped;

  tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios;

  # nixpkgs bumped invoke to 3.x, which fabric doesn't support yet
  # (fabric/fabric#2376), so fabric is marked broken and azure-cli, which
  # imports it for `az webapp`, won't evaluate. Take the same azure-cli 2.91.0
  # from the last nixpkgs with invoke 2.2.1 (prebuilt in the cache). Drop this
  # and the nixpkgs-azure-cli input once pkgs.azure-cli evaluates again.
  azureCli = inputs.nixpkgs-azure-cli.legacyPackages.${pkgs.stdenv.hostPlatform.system}.azure-cli;
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
  systemd.user.services.niri.serviceConfig.ManagedOOMPreference = "avoid";

  imports = [
    ./ai-tools.nix
    ./eset.nix
  ];

  # `false` drops ESET from the build; `sudo eset off` stops it without one.
  services.eset.enable = true;

  # Trust the ASP.NET Core dev cert (`dotnet dev-certs https`) for OpenSSL
  # clients: Kestrel, HttpClient, curl. Only the public cert is kept here; the
  # key stays in ~/.dotnet. Copy it again after a regenerate (expires 2027-09-25).
  security.pki.certificateFiles = [ ../certs/aspnet-dev.crt ];

  # Numtide's cache for Claude Desktop (flake input llm-agents). It advertises
  # priority 30, ahead of cache.nixos.org's 40; 50 keeps nixpkgs paths coming
  # from cache.nixos.org.
  nix.settings.substituters = [ "https://cache.numtide.com?priority=50" ];
  nix.settings.trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Re-patch the NVIDIA tools (nvidia-smi, nvidia-powerd) in two patchelf calls: patchelf
  # 0.19.2 breaks the combined call and they segfault on start (NixOS/nixpkgs#576412,
  # #576435). Only the userspace tools change; the kernel module is untouched.
  # Drop the override once nixpkgs fixes this.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      for orig in $bin/origBin/*; do
        f=$bin/bin/$(basename $orig)
        rp=$(patchelf --print-rpath $f); int=$(patchelf --print-interpreter $f)
        install -m755 $orig $f
        patchelf --set-rpath "$rp" $f
        patchelf --interpreter "$int" $f
      done
    '';
  });
  # A live switch to new NVIDIA userspace leaves the old kernel module loaded,
  # and new GL/CUDA clients fail with "API mismatch" until a reboot. Refuse the
  # switch when the driver version changes; use `nh os boot` and reboot instead.
  system.switch.inhibitors.nvidia-driver = config.hardware.nvidia.package.version;

  # Rootful Docker daemon. Membership in the docker group is root-equivalent.
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
    # From llm-agents: it tracks npm releases within a day or so, while
    # nixos-unstable can sit on an older one for days.
    llmAgents.claude-code
    claudeDesktop
    pi-coding-agent
    omp
    tuios
    herdr
    azureCli
    bruno
    # Yarn 4 as `yarn` (pay-on-phone, Aspire's WithYarn). In the Yarn 1 projects
    # (orderpro), run `corepack yarn@1.22.22 install`: bare `yarn` would
    # migrate and rewrite their yarn.lock.
    yarn-berry
    pnpm # switches itself to the package.json packageManager version
  ];
}
