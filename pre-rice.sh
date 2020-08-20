# Run this as root after rebooting from a clean installation of nixOS

echo "Backing up configuration.nix in the same directory /etc/nixos/ .."
mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak.$(date -Is)

echo "Symlinking our configuration.nix to /etc/nixos .."
ln -sf $(pwd)/configuration.nix /etc/nixos/configuration.nix

echo "Rebuilding.."
nixos-rebuild switch

echo "DONE!"

exit
