This is a collection of nix derivations I have created.

Each comment is peppered with helpful comments to understand why I wrote the file as well as certain components

To avoid overload and certain security concerns, I have removed the actual source code that the nix expressions build however pyShell.nix and scrappy-bestbuy-tutorial 
have all the pieces necessary to run the expression

- ace-default.nix: describes how to build my full-stack haskell application @ aceinterviewprep.app
- static-default.nix: describes how to build the static assets for Ace, which is called by ace-default.nix
- scrappy-bestbuy-tutorial/: Tutorial for my library, scrappy, which can be built and used via the commands in WEBISOFT-DEMO.md
- BuildOpenGL.nix: build the OpenGL haskell library which requires a number of system dependencies
- digital-ocean-OS.nix: This is a NixOS module file, which means it describes how to build NixOS server for Digital Ocean
- my-nixos-system-configuration.nix: Describes how to build my NixOS System from networking to hardware config to available packages like emacs, zoom, slack, etc.
- pyShell.nix: create a `python3` with access to selenium and drivers so that I can run webscraping scripts
- python-brownie: Describe how to build brownie as a nix-python package that would be callable by nix files like pyShell.nix
