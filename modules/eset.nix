# ESET PROTECT for the work entry: ESET Management Agent + ESET Server Security.
#
# ESET doesn't support NixOS. Its Live Installer refuses anything that isn't
# Ubuntu/Debian/RHEL/SUSE, and Server Security only installs through dpkg/rpm.
# So this module does the installers' work itself:
#
# - Server Security: unpacked from ESET's public repository, its kernel
#   modules built against our kernel, the product tree copied to the writable
#   /opt and /var paths it hardcodes, and its postinst transcribed below.
# - Management Agent: installed once by `sudo eset-agent-install <live
#   installer>`, which runs the company's Live Installer in a private mount
#   namespace that looks like Ubuntu. That also enrols the machine and
#   activates Server Security. The installer carries the PROTECT enrolment
#   and subscription tokens, so it is never committed or copied into the store.
#
# Enabled with services.eset.enable. `sudo eset off` / `sudo eset on` stop
# and start the whole suite without a rebuild; `eset status` shows it, and
# eset-tray.py puts the same switch in the system tray.
#
# ESET's binaries are left byte-identical and run through nix-ld; the agent's
# self-updates replace files in /opt and would drift from patched copies.
# Product upgrades pushed from the console won't work: bump the URLs and
# hashes here instead.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  kernel = config.boot.kernelPackages.kernel;

  efs = pkgs.stdenvNoCC.mkDerivation {
    pname = "eset-server-security";
    version = "13.2.53.0";
    src = pkgs.fetchurl {
      url = "https://repository.eset.com/v1/com/eset/apps/business/efs/linux/v13/13.2.53.0/efs.x86_64.bin";
      hash = "sha256-Z3cN/1fLYYJmN9lEYwq159QEbzYOraC7c6gszaoD0xE=";
    };
    nativeBuildInputs = [ pkgs.cpio ];
    dontUnpack = true;
    dontFixup = true;
    # The .bin is a shell script with a tar appended after its first bare
    # `exit`; the tar holds the rpm payload and the kernel module sources.
    installPhase = ''
      runHook preInstall
      mkdir payload root
      tail -n +"$(awk '/^exit$/ { print NR + 1; exit }' "$src")" "$src" | tar -C payload -x
      (cd root && gunzip -c ../payload/data.cpio.gz | cpio -imd --quiet)
      mkdir -p $out
      mv root/opt root/var payload/eset_rtp-*.tgz payload/eset_wap-*.tgz $out/
      runHook postInstall
    '';
  };

  mkKernelModule =
    name: src:
    kernel.stdenv.mkDerivation {
      pname = name;
      version = "${efs.version}-${kernel.version}";
      inherit src;
      nativeBuildInputs = kernel.moduleBuildDependencies;
      makeFlags = config.boot.kernelPackages.kernelModuleMakeFlags ++ [
        "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];
      buildFlags = [ "modules" ];
      installPhase = ''
        install -Dm444 ${name}/${name}.ko -t $out/lib/modules/${kernel.modDirVersion}/extra
      '';
    };

  eset-rtp = mkKernelModule "eset_rtp" "${efs}/eset_rtp-3.1.tgz";
  eset-wap = mkKernelModule "eset_wap" "${efs}/eset_wap-1.0.tgz";

  # ESET's daemons run as these users; from the postinst's useradd loop.
  efsUsers = {
    eset-efs-licensed = "eset-efs-daemons";
    eset-efs-vapmd = "eset-efs-daemons";
    eset-efs-authd = "eset-efs-daemons";
    eset-efs-sched = "eset-efs-agents";
    eset-efs-scand = "eset-efs-daemons";
    eset-efs-webd = "eset-efs-daemons";
    eset-efs-updated = "eset-efs-daemons";
    eset-efs-vapm-wrapper = "eset-efs-vapm";
    eset-efs-logd = "eset-efs-daemons";
    eset-efs-econnd = "eset-efs-daemons";
    eset-efs-confd = "eset-efs-daemons";
    eset-efs-icapd = "eset-efs-daemons";
    eset-efs-netisd = "eset-efs-daemons";
    eset-efs-wapd = "eset-efs-daemons";
    eset-efs-watchd = "eset-efs-daemons";
  };

  # systemd units don't see environment.variables.
  nixLdEnv = {
    inherit (config.environment.variables) NIX_LD NIX_LD_LIBRARY_PATH;
  };

  # ESET identifies btrfs subvolumes with `btrfs subvolume show`, which needs
  # root, but scand runs unprivileged; without it every scanned file logs
  # "Cannot find volume id". Route those read-only calls through sudo.
  btrfsSubvolume = "${pkgs.btrfs-progs}/bin/btrfs subvolume";
  btrfsWrapper = pkgs.writeShellScriptBin "btrfs" ''
    if [ "$(id -u)" -ne 0 ] && [ "''${1:-}" = subvolume ] && { [ "''${2:-}" = show ] || [ "''${2:-}" = list ]; }; then
      exec /run/wrappers/bin/sudo -n ${pkgs.btrfs-progs}/bin/btrfs "$@"
    fi
    exec ${pkgs.btrfs-progs}/bin/btrfs "$@"
  '';

  # What ESET's own scripts expect to find on an Ubuntu/RHEL PATH.
  esetPath = with pkgs; [
    bash
    btrfsWrapper
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    gzip
    kmod
    openssl
    procps
    systemd
    util-linux
    which
  ];

  # The agent installer (re)installs its unit with systemctl under `set -e`,
  # which fails against NixOS's read-only unit directory. NixOS owns the unit,
  # so make those calls no-ops and pass the rest through.
  systemctlShim = pkgs.writeShellScriptBin "systemctl" ''
    case "''${1:-}" in
      enable | disable | reenable | daemon-reload | mask | unmask)
        echo "eset-agent-install: skipping 'systemctl $*' (unit is managed by NixOS)" >&2
        exit 0
        ;;
      is-enabled)
        exit 1
        ;;
    esac
    exec ${pkgs.systemd}/bin/systemctl "$@"
  '';

  fakeOsRelease = pkgs.writeText "os-release" ''
    NAME="Ubuntu"
    VERSION="24.04 LTS (Noble Numbat)"
    ID=ubuntu
    ID_LIKE=debian
    PRETTY_NAME="Ubuntu 24.04 LTS"
    VERSION_ID="24.04"
    VERSION_CODENAME=noble
  '';

  # Server Security's installer ends in `apt-get install ./efs.deb`. This
  # module already provides the package, so report success: the Live
  # Installer then applies its policy and activates the running product
  # with the subscription token it carries (`lic --token=...`).
  fakeAptGet = pkgs.writeShellScriptBin "apt-get" ''
    if [ "''${1:-}" = --version ]; then
      echo "apt 2.7.14 (amd64)"
    else
      echo "eset-agent-install: skipping 'apt-get $*' (NixOS provides ESET Server Security)" >&2
    fi
  '';

  # The Live Installer pipes through /usr/bin/tee (and pages with fold/less);
  # the agent installer calls /bin/cp and /bin/echo; Server Security's
  # installer needs ar and cpio to build its .deb.
  installerBin = pkgs.symlinkJoin {
    name = "eset-installer-bin";
    paths = with pkgs; [
      bash
      binutils
      coreutils
      cpio
      fakeAptGet
      less
    ];
  };

  # Runs the company's Live Installer as if on Ubuntu, so it enrols this
  # machine, installs the agent and activates Server Security. Re-running it
  # repairs the agent in place and keeps the device's identity.
  eset-agent-install = pkgs.writeShellApplication {
    name = "eset-agent-install";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.util-linux
    ];
    # $1 in the single-quoted `sh -c` script is meant for the inner shell.
    excludeShellChecks = [ "SC2016" ];
    text = ''
      if [ "$(id -u)" -ne 0 ]; then
        echo "Run this with sudo." >&2
        exit 1
      fi
      installer=''${1:?usage: sudo eset-agent-install /path/to/epi_lin_live_installer.bin}

      work=$(mktemp -d)
      trap 'rm -rf "$work"' EXIT
      install -m 0700 "$installer" "$work/epi.bin"

      export NIX_LD=${nixLdEnv.NIX_LD} NIX_LD_LIBRARY_PATH=${nixLdEnv.NIX_LD_LIBRARY_PATH}
      export PATH=${systemctlShim}/bin:${installerBin}/bin:${lib.makeBinPath esetPath}:/run/wrappers/bin:/run/current-system/sw/bin

      # Without both mounts the agent installer half-installs, so stop first.
      unshare --mount --propagation private sh -c '
        set -e
        mount --bind ${fakeOsRelease} /etc/os-release
        mount -t tmpfs tmpfs /etc/systemd/system
        mount --bind ${installerBin}/bin /usr/bin
        mount --bind ${installerBin}/bin /bin
        "$1"
      ' sh "$work/epi.bin"
    '';
  };

  efsSetup = pkgs.writeShellScript "eset-efs-setup" ''
    set -eu
    opt=/opt/eset/efs
    var=/var/opt/eset/efs

    # Copy the product in when the package changes, keeping the toggles ESET
    # writes under etc/.
    if [ "$(cat $opt/.nix-source 2>/dev/null || true)" != ${efs} ]; then
      mkdir -p /opt/eset $var
      rsync -rlt --chmod=Du+w,Fu+w \
        --exclude=/etc/systemd/environment --exclude='/etc/*_DISABLED' --exclude='/etc/*_ENABLED' \
        ${efs}/opt/eset/efs/ $opt/
      rsync -rlt --chmod=Du+w,Fu+w ${efs}/var/opt/eset/efs/ $var/

      # From the postinst: unpack and compile the bundled detection modules.
      mkdir -p $var/updated/modules
      tar -xf $var/lib/modules_efs.tar -C $var/updated/modules
      $opt/lib/modfetch --compile-nups || echo "eset-efs-setup: detection module compilation failed" >&2
      fresh=1
    fi

    # Web protection needs nftables, sysctl and udev hooks that this module
    # doesn't set up yet, so keep it off (the postinst's ESET_DISABLE_WAP).
    [ -e $opt/etc/NFTABLES_DISABLED ] || echo 1 > $opt/etc/NFTABLES_DISABLED

    # From the postinst, generated by ESET from product_paths.json.
    install -d -o eset-efs-logd -g eset-efs-daemons -m 0755 /var/log/eset/efs
    install -d -o eset-efs-logd -g eset-efs-daemons -m 0700 /var/log/eset/efs/logd
    install -d -o eset-efs-icapd -g eset-efs-daemons -m 0700 /var/log/eset/efs/icap
    install -d -o root -g eset-efs-daemons -m 1770 /var/log/eset/efs/internal
    install -d -o root -g eset-efs-daemons -m 0775 $var
    install -d -o eset-efs-confd -g eset-efs-daemons -m 0700 $var/confd
    install -d -o root -g eset-efs-daemons -m 0755 /run/eset/efs
    install -d -o eset-efs-scand -g eset-efs-services -m 1770 $var/cache
    install -d -o eset-efs-scand -g eset-efs-daemons -m 1770 $var/cache/data
    install -d -o eset-efs-scand -g eset-efs-daemons -m 1770 $var/cache/data/Logs
    install -d -o eset-efs-scand -g eset-efs-daemons -m 1770 $var/cache/data/Diagnostics
    install -d -o root -g eset-efs-daemons -m 0775 $var/installer
    install -d -o root -g eset-efs-vapm -m 0770 $var/vapm
    install -d -o eset-efs-vapmd -g eset-efs-vapm -m 0640 $var/vapm/database
    chown -R eset-efs-vapmd:eset-efs-vapm $var/vapm/database
    find -P $var/vapm/database -type d -exec chmod 0750 '{}' +
    find -P $var/vapm/database -type f -exec chmod 0640 '{}' +
    install -d -o eset-efs-vapm-wrapper -g eset-efs-vapm -m 0600 $var/vapm/logs
    chown -R eset-efs-vapm-wrapper:eset-efs-vapm $var/vapm/logs
    find -P $var/vapm/logs -type d -exec chmod 0700 '{}' +
    find -P $var/vapm/logs -type f -exec chmod 0600 '{}' +
    install -d -o eset-efs-updated -g eset-efs-daemons -m 0644 $var/lib
    chown -R eset-efs-updated:eset-efs-daemons $var/lib
    find -P $var/lib -type d -exec chmod 0755 '{}' +
    find -P $var/lib -type f -exec chmod 0644 '{}' +
    install -d -o root -g root -m 0755 $var/modules_notice
    install -d -o eset-efs-updated -g eset-efs-daemons -m 0755 $var/updated
    install -d -o eset-efs-updated -g eset-efs-daemons -m 0700 $var/updated/app
    install -d -o eset-efs-updated -g eset-efs-daemons -m 0644 $var/updated/modules
    chown -R eset-efs-updated:eset-efs-daemons $var/updated/modules
    find -P $var/updated/modules -type d -exec chmod 0755 '{}' +
    find -P $var/updated/modules -type f -exec chmod 0644 '{}' +
    install -d -o root -g root -m 0755 /opt/eset/lib
    install -d -o root -g eset-efs-services -m 0775 /opt/eset/lib/modules
    install -d -o root -g eset-efs-services -m 0775 $var/dumps
    install -d -o root -g root -m 0700 $var/nft_scripts
    # From install_scripts/configure.sh.
    chown -R root $var/ertp

    if [ -n "''${fresh:-}" ]; then
      echo ${efs} > $opt/.nix-source
    fi
  '';

  # The rest of the postinst talks to the running daemons. If they aren't
  # answering yet, leave the marker unset and retry on the next start.
  efsFirstRun = pkgs.writeShellScript "eset-efs-first-run" ''
    marker=/var/opt/eset/efs/.nix-first-run
    [ -e $marker ] && exit 0
    cfg=/opt/eset/efs/sbin/cfg

    # The installer's built-in terms of use, as accepted by its postinst.
    $cfg --eula-tag TOU-BUSINESS --eula-version 3537.0.3 > /dev/null &&
      $cfg -i /dev/stdin > /dev/null <<EOF &&
    {"method": "_CE.rpc_api.screen_values_set", "params": {"values": {
      "State.Plugins.Webd.LastProcessedVersion": [13, 2, 53, 0],
      "State.Common.DateOfProductInstallation": $(date +%s)
    }}}
    EOF
      $cfg --set Settings.Plugins.Wapd.Protoscan.WebProtectionEnabled 0 > /dev/null &&
      touch $marker ||
      echo "eset-efs-first-run: cfg failed, will retry on next start" >&2
    exit 0
  '';

  # oaeventd and wapd load their modules from where check_start.sh would
  # have compiled them, not through modprobe.
  esetModDir = "/lib/modules/${kernel.modDirVersion}/eset/efs";

  # Runtime kill switch. Every ESET unit checks this flag, so `eset off`
  # also holds across reboots and switches without a rebuild.
  offFlag = "/var/lib/eset/disabled";
  unlessOff = "!${offFlag}";

  eset-switch = pkgs.writeShellApplication {
    name = "eset";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      kmod
      systemd
    ];
    text = ''
      units=(eset-cron.service efs.service eraagent.service)

      need_root() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "Run this with sudo." >&2
          exit 1
        fi
      }

      case "''${1:-status}" in
        off)
          need_root
          mkdir -p ${dirOf offFlag}
          touch ${offFlag}
          systemctl stop "''${units[@]}" eset-efs-setup.service
          for m in eset_wap eset_rtp; do
            if grep -q "^$m " /proc/modules; then
              rmmod "$m" || echo "Could not unload $m; it goes away on reboot." >&2
            fi
          done
          echo "ESET is off, including after reboots, until 'sudo eset on'."
          ;;
        on)
          need_root
          rm -f ${offFlag}
          systemctl start "''${units[@]}"
          echo "ESET is on."
          ;;
        status)
          if [ -e ${offFlag} ]; then echo "switch    off"; else echo "switch    on"; fi
          for u in "''${units[@]}"; do
            printf '%-9s %s\n' "''${u%.service}" "$(systemctl is-active "$u" || true)"
          done
          if grep -q '^eset_rtp ' /proc/modules; then echo "eset_rtp  loaded"; else echo "eset_rtp  not loaded"; fi
          ;;
        *)
          echo "usage: eset [on|off|status]" >&2
          exit 2
          ;;
      esac
    '';
  };

  esetTrayScript =
    pkgs.writers.writePython3 "eset-tray"
      {
        libraries = [ pkgs.python3Packages.pyqt6 ];
        flakeIgnore = [ "E501" ];
      }
      (
        builtins.replaceStrings [ "@eset@" ] [ "${eset-switch}/bin/eset" ] (
          builtins.readFile ./eset-tray.py
        )
      );

  eset-tray = pkgs.stdenv.mkDerivation {
    name = "eset-tray";
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.qt6.wrapQtAppsHook ];
    buildInputs = with pkgs.qt6; [
      qtbase
      qtsvg
      qtwayland
    ];
    installPhase = ''
      install -Dm755 ${esetTrayScript} $out/bin/eset-tray
    '';
    # The hook only wraps ELF binaries on its own.
    dontWrapQtApps = true;
    postFixup = ''
      wrapQtApp $out/bin/eset-tray
    '';
  };
