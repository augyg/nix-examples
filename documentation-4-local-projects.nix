# This is a nix derivation which builds all of my local packages so that I can
# search them at https://localhost:8080


{ pkgs ? import <nixpkgs> {} }:
# TODO: use nixpkgs from Ace

let
  #todo: builtins.readJSON
  ntconfig = {
    owner = "obsidiansystems";
    repo = "nix-thunk";
    rev = "8fe6f2de2579ea3f17df2127f6b9f49db1be189f";
    sha256 = "14l2k6wipam33696v3dr3chysxhqcy0j7hxfr10c0bxd1pxv7s8b";
  };
  nix-thunk = import (pkgs.fetchFromGitHub ntconfig) {};

  callMyHaskellDep = filepath: pkgs.haskellPackages.callPackage (nix-thunk.thunkSource filepath) {};
  #scrappy = callMyHaskellDep ./deps/scrappy;
  lazy-js = callMyHaskellDep ./deps/lazy-js;
  matplotlib-haskell = callMyHaskellDep ./deps/matplotlib-haskell;
  wikiScraper = callMyHaskellDep ./deps/wikiScraper;
  Haskell-Music = callMyHaskellDep ./deps/Haskell-Music;
  bashScripting = callMyHaskellDep ./deps/bashScripting;

  # TODO : fix webdriver issues
  #  freeScrape = callMyHaskellDep ./deps/freeScrape;
  #  AuthdScraper = callMyHaskellDep ./deps/AuthdScraper;
in
pkgs.stdenv.mkDerivation {
  name = "my-hoogle-server";
  buildInputs = [
    (pkgs.haskellPackages.ghcWithHoogle (hpkgs: with hpkgs; [
      #scrappy
      lazy-js
      matplotlib-haskell
      wikiScraper
      Haskell-Music
      bashScripting
      #freeScrape
      #AuthdScraper
    ]))
  ];
  shellHook = "hoogle server -p 8080 --local"; # starts server at 8080
}
