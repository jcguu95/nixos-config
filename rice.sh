# Run this as root

## System Config
git clone https://github.com/jcguu95/nixos-config
cd nixos-config

mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
cp ./configuration.nix /etc/nixos.configuration.nix

## Git Config
git config --global user.name "Jin"
git config --global user.email "jcguu95@gmail.com"

## .xinitrc
echo "ssh-agent xmonad" >> "$/home/jin/.xinitrc"

## TODO xmonad & xmobar

