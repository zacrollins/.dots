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
  yazi
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
# stow -v -R -t "$HOME" -S alacritty
# stow -v -R -t "$HOME" -S bat
# stow -v -R -t "$HOME" -S borders
# stow -v -R -t "$HOME" -S git
# stow -v -R --no-folding -t "$HOME" -S powershell 
# stow -v -R -t "$HOME" -S skhd
# stow -v -R -t "$HOME" -S starship
# stow -v -R -t "$HOME" -S tmux
# stow -v -R -t "$HOME" -S yabai
# stow -v -R --no-folding -t "$HOME" -S nvim
# stow -v -R --no-folding -t "$HOME" -S nvim-lazyvim
# stow -v -R --no-folding -t "$HOME" -S scripts
# stow -v -R --no-folding -t "$HOME" -S zsh
# stow -v -R --no-folding -t "$HOME" -S yazi
