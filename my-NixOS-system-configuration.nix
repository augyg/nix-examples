# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


# FIND OUT WHAT ANY OF THESE OPTIONS ARE HERE:
# https://search.nixos.org/options?

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./gitea.nix
    ];


  nix = {
    extraOptions = ''
      experimental-features = nix-command
    '';
  };
  environment.interactiveShellInit = ''
     alias hoogleS="pkill hoogle; nix-shell /home/lazylambda/hoogle-server/shell.nix &; hoogle server -p 8080 --local &"
     alias scrape="cd /home/lazylambda/code/Ace/wikiScraper/; sudo nix-shell --run \"cabal repl\""
     alias ncrepl="nix-shell --run \"cabal repl\""
     function deleteNixStorePattern() {
        if [[ -z "$1" ]]; then
           echo "Usage: deleteNixStorePattern <pattern>"
           return 1
        fi
        local pattern=$1
        echo
        sudo nix-store --delete $(ls /nix/store | grep $pattern | sed 's/^/\/nix\/store\//')
     }
     # This is a command I can get my girlfriend to run and it will deploy to aceinterviewprep.app lmao
     tamaraDeploy() {
       cd ~/code/Ace/Ace/DigOcean
       ob thunk update src
       ob deploy push -v
     }
     mkHackageTar() {
         if [ -z "$1" ]; then
            echo "Usage: prepareTar <directory>"
            return 1
         fi

         # Target directory to be archived
         TARGET_DIR="$1"
         echo $TARGET_DIR
         # Name of the resulting tar.gz file
         OUTPUT_FILE="$TARGET_DIR.tar.gz"
         echo $OUTPUT_FILE

         # Step 1: Remove the 'dist-newstyle' directory
         echo "Removing 'dist-newstyle' directory if it exists..."
         echo "$TARGET_DIR/dist-newstyle"
         rm -rf "$TARGET_DIR/dist-newstyle"

         # Step 2: Remove files ending with '~' or containing '#'
         echo "Removing files ending with '~' or containing '#'..."
         find $TARGET_DIR \( -name '*~' -o -name '*#*' \) -exec rm -f {} +

         # Step 3: Set file permissions to 644 and directory permissions to 755
         echo "Setting file permissions to 644 and directory permissions to 755..."
         find $TARGET_DIR -type d -exec chmod 755 {} +
         find $TARGET_DIR -type f -exec chmod 644 {} +

         # Step 3: Create tar.gz file, excluding .git directory
         echo "Creating tar.gz file..."
         tar -czvf $OUTPUT_FILE --exclude="$TARGET_DIR/.git" --format=ustar $TARGET_DIR

    echo "Tarball $OUTPUT_FILE created successfully."
}

  '';

  services.postgresql.enable = true;

  services.postfix.enable = true;
  services.mullvad-vpn.enable = true;
  #All for git-xmpp
  # virtualisation.libvirtd.enable = true;
  # networking.firewall.allowedTCPPorts = [ 3000 8000 ];
  # services.gitea.domain = "10.233.1.2";
  # services.gitea.rootUrl = "http://10.233.1.2:3000/";
  # services.gitea.httpAddress = "10.233.1.2";

  # Options that would be in nix.conf
  nix.settings = {
    substituters = [ "https://nixcache.reflex-frp.org" ];
    trusted-public-keys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    ];
    log-lines = 500;
  };

  services.localtimed.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.permittedInsecurePackages = [
    "python2.7-Pillow-6.2.2"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_5_15;
  boot.initrd.luks.devices.root = {
    device = "<omitted>";
    allowDiscards = true;
  };
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "<omitted>"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # In your configuration.nix
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.virtualbox.host.enable = true;


  # Set your time zone.
  time.timeZone = "America/Toronto";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp46s0.useDHCP = false;
  networking.interfaces.wlp48s0.useDHCP = false;
  networking.hostId = "<omitted>";
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.xmonad.enable  = true;
  #hardware.nvidiaOptimus.disable = true;
  #services.xserver.videoDrivers = [ "i915" ];

  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  networking.firewall.allowedTCPPorts = []; #omitted

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lazylambda = {
    isNormalUser = true;
    extraGroups = [ "wheel" "podman" "networkmanager" "vboxusers" ];
  };

  services.teamviewer.enable = true;

  hardware.opengl.driSupport32Bit = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #let


  environment.systemPackages = (
  # not actually unstable rn but master (which is less stable lol)
  let unstable = import (pkgs.fetchFromGitHub {
        owner="NixOS";
		    repo="nixpkgs";
        rev="d8fe5e6c92d0d190646fb9f1056741a229980089";
       	sha256= "sha256-iMUFArF0WCatKK6RzfUJknjem0H9m4KgorO/p3Dopkk=";
	    }) { config = {
             allowUnfree = true;
             overlays = [
               (import (builtins.fetchTarball {
                 url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
               }))
             ];
           };
         };
  in
  with pkgs; [
    vim
    wget
    git
    tree
    zoom
    nix-prefetch-git
    niv
    zoom-us
    spotify
    notejot
    protonvpn-cli
    wireguard-tools
    htop
    remmina
    obs-studio
    scribus
    glslang
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-validation-layers
    lutris
    steam
    wine
    winetricks
    openssl
    libreoffice
    lilo
    gparted
    #unityhub
    # mono # needed for unity hub
    #vscode
    teamviewer
    slack
    whatsapp-for-linux
    ngrok
    simplescreenrecorder
    librecad
    xsel
    jitsi
  ] ++ (
  with unstable; [
    vscode
    discord
    signal-desktop
    element-desktop
    unityhub
    google-chrome
    yt-dlp
    openshot-qt
    firefox
    chatgpt-cli
    # (emacsWithPackagesFromUsePackage {
    #   package = pkgs.emacs;  # replace with pkgs.emacsPgtk, or another version if desired.
    #   #config = "";
    #   config = /home/lazylambda/.emacs.d/init.el; # Org-Babel configs also supported

    #   # # Optionally provide extra packages not in the configuration file.
    #   # extraEmacsPackages = epkgs: [
    #   #   epkgs.use-package
    #   # ];

    #   # # Optionally override derivations.
    #   # override = epkgs: epkgs // {
    #   #   somePackage = epkgs.melpaPackages.somePackage.overrideAttrs(old: {
    #   #      # Apply fixes here
    #   #   });
    #   # };
    # })
    (emacs.pkgs.withPackages (epkgs: with epkgs.melpaStablePackages; [
       haskell-mode
       nix-mode
       csharp-mode
       epkgs.chatgpt-shell
       rust-mode
    ]))

  ]));

  services.x2goserver.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [] #omitted
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
