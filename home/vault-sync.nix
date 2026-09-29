# KeePassXC vault synced to Google Drive, plus the SSH agent KeePassXC loads
# keys into. Imported by profiles/keepassxc-sync.nix (gaming and work only),
# which keeps the system-side keyring and PAM settings.
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
  home.packages = with pkgs; [
    keepassxc
    libsecret
    rclone
    seahorse
    wl-clipboard
  ];

  # Static agent socket for KeePassXC. The module also exports SSH_AUTH_SOCK
  # to shells and to the systemd/D-Bus activation environment.
  services.ssh-agent = {
    enable = true;
    socket = "ssh-agent.socket";
  };
  # Set it before the session starts too, so apps launched by Hyprland see it.
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.socket";

  systemd.user.services = {
    rclone-vault-sync = {
      Unit = {
        Description = "Sync KeePassXC vault to Google Drive (rclone bisync)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
        ConditionPathIsDirectory = "%h/vault";
        OnFailure = [ "notify-vault-sync-failure@%n.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${vaultSync}/bin/rclone-vault-sync";
      };
    };

    "notify-vault-sync-failure@" = {
      Unit.Description = "Desktop notification when %i fails";
      Service = {
        Type = "oneshot";
        ExecStart = "${notifyFailure}/bin/notify-vault-sync-failure %I";
      };
    };
  };

  systemd.user.paths.rclone-vault-sync = {
    Unit.Description = "Sync vault when Passwords.kdbx changes";
    Path.PathChanged = "%h/vault/Passwords.kdbx";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.rclone-vault-sync = {
    Unit.Description = "Periodic KeePassXC vault sync to Google Drive";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
