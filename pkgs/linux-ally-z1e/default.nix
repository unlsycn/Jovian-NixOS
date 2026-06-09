{
  lib,
  fetchFromGitHub,
  buildLinux,
  writeText,
  ...
}:
{ ... }@args:

let
  inherit (lib) versions;

  kernelVersion = "6.18.33";
  vendorVersion = "valve1";
  hash = "sha256-MkYCrIsOcuwnCaqrvwaRCN7LBW/mHOotEzl37zhSlzk=";

  structuredConfig = import ./structured-config.nix { inherit lib; };
  isDigit =
    char:
    lib.elem char [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    ];
  isNumeric = value: value != "" && lib.all isDigit (lib.stringToCharacters value);
  renderFreeformSeed =
    value: if isNumeric value || lib.hasPrefix "0x" value then value else builtins.toJSON value;
  renderValue =
    value:
    if builtins.hasAttr "freeform" value then
      renderFreeformSeed value.freeform
    else if value.tristate == "y" then
      "y"
    else if value.tristate == "m" then
      "m"
    else if value.tristate == "n" then
      "n"
    else
      null;
  shouldCheckConfig =
    name: value: name != "CC_CAN_LINK" && !(builtins.hasAttr "freeform" value && value.freeform == "");
  checkedStructuredConfig = lib.filterAttrs shouldCheckConfig structuredConfig;
  renderConfigLine =
    name: value:
    let
      renderedValue = renderValue value;
    in
    if renderedValue == null then
      ""
    else if renderedValue == "n" then
      "# CONFIG_${name} is not set\n"
    else
      "CONFIG_${name}=${renderedValue}\n";
  configSeed = writeText "ally-z1e-config-seed" (
    lib.concatStrings (lib.mapAttrsToList renderConfigLine structuredConfig)
  );
in
(buildLinux (
  args
  // rec {
    version = "${kernelVersion}-${vendorVersion}";

    # branchVersion needs to be x.y
    extraMeta.branch = versions.majorMinor version;

    defconfig = "KCONFIG_ALLCONFIG=${configSeed} allnoconfig";
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
