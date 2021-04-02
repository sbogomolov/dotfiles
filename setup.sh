#!/usr/bin/env bash

set -euo pipefail

PROFILE=~/.bash_profile
SHELLRC=~/.bashrc


add_line() {
    file="$1"
    line="$2"
    comment="$3"

    echo "Config file: $file"

    if ! grep -Fq "$line" "$file"; then
        if [ -f "$file" ]; then
            echo >> "$file"
        else
            echo "- Creating file: $file"
        fi

        echo "- Adding line: $line"
        echo "$comment" >> "$file"
        echo "$line" >> "$file"
    else
        echo "- File already contains line: $line"
    fi
}


create_symlink() {
    src="$PWD/$1"
    dst="$2"

    echo "Config file: $dst"

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "- Symlink already exists: $dst -> $src"
            return
        else
            echo "- Symlink exists, but it is broken: $dst -> $(readlink "$dst")"
            echo "- Deleting broken symlink"
            rm $dst
        fi
    fi

    if [ -e "$dst" ]; then
        echo "- File or directory already exists"
        echo "- Backing up: $dst -> $dst.old"
        mv "$dst" "$dst.old"
    fi

    echo "- Creating symlink: $dst -> $src"
    ln -s "$src" "$dst"
}


if [ ! -f "$PROFILE" ]; then
    touch "$PROFILE"
fi

add_line "$SHELLRC" ". ~/.dotfiles/setup_cmd_prompt" "# Setup command prompt"
add_line "$PROFILE" ". ~/.dotfiles/start_ssh_agent" "# Start ssh-agent"

mkdir -p $HOME/.config/{i3,i3status,gtk-3.0}

create_symlink ".config/compton.conf" "$HOME/.config/compton.conf"
create_symlink ".config/i3/config" "$HOME/.config/i3/config"
create_symlink ".config/i3status/config" "$HOME/.config/i3status/config"
create_symlink ".config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
create_symlink ".gtkrc-2.0" "$HOME/.gtkrc-2.0"
create_symlink ".urxvt" "$HOME/.urxvt"
create_symlink ".vimrc" "$HOME/.vimrc"
create_symlink ".Xresources" "$HOME/.Xresources"
