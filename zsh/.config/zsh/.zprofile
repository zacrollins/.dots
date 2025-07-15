#!/bin/zsh
#
# .zprofile - execute login commands pre-zshrc
#

# Dotfiles
export DOTFILES=$HOME/.dots

# XDG
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state
export XDG_RUNTIME_DIR=~/.xdg
export XDG_PROJECTS_DIR=~/src

# Homebrew
if [ -d "$HOME/homebrew" ]; then
	eval "$($HOME/homebrew/bin/brew shellenv)"
else
  if [[ $OSTYPE == 'darwin'* ]]; then
    test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
    test -f /usr/local/bin/brew && eval "$(/usr/local/bin/brew shellenv)"
  else
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Ensure path arrays do not contain duplicates.
typeset -gU fpath path cdpath

# Set the list of directories that Zsh searches for programs.
path=(
  # core
  $HOME/{,s}bin(N)
  $HOME/.local/bin
  $HOME/.local/bin/mdTable_nvim
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  /opt/homebrew/opt/postgresql@15/bin
  # path
  $path
)

# History
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
export HIST_STAMPS="yyyy-mm-dd"

# Editors
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export PAGER="less"
[[ "$OSTYPE" == darwin* ]] && export BROWSER='open'

# Regional settings
export LANG='en_US.UTF-8'

# Misc
export KEYTIMEOUT=1
export SHELL_SESSIONS_DISABLE=1        # Make Apple Terminal behave.

# Use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER

# eza (better ls) config path
export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza

#region Pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"


# vi: ft=zsh
