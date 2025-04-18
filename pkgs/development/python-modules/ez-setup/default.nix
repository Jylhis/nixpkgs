{
  lib,
  fetchPypi,
  buildPythonPackage,
  python3,
  python3Packages,
}:
buildPythonPackage rec {

  pname = "ez-setup";
  version = "0.9";
  pyproject = true;

  src = fetchPypi {
    pname = "ez_setup";
    inherit version;
    sha256 = "303c5b17d552d1e3fb0505d80549f8579f557e13d8dc90e5ecef3c07d7f58642";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3Packages; [
    distutils
  ];
  pythonImportsCheck = [
    "ez_setup"
  ];

  # meta = {
  #   homepage = "https://github.com/ActiveState/ez_setup";
  #   license = lib.licenses.psfl;
  #   description = "Yet another Python setup tool.";
  #   # maintainers = with maintainers; [ BadDecisionsAlex ];
  # };
  meta = {
    description = "Ez_setup.py and distribute_setup.py";
    homepage = "https://pypi.org/project/ez_setup/";
    license = lib.licenses.mit;
    #  maintainers = with lib.maintainers; [ ];
    mainProgram = "ez-setup";
  };

}
