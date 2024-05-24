# ls list dir

# alias ls='ls --color=auto'
# alias l='ls -l'
# alias ll='ls -lahF'
# alias la='ls -A'
# alias ll='eza -alF --color=always --sort=size | grep -v /'
# alias ls='eza -alF --color=always --sort=size'

# Eza
eza_params=('--git' '--all' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

# alias l="eza -l --icons --git -a"
# alias lt="eza --tree --level=2 --long --icons --git"
# alias ls="eza"

# cd to zoxide
# alias cd="z"

# CD Aliases
if command -v z &> /dev/null; then
    alias home="z ~"
    alias ..="z .."
else
    alias home="cd ~"
    alias ..="cd .."
fi

# alacritty new window
alias alacritty-new='alacritty msg create-window; open -a Alacritty'

# bat == cat
if command -v bat &> /dev/null; then
    alias catt="bat -pp"
    alias cat="bat"
fi
# alias cat='bat'

# copy
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# clear
alias cls='clear'

# ping
alias pg='ping 8.8.8.8'

# macos
if [[ ${OSTYPE} == "darwin"* ]]; then
    alias cpwd='pwd | tr -d "\n" | pbcopy'                        # Copy the working path to clipboard
    alias cl="fc -e -|pbcopy"                                     # Copy output of last command to clipboard
    alias caff="caffeinate -ism"                                  # Run command without letting mac sleep
    alias cleanDS="find . -type f -name '*.DS_Store' -ls -delete" # Delete .DS_Store files on Macs
fi

# time
alias time='/usr/bin/time'

# neovim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# exit
alias e='exit'

# tmux
alias t='tmux'
alias ta='t a -t'
alias tls='t ls'
alias tn='t new -t'

# git
alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gp='git push'
alias gl='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short' # A nicer Git Log

# netstat
alias port="netstat -tulpn | grep"

# code
alias code='code-insiders'

# kubectl
alias k='kubectl'

# azure cli
alias devsub='az account set --subscription "DevTest Subscription"; az account show'
alias prodsub='az account set --subscription "Prod Subscription"; az account show'

alias zvm='devvm_start'

# # ex - archive extractor
# # usage: ex <file>
ex() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $@ ;;
        *.tar.gz) tar xzf $@ ;;
        *.tar.xz) tar xJf $@ ;;
        *.bz2) bunzip2 $@ ;;
        *.rar) unrar x $@ ;;
        *.gz) gunzip $@ ;;
        *.tar) tar xf $@ ;;
        *.tbz2) tar xjf $@ ;;
        *.tgz) tar xzf $@ ;;
        *.zip) unzip $@ ;;
        *.Z) uncompress $@ ;;
        *.7z) 7z x $@ ;;
        *) echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# dotfiles git alias
alias dotfiles='git --git-dir=$HOME/dotfiles.git --work-tree=$HOME'
