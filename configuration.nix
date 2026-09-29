# Work is the default boot entry. Gaming is a specialisation built from the
# same shared modules/core.nix, but it inherits nothing from work (no Docker,
# VPN, or work apps).
{
  imports = [
    ./modules/core.nix
    ./profiles/work.nix
  ];

  specialisation.gaming = {
    inheritParentConfig = false;
    configuration = {
      imports = [
        ./modules/core.nix
        ./profiles/gaming.nix
      ];
      # Lets `nh os switch` stay in gaming when booted into it; work, the
      # default entry, needs no marker.
      environment.etc."specialisation".text = "gaming";
    };
  };
}
