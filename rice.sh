# Should be run after a clean installation of nixOS and `pre-rice.sh`.

## xmonad
echo "\n### Configuring xmonad.. ###"
echo "Backing up xmonad config if any.."
mv $HOME/.xmonad $HOME/.xmonad_bak
echo "Symlinking our xmonad config to $HOME/.xmonad.."
ln -sf $(pwd)/.dotfiles/.xmonad $HOME/.xmonad
echo "Recompiling xmonad.."
xmonad --recompile
echo "Done."

## xmobar
echo "\n### Configuring xmobar.. ###"
echo "Symlinking our xmobar config to $HOME/.config/xmobar.."
ln -sf $(pwd)/.dotfiles/.config/xmobar $HOME/.config/xmobar
echo "  Done."

## TODO Luke Smith's st
#
#
#
## TODO Luke Smith's st


## ALL DONE! Fade off..
echo "\n###All done. Exit in 3 seconds..###"; sleep 3;

exit
