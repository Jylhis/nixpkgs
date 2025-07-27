{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python,
  pkg-config,
  libxml2,
  glib,
  openssl,
  zchunk,
  curl,
  check,
  gpgme,
  libselinux,
  nix-update-script,
  doxygen,
  sphinx,
  selinuxSupport ? false,
}:

stdenv.mkDerivation rec {
  version = "1.19.0";
  pname = "librepo";

  outputs = [
    "out"
    "dev"
    "py"
    "doc"
  ];

  src = fetchFromGitHub {
    owner = "rpm-software-management";
    repo = "librepo";
    rev = version;
    sha256 = "sha256-ws57vFoK5yBMHHNQ9W48Icp4am0/5k3n4ybem1aAzVM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
    sphinx
  ];

  separateDebugInfo = true;

  cmakeBuildType = "RelWithDebInfo";
  buildInputs = [
    python
    libxml2
    glib
    openssl
    curl
    check
    gpgme
    zchunk
  ] ++ lib.optionals selinuxSupport [libselinux];

  # librepo/fastestmirror.h includes curl/curl.h, and pkg-config specfile refers to others in here
  propagatedBuildInputs = [
    curl
    gpgme
    libxml2
  ];

  cmakeFlags = [
    "-DPYTHON_DESIRED=${lib.substring 0 1 python.pythonVersion}"
    (lib.cmakeBool "ENABLE_SELINUX" selinuxSupport)
  ];

  postFixup = ''
    moveToOutput "lib/${python.libPrefix}" "$py"
    mkdir -p "$dev/share/cmake/${pname}"
    cp "../utils/FindLibrepo.cmake" "$dev/share/cmake/${pname}"
  '';

  postBuild =''
    make doc
    mkdir -p $doc/share/doc/${pname}/html
    cp -r doc/c/html $doc/share/doc/${pname}/html/c
    cp -r doc/python $doc/share/doc/${pname}/html/python
    rm $doc/share/doc/${pname}/html/python/*.cmake
    rm -r $doc/share/doc/${pname}/html/python/CMakeFiles
    rm $doc/share/doc/${pname}/html/python/Makefile
    '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Library providing C and Python (libcURL like) API for downloading linux repository metadata and packages";
    homepage = "https://rpm-software-management.github.io/librepo/";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ copumpkin ];
  };
}
