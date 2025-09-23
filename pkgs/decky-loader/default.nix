{ lib
, fetchFromGitHub
, nodejs
, pnpm_9
, fetchPnpmDeps
, pnpmConfigHook
, python3
, coreutils
, psmisc
}:
python3.pkgs.buildPythonPackage rec {
  pname = "decky-loader";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-QC1vmosEY+gQGMskA+y3yz3zpHJjXNjoYk3TA93ffJw=";
  };
  
  patches = [ ./respect-path.patch ];

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-rjou5KDHlF0MWAMzIKjc9UiIKk8t626SOM1Nw7WQzy4=";
  };

  pyproject = true;

  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
    pnpm_9
    pnpmConfigHook
  ];

  preBuild = ''
    cd frontend
    pnpm build
    cd ../backend
  '';

  build-system = with python3.pkgs; [ 
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [
    aiohttp
    aiohttp-cors
    aiohttp-jinja2
    certifi
    multidict
    packaging
    setproctitle
    watchdog
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ coreutils psmisc ]}"
  ];

  pythonRelaxDeps = [
    "aiohttp-cors"
    "packaging"
    "watchdog"
  ];

  passthru.python = python3;

  meta = with lib; {
    description = "A plugin loader for the Steam Deck";
    homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
    platforms = platforms.linux;
    license = licenses.gpl2Only;
  };
}
