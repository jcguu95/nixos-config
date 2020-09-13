#!/bin/sh
# this script must be run in this directory

## .config
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

## Others
ln -sf $(pwd)/tilde/.xmonad ~/.xmonad

exit
