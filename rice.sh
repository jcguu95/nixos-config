# Should be run after a clean installation of nixOS and `pre-rice.sh` at *THIS* directory.

## .config
### Un-safe/un-reproducible.. but whatelse can I do?
### https://github.com/rycee/home-manager/issues/257
echo "\n### Configuring ~/.config un-reproducibly.. ###"
echo "Backing up ~/.config if any.."
mv $HOME/.config $HOME/.config_bak_$(date -Is)
echo "Symlinking to ~/.config.."
ln -sf $(pwd)/tilde/.config $HOME/.config 
echo "Done."

## xmonad
echo "\n### Configuring xmonad un-reproducibly.. ###"
echo "Backing up xmonad config if any.."
mv $HOME/.xmonad $HOME/.xmonad_bak_$(date -Is)
echo "Symlinking our xmonad config to $HOME/.xmonad.."
ln -sf $(pwd)/tilde/.xmonad $HOME/.xmonad
echo "Recompiling xmonad.."
xmonad --recompile
echo "Done."

## xmobar
echo "\n### Configuring xmobar un-reproducibly.. ###"
echo "Symlinking our xmobar config to $HOME/.config/xmobar.."
ln -sf $(pwd)/tilde/.config/xmobar $HOME/.config/xmobar
echo "  Done."

## TODO Luke Smith's st
#
#
#
## TODO Luke Smith's st


## ALL DONE! Fade off..
echo "\n###All done. You can use `xmonad --restart` to see the effect."
echo "Exit in 3 seconds..###"; sleep 3;

exit
