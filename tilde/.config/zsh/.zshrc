source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/zsh-autocomplete/zsh-autocomplete.zsh
source ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init

# Use beam shape cursor on startup.
echo -ne '\e[5 q'
# Use beam shape cursor for each new prompt.
preexec() { echo -ne '\e[5 q' ;}

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

bindkey -s '^o' 'lfcd\n'  # zsh

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Internet
alias ytv="youtube-dl -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' --output \"%(title)s.%(ext)s\" --add-metadata -i" # Download video link
alias yta="youtube-dl --output \"%(title)s.%(ext)s\" --extract-audio --audio-format mp3 --audio-quality 0" # Download only audio

shdl() { curl -O $(curl -s http://sci-hub.tw/"$@" | grep location.href | grep -o http.*pdf) ;}
se() { du -a ~/.scripts/* ~/.config/* | awk '{print $2}' | fzf | xargs  -r $EDITOR ;}
sv() { vcopy "$(du -a ~/.scripts/* ~/.config/* | awk '{print $2}' | fzf)" ;}
vf() { fzf | xargs -r -I % $EDITOR % ;}
dic() { sdcv "$1" ; yd "$1" ; }

# Not of LARBS
alias power="cat /sys/class/power-supply/BAT0/capacity"
alias screen-off="xset dpms force off"
alias bt-on="sudo rfkill unblock bluetooth"
alias bt-off="sudo rfkill block bluetooth"
alias pinknoise="play -t sl -r48000 -c2 -n synth -1 pinknoise .1"
alias vim="nvim"
alias h="hledger"

bt() {
	case "$1" in
		"on") sudo rfkill unblock bluetooth ;;
		"off") sudo rfkill block bluetooth ;;
		*) echo "option=[on,off]" ;;
	esac
}

alias edit_config="$EDITOR $HOME/.config/zsh/.zshrc"
kill_emacs_really() { for i in $(pgrep emacs); do print $i; kill -9 $i; done }

cut-video () {
	ffmpeg -i "$1" -ss "$2" -to "$3" -c copy cut-from-"$2"s+"$3"s."$1"
}

alias offscreen="sleep 1 && xset -display :0.0 dpms force off"

### This is for the program `fast-p`
ppp() {
    open=zathura   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:90% --preview '
            v=$(echo {q} | tr " " "|");
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
}

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.local/share/zsh/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
