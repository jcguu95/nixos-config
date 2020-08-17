# TODO it is still not working. code taken from
# https://github.com/utdemir/dotfiles/blob/a07f915e1dd55d5e038686fcade52255e27ea021/home/qutebrowser.nix  

{ config, pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.qutebrowser ]; };

    #home.file.".config/qutebrowser/config.py".text = ''
    #    this is just a test
    #  '';
    #};
}
