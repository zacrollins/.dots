#!/usr/bin/env bash

# stow packages to install
base=(
    alacritty
    bat
    borders
    git
    skhd
    starship
    tmux
    yabai
)

nofold=(
  nvim
  powershell
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


# manual stow each package
#
# stow -v -R -S alacritty
# stow -v -R -S bat
# stow -v -R -S borders
# stow -v -R -S git
# stow -v -R --no-folding -S powershell 
# stow -v -R -S skhd
# stow -v -R -S starship
# stow -v -R -S tmux
# stow -v -R -S yabai
# stow -v -R --no-folding -S nvim
# stow -v -R --no-folding -S scripts
# stow -v -R --no-folding -S zsh
