#!/usr/bin/env bash

# stow packages to install
base=(
    alacritty
    bat
    borders
    git
    powershell
    skhd
    starship
    tmux
    yabai
)

nofold=(
  nvim
  scripts
  zsh
)

# run the stow command for the passed in directory ($2) in location $1
stowit() {
    usr=$1
    app=$2
    # -v verbose
    # -R restow
    # -t target
    stow -v -R -t "${usr}" "${app}"
}

stowit_nofold() {
    usr=$1
    app=$2
    # -v verbose
    # -R restow
    # -t target
    stow -v --no-folding -R -t "${usr}" "${app}"
}

echo ""
echo "Stowing apps..."

# install stow packages in base
for app in "${base[@]}"; do
    stowit "${HOME}" "$app"
done

# install stow packages in nofold adding --no-folding to the stow command
for app in "${nofold[@]}"; do
    stowit_nofold "${HOME}" "$app"
done

echo ""
echo "##### ALL DONE"
