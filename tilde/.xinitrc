export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.scripts/bin:$PATH"
export ZDOTDIR="$HOME/.config/zsh"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

killall xcape 2>/dev/null ; xcape -e 'Control_L=Escape' &
feh --bg-fill ~/.wall.png
ssh-agent xmonad
