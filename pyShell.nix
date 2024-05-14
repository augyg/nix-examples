# Builds a python interpreter in an environment where Selenium artifacts are available via PATH
{ pkgs ? import <nixpkgs> {} }:
let
  python-with-my-packages = pkgs.python3.withPackages (p: with p; [
    pandas
    requests
    numpy
    imutils
    tensorflow
    dlib
    matplotlib
    selenium
    xlrd
    shutilwhich
    # other python packages you want
  ]);
in
pkgs.mkShell {
  packages = [
    pkgs.geckodriver
    pkgs.chromedriver
    pkgs.google-chrome
  ];

  inputsFrom = [ python-with-my-packages.env ];
  # When derivations have sucessfully built, run:
  shellHook = ''
    export PATH=$PATH:${pkgs.chromedriver}/bin
  '';

}
