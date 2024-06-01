#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set to superior editing mode
set -o vi

# source configs
source "$XDG_CONFIG_HOME/bash/completion"
source "$XDG_CONFIG_HOME/bash/aliases"

# source fzf
[[ -f "$XDG_CONFIG_HOME/bash/fzf.bash" ]] && source "$XDG_CONFIG_HOME/bash/fzf.bash"

if [[ $DISPLAY ]]; then
  shopt -s checkwinsize  # Update LINES and COLUMNS after each command
fi

# Clean-up Apple's useless garbage
[ -f .DS_Store ] && rm -f .DS_Store

# fnm fast node manager
# eval "$(fnm env --use-on-cd)"

# starship prompt
eval "$(starship init bash)"
