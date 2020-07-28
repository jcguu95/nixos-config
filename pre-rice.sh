# Run this as root after rebooting from a clean installation of nixOS

nix-env -iA nixos.git
git clone https://github.com/jcguu95/nixos-config
nix-env -e nixos.git

cd nixos-config
tmpDir=tmp-$(date -Is); mkdir $tmpDir;
mv /etc/nixos/configuration.nix ./$tmpDir/configuration.nix.bak
cp ./configuration.nix /etc/nixos/configuration.nix
nixos-rebuild switch

exit
