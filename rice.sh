# Run this as root

## System Config
git clone https://github.com/jcguu95/nixos-config
cd nixos-config

mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
cp ./configuration.nix /etc/nixos.configuration.nix

## TODO .xinitrc
## TODO xmonad & xmobar

