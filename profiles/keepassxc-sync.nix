{ pkgs, ... }:

let
  vaultSync = pkgs.writeShellApplication {
    name = "rclone-vault-sync";
    runtimeInputs = [ pkgs.rclone ];
    text = ''
      rclone bisync "$HOME/vault" gdrive:vault \
        --resilient \
        --recover \
        --force \
        --check-access \
        --max-lock 2m \
        --conflict-resolve newer \
        --conflict-loser num \
        --conflict-suffix conflict \
        --backup-dir1 "$HOME/vault-backup" \
        --backup-dir2 gdrive:vault-backup \
        --create-empty-src-dirs
    '';
  };

  notifyFailure = pkgs.writeShellApplication {
    name = "notify-vault-sync-failure";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      notify-send \
        --urgency=critical \
        --icon=dialog-error \
        "⚠ $1 failed" \
        "Background service failed. Inspect with: journalctl --user -u $1 -e"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    keepassxc
    libsecret
    rclone
    seahorse
    wl-clipboard
  ];

  services.gnome.gnome-keyring.enable = true;
  # KeePassXC uses the separately managed OpenSSH agent below.
  services.gnome.gcr-ssh-agent.enable = false;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Point KeePassXC and the rest of the session at a stable agent socket.
  environment.etc."environment.d/20-ssh-agent.conf".text = ''
    SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent.socket
  '';

  systemd.user.services = {
    ssh-agent = {
      description = "SSH authentication agent (static socket for KeePassXC)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
        ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
      };
    };

    rclone-vault-sync = {
      description = "Sync KeePassXC vault to Google Drive (rclone bisync)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig = {
        ConditionPathIsDirectory = "%h/vault";
        OnFailure = [ "notify-vault-sync-failure@%n.service" ];
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${vaultSync}/bin/rclone-vault-sync";
      };
    };

    "notify-vault-sync-failure@" = {
      description = "Desktop notification when %i fails";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notifyFailure}/bin/notify-vault-sync-failure %I";
      };
    };
  };

  systemd.user.paths.rclone-vault-sync = {
    description = "Sync vault when Passwords.kdbx changes";
    wantedBy = [ "default.target" ];
    pathConfig.PathChanged = "%h/vault/Passwords.kdbx";
  };

  systemd.user.timers.rclone-vault-sync = {
    description = "Periodic KeePassXC vault sync to Google Drive";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
}
