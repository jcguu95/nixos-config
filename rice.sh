# Should be run after a clean installation of nixOS and `pre-rice.sh`.

## Git Config
git config --global user.name "Jin"
git config --global user.email "jcguu95@gmail.com"

## X11 Config
echo "ssh-agent xmonad" >> "/home/jin/.xinitrc"

## xmonad & xmobar
mkdir $HOME/.xmonad
ln -sf $(pwd)/xmonad.hs $HOME/.xmonad
xmonad --recompile

ln -sf $(pwd)/xmobarrc $HOME/.xmobarrc

