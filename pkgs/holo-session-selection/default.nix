{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "holo-session-selection";
  version = "1.0-1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "PKGBUILDs-mirror";
    rev = "holo-main/holo-session-selection-${finalAttrs.version}";
    hash = "sha256-7ENfj+28936u9eqBQxc66FLUG8Wsc4VXd+k5TEEyg1s=";
  };

  # SDDM config set via NixOS module instead
  installPhase = ''
    runHook preInstall

    install -D -m755 holo-session-select $out/bin/holo-session-select

    runHook postInstall
  '';
})
