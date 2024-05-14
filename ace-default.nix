## Hello! ##
#
# This is the file that describes how to build my startup entirely
# even with a number of custom packages sourced from GitHub, including my own projects





{ system ? builtins.currentSystem
# detect if on MacOS or Linux flavor
# we can also set this manually when we build instead of having it autodetect
, obelisk ? import ./.obelisk/impl {
    inherit system;
    config = {
      # Allow use of highly unstable projects such as parseargs
      allowBroken = true;
    };

    # Enable ios and Android builds
    iosSdkVersion = "10.2";
    config.android_sdk.accept_license = true;

    # Enable LetsEncrypt on deployment
    terms.security.acme.acceptTerms = true;
  }
}:
with obelisk;
let
  # fold Nixpkg set overrides
  foldExtensions = lib.foldr lib.composeExtensions (_: _: {});
in
project ./. ({ pkgs, hackGet, ... }@args:
  let
    haskellLib = pkgs.haskell.lib;

    # I dont actually use this next function anymore but `nix-thunk` is a cool package
    # `callMyHaskellDep` does 2 things
    # 1. Turn empty thunk (pointer to github repo) into actual repo via thunkSource
    # 2. Activate the default.nix of that repo, which describes how to build that dependency
    # 3. Note that nix is lazily evaluated, and we can pass this dependency to wherever it is needed
    ntconfig = {
      owner = "obsidiansystems";
      repo = "nix-thunk";
      rev = "8fe6f2de2579ea3f17df2127f6b9f49db1be189f";
      sha256 = "14l2k6wipam33696v3dr3chysxhqcy0j7hxfr10c0bxd1pxv7s8b";
    };
    nix-thunk = import (pkgs.fetchFromGitHub ntconfig) {};
    callMyHaskellDep = filepath: pkgs.haskellPackages.callPackage (nix-thunk.thunkSource filepath) {};


    scrappySrc' = pkgs.fetchFromGitHub {
      owner = "Ace-Interview-Prep";
      repo = "scrappy";
      rev = "3387cc174c7f285ebe23cf8f8027977b59c316ac";
      sha256 = "VfmBuPv4ulxzB3Vfq1QHFQcWKonOAyvQkTq/MgcBBDo=";
    };
    vesselSrc = pkgs.fetchFromGitHub {
      owner = "obsidiansystems";
      repo = "vessel";
      rev = "c290833764f4054ee52047e3604c323493c1e5e8";
      sha256 = "sha256-UsLgsjhc2px9IRRr1N4seIYT6P8BmE3t0IHUgYnBepw=";
    };
    reflex-dom-echartsSrc = pkgs.fetchFromGitHub {
      owner = "augyg";
      repo = "reflex-dom-echarts";
      rev = "3652e0d375e9fd808c587c17ec0e85ca8fc5f889";
      sha256 = "sha256-F2mc3Tyt5Bb3GLKS3sQlKuoOhNDx5Q572+kE0uE2rXk=";
    };

    echarts-jsdomSrc = pkgs.fetchFromGitHub {
      owner = "augyg";
      repo = "echarts-jsdom";
      rev = "aaffb109ef01a449b36bb6d27be8111bb72ae0dc";
      sha256 = "sha256-RHzKD+LBs6DkNlGwd9Xnh8VIbygN6GCEnHmtezbgUHA=";
    };
    deps = pkgs.thunkSet ./dep;

  in with pkgs.haskell.lib; {
    android.applicationId = "systems.obsidian.obelisk.examples.minimal";
    android.displayName = "Ace Interview Prep";
    ios.bundleIdentifier = "systems.obsidian.obelisk.examples.minimal";
    ios.bundleName = "Ace Interview Prep";
    # Use a custom folder with it's own Nix Derivation for static assets
    # which will have a reference to the same set of pkgs we use for this derivation
    # in order to ensure everything builds properly
    staticFiles = import ./static { inherit pkgs; };

    # The following sets are from arbitrary github repos and are pinned to specific commit hashes
    # This set will be built specifically with the package-set that I determine; this is because it will use
    # the same package set that I create through overrides below
    packages = {
      obelisk-oauth-common = (hackGet ./dep/obelisk-oauth) + "/common";
      obelisk-oauth-backend = (hackGet ./dep/obelisk-oauth) + "/backend";
      stripe-haskell = (hackGet ./dep/stripe) + "/stripe-haskell";
      stripe-core = (hackGet ./dep/stripe) + "/stripe-core";
      stripe-http-client = (hackGet ./dep/stripe) + "/stripe-http-client";
      stripe-http-streams = (hackGet ./dep/stripe) + "/stripe-http-streams";
      stripe-tests = (hackGet ./dep/stripe) + "/stripe-tests";
  };
  # In Nix, we start with a base package set. Overrides allows us to add to or change the
  # package set. See #PATCH and BACKEND-FFMPEG for more
  overrides = pkgs.lib.composeExtensions
    (pkgs.callPackage (hackGet ./dep/rhyolite) args).haskellOverrides
    (self: super: with pkgs.haskell.lib; rec {
      # NOTE: Nix is very good at choosing package versions which work together well AND
      # assuming that we are using the same nixpkgs (which anyone who builds this project can guarantee)
      # then we will have the exact same package set / versions
      #
      # The reason why we do need the following, is because the above line:
      # >>> (pkgs.callPackage (hackGet ./dep/rhyolite) args).haskellOverrides
      # requires a number of specific package versions that conflict with specified
      # version bounds in the following packages


      # Ensure that our PostgreSQL Daemon manager is always built with the postgresql from our pkgs
      # note that this `pkgs` refers to the package set from reflex-platform
      # https://github.com/reflex-frp/reflex-platform
      gargoyle-postgresql-nix = haskellLib.overrideCabal super.gargoyle-postgresql-nix {
        librarySystemDepends = [ pkgs.postgresql ];
      };
      email-validate = doJailbreak (super.email-validate);
      aeson-qq = dontCheck (super.aeson-qq);
      beam-core = doJailbreak (super.beam-core);
      beam-migrate = doJailbreak (super.beam-migrate);
      beam-postgres = doJailbreak (super.beam-postgres);
      beam-automigrate = doJailbreak (super.beam-automigrate);
      bytestring-aeson-orphans = doJailbreak (super.bytestring-aeson-orphans);
      dependent-sum-aeson-orphans = doJailbreak (super.dependent-sum-aeson-orphans);
      postgresql-simple = doJailbreak (super.postgresql-simple);
      postgresql-lo-stream = doJailbreak (super.postgresql-lo-stream);
      #PATCH
      # in the starting package set, there exists an attribute "patch"
      # here we set the new value of "patch" to a specific version
      # from the Haskell package list (Hackage)
      patch = doJailbreak (super.callHackage "patch" "0.0.8.0" {});
      parseargs = dontCheck (super.parseargs);
      jmacro = super.callHackage "jmacro" "0.6.17.1" {};
      reflex = doJailbreak super.reflex;
      stripe-core = doJailbreak (super.stripe-core);
      stripe-haskell = dontCheck (super.stripe-haskell);
      stripe-http-client = doJailbreak (super.stripe-http-client);
      stripe-tests = doJailbreak (super.stripe-tests);
      vessel = doJailbreak (self.callCabal2nix "vessel" vesselSrc {});
      reflex-dom-echarts = self.callCabal2nix "reflex-dom-echarts" reflex-dom-echartsSrc {};
      echarts-jsdom = self.callCabal2nix "echarts-jsdom" echarts-jsdomSrc {};
      # Ensure that we can find and build nodejs **before** building my project, scrappy
      # I do this here because scrappy has quite a complex build process for nodejs with custom
      # dependencies and I don't need them
      scrappy = pkgs.haskell.lib.overrideCabal (self.callCabal2nix "scrappy" scrappySrc' {}) {
        librarySystemDepends = [ pkgs.nodejs ];
      };
      #BACKEND-FFMPEG
      # Server Overrides
      ## when we receive a user's video, we need to convert it's format so we call a bash process
      ## which uses ffmpeg. This statement here ensures that ffmpeg is in PATH, downloading if needed
      backend = haskellLib.overrideCabal super.backend {
        librarySystemDepends = [
          pkgs.ffmpeg
          # Bonus note: in my haskell code I write:
          # ffmpeg :: String; ffmpeg = $(staticWhich "ffmpeg")
          #
          # this, through staticWhich ensures that my haskell program can find the version of ffmpeg
          # at compile time!
        ];
      };
    });
  # All packages built with this project, as well as the project itself are available at
  # localhost:8080
  withHoogle = true;
})
