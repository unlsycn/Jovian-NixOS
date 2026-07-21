{
  inputplumber',
  fetchFromGitHub,
  rustPlatform,
}:
inputplumber'.overrideAttrs rec {
  version = "0.77.7";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "InputPlumber";
    tag = "v${version}";
    hash = "sha256-LECHrL+yopymcdpuEZUFvNX1QI30Z+mOtMYP7fnMpBM=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-1g4nHBu9LUMMr0bPkD4LCEFyyIc+GdhIWu+hlyGH3IM=";
  };
}
