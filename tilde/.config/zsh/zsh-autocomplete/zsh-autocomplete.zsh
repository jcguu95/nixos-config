() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  # Make `terminfo` codes work.
  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget line-init _autocomplete.application-mode.hook
  _autocomplete.application-mode.hook() {
    echoti smkx
  }
  add-zle-hook-widget line-finish _autocomplete.raw-mode.hook
  _autocomplete.raw-mode.hook() {
    echoti rmkx
  }

  typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=1

  # In case we're sourced _after_ `zsh-autosuggestions`
  autoload +X -Uz add-zsh-hook
  add-zsh-hook -d precmd _zsh_autosuggest_start

  # Get access to some of the internal hash tables used by the shell.
  zmodload -i zsh/parameter

  # In case we're sourced _before_ `zsh-autosuggestions`
  functions[_autocomplete.add-zsh-hook]=$functions[add-zsh-hook]
  add-zsh-hook() {
    # Prevent `_zsh_autosuggest_start` from being added.
    if [[ ${@[(ie)_zsh_autosuggest_start]} -gt ${#@} ]]; then
      _autocomplete.add-zsh-hook "$@" > /dev/null
    fi
  }

  # Workaround for issue #43
  # https://github.com/marlonrichert/zsh-autocomplete/issues/43
  zle -N zle-line-finish azhw:zle-line-finish

  autoload -Uz zmathfunc && zmathfunc  # `min` function

  [[ ! -v ZLE_REMOVE_SUFFIX_CHARS ]] && export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

  [[ ! -v _autocomplete__options ]] && export _autocomplete__options=(
    GLOB_DOTS
    no_ALWAYS_TO_END no_CASE_GLOB no_COMPLETE_ALIASES
    no_COMPLETE_IN_WORD no_GLOB_COMPLETE no_LIST_BEEP
  )

  # Workaround for https://github.com/zdharma/zinit/issues/366
  [[ -v functions[.zinit-shade-off] ]] && .zinit-shade-off "${___mode:-load}"

  # Initialize completion system, if it hasn't been done yet.
  # Needs to be ASAP, to avoid a race condition.
  # `zsh/complist` should be loaded _before_ `compinit`.
  if ! (zle -l menu-select && bindkey -l menuselect > /dev/null); then
    zmodload -i zsh/complist
    autoload -Uz compinit && compinit -C
  elif ! [[ -v compprefuncs && -v comppostfuncs ]]; then
    autoload -Uz compinit && compinit -C
  fi

  autoload +X -Uz _main_complete
  functions[_autocomplete._main_complete]=$functions[_main_complete]

  _main_complete() {
    setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

    (( $#comppostfuncs == 0 )) &&
      local +h -a comppostfuncs=( _autocomplete.add_extras _autocomplete.handle_long_list )
    _autocomplete._main_complete "$@"
  }

  # Workaround for https://github.com/zdharma/zinit/issues/366
  [[ -v functions[.zinit-shade-on] ]] && .zinit-shade-on "${___mode:-load}"

  add-zsh-hook precmd _autocomplete.main.hook
}

_autocomplete.main.hook() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  # Remove itself after being called.
  add-zsh-hook -d precmd _autocomplete.main.hook

  zmodload -i zsh/zutil  # `zstyle` builtin

  # Remove incompatible styles.
  zstyle -d ':completion:*' format
  zstyle -d ':completion:*:descriptions' format
  zstyle -d ':completion:*' group-name
  zstyle -d ':completion:*:functions' ignored-patterns
  zstyle -d '*' single-ignored
  zstyle -d ':completion:*' special-dirs

  autoload +X -Uz _expand
  functions[_autocomplete._expand]=$functions[_expand]

  _expand() {
    _autocomplete.is_glob && ISUFFIX='*'
    _autocomplete._expand "$@"
    local ret=$?
    ISUFFIX=''
    return ret
  }

  autoload +X -Uz _complete
  functions[_autocomplete._complete]=$functions[_complete]

  _complete() {
    local -i nmatches=$compstate[nmatches]
    _autocomplete._complete "$@"
    local ret=$?
    (( compstate[nmatches] == nmatches )) && _comp_mesg=''
    return ret
  }

  zstyle ':completion:*' completer \
    _expand \
    _complete _complete:-left _complete:-fuzzy _ignored \
    _approximate _autocomplete._history

  zstyle ':completion:*:complete:*' matcher-list '
    l:|=**' '+m:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
  zstyle -e ':completion:*:complete:*' ignored-patterns '
    local word=$PREFIX$SUFFIX
    local prefix=${(M)word##*/}
    local suffix=${word##*/}
    local punct=${(M)suffix##[^[:alnum:]]##}
    local nonpunct=${suffix##[^[:alnum:]]##}
    if [[ -n $punct ]]; then
      reply=( "${(b)prefix}${punct}[^[:alnum:]]*" "^(${(b)prefix}*${punct}(#i)${(b)nonpunct}*)" )
    else
      reply=( "${(b)prefix}[^[:alnum:]]*" "^(${(b)prefix}(#i)${(b)suffix}*)" )
    fi'

  zstyle ':completion:*:complete-left:*' matcher-list '
    l:|=** m:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
  zstyle -e ':completion:*:complete-left:*' ignored-patterns '
    local word=$PREFIX$SUFFIX
    local prefix=${(M)word##*/}
    local suffix=${word##*/}
    local punct=${(M)suffix##[^[:alnum:]]##}
    local nonpunct=${suffix##[^[:alnum:]]##}
    if [[ -n $punct ]]; then
      reply=( "${(b)prefix}([^[:alnum:]]~${punct})*" )
    else
      reply=( "${(b)prefix}[^[:alnum:]]*" )
    fi'

  zstyle ':completion:*:complete-fuzzy:*' matcher-list '
    r:|?=** m:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
  zstyle -e ':completion:*:complete-fuzzy:*' ignored-patterns '
    local word=$PREFIX$SUFFIX
    local prefix=${(M)word##*/}
    local suffix=${word##*/}
    local punct=${(M)suffix##[^[:alnum:]]##}
    local nonpunct=${suffix##[^[:alnum:]]##}
    if [[ -n $punct ]]; then
      reply=( "^(${(b)prefix}*${punct}(#i)${(b)nonpunct[1]}*)" )
    else
      reply=( "^(${(b)prefix}(#i)${(b)suffix[1]}*)" )
    fi'

  zstyle ':completion:*' tag-order '*'
  zstyle ':completion:*:(-command-|cd|z):*' tag-order '! users' '-'
  zstyle ':completion:*:expand:*' tag-order '! original'

  zstyle -e ':completion:*' max-errors '
    if [[ -z $SUFFIX && -n $QIPREFIX && -n $QISUFFIX ]]; then
      reply=( 0 )
    else
      reply=( $(( min(7, (${#PREFIX} + ${#SUFFIX} - 1) / 2) )) )
    fi
    reply+=( numeric )'

  zstyle -e ':completion:*' glob 'reply=( "true" ) && _autocomplete.is_glob || reply=( "false" )'
  zstyle ':completion:*' expand prefix suffix
  zstyle ':completion:*' list-suffixes true
  zstyle ':completion:*' path-completion true

  zstyle ':completion:*' menu 'yes select=long-list'

  if zstyle -m ":autocomplete:tab:" completion 'insert'; then
    zstyle ':completion:*:complete:*' show-ambiguity '07'
  fi

  zstyle ':completion:*' list-dirs-first true
  zstyle ':completion:*:(directories|*-directories|directory-*)' group-name 'directories'
  zstyle ':completion:*' group-order 'directories'

  if zstyle -t ':autocomplete:' groups 'always'; then
    zstyle ':completion:*' format '%F{yellow}%d:%f'
    zstyle ':completion:*' group-name ''
  fi

  zstyle ':completion:*:messages' format '%F{blue}%d%f'
  zstyle ':completion:*:warnings' format '%F{red}%d%f'

  zstyle ':completion:*:recent-(dirs|files)' group-name ''

  zstyle ':completion:*:(requoted|unambiguous)' group-name ''

  zstyle ':completion:*' auto-description '%F{yellow}%d%f'

  zstyle ':completion:*' add-space true
  zstyle ':completion:*' list-packed true
  zstyle ':completion:*' list-separator ''
  zstyle ':completion:*' use-cache true

  zstyle ':completion:correct-word:*' completer _complete _correct
  zstyle ':completion:correct-word:*' ignored-patterns '[[:punct:]]*'
  zstyle -e ':completion:correct-word:complete:*' ignored-patterns 'reply=( "^($PREFIX$SUFFIX)" )'
  zstyle ':completion:correct-word:*:git-*:argument-*:*' tag-order -
  zstyle ':completion:correct-word:*' accept-exact true
  zstyle ':completion:correct-word:*' add-space false
  zstyle ':completion:correct-word:*' glob false

  zstyle ':completion:expand-word:*' menu ''
  zstyle ':completion:list-choices:*' menu ''

  zstyle ':completion:list-expand:*' completer _expand _complete _ignored _approximate
  zstyle ':completion:list-expand:complete:*' matcher-list '
    l:|=** m:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' '+r:|?=**'
  zstyle ':completion:list-expand:complete:*' ignored-patterns ''
  zstyle ':completion:list-expand:complete:*:recent-dirs' ignored-patterns '/'
  zstyle ':completion:list-expand:*' tag-order '*'
  zstyle ':completion:list-expand:*' format '%F{yellow}%d:%f'
  zstyle ':completion:list-expand:*' group-name ''
  zstyle ':completion:list-expand:*' extra-verbose true
  zstyle ':completion:list-expand:*' list-separator '-'
  zstyle ':completion:list-expand:*' menu 'yes select'

  if [[ ! -v key ]]; then
    # This file can be generated interactively with `autoload -Uz zkbd && zkbd`.
    # See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Keyboard-Definition
    if [[ -r ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR} ]]; then
      source ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR}
    fi

    if [[ ! -v key ]]; then
      typeset -g -A key
    fi
  fi

  zmodload -i zsh/terminfo
  if [[ -z $key[Up] ]]; then
    if [[ -n $terminfo[kcuu1] ]]; then key[Up]=$terminfo[kcuu1]; else key[Up]='^[OA'; fi
  fi
  if [[ -z $key[Down] ]]; then
    if [[ -n $terminfo[kcud1] ]]; then key[Down]=$terminfo[kcud1]; else key[Down]='^[OB'; fi
  fi
  if [[ -z $key[Tab] ]]; then
    if [[ -n $terminfo[ht] ]]; then key[Tab]=$terminfo[ht]; else key[Tab]='^I'; fi
  fi
  if [[ -z $key[BackTab] ]]; then
    if [[ -n $terminfo[kcbt] ]]; then key[BackTab]=$terminfo[kcbt]; else key[BackTab]='^[[Z'; fi
  fi

  # Hard-code these values, because they are not generated by `zkbd` nor defined in `terminfo`.
  if [[ -z $key[Return] ]]; then key[Return]='^M'; fi
  if [[ -z $key[LineFeed] ]]; then key[LineFeed]='^J'; fi
  if [[ -z $key[ControlSpace] ]]; then key[ControlSpace]='^@'; fi
  if [[ -z $key[DeleteList] ]]; then key[DeleteList]='^D'; fi

  local tab_completion
  zstyle -s ":autocomplete:tab:" completion tab_completion || tab_completion='accept'
  case $tab_completion in
    'cycle')
      bindkey $key[Tab] menu-complete
      zle -C menu-complete menu-complete menu-complete
      bindkey $key[BackTab] reverse-menu-complete
      zle -C reverse-menu-complete reverse-menu-complete menu-complete

      menu-complete() {
        setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

        _main_complete
      }

      ;;
    'select')
      bindkey $key[Tab] menu-complete
      zle -C menu-complete menu-select menu-complete
      bindkey $key[BackTab] reverse-menu-complete
      zle -C reverse-menu-complete menu-select menu-complete

      menu-complete() {
        setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

        case $WIDGET in
          menu-complete)
            compstate[insert]='menu:1'
            ;;
          reverse-menu-complete)
            compstate[insert]='menu:-1'
            ;;
        esac
        _main_complete
      }

      ;;
    'insert')
      bindkey $key[Tab] menu-complete
      zle -C menu-complete menu-complete menu-complete
      bindkey $key[BackTab] reverse-menu-complete
      zle -C reverse-menu-complete reverse-menu-complete menu-complete

      menu-complete() {
        setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

        compstate[insert]='menu'
        _main_complete
        if (( ${#compstate[exact_string]} > 0 )); then
          case $WIDGETSTYLE in
            menu-complete)
              compstate[insert]='menu:2'
              ;;
            reverse-menu-complete)
              compstate[insert]='menu:-1'
              ;;
          esac
        elif (( ${compstate[unambiguous_cursor]} > (${#:-$PREFIX$SUFFIX} + 1) )); then
          compstate[insert]='unambiguous'
        fi
      }

      ;;
    'accept')
      zstyle ':autocomplete:tab:*' completion accept
      if [[ -v functions[_zsh_autosuggest_invoke_original_widget] ]]; then
        bindkey $key[Tab] _complete_word
        zle -N _complete_word _autocomplete.complete-word.zle-widget
      else
        bindkey $key[Tab] complete-word
      fi
      ;;
    'fzf')
      export fzf_default_completion='complete-word'
      ;;
  esac
  if [[ $tab_completion == (accept|fzf) ]]; then
      zle -C complete-word complete-word _autocomplete.complete-word.completion-widget

      bindkey $key[BackTab] list-expand
      zle -C list-expand menu-select _autocomplete.list-expand.completion-widget

      local keymap_main=$( bindkey -lL main )
      if [[ $keymap_main == *emacs* ]]; then
        if [[ ! -v key[Undo] ]]; then key[Undo]='^_'; fi
      elif [[ $keymap_main == *viins* ]]; then
        if [[ ! -v key[Undo] ]]; then key[Undo]='^[u'; fi
      fi
      if [[ -v key[Undo] ]]; then
        bindkey -M menuselect $key[Tab] accept-and-hold
        bindkey -M menuselect -s $key[BackTab] $key[DeleteList]$key[Undo]$key[BackTab]
        bindkey -M menuselect -s $key[Undo] $key[DeleteList]$key[Undo]
      fi
  fi

  [[ -v ZSH_AUTOSUGGEST_IGNORE_WIDGETS ]] && ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(
    prompt_\*
    user:_zsh_highlight_widget_\*-zle-line-finish
  )
  [[ -v ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS ]] && ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(
    forward-char
    vi-forward-char
  )

  if zstyle -T ':autocomplete:' fuzzy-search fzf && zle -l fzf-history-widget; then
      bindkey $key[Up] up-line-or-history-search
      zle -N up-line-or-history-search _autocomplete.up-line-or-history-search.zle-widget

      bindkey '^['$key[Up] history-search
      zle -N history-search _autocomplete.history-search.zle-widget

      bindkey $key[Down] down-line-or-menu-select
      zle -N down-line-or-menu-select _autocomplete.down-line-or-menu-select.zle-widget

      bindkey '^['$key[Down] menu-select
      zle -C menu-select menu-select _autocomplete.menu-select.completion-widget
      zstyle ':autocomplete:menu-select:*' key-binding "(Alt) Down Arrow"
  fi

  local menuselect
  zstyle -s ':autocomplete:menu-select:' key-binding menuselect || menuselect="Ctrl-Space"
  case $menuselect in
    "Ctrl-Space")
      bindkey $key[ControlSpace] menu-select
      zle -C menu-select menu-select _autocomplete.menu-select.completion-widget
      zstyle ':autocomplete:menu-select:*' key-binding "Ctrl-Space"
      ;;
    *)
      if zstyle -T ':autocomplete:' fuzzy-search fzf &&
          zle -l fzf-completion && zle -l fzf-cd-widget && zle -l fzf-file-widget; then
        bindkey $key[ControlSpace] expand-or-complete
        zle -N expand-or-complete _autocomplete.expand-or-complete.zle-widget
      else
        bindkey $key[ControlSpace] expand-word
      fi
      zle -C expand-word complete-word _autocomplete.expand-word.completion-widget
      bindkey -M menuselect $key[ControlSpace] end-of-history
      zstyle ':completion:*:requoted' format '%F{green}%d%f %F{blue}(Ctrl-Space)%f%F{green}:%f'
      zstyle ':completion:*:unambiguous' format '%F{green}%d%f %F{blue}(Ctrl-Space)%f%F{green}:%f'
      ;;
  esac

  bindkey ' ' magic-space
  zle -N magic-space

  magic-space() {
    setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

    zstyle -t ":autocomplete:space:" magic expand-history && zle .expand-history
    zle .self-insert
  }

  zle -C correct-word complete-word _autocomplete.correct-word.completion-widget
  bindkey '^[ ' self-insert-unmeta

  bindkey -M menuselect '^['$key[Up] vi-backward-blank-word
  bindkey -M menuselect '^['$key[Down] vi-forward-blank-word

  _autocomplete.no-op() { :; }
  if [[ ! -v functions[_zsh_highlight] ]]; then
    functions[_zsh_highlight]=$functions[_autocomplete.no-op]
  fi
  if [[ ! -v functions[_zsh_autosuggest_highlight_apply] ]]; then
    functions[_zsh_autosuggest_highlight_apply]=$functions[_autocomplete.no-op]
  fi

  [[ -v functions[_zsh_autosuggest_bind_widgets] ]] && _zsh_autosuggest_bind_widgets

  if [[ -v functions[zshz] && -v functions[_zshz_precmd] ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'zsh-z'; then

    _autocomplete.recent-dirs() {
      reply=( $( zshz --complete -l $1 2> /dev/null ) )
    }

  elif [[ -v commands[zoxide] && -v functions[_zoxide_hook] ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'zoxide'; then

    _autocomplete.recent-dirs() {
      reply=( $( zoxide query --list $1 2> /dev/null ) )
    }

  elif [[ -v functions[_zlua] && -v functions[_zlua_precmd] ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'z.lua'; then

    _autocomplete.recent-dirs() {
      reply=(
        "${(@)${(f)$( _zlua --complete $1 2> /dev/null )}##[[:digit:].]##[[:space:]]##}"
      )
    }

  elif [[ -v functions[_z] && -v functions[_z_precmd] ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'z.sh'; then

    _autocomplete.recent-dirs() {
      reply=(
        "${(@)${(f)$( _z -l $1 2>&1 )}##(common:|[[:digit:]]##)[[:space:]]##}"
      )
    }

  elif [[ -v commands[autojump] && -v AUTOJUMP_SOURCED ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'autojump'; then

    _autocomplete.recent-dirs() {
      reply=(
        "${(@)${(f)$( autojump --complete $1 2> /dev/null )}##${1}__[[:digit:]]__}"
      )
    }

  elif [[ ( -v commands[fasd] || -v functions[fasd] ) && -v functions[_fasd_preexec] ]] &&
      zstyle -T ':autocomplete:' recent-dirs 'fasd'; then

    _autocomplete.recent-dirs() {
      reply=( $( fasd -dlR $1 2> /dev/null ) )
    }

  else
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':chpwd:*' recent-dirs-max 0

    _autocomplete.recent-dirs() {
      cdr -r
    }
  fi

  if [[ ( -v commands[fasd] || -v functions[fasd] ) && -v functions[_fasd_preexec] ]] &&
      zstyle -T ':autocomplete:' recent-files 'fasd'; then

    _autocomplete.recent-files() {
      reply=( $( fasd -flR $1 2> /dev/null ) )
    }

  fi

  autoload +X -Uz _path_files
  functions[_autocomplete._path_files]=$functions[_path_files]

  _path_files() {
    setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

    local ret
    _autocomplete._path_files "$@"
    ret=$?

    (( compstate[nmatches] == 0 )) && [[ $_completer != complete-fuzzy ]] && return ret

    typeset -gaU reply
    local word="$PREFIX$SUFFIX"

    _autocomplete.recent-dirs "$word" &&
      _autocomplete.recent-paths recent-dirs 'recent directory' "$word" $reply
    (( ? == 0 )) && ret=0

    [[ ! -v functions[_autocomplete.recent-files] ]] && return ret

    local mopts tmp1; zparseopts -E -a mopts '/=tmp1'
    [[ -z tmp1 ]] && return ret

    _autocomplete.recent-files "$word" &&
      _autocomplete.recent-paths recent-files 'recent file' "$word" $reply
    (( ? == 0 )) && ret=0

    return ret
  }

  _autocomplete.recent-paths() {
    local tag=$1
    local group_name=$2
    local _word=${~3:P}
    shift 3

    local disp prefix file_prefix suffix ret=1
    local -a display popt
    local -i i=0

    local path; for path in ${~@:P}; do
      prefix="${~path:h}"
      [[ "$path" == "$_word" || "$prefix" == ("${_word:h}"|"$PWD") ]] && continue

      [[ $prefix != */ ]] && prefix="${prefix}/"
      suffix=${${path#$PWD/}:t}
      display=( "${prefix/$HOME/~}$suffix" )

      popt=()
      if [[ $prefix == /* ]]; then
          prefix=${prefix#/}
          popt=( -P '/' -W '/' )
      fi

      if _wanted $tag expl $group_name \
          compadd -V $tag -d display -fQ $popt - "$prefix$suffix"; then
        ret=0
        (( i++ ))
      fi
      
      (( compstate[lines] >= _autocomplete__max_lines() || i >= 4 )) && break
    done

    return ret
  }

  zmodload -i zsh/system  # `sysparams` array
  zmodload -i zsh/zpty
  typeset -g _autocomplete__async_fd
  typeset -g _autocomplete_lbuffernew _autocomplete_rbuffernew
  typeset -gaU _autocomplete__child_pids=( )
  zle -N _autocomplete.async_callback
  zle -C _list_choices list-choices _autocomplete.list-choices.completion-widget
  add-zle-hook-widget line-pre-redraw _autocomplete.list-choices.hook
  add-zsh-hook preexec _autocomplete.cancel_async
  add-zsh-hook zshexit _autocomplete.cancel_async
}

_autocomplete.list-choices.hook() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  if (( (PENDING + KEYS_QUEUED_COUNT) > 0 )); then
    return
  fi

  if (( $#BUFFER > 0)); then
    _zsh_highlight
    _zsh_autosuggest_highlight_apply
  fi

  if ( [[ $KEYS == *${key[BackTab]} ]] && zstyle -m ":autocomplete:tab:" completion 'accept' ) ||
      [[ $LASTWIDGET == (_complete_help|*(history|search)*) ]]; then
    return
  fi

  _autocomplete.async-list-choices "$KEYS" "$LBUFFER" "$RBUFFER"
}

_autocomplete.cancel_async() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  # If we've got a pending request, cancel it.
  if [[ -n "$_autocomplete__async_fd" ]] && { true <&$_autocomplete__async_fd } 2> /dev/null; then
    # Close the file descriptor and remove the handler.
    exec {_autocomplete__async_fd}<&-
    zle -F $_autocomplete__async_fd
  fi

  # Zsh will make a new process group for the child process only if job control is enabled.
  local group='-' && [[ -o MONITOR ]] || group=''

  # Kill all processes we spawned.
  local pid; for pid in ${(A)_autocomplete__child_pids}; do
    # Kill the process or process group.
    kill -TERM $group$pid 2> /dev/null
  done
  _autocomplete__child_pids=( )
}

_autocomplete.async-list-choices() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options
  setopt nobanghist noxtrace noverbose

  _autocomplete.cancel_async

  {
    # Fork a process and open a pipe to read from it.
    exec {_autocomplete__async_fd}< <(
      # Tell parent process our process ID.
      echo $sysparams[pid]

      {
        local REPLY
        zpty _autocomplete__zpty _autocomplete.query-list-choices '$1' '$2' '$3'
        zpty -w _autocomplete__zpty $'\t'

        local line
        zpty -r _autocomplete__zpty line '*'$'\0'$'\0'
        zpty -r _autocomplete__zpty line '*'$'\0'$'\0'
        echo -nE $line
      } always {
        zpty -d _autocomplete__zpty
      }
    )

    # There's a weird bug in Zsh < 5.8, where where ^C stops working unless we force a fork.
    # See https://github.com/zsh-users/zsh-autosuggestions/issues/364
    command true

  } always {
    # Read the process ID from the child process
    local pid
    read pid <&$_autocomplete__async_fd
    _autocomplete__child_pids+=( $pid )

  # Install a widget to handle input from the fd
    zle -F -w "$_autocomplete__async_fd" _autocomplete.async_callback
  }
}

_autocomplete.query-list-choices() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options
  setopt nobanghist

  local hook_functions=( chpwd periodic precmd preexec zshaddhistory zshexit zsh_directory_name )
  local f; for f in $hook_functions; do
    unset ${f}_functions &> /dev/null
    unfunction $f &> /dev/null
  done
  zle -D zle-isearch-exit zle-isearch-update zle-line-pre-redraw zle-line-init zle-line-finish \
         zle-history-line-set zle-keymap-select &> /dev/null

  typeset -g __keys=$1 __lbuffer=$2 __rbuffer=$3 __lbuffernew=$2 __rbuffernew=$3
  zle-widget() {
    LBUFFER=$__lbuffer
    RBUFFER=$__rbuffer
    case $__keys in
      ' ')
        if zstyle -T ":autocomplete:space:" magic correct-word && [[ ${LBUFFER[-1]} == ' ' ]]; then
          (( CURSOR-- ))
          zle correct-word
          zle .auto-suffix-remove
          (( CURSOR++ ))
        fi
        ;;
      '/')
        if zstyle -T ":autocomplete:slash:" magic correct-word && [[ ${LBUFFER[-1]} == '/' ]]; then
          LBUFFER=$LBUFFER[1,-2]
          RBUFFER=' '$RBUFFER
          zle correct-word
          zle .auto-suffix-remove
          LBUFFER=$LBUFFER'/'
          RBUFFER=$RBUFFER[2,-1]
        fi
        ;;
    esac
    [[ $LBUFFER != $__lbuffer ]] && __lbuffernew=$LBUFFER
    [[ $RBUFFER != $__rbuffer ]] && __lbuffernew=$RBUFFER
    zle completion-widget 2>&1
  }
  completion-widget() {
    echo -nE $'\0'$'\0'

    print_comp_mesg() {
      echo -nE "${(qq)_comp_mesg}"$'\0'
      compstate[insert]=''
      compstate[list_max]=0
      compstate[list]=''
    }

    unset 'compstate[vared]'
    local curcontext; _autocomplete.curcontext list-choices
    local +h -a comppostfuncs=( print_comp_mesg )
    _main_complete 2> /dev/null
    compstate[insert]=''
    compstate[list]=''
    compstate[list_max]=0

    echo -nE "${(q)__lbuffer}"$'\0'"${(q)__rbuffer}"$'\0'
    echo -nE "${(q)__lbuffernew}"$'\0'"${(q)__rbuffernew}"$'\0'
    echo -nE "${compstate[nmatches]}"$'\0'"${compstate[list_lines]}"$'\0'
    echo -nE $'\0'
  }
  zle -N zle-widget
  zle -C completion-widget list-choices completion-widget
  bindkey '^I' zle-widget
  vared LBUFFER 2>&1
}

# Called when new data is ready to be read from the pipe.
# First arg will be fd ready for reading.
# Second arg will be passed in case of error.
_autocomplete.async_callback() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options
  setopt nobanghist

  {
    if [[ -z "$2" || "$2" == "hup" ]]; then
      local null comp_mesg lbuffer rbuffer
      local -i nmatches list_lines columns lines
      IFS=$'\0' read -r -u $1 comp_mesg lbuffer rbuffer \
        _autocomplete_lbuffernew _autocomplete_rbuffernew nmatches list_lines null

      [[ "${LBUFFER}" != "${(Q)lbuffer}" || "${RBUFFER}" != "${(Q)rbuffer}" ]] && return

      _autocomplete_lbuffernew="${(Q)_autocomplete_lbuffernew}"
      _autocomplete_rbuffernew="${(Q)_autocomplete_rbuffernew}"
      [[ "$LBUFFER" != "$_autocomplete_lbuffernew" ]] && LBUFFER="$_autocomplete_lbuffernew"
      [[ "$RBUFFER" != "$_autocomplete_rbuffernew" ]] && RBUFFER="$_autocomplete_rbuffernew"

      zle _list_choices $nmatches $list_lines $comp_mesg

      # If a widget can't be called, ZLE always returns 0.
      # Thus, we return 1 on purpose, so we can check if our widget got called.
      case $? in
        1)
          unset _ZSH_HIGHLIGHT_PRIOR_BUFFER
          _zsh_highlight
          _zsh_autosuggest_highlight_apply
          zle -R
          ;;
        *)
          :
          ;;
      esac
    fi
  } always {
    if [[ -n "$1" ]] && { true <&$1 } 2>/dev/null; then
      # Close the fd
      exec {1}<&-

      # Remove the handler
      zle -F "$1"
    fi
  }
}

_autocomplete.list-choices.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext list-choices

  local min_input
  zstyle -s ":autocomplete:$curcontext" min-input min_input || min_input=1
  if (( CURRENT == 1 && $#PREFIX + $#SUFFIX < min_input )); then
    _main_complete -
    local mesg reply _comp_mesg
    zstyle -s ":autocomplete:${curcontext}:no-matches-yet" message mesg || mesg='Type more...'
    _autocomplete.explain message $mesg
  elif [[ -v 1 ]] && (( $1 == 0 )); then
    if [[ $PREFIX$SUFFIX == '' ]]; then
      if [[ $3 == 'yes' ]] && (( $2 > 0 )); then
        local +h -a comppostfuncs=( _autocomplete.list-choices.comppostfunc )
        _main_complete
      else
        _main_complete -
        local mesg reply _comp_mesg
        zstyle -s ":autocomplete:${curcontext}:no-matches-yet" message mesg || mesg='Type more...'
        _autocomplete.explain message $mesg
      fi
    else
      _main_complete -
      local mesg
      zstyle -s ":autocomplete:${curcontext}:no-matches-at-all" message mesg ||
        mesg='No matching completions found.'
      _autocomplete.explain warning $mesg
    fi
  elif [[ -v 2 ]] && (( $2 > _autocomplete__max_lines() )); then
    _main_complete -
    local mesg reply
    if ! zstyle -s ":autocomplete:${curcontext}:too-many-matches" message mesg; then
      local menuselect
      zstyle -s ':autocomplete:menu-select:' key-binding menuselect || menuselect="menu-select"
      mesg="Too long list. Press $menuselect to open or type more to filter."
    fi
    _autocomplete.explain message $mesg
  else
    local +h -a comppostfuncs=( _autocomplete.list-choices.comppostfunc )
    _main_complete
  fi
  compstate[insert]=''
  compstate[list_max]=0

  # If a widget can't be called, ZLE always returns 0.
  # Thus, we return 1 on purpose, so we can check if our widget got called.
  return 1
}

_autocomplete__max_lines() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  local available max_lines
  zstyle -s ":autocomplete:$curcontext" max-lines max_lines || max_lines='50%'
  if [[ $max_lines == *% ]]; then
    (( max_lines = (LINES - BUFFERLINES) * ${max_lines%%\%} / 100 ))
  else
    (( max_lines = min(max_lines, LINES - BUFFERLINES) ))
  fi
  return max_lines
}
functions -M _autocomplete__max_lines

_autocomplete.list-choices.comppostfunc() {
  setopt localoptions noshortloops nowarncreateglobal extendedglob $_autocomplete__options
  if [[ "$PREFIX$SUFFIX" == '' ]] && (( compstate[list_lines] == 0 )); then
    local reply _comp_mesg
    _message "Type more..."
  fi
  _autocomplete.add_extras
}

_autocomplete.explain() {
  setopt localoptions noshortloops nowarncreateglobal extendedglob $_autocomplete__options

  local format
  zstyle -s ":completion:${curcontext}:${1}s" format format
  _setup "${1}s"
  local mesg
  zformat -f mesg "$format" "d:$2" "D:$2"
  compadd -x "$mesg"
  compstate[list]='list force'
}

_autocomplete.correct-word.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  if _autocomplete.is_glob || [[ "${LBUFFER[-1]}${RBUFFER[1]}" == [[:IFS:][:space:]]# ||
       ${_lastcomp[insert]} == menu || -n $QIPREFIX && -n $QISUFFIX ]]; then
    compstate[insert]=''
    return 1
  fi

  unset 'compstate[vared]'
  local curcontext; _autocomplete.curcontext correct-word
  _main_complete
  compstate[insert]='1 ' &&
    ( (( compstate[nmatches] == 0 )) || [[ ${_lastcomp[completer]} == complete ]] ) &&
    compstate[insert]=''
}

_autocomplete.list-expand.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext list-expand
  _main_complete
}

_autocomplete.complete-word.zle-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local lbuffer="$LBUFFER"
  if (( $#RBUFFER == 0 && $#POSTDISPLAY > 0 )); then
    zle forward-word
  fi
  if [[ "$lbuffer" == "$LBUFFER" ]]; then
    zle complete-word
  fi
}

_autocomplete.complete-word.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext complete-word

  if [[ $_autocomplete_lbuffernew == ($LBUFFER|$LBUFFER$QIPREFIX) &&
        $_autocomplete_rbuffernew == ($QISUFFIX$RBUFFER|$RBUFFER) ]]; then
    compstate[old_list]='keep'
    _main_complete _oldlist
  else
    _main_complete
  fi
  compstate[insert]='1'
  [[ ${compstate[context]} == (command|redirect) ]] && compstate[insert]+=' '
}

_autocomplete.down-line-or-menu-select.zle-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext
  _autocomplete.curcontext down-line-or-menu-select

  if (( BUFFERLINES == 1 )); then
    zle menu-select
  else
    zle .down-line || zle .end-of-line
  fi
}

_autocomplete.menu-select.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext menu-select
  _main_complete
}

_autocomplete.up-line-or-history-search.zle-widget() {
  setopt localoptions extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext
  _autocomplete.curcontext up-line-or-history-search

  if (( BUFFERLINES == 1 )); then
    zle history-search
  else
    zle .up-line || zle .beginning-of-line
  fi
}

_autocomplete.history-search.zle-widget() {
  setopt localoptions extendedglob $_autocomplete__options

  local curcontext; _autocomplete.curcontext
  _autocomplete.curcontext history-search

  local FZF_COMPLETION_TRIGGER=''
  local fzf_default_completion='list-expand'
  local FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi --bind=ctrl-space:abort,ctrl-k:kill-line"

  zle fzf-history-widget
}

_autocomplete.expand-or-complete.zle-widget() {
  setopt localoptions extendedglob $_autocomplete__options

  local FZF_COMPLETION_TRIGGER=''
  local fzf_default_completion='fzf-file-widget'
  local FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi --bind=ctrl-space:abort,ctrl-k:kill-line"

  local curcontext; _autocomplete.curcontext
  _autocomplete.curcontext expand-or-complete

  if [[ $BUFFER == [[:IFS:]]# ]]; then
    zle fzf-cd-widget
    return
  fi

  zle expand-word && return

  zle .select-a-shell-word
  zle fzf-completion
}

_autocomplete.expand-word.completion-widget() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  if [[ -v compstate[old_list] && ${_lastcomp[tags]} == *(requoted|unambiguous)* ]]; then
    compstate[old_list]='keep'
    compstate[insert]='0'
    compstate[to_end]=''
    return
  fi

  local curcontext; _autocomplete.curcontext expand-word
  _main_complete _expand_alias
  (( compstate[nmatches] > 0 ))
}

_autocomplete.curcontext() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  typeset -g curcontext
  curcontext="${curcontext:-}"
  if [[ -z "$curcontext" ]]; then
    curcontext="$1:::"
  else
    curcontext="$1:${curcontext#*:}"
  fi
}

_autocomplete.is_glob() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  local word=$PREFIX$SUFFIX
  [[ $word == *(${(j:|:)~${(@b)patchars}})* && $word == ${~${(q)word}} && ! -e $~word ]]
}

_autocomplete._history() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local prefix=${LBUFFER/%$IPREFIX$PREFIX/$QIPREFIX$IPREFIX$PREFIX}
  local -a lines=( "${(@)history[(R)(*[[:IFS:]]|)${(b)prefix}?##]}" )
  local -a matches=() words
  local word
  local line; for line in $lines[1,$(( _autocomplete__max_lines() ))]; do
    line="$QIPREFIX$IPREFIX$PREFIX${line#*$prefix}$SUFFIX$ISUFFIX$QISUFFIX"
    words=( "${(Az)line}" )
    word=$words[1]
    case $compstate[quoting] in
      single)
        word=${(QQ)word}
        ;;
      double)
        word=${(QQQ)word}
        ;;
    esac
    matches+=( "$word" )
  done

  _comp_tags+=' history-words'
  local expl
  _description history-words expl 'history word'
  compadd "$expl[@]" -QU -a matches
}

_autocomplete.add_extras() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  _autocomplete.requote || _autocomplete.add_unambiguous
}

_autocomplete.requote() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  local requoted
  if [[ $_completer == expand ]] && (( compstate[nmatches] == 1 )); then
    requoted=${(Q)compstate[unambiguous]}
  elif (( compstate[nmatches] == 0 )); then
    requoted=${(Q):-$PREFIX$SUFFIX}
  else
    return 1
  fi

  [[ $requoted == $PREFIX$SUFFIX ]] && return

  _comp_tags+=' requoted'
  local expl
  _description requoted expl 'human readable'
  compadd "$expl[@]" -qS ' ' -QU - ${(q+)requoted}
  return 0
}

_autocomplete.add_unambiguous() {
  setopt localoptions noshortloops warncreateglobal extendedglob $_autocomplete__options

  [[ -z $compstate[unambiguous] ]] || (( compstate[nmatches] <= 1 )) &&
    return 1

  local word=$PREFIX$SUFFIX
  local unambiguous=${compstate[unambiguous]}
  local iprefix=$QIPREFIX$IPREFIX
  local isuffix=$ISUFFIX$QISUFFIX
  [[ -n $iprefix ]] && unambiguous=${unambiguous#$iprefix}
  [[ -n $isuffix ]] && unambiguous=${unambiguous%$isuffix}

  [[ $unambiguous == ? || $unambiguous == (#i)$word? || $word == (#i)$unambiguous* ]] && return 1

  local i
  if _autocomplete.is_glob; then
    for (( i=-1; i >= -$#word ; i-- )); do
      if [[ $unambiguous == ${~word[1,i]} ]]; then
        word=$word[i+1,-1]
        break
      fi
    done
  else
    local match mbegin mend
    word=${word##${~unambiguous//(#b)(?)/(${(b)match[1]}(#c0,1))}}
  fi
  word+=$isuffix
  [[ -z $QISUFFIX ]] && word+=$QIPREFIX

  _comp_tags+='unambiguous'
  local -a sopt=( -I $word ) && [[ -n $word ]] || sopt=()
  local expl
  _description unambiguous expl 'common substring'
  compadd "$expl[@]" $sopt -QU - $unambiguous
  return 0
}

_autocomplete.handle_long_list() {
  emulate -LR zsh -o noshortloops -o warncreateglobal -o extendedglob

  compstate[list_max]=0
  if (( compstate[list_lines] + BUFFERLINES + 1 > LINES )); then
    compstate[list]=''
    if [[ $WIDGET != list-choices ]]; then
      compstate[insert]='menu'
    fi
  fi
  return 0
}
