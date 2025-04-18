{
  callPackage,
  lib,
  stdenv,
  fetchurl,
  nixos,
  testers,
  versionCheckHook,
  hello,
  fetchFromGitLab,
  python3,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "LazyLibrarian";
  version = "2025.04.10";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "LazyLibrarian";
    repo = "LazyLibrarian";
    rev = "3d7fc588b4c04740ccdab9e3517ae2f16595b57a";
    hash = "sha256-yvBAOdCRb4YoIgyV0wD59OnQPf9IqrtyxnVpolkjtI8=";
  };

  build-system = with python3Packages; [
    ez-setup
    setuptools
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    # html5lib
    # webencodings
    # requests
    # urllib3
    # pyopenssl
    # cherrypy
    # cherrypy-cors
    apprise
    apscheduler

    cherrypy
    cherrypy-cors
    deluge-client
    html5lib
    httpagentparser
    httplib2
    irc
    mako
    pillow
    pyopenssl
    pyparsing
    pypdf
    python-magic
    rapidfuzz
    requests
    tzdata
    urllib3
    webencodings
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
    pytest-cov
    mock
    pytest-order
    pytestCheckHook
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "bs4" "beautifulsoup4"
  '';

  pytestFlagsArray = [
    "unittests"
  ];

  disabledTests = [
    "test_gb_call"
    "test_fetch_url_with_mock"
    "test_onchange"
    "test_post_save_actions"
    "test_schedule_list"
    "test_tables_list"
    "test_version_and_integrity"
    "test_crawl_image"
    "test_record_usage_data"
    "test_set_config_data"
    "test_construct_data_string"
    "test_get_book_cover"
    "FormatterTest"
    "ImporterTest"
    "SchedulingTest"
  ];

  disabledTestPaths = [
    "unittests/test_icrawler.py"
  ];

  meta = {
    description = "LazyLibrarian is a SickBeard, CouchPotato, Headphones-like application for ebooks, audiobooks and magazines";
    homepage = "https://gitlab.com/LazyLibrarian/LazyLibrarian";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    #mainProgram = "lazy-librarian";
    # description = "Program that produces a familiar, friendly greeting";
    # longDescription = ''
    #   GNU Hello is a program that prints "Hello, world!" when you run it.
    #   It is fully customizable.
    # '';
    # homepage = "https://www.gnu.org/software/hello/manual/";

    # license = lib.licenses.gpl3Plus;
    # maintainers = with lib.maintainers; [ stv0g ];
    # mainProgram = "hello";
    # platforms = lib.platforms.all;
  };
}
