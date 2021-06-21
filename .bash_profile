# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# User services directory
export SVDIR="$HOME/service"

# Set terminal
export TERMINAL=foot

# Start gnome-keyring
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

# Add .local/bin to PATH
if ! [[ "$PATH" =~ "$HOME/.local/bin:" ]]
then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH

# Host-specific configuration
[ -f $HOME/.env ] && . $HOME/.env
