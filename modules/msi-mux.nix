# MSI MUX: Qt tray app for switching the GPU MUX (Hybrid/Discrete/Integrated).
# Upstream installs to fixed /usr paths and only enables the MS-15M3; this
# patches both for NixOS and this laptop's MS-15M1.

{ inputs, pkgs, ... }:

let
  # Refresh after a BIOS update (fwupd), or switching is disabled again.
  model = "Vector 16 HX A14VHG";
  board = "MS-15M1";
  bios = "E15M1IMS.915";

  msi-mux = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "msi-mux";
    version = "0.5.0";
    src = inputs.msi-mux;

    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = "${finalAttrs.src}/Cargo.lock";
    };

    nativeBuildInputs = with pkgs; [
      cmake
      ninja
      cargo
      rustc
      rustPlatform.cargoSetupHook
      python3
      qt6.wrapQtAppsHook
    ];
    buildInputs = with pkgs.qt6; [
      qtbase
      qtsvg
    ];

    cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

    postPatch = ''
      grep -rlZ -e 'Vector 16 HX AI A2XWIG' -e 'MS-15M3' -e 'E15M3IMS.116' src gui \
        | xargs -0 sed -i \
            -e 's/Vector 16 HX AI A2XWIG/${model}/g' \
            -e 's/MS-15M3/${board}/g' \
            -e 's/E15M3IMS\.116/${bios}/g'

      # The /usr-only prefix guard; paths are pinned to the store below instead.
      sed -i '/NOT CMAKE_INSTALL_PREFIX STREQUAL "\/usr"/,/^endif()/d' CMakeLists.txt

      substituteInPlace gui/backend.cpp \
        --replace-fail /usr/bin/pkexec /run/wrappers/bin/pkexec \
        --replace-fail /usr/lib/msi-mux/msi-mux-helper $out/lib/msi-mux/msi-mux-helper
      substituteInPlace gui/backend.h \
        --replace-fail /usr/bin/msi-mux-switch $out/bin/msi-mux-switch
      substituteInPlace packaging/org.hayatboj.msimux.policy \
        --replace-fail /usr/lib/msi-mux/msi-mux-helper $out/lib/msi-mux/msi-mux-helper
      substituteInPlace packaging/org.hayatboj.msimux.desktop \
        --replace-fail /usr/bin/msi-mux-tray $out/bin/msi-mux-tray
      # Autostart entries outlive a generation, so use the stable profile path.
      # The ••• menu button's padding and arrow leave no room for its text.
      substituteInPlace gui/window.cpp \
        --replace-fail /usr/bin/msi-mux-tray /run/current-system/sw/bin/msi-mux-tray \
        --replace-fail 'm_preferencesButton->setFixedSize(44, 36);' \
          'm_preferencesButton->setFixedSize(44, 36); m_preferencesButton->setStyleSheet(QStringLiteral("QToolButton { padding:0; } QToolButton::menu-indicator { image:none; width:0; }"));'

      # /nix/store itself is group-writable (nixbld), so trust the output's own
      # directories instead. auto-optimise-store hard-links every store file,
      # so the single-link check can never pass.
      substituteInPlace packaging/helper.cpp \
        --replace-fail /usr/bin/msi-mux-switch $out/bin/msi-mux-switch \
        --replace-fail '{"/", "/usr", "/usr/bin"}' '{"/", "/nix", "'$out'", "'$out'/bin"}' \
        --replace-fail ' && st.st_nlink == 1' "" \
        --replace-fail 'PATH=/usr/sbin:/usr/bin:/sbin:/bin' 'PATH=/run/current-system/sw/bin'
    '';

    # Only the tray is a Qt app; the backend runs as root through the helper
    # and must stay a plain binary.
    dontWrapQtApps = true;
    postFixup = ''
      wrapQtApp $out/bin/msi-mux-tray
    '';

    meta.mainProgram = "msi-mux-tray";
  });
in
{
  # Also provides the polkit action (share/polkit-1/actions).
  environment.systemPackages = [ msi-mux ];
}
