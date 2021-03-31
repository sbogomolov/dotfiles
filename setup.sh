#!/usr/bin/env bash

set -euo pipefail

PROFILE=~/.bash_profile


add_line() {
    file="$1"
    line="$2"
    comment="$3"

    echo "Config file: $file"

    file_exists=$(test -f "$file")
    if ! grep -Fq "$line" "$file"; then
        if (( file_exists == 0 )); then
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

add_line "$PROFILE" ". ~/.dotfiles/start_ssh_agent" "# Start ssh-agent"
create_symlink ".config/compton.conf" "$HOME/.config/compton.conf"
create_symlink ".config/i3/config" "$HOME/.config/i3/config"
create_symlink ".config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
create_symlink ".gtkrc-2.0" "$HOME/.gtkrc-2.0"
create_symlink ".urxvt" "$HOME/.urxvt"
create_symlink ".vimrc" "$HOME/.vimrc"
create_symlink ".Xresources" "$HOME/.Xresources"
