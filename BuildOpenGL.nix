# This describes how to build the OpenGL haskell library

# The reason I added is mainly "executableSystemDepends"
# However I forget if this works perfectly or if there is more
# I needed to add in "executableSystemDepends"


{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, gl, GLFW-b, lib, glfw, glui, OpenGLRaw }:
      mkDerivation {
        pname = "example";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base gl glfw ];
        executableSystemDepends = [ glfw
                                    pkgs.xorg.libX11
                                    pkgs.xorg.libXi
                                    pkgs.xorg.libXinerama
                                    pkgs.xorg.libXcursor
                                    pkgs.xorg.libXxf86vm
                                    pkgs.xorg.libXrandr
                                    pkgs.libGLU
                                  ];
        license = lib.licenses.mit;
        mainProgram = "example";
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
