{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  cfg = config.jovian.devices.ally-z1e;
in
{
  options = {
    jovian.devices.ally-z1e = {
      enableKernelPatches = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.ally-z1e.enable";
        description = ''
          Whether to apply kernel patches if available.
        '';
      };
    };
  };
  config = mkIf (cfg.enableKernelPatches) (mkMerge [
    {
      boot.kernelPackages = mkDefault pkgs.linuxPackages_ally-z1e;
      # see https://github.com/Jovian-Experiments/steamos-customizations-jupiter/blob/jupiter-20241107.1/misc/modules-load.d/hid-preload.conf
      boot.kernelModules = ["hid_nintendo" "hid_playstation"];
      boot.kernelParams = ["amdgpu.gttsize=8128"];
    }
  ]);
}
