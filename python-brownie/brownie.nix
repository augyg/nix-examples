# Using standard buildPythonApplication to create a derivation which we can add to our python package set


{ lib
, charset-normalizer
, multidict
, aiohttp
, pytest
, buildPythonApplication
, fetchFromGitHub
, pythonOlder
, pythonRelaxDepsHook
, pkgs
}:

buildPythonApplication rec {
  pname = "eth-brownie";
  version = "1.19.1";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "eth-brownie";
    repo = "brownie";
    rev = "d009fad8c845cd19972a0bec5d9cf446db880cd9";
    sha256 = "14c4mgkb7an9lwxsmqh2ppmmpb0hjzzjnybfn0sgyr05bj5n1mca";
  };

  propagatedBuildInputs = [
    charset-normalizer
    multidict
    aiohttp
    # Ensure ganache, a JavaScript package is available to this build
    pkgs.nodePackages.ganache
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    pytest
  ];
}
