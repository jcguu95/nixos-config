# Should be run after a clean installation of nixOS and `pre-rice.sh`.

## Git Config
echo "Configuring git.."
git config --global user.name "Jin"
git config --global user.email "jcguu95@gmail.com"
echo "Done."

## X11 Config
echo "Configuring X11.."
echo "ssh-agent xmonad" >> "/home/jin/.xinitrc"
echo "Done."

## xmonad & xmobar
### xmonad
echo "Configuring xmonad.."
mv $HOME/.xmonad $HOME/.xmonad_bak
ln -sf $(pwd)/.xmonad $HOME/.xmonad
xmonad --recompile
echo "Done."
### xmobar
echo "Configuring xmobar.."
ln -sf $(pwd)/xmobarrc $HOME/.xmobarrc
echo "Done."

echo "All done. Exit in 5 seconds.."; sleep 5;

exit

