# Should be run after a clean installation of nixOS and `pre-rice.sh`.

## xmonad & xmobar
### xmonad
echo "Configuring xmonad.."
mv $HOME/.xmonad $HOME/.xmonad_bak
ln -sf $(pwd)/.dotfiles/.xmonad $HOME/.xmonad
xmonad --recompile
echo "Done."
### xmobar
echo "Configuring xmobar.."
ln -sf $(pwd)/.dotfiles/.xmobarrc $HOME/.xmobarrc
echo "Done."

## TODO Luke Smith's st
#
#
#
## TODO Luke Smith's st


## ALL DONE! Fade off..
echo "All done. Exit in 5 seconds.."; sleep 5;

exit
