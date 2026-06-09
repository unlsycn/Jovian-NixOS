{
  lib,
  fetchFromGitHub,
  buildLinux,
  ...
}:
{ ... }@args:

let
  inherit (lib) versions;

  kernelVersion = "6.18.33";
  vendorVersion = "valve1";
  hash = "sha256-MkYCrIsOcuwnCaqrvwaRCN7LBW/mHOotEzl37zhSlzk=";

  structuredConfig = import ./structured-config.nix { inherit lib; };
  shouldCheckConfig =
    name: value: name != "CC_CAN_LINK" && !(builtins.hasAttr "freeform" value && value.freeform == "");
  checkedStructuredConfig = lib.filterAttrs shouldCheckConfig structuredConfig;
in
(buildLinux (
  args
  // rec {
    version = "${kernelVersion}-${vendorVersion}";

    # branchVersion needs to be x.y
    extraMeta.branch = versions.majorMinor version;

    defconfig = "defconfig";
    enableCommonConfig = false;
    autoModules = false;
    ignoreConfigErrors = false;
    structuredExtraConfig = checkedStructuredConfig;

    src = fetchFromGitHub {
      owner = "Jovian-Experiments";
      repo = "linux";
      rev = version;
      inherit hash;

      # Sometimes the vendor doesn't update the EXTRAVERSION tag.
      # Let's fix it up in post.
      # ¯\_(ツ)_/¯
      # Also, `postPatch` on the kernel doesn't compose in `buildLinux`.
      # ¯\_(ツ)_/¯
      postFetch = ''
        (
        echo ":: Fixing-up EXTRAVERSION with actual tag"
        cd $out
        sed -i -e 's/^EXTRAVERSION =.*/EXTRAVERSION = -${vendorVersion}/g' Makefile
        )
      '';
    };
  }
  // (args.argsOverride or { })
)).overrideAttrs
  (old: {
    # https://github.com/NixOS/nixpkgs/issues/216529
    # overrided passthru will be ignored by boot.kernelPackages
    # hence we just override features
    features = {
      efiBootStub = true;
      ia32Emulation = true;
      netfilterRPFilter = false;
    };
  })
