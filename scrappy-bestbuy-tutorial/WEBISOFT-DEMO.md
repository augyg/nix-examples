

Steps to check this nix drv is working:

1) Install nix https://nixos.org/download/
2) Run the following:
```sh
cd <this-directory>
nix-shell # create environment with all dependencies for cabal (haskell's cargo)
cabal repl # enter repl
InCabalRepl> import Scrappy.Find  # test importing a dependency that was added by nix
```
