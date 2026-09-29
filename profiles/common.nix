{ pkgs, ... }:

{
  # Shared by the gaming and work specialisations (not the base entry).
  imports = [ ./keepassxc-sync.nix ];

  environment.systemPackages = with pkgs; [
    ayugram-desktop
    nodejs
  ];
}
