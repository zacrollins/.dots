#!/usr/bin/env bash

# Load all environment exports
# shellcheck disable=1091
source "$HOME/.config/bash/exports"

# Load interactive bash shell settings and utilities
if [ "$BASH" ]; then
  source "$XDG_CONFIG_HOME/bash/bashrc"
fi
