# Overrides MSI's broken DPTF ACPI table (SSDT1) at boot so the GPU can leave its 60 W base
# limit. The bug and the exact change are described at the top of ../acpi/dptf-ssdt1.dsl.
#
# The table comes from BIOS E15M1IMS.915. After a BIOS update, re-dump the tables and check
# `journalctl -k -b | grep DBA8` before keeping this: an old table must not replace a new one.

{ pkgs, ... }:

let
  dptfOverride = pkgs.runCommand "acpi-override-dptf.cpio" {
    nativeBuildInputs = [
      pkgs.acpica-tools
      pkgs.cpio
    ];
  } ''
    mkdir -p kernel/firmware/acpi
    iasl -p kernel/firmware/acpi/ssdt-dptf ${../acpi/dptf-ssdt1.dsl}
    test -s kernel/firmware/acpi/ssdt-dptf.aml
    # The kernel only reads ACPI overrides from an uncompressed early cpio archive.
    find kernel | sort | cpio -o -H newc --quiet > $out
  '';
in
{
  boot.initrd.prepend = [ "${dptfOverride}" ];
}
