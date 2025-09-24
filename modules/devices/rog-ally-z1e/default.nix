# ROG Ally Z1E-specific configurations
#
# jovian.devices.ally-z1e

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.ally-z1e;
in
{
  imports = [
    # ./controller.nix
    # ./fan-control.nix
    # ./firmware.nix
    # ./graphical.nix
    # ./hw-support.nix
    ./kernel.nix
    ./perf-control.nix
    # ./sdgyrodsu.nix
    # ./sound.nix
    ./workarounds.nix
  ];

  options = {
    jovian.devices.ally-z1e = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable ROG Ally Z1E-specific configurations.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    jovian.hardware.has = {
      amd.gpu = true;
    };
  };
}
