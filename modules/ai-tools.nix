# AI tools shared by the work and gaming profiles: ChatGPT desktop, Codex,
# and OpenCode (CLI + desktop).
{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  chatgptDesktop =
    inputs.chatgpt-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        # The upstream "auto" hint still selects X11 under Hyprland. Force
        # native Wayland so fractional scaling remains sharp.
        postFixup =
          builtins.replaceStrings [ "--ozone-platform-hint=auto" ] [ "--ozone-platform=wayland" ]
            old.postFixup;
      });

  # OpenCode v2 isn't in nixpkgs yet, so build it from upstream's v2 branch.
  opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};

  opencode = opencodePkgs.opencode.overrideAttrs (old: {
    # Upstream generates shell completions by running the new binary, which
    # currently crashes. Skip them until that's fixed.
    postInstall = "";
    # Upstream builds the CLI as channel "prod", which registers the background
    # service in service-prod.json. The desktop client only looks for
    # service.json and spins on "loading" forever. Official releases use "latest".
    env = old.env // {
      OPENCODE_CHANNEL = "latest";
    };
  });

  # Upstream's nix/electron.nix still carries the Electron 42.10.1 checksums
  # while the desktop app pins 44.4.5, so build that version ourselves.
  opencodeElectron =
    (pkgs.callPackage (pkgs.path + "/pkgs/development/tools/electron/binary/generic.nix") { }) "44.4.5"
      {
        x86_64-linux = "04586a0ec46c3283fbdaef85530f561f71f0b5e136ad0cb9ef63683615609780";
        headers = "sha256-QPkX+99kArlQhhbgOZe+Hsk28G5cadkUy0G0cIDtEh8=";
      };

  opencodeDesktop =
    (opencodePkgs.opencode-desktop.override {
      inherit opencode;
      callPackage =
        fn: args: if baseNameOf fn == "electron.nix" then opencodeElectron else pkgs.callPackage fn args;
    }).overrideAttrs
      (old: {
        # The desktop inherits the CLI's env, but its own code expects "prod".
        env = old.env // {
          OPENCODE_CHANNEL = "prod";
        };
        # The desktop prebuild now reads the bundled CLI's version from a
        # package.json next to its binary, which upstream's derivation doesn't write.
        buildPhase =
          assert lib.hasInfix "\nbun run build\n" old.buildPhase;
          builtins.replaceStrings
            [ "\nbun run build\n" ]
            [
              ''

                echo '{"version":"${opencode.version}"}' > "$OPENCODE_CLI_DIST/$cli_package/package.json"
                bun run build
              ''
            ]
            old.buildPhase;
      });
in

{
  imports = [ inputs.chatgpt-desktop.nixosModules.default ];

  programs.chatgpt-desktop = {
    enable = true;
    package = chatgptDesktop;
    primaryRuntime.enable = true;
  };

  environment.systemPackages = [
    pkgs.codex
    opencode
    opencodeDesktop
  ];
}
