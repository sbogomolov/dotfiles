# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set command prompt
parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\n$ "
case $TERM in
    xterm*|rxvt*|foot|alacritty)
        PS1="\[\033]0;\u@\h: \w\007\]$PS1"
        ;;
    *)
        ;;
esac
export PS1

# venv function
function venv() {
    new_venv=false
    venv=".venv"
    if [ ! -d "$venv" ]; then
        new_venv=true
        python3 -m venv $venv
        if [ $? -eq 0 ]; then
            echo "Successfully created virtual environment in $venv"
        else
            echo "Could not create virtual environment in $venv" >&2
            return
        fi
    fi
    source "$venv/bin/activate"
    if [ "$new_venv" = true ]; then
        pip install --upgrade pip
    fi
}

# FZF mappings and options
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Aliases
alias ls='ls --color=auto'
