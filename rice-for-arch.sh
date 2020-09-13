#!/bin/sh
# this script must be run in this directory

ln -sf $(pwd)/tilde/.xmonad ~/.xmonad

link() {
  echo "soft linking $1 to $2"
  ln -sf $1 $2
}

complain() {
  echo "Target of $1 exists. Do nothing."
}

for entry in $(pwd)/tilde/.config/*; do
  link "$entry" ~/.config/ || complain "$entry"
done


#ln -sf $(pwd)/tilde/.config/xmobar ~/.config/xmobar
#ln -sf $(pwd)/tilde/.config/alacritty.yml ~/.config/alacritty.yml

exit
