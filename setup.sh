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


# Enable additional repositories
echo "Enabling additional repositories"
echo "- Enabling RMP Fusion repositories"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "- Enabling fszymanski/interception-tools copr repository"
sudo dnf -y copr enable fszymanski/interception-tools


# Install required RPM packages
PACKAGES=(ImageMagick adwaita-gtk2-theme bemenu chromium-freeworld feh ffmpeg fira-code-fonts foot fzf git gnome-settings-daemon google-roboto-condensed-fonts google-roboto-fonts google-roboto-mono-fonts google-roboto-slab-fonts grim i3status interception-tools j4-dmenu-desktop jq lightdm lightdm-gtk mako mpv openssh-askpass pavucontrol playerctl pulseaudio-utils ranger ripgrep slurp sway swaybg swayidle swaylock w3m-img xdg-user-dirs wl-clipboard xrdb)
echo "Installing packages: ${PACKAGES[@]}"
sudo dnf -y install "${PACKAGES[@]}"


# Install caps2esc
echo "Installing caps2esc (https://gitlab.com/interception/linux/plugins/caps2esc)"
if [ -d "$HOME/code/caps2esc" ]; then
    echo "- Directory $HOME/code/caps2esc already exists, assuming that caps2esc is installed"
else
    sudo dnf -y install gcc make cmake
    mkdir -p "$HOME/code"
    CURRENT_DIR="$PWD"
    cd "$HOME/code"
    git clone git@gitlab.com:interception/linux/plugins/caps2esc.git
    cd caps2esc
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    sudo cmake --install build
    cd "$CURRENT_DIR"
fi


# Amend .bashrc and .bash_profile files
add_line "$PROFILE" 'export TERMINAL=foot' '# Set terminal'
add_line "$PROFILE" ". \"$PWD/.bashrc.d/start_ssh_agent\"" '# Start ssh-agent'
add_line "$SHELLRC" ". \"$PWD/.bashrc.d/set_cmd_prompt\"" '# Set command prompt'
add_line "$SHELLRC" ". \"$PWD/.bashrc.d/fzf_conf\"" '# FZF mappings and options'
add_line "$SHELLRC" ". \"$PWD/.bashrc.d/venv_func\"" '# Create/activate Python virtual environment helper function'


# Create symlinks
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
create_symlink ".local/share/applications/chromium-freeworld.desktop" "$HOME/.local/share/applications/chromium-freeworld.desktop"
create_symlink ".config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
create_symlink ".config/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
create_symlink ".config/mpv/mpv.conf" "$HOME/.config/mpv/mpv.conf"
create_symlink ".local/bin/j4-footclient" "$HOME/.local/bin/j4-footclient"
create_symlink ".local/bin/code" "$HOME/.local/bin/code"
sudo_create_symlink "xorg.conf.d/95-libinput-overrides.conf" "/usr/share/X11/xorg.conf.d/95-libinput-overrides.conf"
sudo_create_symlink "udevmon.d/caps2esc.yaml" "/etc/interception/udevmon.d/caps2esc.yaml"
sudo_create_symlink "lightdm/lightdm-gtk-greeter.conf" "/etc/lightdm/lightdm-gtk-greeter.conf"


# Enable and start udevmon service
sudo systemctl enable --now udevmon


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


# Set gsettings
echo "Setting configuration via gsettings"
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface document-font-name 'sans-serif 10'
gsettings set org.gnome.desktop.interface font-name 'sans-serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'monospace 10'
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
