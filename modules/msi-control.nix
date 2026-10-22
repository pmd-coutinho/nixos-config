# msi-control: daemon + CLI + GTK GUI for msi-ec, the GPU MUX and power profiles.
# Runs alongside ./msi-mux.nix until its native MUX switching is proven on this laptop.

{ inputs, ... }:

{
  imports = [ inputs.msi-control.nixosModules.default ];

  services.msi-control.enable = true;

  # Same EC shift modes as the tuned profiles in noctalia.nix, so the two writers agree:
  # no turbo, and performance stays on comfort with EPP doing the work. Fan mode stays auto.
  # EC -> profile sync stays off (ec_to_ppd) because performance and balanced share a shift mode.
  environment.etc."msi-control/config.toml".text = ''
    sync = true
    ec_to_ppd = false

    [profiles.power-saver]
    shift_mode = "eco"
    fan_mode = "auto"

    [profiles.balanced]
    shift_mode = "comfort"
    fan_mode = "auto"

    [profiles.performance]
    shift_mode = "comfort"
    fan_mode = "auto"

    # Matches tuned's msi-balanced-battery: balanced on battery runs eco.
    [battery_profiles.balanced]
    shift_mode = "eco"
    fan_mode = "auto"
  '';
}
