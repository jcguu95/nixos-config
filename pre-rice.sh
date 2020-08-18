# Run this as root after rebooting from a clean installation of nixOS

mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak.$(date -Is)
ln -sf $(pwd)/configuration.nix /etc/nixos/configuration.nix
nixos-rebuild switch

exit
