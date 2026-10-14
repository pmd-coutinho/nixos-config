# Gaming lives on Windows (its own boot entry, see modules/core.nix).
{
  imports = [
    ./modules/core.nix
    ./profiles/work.nix
  ];
}