in

{
  options.services.eset.enable = lib.mkEnableOption "ESET PROTECT (Management Agent and Server Security)";

  config = lib.mkIf config.services.eset.enable {
    boot.extraModulePackages = [
      eset-rtp
      eset-wap
    ];

    # libsqlite3 is the one NEEDED library outside nix-ld's base set.
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = [ pkgs.sqlite ];

    users.groups = lib.genAttrs [
      "eset-efs-services"
      "eset-efs-daemons"
      "eset-efs-vapm"
      "eset-efs-agents"
    ] (_: { });
    users.users = lib.mapAttrs (name: group: {
      isSystemUser = true;
      inherit group;
      extraGroups = [ "eset-efs-services" ] ++ lib.optional (name == "eset-efs-vapmd") "eset-efs-vapm";
      home = "/opt/eset/efs";
    }) efsUsers;

    environment.systemPackages = [
      eset-agent-install
      eset-switch
    ];

    # The tray toggles through pkexec: ask for the password, then keep it for
    # a few minutes, as for sudo.
    security.polkit.extraConfig = ''
      polkit.addRule(function (action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "${eset-switch}/bin/eset" &&
            subject.local && subject.active && subject.isInGroup("wheel")) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
      });
    '';

    systemd.user.services.eset-tray = {
      description = "ESET status in the system tray";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${eset-tray}/bin/eset-tray";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    security.sudo.extraRules = [
      {
        groups = [ "eset-efs-services" ];
        commands = [
          {
            command = "${btrfsSubvolume} show *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${btrfsSubvolume} list *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # ESET schedules scans by writing jobs to /etc/cron.d, which NixOS's Vixie
    # cron doesn't read. Run cronie for them instead.
    assertions = [
      {
        assertion = !config.services.cron.enable;
        message = "modules/eset.nix runs cronie for ESET; services.cron would run /etc/crontab twice.";
      }
    ];
    # The paths follow the configured kernel, so after a kernel update
    # real-time protection is off until the next reboot.
    systemd.tmpfiles.rules = [
      "d /etc/cron.d 0755 root root -"
      "d /var/spool/cron 0700 root root -"
      "d ${esetModDir} 0755 root root -"
      "L+ ${esetModDir}/eset_rtp.ko - - - - ${eset-rtp}/lib/modules/${kernel.modDirVersion}/extra/eset_rtp.ko"
      "L+ ${esetModDir}/eset_wap.ko - - - - ${eset-wap}/lib/modules/${kernel.modDirVersion}/extra/eset_wap.ko"
    ];
    systemd.services.eset-cron = {
      description = "Cron daemon for ESET scheduled tasks";
      wantedBy = [ "multi-user.target" ];
      before = [ "efs.service" ];
      unitConfig.ConditionPathExists = unlessOff;
      serviceConfig = {
        ExecStart = "${pkgs.cronie}/bin/crond -n";
        Restart = "on-failure";
      };
    };

    systemd.services.eset-efs-setup = {
      description = "Install ESET Server Security files";
      path = [ pkgs.rsync ] ++ esetPath;
      environment = nixLdEnv;
      unitConfig.ConditionPathExists = unlessOff;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = efsSetup;
        # The first run unpacks and compiles ~185 MB of detection modules.
        TimeoutStartSec = 900;
      };
    };

    # From /opt/eset/efs/etc/systemd/efs.service, minus check_start.sh: the
    # modules are built above, and it would find them through modinfo outside
    # its own directory and complain.
    systemd.services.efs = {
      description = "ESET Server Security";
      wantedBy = [ "multi-user.target" ];
      requires = [ "eset-efs-setup.service" ];
      after = [
        "network.target"
        "eset-efs-setup.service"
      ];
      path = esetPath;
      environment = nixLdEnv;
      unitConfig.ConditionPathExists = unlessOff;
      serviceConfig = {
        Type = "notify";
        ExecStart = "/opt/eset/efs/sbin/startd";
        ExecStartPost = efsFirstRun;
        KillMode = "process";
        Restart = "always";
        TimeoutStartSec = 180;
        TimeoutStopSec = 120;
        OOMScoreAdjust = -800;
        EnvironmentFile = "-/opt/eset/efs/etc/systemd/environment";
      };
    };

    # From the agent's setup/systemd.service, under the name its installer and
    # self-upgrades use. Inert until eset-agent-install has run.
    systemd.services.eraagent = {
      description = "ESET Management Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      unitConfig.ConditionPathExists = [
        "/opt/eset/RemoteAdministrator/Agent/ERAAgent"
        unlessOff
      ];
      path = esetPath;
      environment = nixLdEnv;
      serviceConfig = {
        Type = "forking";
        KillMode = "process";
        PIDFile = "/run/eraagent.pid";
        ExecStart = "/opt/eset/RemoteAdministrator/Agent/ERAAgent --daemon --pidfile /run/eraagent.pid";
        Restart = "on-abort";
        RestartSec = 60;
      };
    };
  };
}
