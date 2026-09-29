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

  tuios = inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios.overrideAttrs (_: {
    # Upstream v0.8.0 currently carries the previous Go dependency hash.
    vendorHash = "sha256-mgVS2X9j+2qepgNNlCQLyBHnjrYWpJtJyqIfTq/nYcU=";
  });
in

{
  imports = [
    ./common.nix
    inputs.chatgpt-desktop.nixosModules.default
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_zen;
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;

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
    opencode
    opencode-desktop
    tuios
  ];
}
