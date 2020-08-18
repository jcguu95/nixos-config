# Should be run after a clean installation of nixOS and `pre-rice.sh`.

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

## alacritty
echo "Configuring alacritty.."
mkdir $HOME/.config
ln -sf $(pwd)/alacritty.yml $HOME/.config
echo "Done."

## TODO Luke Smith's st
#
#
#
## TODO Luke Smith's st


## ALL DONE! Fade off..
echo "All done. Exit in 5 seconds.."; sleep 5;

exit
