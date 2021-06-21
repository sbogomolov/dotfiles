# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# User services directory
export SVDIR="$HOME/service"

# Set terminal
export TERMINAL=foot

# Source ssh-agent env
[ -f $HOME/.ssh/ssh-agent-env ] && . $HOME/.ssh/ssh-agent-env

# Add .local/bin to PATH
if ! [[ "$PATH" =~ "$HOME/.local/bin:" ]]
then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH

# Add SSH keys
if ! ssh-add -l >/dev/null; then
    ssh-add
fi

# Host-specific configuration
[ -f $HOME/.env ] && . $HOME/.env
