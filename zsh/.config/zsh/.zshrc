#!/usr/bin/env zsh

# If not running interactively, don't do anything
#############################################
case $- in
    *i*) ;;
    *) return ;;
esac
[ -z "$PS1" ] && return

# ZSH Options
#############################################

# ZSH Navigation
setopt AUTO_CD                   # Go to folder path without using cd.
setopt AUTO_PUSHD                # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack.
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd.
setopt CORRECT                   # Spelling correction
setopt CDABLE_VARS               # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB             # Use extended globbing syntax.
setopt NO_CASE_GLOB		         # set for case insensitive tab complete
unsetopt BEEP			         # Disable BEEP noise

# ZSH History options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# set wordchars, remove / - _ .
WORDCHARS="*?[]~=&;!#$%^(){}<>"

# set to emacs mode
# bindkey -e

# source aliases
#############################################
[ -f $ZDOTDIR/aliases.zsh ] && source $ZDOTDIR/aliases.zsh

# source functions
#############################################
[ -f $ZDOTDIR/functions.zsh ] && source $ZDOTDIR/functions.zsh

# completion
#############################################
[ -f $ZDOTDIR/completion.zsh ] && source $ZDOTDIR/completion.zsh

# brew wrapper for brew bundle dump file
############################################
[ -f $ZDOTDIR/integrations/brew.zsh ] && source $ZDOTDIR/integrations/brew.zsh

# az cli completion (bash only)
############################################
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

# op cli completion
############################################
eval "$(op completion zsh)"; compdef _op op

# fnm fast node manager
############################################
eval "$(fnm env --use-on-cd)"

# kubeswitch
# source <(switcher init zsh)
# source <(compdef _switcher switch)

# Zoxide init
eval "$(zoxide init zsh)"

# jq zsh plugin
#############################################
[ -f $ZDOTDIR/plugins/jq-zsh-plugin/jq.plugin.zsh ] && source $ZDOTDIR/plugins/jq-zsh-plugin/jq.plugin.zsh

bindkey '^[,' jq-complete

# ZSH syntax highlighting
#############################################
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ZSH Vi Mode
#############################################
# run after zsh vi mode is initialized
function zvm_after_init() {
    # fzf shell integration
    source <(fzf --zsh)
    # ZSH auto suggestions
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
}
source $(brew --prefix)/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# TMUX
#############################################
# Start the tmux session if not alraedy in the tmux session
# if [[ ! -n $TMUX ]]; then
#   # Get the session IDs
#   session_ids="$(tmux list-sessions)"
#
#   # Create new session if no sessions exist
#   [[ -z "$session_ids" ]] && tmux new-session
#
#   # Select from following choices
#   #   - Attach existing session
#   #   - Create new session
#   #   - Start without tmux
#   create_new_session="Create new session"
#   start_without_tmux="Start without tmux"
#   choices="$session_ids\n${create_new_session}:\n${start_without_tmux}:"
#   choice="$(echo $choices | fzf | cut -d: -f1)"
#
#   if expr "$choice" : "[0-9]*$" >&/dev/null; then
#     # Attach existing session
#     tmux attach-session -t "$choice"
#   elif [[ "$choice" = "${create_new_session}" ]]; then
#     # Create new session
#     tmux new-session
#   elif [[ "$choice" = "${start_without_tmux}" ]]; then
#     # Start without tmux
#     :
#   fi
# fi

# direnv hook
eval "$(direnv hook zsh)"

# Starship Prompt
#############################################
eval "$(starship init zsh)"
