{
  rustPlatform,
  fetchFromGitHub,
  lm_sensors,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vpower";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "vpower";
    tag = finalAttrs.version;
    hash = "sha256-68rtpV/8w/6MvsI4FpXjky0TZqvrxAI3lrPPglufglk=";
  };

  postPatch = ''
    substituteInPlace vpower.service \
      --replace-fail /usr/lib/vpower $out/bin/vpower
  '';

  cargoHash = "sha256-OWR1n12KvD+h1HKng/3ghdolOTvjwb+qszuokawYpSg=";

  buildInputs = [
    lm_sensors
  ];

  postInstall = ''
    install -Dm644 vpower.service "$out/lib/systemd/system/vpower.service"
  '';
})
