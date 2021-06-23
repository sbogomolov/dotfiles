#!/usr/bin/env bash

set -euo pipefail


create_symlink() {
    src="$PWD/$1"
    dst="$2"

    echo "Creating symlink: $dst"

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

    dst_dir="$(dirname "$dst")"
    if [ ! -d "$dst_dir" ]; then
        echo "- Creating directory: $dst_dir"
        mkdir -p "$dst_dir"
    fi

    echo "- Creating symlink: $dst -> $src"
    ln -s "$src" "$dst"
}


sudo_create_symlink() {
    sudo bash -c "$(declare -f create_symlink); create_symlink "$1" "$2""
}


copy() {
    src="$PWD/$1"
    dst="$2"

    echo "Copying: $dst"

    if [ -e "$dst" ]; then
        echo "- File or directory already exists"
        md5_old="$(sha256sum "$dst" | awk '{ print $1 }')"
        md5_new="$(sha256sum "$src" | awk '{ print $1 }')"
        if [ "$md5_old" = "$md5_new" ]; then
            echo "- Files are identical, skipping the copy"
            return
        fi
        echo "- Backing up: $dst -> $dst.old"
        mv "$dst" "$dst.old"
    fi

    dst_dir="$(dirname "$dst")"
    if [ ! -d "$dst_dir" ]; then
        echo "- Creating directory: $dst_dir"
        mkdir -p "$dst_dir"
    fi

    echo "- Copying: $src -> $dst"
    cp -R "$src" "$dst"
}


sudo_copy() {
    sudo bash -c "$(declare -f copy); copy "$1" "$2""
}


# Create symlinks
create_symlink ".bashrc" "$HOME/.bashrc"
create_symlink ".bash_profile" "$HOME/.bash_profile"
create_symlink ".config/i3status/config" "$HOME/.config/i3status/config"
create_symlink ".config/sway/config" "$HOME/.config/sway/config"
create_symlink ".config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
create_symlink ".config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
create_symlink ".config/mako/config" "$HOME/.config/mako/config"
create_symlink ".config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
create_symlink ".gtkrc-2.0" "$HOME/.gtkrc-2.0"
create_symlink ".vimrc" "$HOME/.vimrc"
create_symlink ".Xresources" "$HOME/.Xresources"
create_symlink ".config/fontconfig/conf.d/99-improved-rendering.conf" "$HOME/.config/fontconfig/conf.d/99-improved-rendering.conf"
create_symlink ".config/fontconfig/conf.d/10-default-monospace-font.conf" "$HOME/.config/fontconfig/conf.d/10-default-monospace-font.conf"
create_symlink ".config/fontconfig/conf.d/10-default-sans-serif-font.conf" "$HOME/.config/fontconfig/conf.d/10-default-sans-serif-font.conf"
create_symlink ".config/fontconfig/conf.d/10-default-serif-font.conf" "$HOME/.config/fontconfig/conf.d/10-default-serif-font.conf"
create_symlink ".config/fontconfig/conf.d/20-fallback-monospace-fonts.conf" "$HOME/.config/fontconfig/conf.d/20-fallback-monospace-fonts.conf"
create_symlink ".config/fontconfig/conf.d/20-fallback-sans-serif-fonts.conf" "$HOME/.config/fontconfig/conf.d/20-fallback-sans-serif-fonts.conf"
create_symlink ".config/fontconfig/conf.d/20-fallback-serif-fonts.conf" "$HOME/.config/fontconfig/conf.d/20-fallback-serif-fonts.conf"
create_symlink ".config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
create_symlink ".config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
# create_symlink ".local/share/applications/chromium-freeworld.desktop" "$HOME/.local/share/applications/chromium-freeworld.desktop"
create_symlink ".config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
create_symlink ".config/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
create_symlink ".config/mpv/mpv.conf" "$HOME/.config/mpv/mpv.conf"
create_symlink ".local/bin/j4-footclient" "$HOME/.local/bin/j4-footclient"
create_symlink ".local/bin/code" "$HOME/.local/bin/code"
sudo_create_symlink "udevmon.d/caps2esc.yaml" "/etc/interception/udevmon.d/caps2esc.yaml"
sudo_copy "greetd/config.toml" "/etc/greetd/config.toml"
sudo_copy "greetd/environments" "/etc/greetd/environments"
sudo_copy "greetd/sway-config" "/etc/greetd/sway-config"
sudo chown -R _greeter:_greeter /etc/greetd
sudo_copy "bin/sway-run" "/usr/local/bin/sway-run"
sudo_copy "acpi/handler.sh" "/etc/acpi/handler.sh"
# sudo_copy "lightdm/lightdm-gtk-greeter.conf" "/etc/lightdm/lightdm-gtk-greeter.conf"


# Resize lock screen image
PICTURES_DIR="$(xdg-user-dir PICTURES)"
SRC_LOCK_SCREEN_IMG_PATH="img/lock_screen.png"
DST_LOCK_SCREEN_IMG_PATH="$PICTURES_DIR/lock_screen.png"
SCREEN_RESOLUTION=$(xdpyinfo | awk '/dimensions/{print $2}')
echo "Preparing lock screen image: $DST_LOCK_SCREEN_IMG_PATH"
mkdir -p "$PICTURES_DIR"
echo "- Screen resolution: $SCREEN_RESOLUTION"
echo "- Converting image: $SRC_LOCK_SCREEN_IMG_PATH -> $DST_LOCK_SCREEN_IMG_PATH"
convert "$SRC_LOCK_SCREEN_IMG_PATH" -background none -gravity center -extent "$SCREEN_RESOLUTION" "$DST_LOCK_SCREEN_IMG_PATH"


# Install vim-plug
echo "Installing vim-plug"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

