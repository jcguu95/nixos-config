export PATH="$HOME/.scripts:$PATH"
export ZDOTDIR="$HOME/.config/zsh"

killall xcape 2>/dev/null ; xcape -e 'Control_L=Escape' &
feh --bg-fill ~/.wall.png
ssh-agent xmonad
