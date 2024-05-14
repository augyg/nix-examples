# Scrappy Tutorial # 

In the app folder, in Main.hs you will find the tutorial code

to run this you will need to install Nix and will need to be Unix (Linux or MacOS). If you are on windows I'd get WSL. You could rip out the main function and just use main' as well as remove rhyolite-common from cabal and then use Stack to get the current version of scrappy but I'm not doing that here. Trust me Nix is amazing and worth it, same with WSL. 

If you are unable to do so for whatever reason, shoot me a message at galen.sprout@gmail.com

## Run this package ## 

Follow the relevant instructions here:

https://nixos.org/download.html#nix-install-linux

Once that's done, you can run the following 

```
nix-shell
cabal run scrappy-tutorial 
```

or instead for a little more interactiveness, instead do `cabal repl scrappy-tutorial`

## nix-thunk For Changes to Scrappy ## 

nix-thunk is an amazing tool for working on open-source projects that you depend on. 

It can be installed by running

```bash
nix-env -f https://github.com/obsidiansystems/nix-thunk/archive/master.tar.gz -iA command
```

This allows you to directly edit scrappy's source code on your own branch and use it as easily as any other function you would create in your own project.

A thunked project is really just a git repository so we could do the following to edit scrappy ourselves

```bash 
nix-thunk unpack deps/scrappy
cd deps/scrappy
git checkout -b <my-new-branch-name> 
```
*do some edits* 
```bash
git add -p .
git commit -m "some commit message" 
git push origin <my-new-branch-name> 
cd ../..
nix-thunk pack deps/scrappy
```

Now when you run:
```bash
nix-shell
cabal repl scrappy-tutorial
```

You will be using your branch of scrappy.

## Documentation ## 

This is a hack, but regardless will give you a hoogle server with scrappy.

```bash
git clone https://github.com/augyg/Obelisk-Scrappy.git 
cd Obelisk-Scrappy
ob hoogle
```

then navigate to localhost:8080/

All packages in use will be available.
