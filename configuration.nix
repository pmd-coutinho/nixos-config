# Gaming lives on CachyOS on the T-Force NVMe; Limine chainloads it
# (modules/core.nix).
{
  imports = [
    ./modules/core.nix
    ./modules/work.nix
  ];
}
