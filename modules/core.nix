# Shared by both boot entries: work (the default, configuration.nix) and gaming
# (a specialisation that inherits nothing from work). Each entry picks its own
# kernel and NVIDIA driver in its profile.

{
  config,
  pkgs,
  inputs,
  ...
}:

let
  msi-ec = config.boot.kernelPackages.msi-ec.overrideAttrs (_: {
    # Nixpkgs 0.12 lacks support for the Vector 16 HX A14V EC firmware .112.
    version = "0.13-git-d7fbbd8";
    src = inputs.msi-ec;
    patches = [ ../patches/msi-ec-nix-build.patch ];
  });
in
{
  imports = [
    # Include the results of the hardware scan.
    ../hardware-configuration.nix
    ../noctalia.nix
    ./keepassxc-sync.nix
    ./msi-mux.nix
    # Also needed in work: it configures the Chaotic Nyx binary cache, so
    # building the gaming entry from work downloads its kernel instead of
    # compiling it.
    inputs.chaotic.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # Keep five recent generations; each includes a work and a gaming entry.
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  # /tmp lives on disk and build scratch (nix-shell, MSBuild) piles up there.
  # Not tmpfs: those dirs reach tens of GB.
  boot.tmp.cleanOnBoot = true;

  boot.extraModulePackages = [ msi-ec ];
  boot.kernelModules = [
    "msi-ec"
    "ec_sys"
  ];
  # Required by MControlCenter for EC temperature and fan-curve access.
  boot.extraModprobeConfig = "options ec_sys write_support=1";

  networking.hostName = "pedrocoutinho-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  environment.sessionVariables = {
    BROWSER = "helium";
    # Electron/Chromium apps (VS Code, Helium, ...) otherwise fall back to
    # blurry XWayland rendering, especially on fractionally scaled displays.
    NIXOS_OZONE_WL = "1";
  };
  xdg.mime.defaultApplications = {
    "text/html" = "helium.desktop";
    "application/xhtml+xml" = "helium.desktop";
    "x-scheme-handler/http" = "helium.desktop";
    "x-scheme-handler/https" = "helium.desktop";
  };

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Configure keymap in X11

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."pedrocoutinho" = {
    isNormalUser = true;
    description = "Pedro Coutinho";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # zsh must be enabled system-wide to be a login shell. Its interactive
  # config (history, plugins, prompt) lives in home/shell.nix.
  programs.zsh = {
    enable = true;
    # Home Manager runs compinit; doing it here too slows every shell start.
    enableCompletion = false;
  };
  # Expose completions shipped by system packages to Home Manager's compinit.
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Move pre-existing dotfiles aside instead of failing activation.
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.pedrocoutinho.imports = [ ../home ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    cascadia-code
    nerd-fonts.caskaydia-cove
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    firefox
    blueman
    pwvucontrol
    vscode
    mcontrolcenter
    bibata-cursors
    ayugram-desktop
    nodejs
    (python3.withPackages (ps: [ ps.pip ]))
    uv
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon (key-based authentication only).
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Throttles the CPU before it overheats, using the firmware's DPTF tables.
  services.thermald.enable = true;

  # Firmware updates (BIOS, EC, SSD) via LVFS: `fwupdmgr refresh && fwupdmgr update`.
  services.fwupd.enable = true;

  # Swap is per profile: work uses zswap + a disk swapfile (large .NET builds),
  # gaming uses zram. See profiles/work.nix and profiles/gaming.nix.

  # Transparent compression and no access-time writes on every btrfs mount.
  # These merge with the options in hardware-configuration.nix.
  fileSystems."/".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/home".options = [
    "compress=zstd"
    "noatime"
  ];
  fileSystems."/nix".options = [
    "compress=zstd"
    "noatime"
  ];
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
  security.polkit.enable = true;
  security.rtkit.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Hard-link identical files in the store to save space.
    auto-optimise-store = true;
  };

  # `nh os switch` wraps nixos-rebuild with a package diff; `nh clean` prunes
  # old generations weekly so the store does not grow unbounded.
  programs.nh = {
    enable = true;
    flake = "/home/pedrocoutinho/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };
}
