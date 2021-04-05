#!/usr/bin/env bash

set -euo pipefail

PROFILE="$HOME/.bash_profile"
SHELLRC="$HOME/.bashrc"


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


sudo_create_symlink() {
    sudo bash -c "$(declare -f create_symlink); create_symlink "$1" "$2""
}


# Install required RPM packages
PACKAGES=(git compton adwaita-gtk2-theme ImageMagick pactl pavucontrol pasystray openssh-askpass fzf ripgrep xset xrdb xss-lock)
echo "Installing packages: ${PACKAGES[@]}"
sudo dnf -y install "${PACKAGES[@]}"


# Install xcape
echo "Installing xcape (https://github.com/alols/xcape)"
if [ -d "$HOME/code/xcape" ]; then
    echo "- Directory $HOME/code/xcape already exists, assuming that xcape is installed"
else
    sudo dnf -y install gcc make pkgconfig libX11-devel libXtst-devel libXi-devel
    mkdir -p "$HOME/code"
    CURRENT_DIR="$PWD"
    cd "$HOME/code"
    git clone git@github.com:alols/xcape.git
    cd xcape
    make
    sudo make install
    cd "$CURRENT_DIR"
fi


# Install ffmpeg
echo "Installing ffmpeg"
echo "- Enabling RMP fusion repositories"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "- Installing ffmpeg"
sudo dnf -y install ffmpeg


# Amend .bashrc and .bash_profile files
add_line "$PROFILE" '. "$HOME/.dotfiles/start_ssh_agent"' '# Start ssh-agent'
add_line "$SHELLRC" '. "$HOME/.dotfiles/set_cmd_prompt"' '# Set command prompt'
add_line "$SHELLRC" '. "$HOME/.dotfiles/fzf_conf"' '# FZF mappings and options'


# Create symlinks to config files
mkdir -p $HOME/.config/{i3,i3status,gtk-3.0}
mkdir -p $HOME/.config/fontconfig/conf.d
create_symlink ".config/compton.conf" "$HOME/.config/compton.conf"
create_symlink ".config/i3/config" "$HOME/.config/i3/config"
create_symlink ".config/i3status/config" "$HOME/.config/i3status/config"
create_symlink ".config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
create_symlink ".gtkrc-2.0" "$HOME/.gtkrc-2.0"
create_symlink ".urxvt" "$HOME/.urxvt"
create_symlink ".vimrc" "$HOME/.vimrc"
create_symlink ".Xresources" "$HOME/.Xresources"
create_symlink ".config/fontconfig/conf.d/99-improved-rendering.conf" "$HOME/.config/fontconfig/conf.d/99-improved-rendering.conf"
sudo_create_symlink "xorg.conf.d/95-libinput-overrides.conf" "/usr/share/X11/xorg.conf.d/95-libinput-overrides.conf"
sudo_create_symlink "xorg.conf.d/95-synaptics-overrides.conf" "/usr/share/X11/xorg.conf.d/95-synaptics-overrides.conf"


# Resize lock screen image
SRC_LOCK_SCREEN_IMG_PATH="$HOME/.dotfiles/img/lock_screen.png"
DST_LOCK_SCREEN_IMG_PATH="$HOME/Pictures/lock_screen.png"
SCREEN_RESOLUTION=$(xdpyinfo | awk '/dimensions/{print $2}')
echo "Preparing lock screen image: $DST_LOCK_SCREEN_IMG_PATH"
mkdir -p "$HOME/Pictures"
echo "- Screen resolution: $SCREEN_RESOLUTION"
echo "- Converting image: $SRC_LOCK_SCREEN_IMG_PATH -> $DST_LOCK_SCREEN_IMG_PATH"
convert "$SRC_LOCK_SCREEN_IMG_PATH" -background none -gravity center -extent "$SCREEN_RESOLUTION" "$DST_LOCK_SCREEN_IMG_PATH"

# Install vim-plug
echo "Installing vim-plug"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
