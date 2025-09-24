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
      enableInputPlumberWorkarounds = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.ally-z1e.enable";
        description = ''
          Whether to add some workarounds for https://github.com/ShadowBlip/InputPlumber/issues/241.
        '';
        # Don't expose to users.
        internal = true;
        readOnly = true;
      };
    };
  };
  config = mkIf (cfg.enableInputPlumberWorkarounds) {
    systemd.services.restart-inputplumber-after-resume = {
      description = "Restart InputPlumber after resume";
      after = ["sleep.target"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "systemctl restart inputplumber.service";
        User = "root";
      };

      wantedBy = ["sleep.target"];
    };
  };
}
