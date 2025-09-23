{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.ally-z1e;
in
{
  options = {
    jovian.devices.ally-z1e = {
      enablePerfControlUdevRules = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.ally-z1e.enable";
        description = ''
          Whether to make performance-related device attributes controllable by users.

          The Steam Deck Client directly modifies several device attributes to
          control the display brightness and to enable performance tuning (TDP
          limit, GPU clock control).
        '';
      };
    };
  };
  config = mkIf (cfg.enablePerfControlUdevRules) {
    services.udev.extraRules = ''
      # Enables manual GPU clock control in Steam
      # - /sys/class/drm/card0/device/power_dpm_force_performance_level
      # - /sys/class/drm/card0/device/pp_od_clk_voltage
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"

      # https://github.com/ublue-os/bazzite/blob/f5f033424281f88f0a132ec0561a5a5f002faf24/system_files/deck/shared/usr/lib/udev/rules.d/50-ally-fingerprint.rules
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{idVendor}=="1c7a", ATTR{idProduct}=="0588", ATTR{power/control}="auto"
    '';
  };
}
