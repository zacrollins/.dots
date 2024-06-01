#!/usr/bin/env bash

# # install all mac updates
# sudo softwareupdate -i -a --restart

# # install apple's cli tools (xcode)
xcode-select --install

# # Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Update/Upgrade brew
brew update
brew upgrade

# BREW_PREFIX=$(brew --prefix)

# Tap into additional Homebrew channels
declare -a taps=(
    'azure/kubelogin'
    'homebrew/autoupdate'
    'homebrew/bundle'
    'homebrew/cask-fonts'
    'homebrew/services'
    'koekeishiya/formulae'
    'felixkratz/formulae'
    'microsoft/git'
)
for tap in "${taps[@]}"; do
    brew tap "$tap"
done

# install brew apps
declare -a brews=(
    'azure-cli'
    'azure/kubelogin/kubelogin'
    'bash'
    'bash-completion@2'
    'bat'
    'bat-extras'
    'coreutils'
    'lima'
    'colima'
    'docker'
    'docker-buildx'
    'docker-compose'
    'docker-credential-helper'
    'eza'
    'fd'
    'fnm'
    'fx'
    'fzf'
    'gh'
    'git'
    'helm'
    'jc'
    'jq'
    'kubernetes-cli'
    'neovim'
    'openssl'
    'reattach-to-user-namespace'
    'readline'
    'ripgrep'
    'skhd'
    'starship'
    'stow'
    'tlrc'
    'tmux'
    'trash'
    'watch'
    'wget'
    'yabai'
    'yq'
    'zoxide'
    'zsh'
    'zsh-autosuggestions'
    'zsh-completions'
    'zsh-history-substring-search'
    'zsh-syntax-highlighting'
    'zsh-vi-mode'
    'felixkratz/formulae/borders'
)

for brew in "${brews[@]}"; do
    brew install "$brew"
done

# install casks
declare -a cask_apps=(
    '1password'
    '1password-cli'
    'alacritty'
    'azure-data-studio'
    'brave-browser'
    'doll'
    'dotnet-sdk'
    "font-caskaydia-cove-nerd-font"
    "font-fira-code-nerd-font"
    "font-hack-nerd-font"
    "font-iosevka-nerd-font"
    "font-jetbrains-mono-nerd-font"
    "font-meslo-lg-nerd-font"
    'git-credential-manager'
    'google-chrome'
    'hammerspoon'
    'karabiner-elements'
    'microsoft-azure-storage-explorer'
    'microsoft-edge'
    'microsoft-outlook'
    'microsoft-remote-desktop'
    'microsoft-teams'
    'obsidian'
    'powershell'
    'raycast'
    'sf-symbols'
    'slack'
    'via'
    'visual-studio-code'
    'visual-studio-code-insiders'
)

for app in "${cask_apps[@]}"; do
    brew install --cask "$app"
done
