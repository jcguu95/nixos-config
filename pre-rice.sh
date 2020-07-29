# Run this as root after rebooting from a clean installation of nixOS

tmpDir=tmp-$(date -Is); mkdir $tmpDir;
mv /etc/nixos/configuration.nix ./$tmpDir/configuration.nix.bak
cp ./configuration.nix /etc/nixos/configuration.nix
nixos-rebuild switch

exit
