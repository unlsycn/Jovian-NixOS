{ lib, fetchFromGitHub, linuxManualConfig, ... }:
{ ... } @args:


let
  inherit (lib) versions;

  kernelVersion = "6.16.12";
  vendorVersion = "valve7";
  hash = "sha256-x9moiht4YqVpg+048ol6NXW08OogUjAGAC8a6pd9Y3U=";
in
(linuxManualConfig
  (args // rec {
    version = "${kernelVersion}-${vendorVersion}";

    # branchVersion needs to be x.y
    extraMeta.branch = versions.majorMinor version;

    configfile = ./ally-z1e-config;
    allowImportFromDerivation = true;

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
  } // (args.argsOverride or { }))).overrideAttrs (old: {
  # https://github.com/NixOS/nixpkgs/issues/216529
  # overrided passthru will be ignored by boot.kernelPackages
  # hence we just override features
  features = {
    efiBootStub = true;
    ia32Emulation = true;
    netfilterRPFilter = false;
  };
})
