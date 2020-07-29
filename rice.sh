# Should be run after a clean installation of nixOS and `pre-rice.sh`.

## Git Config
git config --global user.name "Jin"
git config --global user.email "jcguu95@gmail.com"

## X11 Config
echo "ssh-agent xmonad" >> "/home/jin/.xinitrc"

## xmonad & xmobar
### xmonad
mv $HOME/.xmonad $HOME/.xmonad_bak
ln -sf $(pwd)/.xmonad $HOME/.xmonad
xmonad --recompile
### xmobar
ln -sf $(pwd)/xmobarrc $HOME/.xmobarrc

