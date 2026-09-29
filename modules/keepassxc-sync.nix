# System side of the KeePassXC setup. The packages, SSH agent, and vault
# sync units live in home/vault-sync.nix.
{
  services.gnome.gnome-keyring.enable = true;
  # KeePassXC uses the Home Manager ssh-agent instead.
  services.gnome.gcr-ssh-agent.enable = false;
  security.pam.services.greetd.enableGnomeKeyring = true;

  home-manager.users.pedrocoutinho.imports = [ ../home/vault-sync.nix ];
}
