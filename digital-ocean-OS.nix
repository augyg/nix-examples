# This function describes how to build the Linux/NixOS Server for Digital Ocean
# that I deploy my app to

{ nixosPkgs, ... }: { config, lib, ... }: {
  imports = [ "${nixosPkgs.path}/nixos/modules/virtualisation/digital-ocean-image.nix" ];
  # Override nginx to allow unlimited body size
  # so that users can send recordings which are up to 5 minutes in length
  # to be analyzed
  services.nginx.clientMaxBodySize = "0";
}
