{ mkDerivation, base, http-client, http-client-tls, lib, parsec
, text, nodejs, fetchFromGitHub, pkgs, callCabal2nix, csv, async
}:
let
  nix-thunk = fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "nix-thunk";
    rev = "8fe6f2de2579ea3f17df2127f6b9f49db1be189f";
    sha256 = "14l2k6wipam33696v3dr3chysxhqcy0j7hxfr10c0bxd1pxv7s8b";
  };
  n = import nix-thunk {};
  scrappySrc = n.thunkSource ./deps/scrappy; 
  scrappy = pkgs.haskell.lib.overrideCabal (callCabal2nix "scrappy" scrappySrc {}) {
    librarySystemDepends = [ nodejs ];
  };

  rhyolite = import ./deps/rhyolite/default.nix;
  rhyolite' = fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "rhyolite";
    private = false;
    rev =  "c5936cb87cb934a02276201b0320facb0c4d8563";
    sha256 = "0hk1hk99frynhb0in5q85qq5g4mvijpqqnn4x2pbvgpg0kds92yc"; # "119wqi7asqhx5qy7j54973x1a9frbxbrbkbw415ak5asii903gf6";

  };
  rhyolite'' = import rhyolite'; 
  rhyolite-package-set = ((rhyolite'' {}).rhyolitePackages pkgs.haskellPackages);
  rhyolite-packages = pkgs.lib.mapAttrsToList (attr: val: val) rhyolite-package-set;
    
in 
mkDerivation {
  pname = "scrappy-tutorial";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base http-client http-client-tls parsec scrappy text csv 
  ] ;
  license = lib.licenses.bsd3;
}
