export PATH="$HOME/.scripts:$PATH"
killall xcape 2>/dev/null ; xcape -e 'Control_L=Escape' &
feh --bg-fill ~/.wall.png
ssh-agent xmonad
