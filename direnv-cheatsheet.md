# direnv cheatsheet

direnv loads a project's environment when you `cd` into it and unloads it
when you leave. It's enabled in every boot entry (see `home/shell.nix`), hooked
into zsh, with nix-direnv caching the environment so re-entering is instant.

## Set up a project

1. Add a `flake.nix` with a dev shell listing the tools the project needs:

   ```nix
   {
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

     outputs =
       { nixpkgs, ... }:
       let
         pkgs = nixpkgs.legacyPackages.x86_64-linux;
       in
       {
         devShells.x86_64-linux.default = pkgs.mkShell {
           packages = with pkgs; [
             dotnet-sdk_10
             nodejs
           ];
           # Plain environment variables work too.
           DOTNET_CLI_TELEMETRY_OPTOUT = "1";
         };
       };
   }
   ```

2. Tell direnv to use it, then approve the file:

   ```sh
   echo "use flake" > .envrc
   direnv allow
   ```

3. Commit `flake.nix`, `flake.lock` and `.envrc`. Add `.direnv/` to `.gitignore`
   (that's the local cache).

**In a git repo, the flake only sees tracked files.** `git add flake.nix`
before the first `direnv allow`, or you get "path does not exist" errors.

No flake? A `shell.nix` with `use nix` in `.envrc` works the same way.

## Commands

| Command            | What it does                                                 |
|--------------------|--------------------------------------------------------------|
| `direnv allow`     | Approve `.envrc` (needed again after every edit to it)       |
| `direnv deny`      | Revoke approval; the environment stops loading               |
| `direnv reload`    | Re-evaluate now (e.g. after changing `flake.nix`)            |
| `direnv status`    | Show which `.envrc` is loaded and whether it's allowed       |
| `nix flake update` | Update the project's pinned nixpkgs (then `direnv reload`)   |

nix-direnv re-evaluates automatically when `flake.nix` or `flake.lock` change,
so `direnv reload` is only for forcing it.

## Rules of thumb

- **Nothing to install globally.** Put project tools in the dev shell, not in
  the system config, so each project pins its own versions.
- **`direnv allow` is a security prompt.** An `.envrc` runs code, so read it
  before allowing one from a repo you just cloned.
- **Keep mise where it already works.** Mise handles work repos that already
  use `mise.toml`; use direnv + flakes for new or personal projects where you
  want the whole toolchain pinned by Nix. Don't use both in the same project.
- **Slow first entry is normal.** The first `cd` builds or downloads the shell;
  after that nix-direnv serves it from cache.
