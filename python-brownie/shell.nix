## This package is callable by nix-shell shell.nix

# shell.nix
{ hostPkgs ? import <nixpkgs> {} }:
let
  # In this next comment block, I use whatever nixpkgs my system has
  # and get the nixpkgs at commit hash (rev = "e0761655d8682b02a52fee01958cfe2873438d42";)
  # to ensure builds will always be the exact same regardless of who's building it
  ###############################################
  pkgsSrc = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e0761655d8682b02a52fee01958cfe2873438d42";
    sha256 = "1wc0ml0hc903l95zg2lnqcs99j019qha8zb1j7g8ybifg3g68a1b";
  };
  pkgs = import pkgsSrc {};
  ###############################################
  python-with-my-packages = pkgs.python3.withPackages (p: with p; [
    (callPackage ./brownie.nix {})
  ]);
  pipx = pkgs.python39Packages.pipx;
in
#python-with-my-packages
pkgs.mkShell {
   buildInputs = [ pkgs.nodePackages.ganache pkgs.solc ];
   inputsFrom = [ python-with-my-packages.env ];

   # Once depenendencies have all been installed, this command will be run
   shellHook = ''
      ${pipx}/bin/pipx install eth-brownie
      alias brownie=~/.local/bin/brownie
   '';
}
